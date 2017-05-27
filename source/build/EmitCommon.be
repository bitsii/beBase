// Copyright 2015 Craig Welch
//
// Licensed under the MIT license. See LICENSE.txt file in the project root 
// for full license information.

use IO:File;
use Build:VisitError;
use Build:Visit;
use Build:EmitException;
use Build:NamePath;
use Build:Node;
use Build:ClassConfig;
use Test:Assertions;

/*

Emitted lang Implementation notes:

NAMESPACE

The native lang package corresponds to libraries, NamePath's (System:Object) are all encoded using class name mangling 

NAMESPACE

DYNAMIC CALLS 

(bemd_#):

one per set of args up (to max, then array for remainder)
callCase is the random code genned at link time for the call
generated classes override and use code to find and dispatch call

DYNAMIC CALLS

ONCE EVAL
MANY EVAL

Statically initialize for onceeval literal cases
FASTER if a variable assigned to from a once eval is not assigned to any other time just use the once eval any directly and do no assign

MANY EVAL
ONCE EVAL

NATIVE TYPES

Int == int, Float == float, will have double and long later

for BOOL

NATIVE TYPES

THREADS

nothing threadsafe except special classes made to be so - must stick to those, provide locks/mutexes for constructing them

THREADS

*/

use local class Build:EmitCommon(Build:Visit:Visitor) {

    new(Build:Build _build) {
        build = _build;
        fields {
          
          //current emitting class config and parent, if any
          ClassConfig classConf;
          ClassConfig parentConf;
          
          //The name of the language, it's file extension, and how 
          //exceptions need to be declared for methods, already populated by
          //language-specific subclass
          String emitLang;
          String fileExt;
          String exceptDec;
          
          //A newline, often useful
          String nl = build.nl;
          //And, a quote
          String q = TS.quote;
          
          //The ClassConfig cache
          Map ccCache = Map.new();
          
          //requires chaos
          System:Random rand = System:Random.new();
          
          //Commonly needed namepaths
          NamePath objectNp = NamePath.new("System:Object");
          NamePath boolNp = NamePath.new("Logic:Bool");
          NamePath intNp = NamePath.new("Math:Int");
          NamePath floatNp = NamePath.new("Math:Float");
          NamePath stringNp = NamePath.new("Text:String");
          
          //Commonly needed values
          
          String invp = ".";
          String scvp = ".";
          String trueValue = "be.BECS_Runtime.boolTrue";
          String falseValue = "be.BECS_Runtime.boolFalse";
          String nullValue = "null";
          
          String instanceEqual = " == ";
          String instanceNotEqual = " != ";
          
          //Shared library code genned based on lib contents
          String libEmitName = libEmitName(build.libName);
          String fullLibEmitName = fullLibEmitName(build.libName);
          IO:File:Path libEmitPath = build.emitPath.copy().addStep(self.emitLang).addStep("be").addStep(libEmitName + fileExt);
          
          IO:File:Path synEmitPath = build.emitPath.copy().addStep(self.emitLang).addStep("be").addStep(libEmitName + ".syn");
          
          String methodBody = String.new();
          Int lastMethodBodySize = 0;
          Int lastMethodBodyLines = 0;
          List methodCalls = List.new();
          Int methodCatch = 0;
          
          Int maxDynArgs = 8; //was 2
          Int maxSpillArgsLen = 0;
          
          Bool dynConditionsAll;
          
          Node lastCall;
          
          Set callNames = Set.new();
          
          //Comonly needed classconfigs
          ClassConfig objectCc = getClassConfig(objectNp);
          ClassConfig boolCc = getClassConfig(boolNp);
          
          //Other useful things
          if(emitting("cs")) {
            String instOf = " is ";
          } else {
            instOf = " instanceof "
          }
          
          //class to emit lines (first is from source, second is emitted)
          //for sourcemaps
          Map smnlcs = Map.new();
          Map smnlecs = Map.new();
          Map nameToId = Map.new();
          Map idToName = Map.new();
        }
    }
    
    runtimeInitGet() String {
        return("be.BECS_Runtime.init();" + nl);
    }
    
    libEmitName(String libName) {
        return("BEX_E");
    }
    
    fullLibEmitName(String libName) { 
        return(libNs(libName) + "." + libEmitName(libName));
    }
    
    getClassConfig(NamePath np) ClassConfig {
      String dname = np.toString();
      ClassConfig toRet = ccCache.get(dname);
      if (undef(toRet)) {
         for (Build:Library pack in build.usedLibrarys) {
            toRet = Build:ClassConfig.new(np, self, pack.emitPath, pack.libName);
            if (toRet.synPath.file.exists) {
               ccCache.put(dname, toRet);
               return(toRet);
            }
         }
         toRet = Build:ClassConfig.new(np, self, build.emitPath, build.libName);
         ccCache.put(dname, toRet);
      }
      return(toRet);
   }
   
   getCallId(String name) Int {
      Int id = nameToId.get(name);
      if (undef(id)) {
        //get random int
        id = rand.getInt();
        while (idToName.has(id)) {
          id = rand.getInt();
        }
        nameToId.put(name, id);
        idToName.put(id, name);
      }
      return(id);
   }
   
   getLocalClassConfig(NamePath np) ClassConfig {
      String dname = np.toString();
      ClassConfig toRet = ccCache.get(dname);
      if (undef(toRet)) {
        toRet = Build:ClassConfig.new(np, self, build.emitPath, build.libName);
        ccCache.put(dname, toRet);
      }
      return(toRet);
   }
   
   complete(Node clgen) {
      if (build.printSteps || build.printPlaces) {
        ("Completing class " + clgen.held.name).print();
      }
      any trans = Build:Transport.new(build, clgen.transUnit);
      
      
      any emvisit;
      
      if (build.printSteps) {
         ". ".echo();
      }
      emvisit = Build:Visit:Rewind.new();
      emvisit.emitter = self;
      emvisit.build = build;
      trans.traverse(emvisit);
      
      if (build.printSteps) {
         ".. ".echo();
      }
      emvisit = Build:Visit:TypeCheck.new();
      emvisit.emitter = self;
      emvisit.build = build;
      trans.traverse(emvisit);
      
      if (build.printSteps) {
         "... ".echo();
         " ".print();
      }
      if (build.printSteps) {
        //("Begin Emit Visit").print();
      }
      trans.traverse(self);
      if (build.printSteps) {
        //("End Emit Visit").print();
      }
      
      if (build.printSteps) {
        //("Begin Stack Lines").print();
      }
      buildStackLines(clgen);
      if (build.printSteps) {
        //("End Stack Lines").print();
      }
      
   }
   
   doEmit() {
        
        //order by depth (of inheritance) to guarantee that a classes ancestors
        //are processed before the class (important for some initialization)
        Map depthClasses = Map.new();
        for (any ci = build.emitData.parseOrderClassNames.iterator;ci.hasNext;;) { 
            String clName = ci.next;
            
            Node clnode = build.emitData.classes.get(clName);
            
            Int depth = clnode.held.syn.depth;
            List classes = depthClasses.get(depth);
            if (undef(classes)) {
                classes = List.new();
                depthClasses.put(depth, classes);
            }
            classes += clnode;
        }
        
        List depths = List.new();
        for (ci = depthClasses.keyIterator;ci.hasNext;;) { 
            depth = ci.next;
            depths += depth;
        }
        
        depths = depths.sort();
        fields {
            List classesInDepthOrder = List.new();
        }
        for (depth in depths) {
            classes = depthClasses.get(depth);
            for (clnode in classes) {
                classesInDepthOrder += clnode;
            }
        }
        
        for (ci = classesInDepthOrder.iterator;ci.hasNext;;) {   
        
            clnode = ci.next;
            
            classConf = getLocalClassConfig(clnode.held.namepath);
            if (build.printSteps) {
              //("will emit " + classConf.np + " " + classConf.emitName).print();
            }
            
            complete(clnode);
            
            //open the class output file
            IO:File:Writer cle = getClassOutput();
            
            //gen into the file
            
            String bns = self.beginNs();
            lineCount += countLines(bns);
            cle.write(bns);
            
            //things before the class, after the namespace
            lineCount += countLines(preClass);
            cle.write(preClass);
            
            //class declaration
            String cb = self.classBegin(clnode.held.syn);
            lineCount += countLines(cb);
            cle.write(cb);
            
            //the class level emits
            lineCount += countLines(classEmits);
            cle.write(classEmits);
            
            lineCount += writeOnceDecs(cle, onceDecs);
            //the initial instance
            String idec = self.initialDec;
            lineCount += countLines(idec);
            cle.write(idec);
            
            //properties
            unless (emitting("cc")) {
              lineCount += countLines(propertyDecs);
              cle.write(propertyDecs);
            }
            
            //need offset of cle so far
            //add to all classCalls nlec s
            //could also output them here
            
            String nlcs = String.new();
            String nlecs = String.new();
            
            Bool firstNlc = true;
            
            Int lastNlc;
            Int lastNlec;
            
            String lineInfo = "/* BEGIN LINEINFO " += nl;
            for (Node cc in classCalls) {
               //("got a classcall!!!!!!!!!!!1").print();
                cc.nlec += lineCount;
                cc.nlec++=;
                if (undef(lastNlc) || lastNlc != cc.nlc || lastNlec != cc.nlec) {
                    //("got a nlc!!!!!!!!!!!1").print();
                    //if(emitting("jv") || emitting("cs")) {
                        if (firstNlc) {
                          firstNlc = false;
                        } else {
                           nlcs += ", ";
                           nlecs += ", ";
                        }
                        nlcs += cc.nlc;
                        nlecs += cc.nlec;
                    //}
                }
                lastNlc = cc.nlc;
                lastNlec = cc.nlec;
                lineInfo += cc.held.orgName += " " += cc.held.numargs += " " += cc.nlc += " " += cc.nlec += nl;
            }
            lineInfo += "END LINEINFO */" += nl;
            
            //("nlcs " + nlcs + " nlecs " + nlecs).print();
            
            String nlcNName = getClassConfig(clnode.held.namepath).relEmitName(build.libName) + ".";
            
            if(emitting("js")) {
              String smpref = 
               getClassConfig(clnode.held.namepath).emitName + ".prototype.";
               nlcNName = smpref;
            }
            
            smnlcs.put(clnode.held.namepath.toString(), nlcNName + "bevs_smnlc");
            smnlecs.put(clnode.held.namepath.toString(), nlcNName + "bevs_smnlec");
            
            if(emitting("cs")) {
              if (csyn.namepath == objectNp) {
               methods += "public static int[] bevs_smnlc" += nl;
              } else {
               methods += "public static new int[] bevs_smnlc" += nl;
              }
              methods += " = new int[] {" += nlcs += "};" += nl;
             }
             if(emitting("jv")) {
               methods += "public static int[] bems_smnlc() {" += nl;
               methods += "return new int[] {" += nlcs += "};" += nl;
               methods += "}" += nl;
               methods += "public static int[] bevs_smnlc" += nl;
               methods += " = bems_smnlc();" += nl;
             }
            if (emitting("js")) {
              methods += smpref += "bevs_smnlc";
              methods += " = [" += nlcs += "];" += nl;
            }
            if(emitting("cs")) {
              //("nlcs " + nlcs + " nlecs " + nlecs).print();
              if (csyn.namepath == objectNp) {
               methods += "public static int[] bevs_smnlec" += nl;
              } else {
               methods += "public static new int[] bevs_smnlec" += nl;
              }
              methods += " = new int[] {" += nlecs += "};" += nl;
             }
             if(emitting("jv")) {
               methods += "public static int[] bems_smnlec() {" += nl;
               methods += "return new int[] {" += nlecs += "};" += nl;
               methods += "}" += nl;
               methods += "public static int[] bevs_smnlec" += nl;
               methods += " = bems_smnlec();" += nl;
             }
            if (emitting("js")) {
              methods += smpref += "bevs_smnlec";
              methods += " = [" += nlecs += "];" += nl;
            }
            
            methods += lineInfo;
            
            //methods
            lineCount += countLines(methods);
            cle.write(methods);
            
            //dynamic wrappers
            if (self.useDynMethods) {
                lineCount += countLines(dynMethods);
                cle.write(dynMethods);
            }
            
            lineCount += countLines(ccMethods);
            cle.write(ccMethods);
            
            //closing brace
            String ce = self.classEnd;
            lineCount += countLines(ce);
            cle.write(ce);
            
            //end of namespace, if any
            String en = self.endNs();
            lineCount += countLines(en);
            cle.write(en);
            
            //done writing
            //does not output anything else, if it ever does, will need to track lines
            finishClassOutput(cle);
            
         }
         emitLib();
    }
    
    writeOnceDecs(cle, onceDecs) {
        cle.write(onceDecs);
        return(countLines(onceDecs));
    }
    
   useDynMethodsGet() Bool {
       return(true);
    }
    
   getClassOutput() IO:File:Writer {
       fields {
         Int lineCount = 0.copy();
       }
       if (classConf.classDir.file.exists!) {
            classConf.classDir.file.makeDirs();
        } 
        return(classConf.classPath.file.writer.open());
   }
   
   finishClassOutput(IO:File:Writer cle) {
        cle.close();
   }
    
    getLibOutput() IO:File:Writer {
        return(libEmitPath.file.writer.open())
    }
    
    saveSyns() {
        "Saving Syns".print();
        Time:Interval sst = Time:Interval.now();
        IO:File:Writer syne = synEmitPath.file.writer.open()
        System:Serializer.new().serialize(build.emitData.synClasses, syne);
        syne.close();
        Time:Interval sse = Time:Interval.now() - sst;
        ("Saving Syns took " + sse).print();
    }
    
    finishLibOutput(IO:File:Writer libe) {
        libe.close();
    }
    
    klassDec(Bool isFinal) String {
      String isfin = "";
      if(emitting("cs") && isFinal) {
        isfin = "sealed ";
      } elseIf (emitting("jv") && isFinal) {
        isfin = "final ";
      }
      return("public " + isfin + "class ");
    }
    
    spropDecGet() String {
        return("public static ");
    }
    
    baseSmtdDecGet() String {
        return("public static ");
    }
    
    baseMtdDecGet() String {
      return(baseMtdDec(null));
    }
    
    baseMtdDec(Build:MtdSyn msyn) String {
        return("");
    }
    
    overrideMtdDecGet() String {
      return(overrideMtdDec(null));
    }
    
    overrideMtdDec(Build:MtdSyn msyn) String {
        return("");
    }
    
    propDecGet() String {
        return("public ");
    }
    
    emitting(String lang) Bool {
        if (self.emitLang == lang) {
            return(true);
        }
        return(false);
    }
    
    emitLib() {
    
        String getNames = String.new();
        
        NamePath mainClassNp = NamePath.new();
        mainClassNp.fromString(build.mainName);
        ClassConfig maincc = getClassConfig(mainClassNp);
        
        String main = "";
        main += self.mainStart;
        main += fullLibEmitName += ".init();" += nl;
        main += maincc.fullEmitName += " mc = new " += maincc.fullEmitName += "();" += nl;
        main += "mc.bem_new_0();" += nl;
        main += "mc.bem_main_0();" += nl;
        main += self.mainEnd;
        
        if (build.saveSyns) {
          saveSyns();
        }
        
        IO:File:Writer libe = getLibOutput();
        libe.write(self.beginNs());
        String extends = extend("be.BECS_Lib");
        libe.write(self.klassDec(true) + libEmitName + extends + "  {" + nl);
        libe.write(self.spropDec + self.boolType + " isInitted = false;" + nl);
        
        String initLibs = String.new();
        for (Build:Library bl in build.usedLibrarys) {
            //bl.libName
            initLibs += fullLibEmitName(bl.libName) += ".init();" += nl;
        }
        
        if (def(build.initLibs)) {
          for (String il in build.initLibs) {
            initLibs += "be." += il += ".init();" += nl;
          }
        }        
        String typeInstances = String.new();
        String notNullInitConstruct = String.new();
        String notNullInitDefault = String.new();
        for (any ci = classesInDepthOrder.iterator;ci.hasNext;;) {  
        
            any clnode = ci.next;
            
            if(emitting("jv")) {
                typeInstances += "be.BECS_Runtime.typeInstances.put(" += q += clnode.held.namepath.toString() += q += ", Class.forName(" += q += getClassConfig(clnode.held.namepath).fullEmitName += q += "));" += nl;
            }
            if(emitting("cs")) {
                String bein = "bece_" + getClassConfig(clnode.held.namepath).relEmitName(build.libName) + "_bevs_inst";
                typeInstances += "be.BECS_Runtime.typeInstances[" += q += clnode.held.namepath.toString() += q += "] = typeof(" += getClassConfig(clnode.held.namepath).relEmitName(build.libName) += ");" += nl;
                typeInstances += "typeof(" += getClassConfig(clnode.held.namepath).relEmitName(build.libName) += ")";
                typeInstances += ".GetField(" += q += bein += q += ").GetValue(null);" += nl;
            }
            
            if (clnode.held.syn.hasDefault) {
                String nc = "new " + getClassConfig(clnode.held.namepath).relEmitName(build.libName) + "()";
                notNullInitConstruct += "be.BECS_Runtime.initializer.bem_notNullInitConstruct_1(" += nc += ");" += nl;
                notNullInitDefault += "be.BECS_Runtime.initializer.bem_notNullInitDefault_1(" += nc += ");" += nl;
            }
        }
        
        for (String callName in callNames) {
            libe.write(self.spropDec + "int bevn_" + callName + ";" + nl;);
            getNames += "putCallId(" += TS.quote += callName += TS.quote += ", " += getCallId(callName) += ");" += nl;
            getNames += "bevn_" += callName += " = " += getCallId(callName) += ";" += nl;
        }
        
        String smap = String.new();
        
        for (String smk in smnlcs.keys) {
          //("nlcs key " + smk + " nlc " + smnlcs.get(smk) + " nlec " + smnlecs.get(smk)).print();
          smap += "putNlcSourceMap(" += TS.quote += smk += TS.quote += ", " += smnlcs.get(smk) += ");" += nl;
          smap += "putNlecSourceMap(" += TS.quote += smk += TS.quote += ", " += smnlecs.get(smk) += ");" += nl;
          //break;
        }
        
        libe.write(self.baseSmtdDec + "void init()" += exceptDec += " {" + nl);
        if(emitting("jv")) {
          libe.write("synchronized (" + libEmitName + ".class) {" + nl);//}
        } elseIf(emitting("cs")) {
          libe.write("lock (typeof(" + libEmitName + ")) {" + nl);//}
        }
        libe.write("if (isInitted) { return; }" + nl;);
        libe.write("isInitted = true;" + nl);
        libe.write(initLibs);
        libe.write(self.runtimeInit);
        libe.write(getNames);
        libe.write(smap);
        libe.write(typeInstances);
        libe.write(notNullInitConstruct);
        libe.write(notNullInitDefault);
        if(emitting("jv") || emitting("cs")) {
          //{
          libe.write("}" + nl);
        }
        libe.write("}" + nl);
        
        if (self.mainInClass) {
            libe.write(main);
        }
        
        libe.write("}" + nl);
        libe.write(self.endNs());
        
        if (self.mainOutsideNs) {
            libe.write(main);
        }
        
        finishLibOutput(libe);
        
    }
    
    mainInClassGet() Bool {
        return(true);
    }
    
    mainOutsideNsGet() Bool {
        return(false);
    }
    
    mainStartGet() String {
        return("");
   }
   
   
   mainEndGet() String {
        
        if(emitting("jv") || emitting("cs")) {
          //{ {
          return("} }" + nl);
        }
        //{
        return("}" + nl);
   }
    
    boolTypeGet() String {
      return("");
   }
    
    //Emit Visit
    begin (transi) {
      super.begin(transi);
      fields {
         String methods = String.new();
         List classCalls = List.new();
         Int lastMethodsSize = 0;
         Int lastMethodsLines = 0;
      }
   }
   
   nameForVar(Build:Var v) String {
   
      String prefix;
      if (v.isTmpVar) {
        prefix = "bevt_";
      } elseIf (v.isProperty) {
        prefix = "bevp_";
      } elseIf (v.isArg) {
        prefix = "beva_";
      } else {
        prefix = "bevl_";
      }
      return(prefix + v.name);
      
   }
   
   typeDecForVar(String b, Build:Var v) {
      if (v.isTyped!) {
        b += objectCc.relEmitName(build.libName);
      } else {
        b += getClassConfig(v.namepath).relEmitName(build.libName);
      }
   }
   
   decForVar(String b, Build:Var v) {
      typeDecForVar(b, v);
      b += " ";
      b += nameForVar(v);
   }
   
   emitNameForMethod(Node node) String {
       return("bem_" + node.held.name);
   }
   
   emitNameForCall(Node node) String {
        return("bem_" + node.held.name);
   }
   
   lookatComp(Node ov) {
     if (ov.held.name == "lookatComp") {
      "found lookatComp".print();
     }
     if (ov.held.isTyped && ov.held.namepath == intNp) {
       if (ov.held.isProperty! && ov.held.isArg!) {
        for (Node c in ov.held.allCalls) {
          if (ov.held.name == "lookatComp") {
            ("lookatComp call " + c.held.name).print();
           }
        }
       }
     }
   }
   
  acceptMethod(Node node) {
      fields {
        Node mnode = node;
        ClassConfig returnType = null;
        Build:MtdSyn msyn;
      }
      msyn = csyn.mtdMap.get(node.held.name);
      
      callNames.put(node.held.name);
      
      String argDecs = String.new();
      String anyDecs = String.new();
      
      //for (Node ovlc in node.held.orderedVars) {
      //  lookatComp(ovlc);
      //}
      
      Bool isFirstArg = true;
      for (Node ov in node.held.orderedVars) {
         if ((ov.held.name != "self") && (ov.held.name != "super")) {
             if (ov.held.isArg) {
                 unless(isFirstArg) {
                    argDecs += ", ";
                 }
                 isFirstArg = false;
                 if (undef(ov.held)) {
                    throw(VisitError.new("Null arg held " + ov.toString(), ov));
                 }
                decForVar(argDecs, ov.held);
             } else {
                decForVar(anyDecs, ov.held);
                if(emitting("js") || emitting("cc")) {
                    anyDecs += ";" += nl;
                } else  {
                    anyDecs += " = null;" += nl;
                }
             }
             ov.held.nativeName = nameForVar(ov.held);
         }
      }
      
      NamePath ertype = msyn.getEmitReturnType(csyn, build);
      
      if (def(ertype)) {
        returnType = getClassConfig(ertype);
      } else {
        returnType = objectCc;
      }
      //node.held.rtype, untyped (obj), isSelf, or particular type
      
      if (msyn.declaration == csyn.namepath) {
         String mtdDec = self.baseMtdDec(msyn);
      } else {
         mtdDec = self.overrideMtdDec(msyn);
      }
      
      startMethod(mtdDec, returnType, emitNameForMethod(node), argDecs, exceptDec);
      
      methods += anyDecs;
      
  }
  
  startMethod(String mtdDec, ClassConfig returnType, String mtdName, String argDecs, exceptDec) {
     
     methods += mtdDec += returnType.relEmitName(build.libName) += " " += mtdName += "(";
      
     methods += argDecs;
      
     methods += ")" += exceptDec += " {" += nl; //}
    
  }
  
  isClose(NamePath np) Bool {
    Build:ClassSyn orgsyn = build.getSynNp(np);
    if (build.closeLibraries.has(orgsyn.libName)) {
        return(true);
    }
    return(false);
  }
  
  acceptClass(Node node) {
     fields {
        String preClass = String.new();
        String classEmits = String.new();
        String onceDecs = String.new();
        Int onceCount = 0;
        String propertyDecs = String.new();
        Node cnode = node;
        Build:ClassSyn csyn = node.held.syn;
        String dynMethods = String.new();
        String ccMethods = String.new();
        List superCalls = List.new();
        Int nativeCSlots = 0;
        String inFilePathed = node.held.fromFile.toStringWithSeparator("/");
     }
     
     any te = node.transUnit.held.emits;
      if (def(te)) {
         for (te = te.iterator;te.hasNext;;) {
            any jn = te.next;
            if (jn.held.langs.has(self.emitLang)) {
                preClass += emitReplace(jn.held.text);
            }
         }
      }
      
       if (def(node.held.extends)) {
          parentConf = getClassConfig(node.held.extends);
          Build:ClassSyn psyn = build.getSynNp(node.held.extends);
       } else {
          parentConf = null;
       }
       
       //Handle class level emits, maybe properties/members or methods (anything, really)
       if (def(node.held.emits)) {
          String inlang = self.emitLang;
          for (Node innode in node.held.emits) {
            //figure out what anys are native
            nativeCSlots = getNativeCSlots(innode.held.text);
            if (innode.held.langs.has(inlang)) {
                classEmits += emitReplace(innode.held.text);
            }
          }
       }
       
       if (def(psyn) && nativeCSlots > 0) {
            nativeCSlots = nativeCSlots - psyn.ptyList.size;
            if (nativeCSlots < 0) {
                nativeCSlots = 0;
            }
       }
       
       //Create property declarations
       //>= natives
       Int ovcount = 0;
       for (any ii = node.held.orderedVars.iterator;ii.hasNext;;) {
            any i = ii.next.held;
            if (i.isDeclared) {
                if (ovcount >= nativeCSlots) {
                    propertyDecs += self.propDec;
                    decForVar(propertyDecs, i);
                    propertyDecs += ";" += nl;
                }
                ovcount++=;
            }
        }
        
      //Its not clear how mtdlist ends up, so just use the map
      Map dynGen = Map.new();
      Container:Set mq = Container:Set.new();
      for (Build:MtdSyn msyn in csyn.mtdList) {
         unless(mq.has(msyn.name)) {
             mq.put(msyn.name);
             msyn = csyn.mtdMap.get(msyn.name);
             if (isClose(msyn.origin)) {
                Int numargs = msyn.numargs;
                if (numargs > maxDynArgs) {
                    numargs = maxDynArgs;
                }
                Map dgm = dynGen.get(numargs);
                if (undef(dgm)) {
                    dgm = Map.new();
                    dynGen.put(numargs, dgm);
                }
                Int msh = getCallId(msyn.name);
                List dgv = dgm.get(msh);
                if (undef(dgv)) {
                    dgv = List.new();
                    dgm.put(msh, dgv); 
                }
                dgv.addValue(msyn);
                //("Added dynGen " + msyn.name + " to dynGen numargs " + numargs).print();
              }
          }
      }
      
      for (Container:Map:MapNode dnode in dynGen) {
        Int dnumargs = dnode.key;
        
        if (dnumargs < maxDynArgs) {
            String dmname = "bemd_" + dnumargs.toString();
        } else {
            dmname = "bemd_x";
        }
        String superArgs = "callCase";
        String args = "int callCase";
        Int j = 1;
        while (j < (dnumargs + 1) && j < maxDynArgs) {
            args = args + ", " + objectCc.relEmitName(build.libName) + " bevd_" + (j - 1);
            superArgs = superArgs + ", " + "bevd_" + (j - 1);
            j++=;
        }
        if (dnumargs >= maxDynArgs) {
            args = args + ", " + objectCc.relEmitName(build.libName) + "[] bevd_x";
            superArgs = superArgs + ", bevd_x";
        }
        dynMethods += self.overrideMtdDec += objectCc.relEmitName(build.libName) += " " += dmname += "(" += args += ")" += exceptDec += " {" += nl;  //}
        dynMethods += "switch (callCase) {" += nl; //}
        
        dgm = dnode.value;
        for (Container:Map:MapNode msnode in dgm) {
            Int thisHash = msnode.key;
            dgv = msnode.value;
            dynMethods += "case " += thisHash.toString() += ": ";
            //do we output if checks against call id for this dmname (this dynamic method)?
            //yes if turned on globally (to avoid possible cases of missing calls beings serviced anyway (very unlikely)
            //or if > 1 entry for this same hash code (have to in that case)
            if (dynConditionsAll || dgv.size > 1) {
                Bool dynConditions = false;
            } else {
                dynConditions = false;
            }
            for (msyn in dgv) {
                String mcall = String.new();
                if (dynConditions) {
                    String constName = libEmitName + scvp + "bevn_" + msyn.name;
                    mcall += "if (callId == " += constName += ") {" += nl; //}
                } 
                mcall += "return bem_" += msyn.name += "(";
                Int vnumargs = 0;
                for (Build:VarSyn vsyn in msyn.argSyns) {
                    if (vnumargs > 0) {
                        if (vnumargs > 1) {
                            String vcma = ", ";
                        } else {
                            vcma = "";
                        }
                        if (vnumargs < maxDynArgs) {
                            String anyg = "bevd_" + (vnumargs - 1);
                        } else {
                            anyg = "bevd_x[" + (vnumargs - maxDynArgs) + "]";
                        }
                        if (vsyn.isTyped && vsyn.namepath != objectNp) {
                            String vcast = formCast(getClassConfig(vsyn.namepath), "checked", anyg);
                        } else {
                            vcast = anyg;
                        }
                        mcall += vcma += vcast;
                    }
                    vnumargs++=;
                }
                mcall += ");" += nl;
                if (dynConditions) {
                    //{
                    mcall += "}" += nl;
                }
                //("mcall built: " + mcall.toString()).print();
                dynMethods += mcall;
            }
            if (dynConditions) {
                dynMethods += "break;" += nl;
            }
        }
        dynMethods += "}" += nl; //end of switch
        dynMethods += "return " + self.superName + invp += dmname += "(" += superArgs += ");" += nl; 
        dynMethods += "}" += nl; //end of method for this argnum
      }
      
      buildClassInfo();
      
      buildCreate();
      
      buildInitial();
      
      //("dynMethods:" + nl + dynMethods.toString() + nl).print();
      
      
  }
  
  getNativeCSlots(String text) Int {
    Int nativeSlots = 0;
    any ll = text.split("/");
      any isfn = false;
      any nextIsNativeSlots = false;
      for (any i in ll) {
         if (nextIsNativeSlots) {
            nextIsNativeSlots = false;
            nativeSlots = Int.new(i);
            isfn = true;
         } elseIf (i == "*-attr- -firstSlotNative-*") {
            isfn = true;
            nativeSlots = 1;
         } elseIf (i == "*-attr- -nativeSlots") {
            nextIsNativeSlots = true;
         }
      }
      if (nativeSlots > 0) {
        //("Found native slots " + nativeSlots + " for class " csyn.namepath).print();
      }
      return(nativeSlots);
  }
  
  buildCreate() {
        ccMethods += self.overrideMtdDec += getClassConfig(objectNp).relEmitName(build.libName) += " bemc_create()" += exceptDec += " {" += nl;  //}
            ccMethods += "return new " += getClassConfig(cnode.held.namepath).relEmitName(build.libName) += "();" += nl;
        //{
        ccMethods += "}" += nl;
    }
    
    buildInitial() {
        String oname = getClassConfig(objectNp).relEmitName(build.libName);
        String mname = classConf.emitName;
        ClassConfig newcc = getClassConfig(cnode.held.namepath);
        String stinst = getInitialInst(newcc);
        
        ccMethods += self.overrideMtdDec += "void bemc_setInitial(" += oname += " becc_inst)" += exceptDec += " {" += nl;  //}
            
            if (mname != oname) {
                String vcast = formCast(classConf, "unchecked", "becc_inst");//no need for type check
            } else {
                vcast = "becc_inst";
            }
            
            ccMethods += stinst += " = " += vcast += ";" += nl;
        //{
        ccMethods += "}" += nl;
        
        
        ccMethods += self.overrideMtdDec += oname += " bemc_getInitial()" += exceptDec += " {" += nl;  //}
            
            ccMethods += "return " += stinst += ";" += nl;
        //{
        ccMethods += "}" += nl;
        
    }

buildClassInfo() self {
    buildClassInfo("clname", classConf.emitName + "_clname", cnode.held.namepath.toString());
    buildClassInfo("clfile", classConf.emitName + "_clfile", inFilePathed);
  }
 
buildClassInfo(String bemBase, String belsBase, String lival) self {
    
    String belsName = "becc_" + belsBase;
    
    String sdec = String.new();
    if(emitting("js")) {
      lstringStart(sdec, "becc_" + bemBase);
    } else {
      lstringStart(sdec, belsName);
    }
      
      Int lisz = lival.size;
      Int lipos = 0;
      Int bcode = Int.new();
      String hs = String.new(2);
      while (lipos < lisz) {
        if (lipos > 0) {
            sdec += ","@;
        }
        lstringByte(sdec, lival, lipos, bcode, hs);
        lipos++=;
      }
      lstringEnd(sdec);
      
    onceDecs += sdec;
    
    buildClassInfoMethod(bemBase, belsBase, lival.size);

}

buildClassInfoMethod(String bemBase, String belsBase, Int len) {
    /*ccMethods += self.overrideMtdDec += "byte[] bemc_" += bemBase += "()" += exceptDec += " {" += nl;  //}
    ccMethods += "return becc_" += belsBase += ";" += nl;
    //{
    ccMethods += "}" += nl;*/
    
    ccMethods += self.overrideMtdDec += "BEC_2_4_6_TextString bemc_" += bemBase += "s()" += exceptDec += " {" += nl;  //}
    ccMethods += "return new BEC_2_4_6_TextString(" += len += ", becc_" += belsBase += ");" += nl;
    //{
    ccMethods += "}" += nl;
}

  initialDecGet() String {
       
       String initialDec = String.new();
       
       String bein = "bece_" + classConf.emitName + "_bevs_inst";
       
       if (csyn.namepath == objectNp) {
          initialDec += baseSpropDec(classConf.emitName, bein) += ";" += nl;
       } else {
          initialDec += overrideSpropDec(classConf.emitName, bein) += ";" += nl;
       }
       
       return(initialDec);
  }
  
  classBegin(Build:ClassSyn csyn) String {
       if (def(parentConf)) {
          String extends = extend(parentConf.relEmitName(build.libName));
       } else {
          extends = extend("be.BECS_Object");
       }
       String clb = "/* IO:File: " += inFilePathed += " */" += nl;
       clb += self.klassDec(csyn.isFinal) += classConf.emitName += extends += " {" += nl; //}
       clb += "public " += classConf.emitName += "() {";
       clb += " }" += nl; //default constructor
       if(emitting("cs")) {
        clb += "static " += classConf.emitName += "() {";
        clb += " }" += nl; //default constructor
       }
       return(clb)
  }
  
  classEndGet() String {
       //{
       return("}" += nl);
  }
      
  baseSpropDec(String typeName, String anyName) {
     return("public static " + typeName + " " + anyName);
  }
  
    onceDec(String typeName, String anyName) {
        return("");
    }
  
  
  overrideSpropDec(String typeName, String anyName) {
    return("");
  }
  
  getTraceInfo(Node node) {
    String trInfo = String.new();
    if (def(node) && def(node.nlc)) {
      trInfo += "Line: " += node.nlc.toString();
    }
    return(trInfo);
  }
  
  acceptBraces(Node node) {
      if (def(node.container)) {
         Int typename = node.container.typename;
         if (typename != ntypes.METHOD && typename != ntypes.CLASS && typename != ntypes.EXPR && typename != ntypes.PROPERTIES && typename != ntypes.CATCH) {
            
            methodBody += " /* " += getTraceInfo(node) += " */ {" += nl; //}
         }
      }
  }
  
  //TODO to avoid a java unreachable code case - if last call is throw, no auto self return
  //TODO to avoid a missing return statement - if last call of return is inside a conditional, still do auto self return
  
  acceptRbraces(Node node) {
     if (def(node.container) && def(node.container.container)) {
        any nct = node.container.container;
        any typename = nct.typename;
        if (typename == ntypes.METHOD) {
           if (def(mnode)) {
             if (undef(lastCall) || lastCall.held.orgName != "return") {
                //what about return_1, return_2?
                //TODO check for types in case not ok for self return
                unless(emitting("cc")) {
                  methodBody += "return this;" += nl;//default self return
                } else {
                  methodBody += "return static_pointer_cast<" += classConf.emitName += ">(shared_from_this());" += nl;
                }
             }
             
             if (maxSpillArgsLen > 0) {
               if (emitting("js")) {
                methods += "var bevd_x = new Array(" += maxSpillArgsLen.toString() += ");" += nl;
               } else {
                methods += objectCc.relEmitName(build.libName) += "[] bevd_x = new " += objectCc.relEmitName(build.libName) += "[" += maxSpillArgsLen.toString() += "];" += nl;
               }
             }
             
             Int methodsOffset = countLines(methods, lastMethodsSize);
             methodsOffset += lastMethodsLines;
             lastMethodsLines = methodsOffset;
             lastMethodsSize = methods.size.copy();
             
             //get methods offset, go through calls in body, add offset, move body calls to class calls
             //Int methodsOffset = countLines(methods);
             for (Node mc in methodCalls) {
               mc.nlec += methodsOffset;
             }
             classCalls += methodCalls;
             methodCalls.length = 0;
             
             methods += methodBody;
             methodBody.clear();
             lastMethodBodySize = 0;
             lastMethodBodyLines = 0;
             
             //reinitialize method level properties
             methodCatch = 0;
             lastCall = null;
             maxSpillArgsLen = 0;
             
             //{
             methods += "} /*method end*/" += nl;
             msyn = null;
             mnode = null;
           }
        } elseIf (typename != ntypes.EXPR && typename != ntypes.PROPERTIES && typename != ntypes.CLASS) {
            //{
           methodBody += "} /* " += getTraceInfo(node) += " */" += nl;
        }
      }
  }
  
  countLines(String text) Int {
    return(countLines(text, 0));
  }
  
  countLines(String text, Int start) Int {
    Int found = 0;
    Int nlval = nl.getInt(0, Int.new());
    Int cursor = Int.new();
    Int slen = text.size.copy();
    for (Int i = start.copy();i < slen;i++=;) {
      text.getInt(i, cursor);
      if (cursor == nlval) {
        found++=;
      }
    }
    return(found);
  }
  
  acceptIf(Node node) {
         String targs = formTarg(node.contained.first.contained.first);
         String btargs = formBoolTarg(node.contained.first.contained.first);
         if (node.contained.first.contained.first.held.isTyped! || node.contained.first.contained.first.held.namepath != boolNp) {
            Bool isBool = false;
         } else {
            isBool = true;
         }
         if (def(node.held) && node.held == "unless") {
            Bool isUnless = true;
         } else {
            isUnless = false;
         }
         String ev = "";
         if (isUnless) {
            ev += "!(";
         }
         if (isBool) {
            ev += btargs;
         } else {
            //TODO FASTER could drop instof check - this is here now for harmony with c - would change behavior (obviously)
            //TODO FASTER (a little), after default is complete, the null check should not be unneeded anymore for harmony
            //but also make faster for the 99% cases, and these things can be explicitely checked for when needed
            //if target is this (in bool class) it's different
            if (btargs == "bevi_bool") {
              ev += btargs;
            } else {
              ev += targs += " != " += nullValue += " && " += targs += instOf += boolCc.relEmitName(build.libName) += " && ";
              if (emitting("js")!) {
                  ev += "(" += formCast(boolCc, "checked", targs);
              }
              if (emitting("js")) {
                ev += targs;
              }
              if (emitting("js")!) {
                  ev += ")";
              }
              ev += invp += "bevi_bool";
            }
         }
         if (isUnless) {
            ev += ")";
         }
         methodBody += "if (" += ev += ")";
   }
   
   acceptCatch(Node node) {
   }
   
   finalAssign(Node node, String sFrom, NamePath castTo, String castType) String {
      String fa = finalAssignTo(node);
      if (def(castTo)) {
        String cast = formCast(getClassConfig(castTo), castType);
        String afterCast = afterCast();
        fa += cast += sFrom;
        fa += afterCast;
        fa += ";" += nl;
      } else {
        fa += sFrom += ";" += nl;
      }
      return(fa);
   }
   
   finalAssignTo(Node node) String {
      if (node.typename == ntypes.NULL) {
         throw(VisitError.new("Cannot assign to literal null"));
      }
      if (node.held.name == "self") {
         throw(VisitError.new("Cannot assign to self"));
      }
      if (node.held.name == "super") {
         throw(VisitError.new("Cannot assign to super"));
      }
      return(nameForVar(node.held) + " = ");
   }
   
   superNameGet() String {
       return("super");
    }
   
   formCast(ClassConfig cc, String type) String { //no need for type check
        return("(" + cc.relEmitName(build.libName) + ") ");
   }
   
   afterCast() String {
     return("");
   }
   
   formCast(ClassConfig cc, String type, String targ) String {
        return(formCast(cc, type) + targ + afterCast());
   }
   
    acceptThrow(Node node) {
        methodBody += "throw new be.BECS_ThrowBack(" += formTarg(node.second) += ");" += nl;
    }
    
    onceVarDec(String count) String {
        return("bece_" + classConf.emitName + "_bevo_" + count);
    }
   
   acceptCall(Node node) {
   
  for (Node cci in node.contained) {
    if (cci.typename == ntypes.VAR) {
      if (cci.held.allCalls.has(node)!) {
        throw(VisitError.new("VAR DOES NOT HAVE MY CALL " + node.held.name + node.toString(), cci));
      }
    }
  }
   
      callNames.put(node.held.name);
   
      lastCall = node;
      
      methodCalls += node;
      
      //offset of method body, put into node.nlec
      
      Int moreLines = countLines(methodBody, lastMethodBodySize);
      lastMethodBodyLines = lastMethodBodyLines + moreLines;
      lastMethodBodySize = methodBody.size.copy();
      
      node.nlec = lastMethodBodyLines;
      //node.nlec = countLines(methodBody);
      
      if ((node.held.orgName == "assign") && (node.contained.length != 2)) {
         any errmsg = "assignment call with incorrect number of arguments " + node.contained.length.toString();
         for (Int ei = 0;ei < node.contained.length;ei++=) {
            errmsg = errmsg + " !!!" + ei + "!! " + node.contained[ei];
         }
         throw(VisitError.new(errmsg, node));
      } elseIf ((node.held.orgName == "assign") && (node.contained.first.held.name == "self")) {
         throw(VisitError.new("self cannot be assigned to", node));
      } elseIf (node.held.orgName == "throw") {
         acceptThrow(node);
         return(self);
      } elseIf (node.held.orgName == "assign") {
      
        if (def(node.second) && def(node.second.contained) && node.second.contained.size == 2 && node.second.contained.first.held.isTyped && node.second.contained.first.held.namepath == intNp && node.second.contained.second.typename == ntypes.VAR && node.second.contained.second.held.isTyped && node.second.contained.second.held.namepath == intNp) {
          Bool isIntish = true;
        } else {
          isIntish = false;
        }
        
        if (def(node.second) && def(node.second.contained) && node.second.contained.size == 1 && node.second.contained.first.held.isTyped && node.second.contained.first.held.namepath == boolNp) {
          Bool isBoolish = true;
        } else {
          isBoolish = false;
        }
      
         NamePath castTo;
         //FASTER (possibly), for self type do /fast (unchecked) casts/ where possible (not ret self), do the check for correctness in
         //the method instead of at assign and only if not returning "self" (do same type check)
         if (node.held.checkTypes) {
            castTo = node.contained.first.held.namepath;
            String castType = node.held.checkTypesType;
         }
         if (node.second.typename == ntypes.VAR) {
            //node.held.checkTypes (for casting needed) (legacy became checkAssignTypes)
            methodBody += finalAssign(node.contained.first, formTarg(node.second), castTo, castType);
         } elseIf (node.second.typename == ntypes.NULL) {
           if(emitting("cc")) {
            methodBody += finalAssign(node.contained.first, "nullptr", null, null);
           } else {
            methodBody += finalAssign(node.contained.first, "null", null, null);
           }
         } elseIf (node.second.typename == ntypes.TRUE) {
            methodBody += finalAssign(node.contained.first, trueValue, castTo, castType);
         } elseIf (node.second.typename == ntypes.FALSE) {
            methodBody += finalAssign(node.contained.first, falseValue, castTo, castType);
         } elseIf (node.second.held.name == "undef_1" || node.second.held.name == "undefined_1" ||
            node.second.held.name == "def_1" || node.second.held.name == "defined_1") {
            //if (node.second.second.held.isTyped) {
            //    Build:ClassSyn dsyn = build.getSynNp(node.second.second.held.namepath);
            //    if (dsyn.isNotNull) {
            //        throw(VisitError.new("Check for defined/undefined on non-nullable type"));
            //    }
            //}
            if (node.held.checkTypes) {
               if (node.contained.first.held.namepath.toString() != "Logic:Bool") {
                  throw(VisitError.new("Incorrect type for undef/undefined on assignment", node));
               }
            }
            if (node.second.held.name.begins("u")) {
               String nullRes = trueValue;
               String notNullRes = falseValue;
            } else {
               nullRes = falseValue;
               notNullRes = trueValue;
            }
            methodBody += "if (" += formTarg(node.second.second) += " == " += nullValue += ") {" += nl;
            methodBody += finalAssign(node.contained.first, nullRes, null, null);
            methodBody += " } else { " += nl;
            methodBody += finalAssign(node.contained.first, notNullRes, null, null);
            methodBody += "}" += nl;  
        } elseIf (isIntish && node.second.held.name == "lesser_1") {
          //do call name in a set later
          //("found an int lesser call").print();
          node.second.inlined = true;
          methodBody += "if (" += formIntTarg(node.second.first) += " < " += formIntTarg(node.second.second) += ") {" += nl;
          methodBody += finalAssign(node.contained.first, trueValue, null, null);
          methodBody += " } else { " += nl;
          methodBody += finalAssign(node.contained.first, falseValue, null, null);
          methodBody += "}" += nl;
        } elseIf (isIntish && node.second.held.name == "lesserEquals_1") {
          //do call name in a set later
          //("found an int lesser call").print();
          node.second.inlined = true;
          methodBody += "if (" += formIntTarg(node.second.first) += " <= " += formIntTarg(node.second.second) += ") {" += nl;
          methodBody += finalAssign(node.contained.first, trueValue, null, null);
          methodBody += " } else { " += nl;
          methodBody += finalAssign(node.contained.first, falseValue, null, null);
          methodBody += "}" += nl;
         } elseIf (isIntish && node.second.held.name == "greater_1") {
          //do call name in a set later
          //("found an int greater call").print();
          node.second.inlined = true;
          methodBody += "if (" += formIntTarg(node.second.first) += " > " += formIntTarg(node.second.second) += ") {" += nl;
          methodBody += finalAssign(node.contained.first, trueValue, null, null);
          methodBody += " } else { " += nl;
          methodBody += finalAssign(node.contained.first, falseValue, null, null);
          methodBody += "}" += nl;
        } elseIf (isIntish && node.second.held.name == "greaterEquals_1") {
          //do call name in a set later
          //("found an int lesser call").print();
          node.second.inlined = true;
          methodBody += "if (" += formIntTarg(node.second.first) += " >= " += formIntTarg(node.second.second) += ") {" += nl;
          methodBody += finalAssign(node.contained.first, trueValue, null, null);
          methodBody += " } else { " += nl;
          methodBody += finalAssign(node.contained.first, falseValue, null, null);
          methodBody += "}" += nl;
         } elseIf (isIntish && node.second.held.name == "equals_1") {
          //do call name in a set later
          //("found an int lesser call").print();
          if (emitting("js")) {
            String ecomp = " === ";
          } else {
            ecomp = " == ";
          }
          node.second.inlined = true;
          methodBody += "if (" += formIntTarg(node.second.first) +=  ecomp += formIntTarg(node.second.second) += ") {" += nl;
          methodBody += finalAssign(node.contained.first, trueValue, null, null);
          methodBody += " } else { " += nl;
          methodBody += finalAssign(node.contained.first, falseValue, null,null);
          methodBody += "}" += nl;
        } elseIf (isIntish && node.second.held.name == "notEquals_1") {
          //do call name in a set later
          //("found an int neq call").print();
          if (emitting("js")) {
            String necomp = " !== ";
          } else {
            necomp = " != ";
          }
          node.second.inlined = true;
          methodBody += "if (" += formIntTarg(node.second.first) += necomp += formIntTarg(node.second.second) += ") {" += nl;
          methodBody += finalAssign(node.contained.first, trueValue, null, null);
          methodBody += " } else { " += nl;
          methodBody += finalAssign(node.contained.first, falseValue, null, null);
          methodBody += "}" += nl;
         } elseIf (isBoolish && node.second.held.name == "not_0") {
          //("found a bool not").print();
          node.second.inlined = true;
          methodBody += "if (" += formTarg(node.second.first) += invp += "bevi_bool) {" += nl;
          methodBody += finalAssign(node.contained.first, falseValue, null, null);
          methodBody += " } else { " += nl;
          methodBody += finalAssign(node.contained.first, trueValue, null, null);
          methodBody += "}" += nl;
         }
         return(self);
      } elseIf (node.held.orgName == "return") {
        //node.held.checkTypes for casting, rsub.held.rtype.isSelf for self type
        if (node.held.checkTypes) {
            methodBody += "return " += formCast(returnType, node.held.checkTypesType, formTarg(node.second)) += ";" += nl; //do type check
        } else {
          methodBody += "return " += formTarg(node.second) += ";" += nl; //first is self
        }
        return(self);
      } elseIf (node.held.name == "def_1" || node.held.name == "defined_1" || node.held.name == "undef_1" || node.held.name == "undefined_1" || node.inlined) {
        //previously detected and handled during assignment section above (possible due to unwind...)
        return(self);
      }
      
      if (node.held.name != node.held.orgName + "_" + node.held.numargs) {
         throw(VisitError.new("Bad name for call " + node.held.name + " " + node.held.orgName + " " + node.held.numargs));
      }
      
      Bool selfCall = false;
      Bool superCall = false;
      Bool isConstruct = false;
      Bool isTyped = false;
      Bool isForward = false;

      if (node.held.isConstruct) {
         isConstruct = true;
         ClassConfig newcc = getClassConfig(node.held.newNp);
      } elseIf (node.contained.first.held.name == "self") {
         selfCall = true;
      } elseIf (node.contained.first.held.name == "super") {
         selfCall = true;
         superCall = true;
         superCalls += node;
         node.held.superCall = true;
      }
      //node.held.checkTypes
      
      Bool sglIntish = false;
      Bool dblIntish = false;
      if (node.inlined! && def(node.contained) && node.contained.size > 0 && node.contained.first.held.isTyped && node.contained.first.held.namepath == intNp) {
        sglIntish = true;
        if (node.contained.size > 1 && node.contained.second.typename == ntypes.VAR && node.contained.second.held.isTyped && node.contained.second.held.namepath == intNp) {
          dblIntish = true;
          String dblIntTarg = formTarg(node.contained.second);
        }
      }
      
      isForward = node.held.isForward;
      
      //prepare args
      String callArgs = String.new();
      String spillArgs = String.new();
      
      Int numargs = 0;
      for (any it = node.contained.iterator;it.hasNext;;) {
         List argCasts = node.held.argCasts;
         any i = it.next;
         if (numargs == 0) {
            //any targetOrg = i.held.name;
            String target = formTarg(i);
            String callTarget = formCallTarg(i);
            Node targetNode = i;
            if (targetNode.held.isTyped && node.held.untyped!) {
                isTyped = true;
            }
            if (isForward) {
              isTyped = false;
              mUseDyn = true;
              mMaxDyn = 0;
            } else {
              Bool mUseDyn = self.useDynMethods;
              Int mMaxDyn = maxDynArgs;
            }
         } else {
            if (isTyped || numargs < mMaxDyn || mUseDyn!) {
                if (numargs > 1) {
                    callArgs += ", ";
                }
                if (argCasts.length > numargs && def(argCasts.get(numargs))) {
                    callArgs += formCast(getClassConfig(argCasts.get(numargs)), "checked", formTarg(i)) += " "; //do type check
                } else {
                  callArgs += formTarg(i);
                }
            } else {
                //put into call array
                if (isForward) {
                  spillArgPos = numargs - 1;
                } else {
                  Int spillArgPos = numargs - mMaxDyn;//spill arg array index
                }
                spillArgs += "bevd_x[" += spillArgPos.toString() += "] = " += formTarg(i) += ";" += nl;
            }
         }
         numargs = numargs++;
      }
      
      //numargs has been incremented higher than the actual number of args by one
      numargs = numargs--;
      
      if (isConstruct && isTyped!) {
        throw(VisitError.new("isConstruct but not isTyped", node));
      }
      
      Bool isOnce = false;
      Bool onceDeced = false;
      String cast = "";
      String afterCast = "";
      
      //Prepare Assignment
      if ((node.container.typename == ntypes.CALL) && (node.container.held.orgName == "assign")) {
        if (isOnceAssign(node.container) && ((isConstruct && newcc.np == boolNp)!)) {
            isOnce = true;
            String oany = onceVarDec(onceCount.toString());
            onceCount = onceCount++;
            
            if (node.container.contained.first.held.isTyped!) {
               String odec = onceDec(objectCc.relEmitName(build.libName), oany);
            } else {
               odec = onceDec(getClassConfig(node.container.contained.first.held.namepath).relEmitName(build.libName), oany);
            }
            
        }
        //node.container.held.checkTypes
        if (node.container.held.checkTypes) {
            //("assign casting").print();
            castTo = node.container.contained.first.held.namepath;
            castType = node.container.held.checkTypesType;
            cast = formCast(getClassConfig(castTo), castType);
            afterCast = afterCast();
         }
        String callAssign = finalAssignTo(node.container.contained.first);
      } else {
        callAssign = "";
      }
      
      if (isOnce) {
        //no cast for the post assign, the oany is always typed based on the type assigned to, so the case when assigning to oany 
        //is all that's needed and the oany is always the same type as the assign to target
        String postOnceCallAssign = nameForVar(node.container.contained.first.held) + " = " + oany + ";" + nl;
        if (def(castTo) && (isConstruct && node.held.isLiteral)!) {
           cast = formCast(getClassConfig(castTo), castType); //do type check
           afterCast = afterCast();
        } else {
           cast = "";
           afterCast = "";
        }
        callAssign = oany + " = ";
      }
      
      //also did include  && odec.isEmpty!
      if ((isTyped || mUseDyn!) && isConstruct && node.held.isLiteral && isOnce) {
       onceDeced = true;
      } elseIf (isOnce) {
        //add flag for warning option later on
        //("!!!Found once not deced for node " + node).print();
        if(emitting("jv")) {
          methodBody += "synchronized (" += classConf.emitName += ".class) {" += nl;//}
        } elseIf(emitting("cs")) {
          methodBody += "lock (typeof(" += classConf.emitName += ")) {" += nl;//}
        }
        methodBody += "if (" + oany + " == " + nullValue + ") {" += nl; //}
      }
      
      //FASTER if undef or def is inside an if skip the assign and just put it into the if
      //FASTER no-call get and set where possible (typed, lib/final, closelib)
      if (isTyped || mUseDyn!) {
          if (isConstruct) {
                if (node.held.isLiteral) {
                    if (newcc.np == intNp) {
                        newCall = lintConstruct(newcc, node);
                    } elseIf (newcc.np == floatNp) {
                        newCall = lfloatConstruct(newcc, node);
                    } elseIf (newcc.np == stringNp) {
                        String belsName = "bece_" + classConf.emitName + "_bels_" + cnode.held.belsCount.toString();                        
                        cnode.held.belsCount++=;
                        String sdec = String.new();
                        lstringStart(sdec, belsName);
                        
                        String liorg = node.held.literalValue;
                      
                          if (node.wideString) {
                            String lival = liorg;
                          } else {
                            lival = Json:Unmarshaller.unmarshall("[" + TS.quote + liorg + TS.quote + "]").first;
                          }
                          
                          Int lisz = lival.size;
                          Int lipos = 0;
                          Int bcode = Int.new();
                          String hs = String.new(2);
                          while (lipos < lisz) {
                            if (lipos > 0) {
                                sdec += ","@;
                            }
                            lstringByte(sdec, lival, lipos, bcode, hs);
                            lipos++=;
                          }
                          lstringEnd(sdec);
                          
                        onceDecs += sdec;
                        newCall = lstringConstruct(newcc, node, belsName, lisz, isOnce);
                    } elseIf (newcc.np == boolNp) {
                        if (node.held.literalValue == "true") {
                            newCall = trueValue;
                        } else {
                            newCall = falseValue;
                        }
                    } else {
                        //("UNHANDLED LITERAL TYPE " + newcc.np.toString()).print();
                        throw(VisitError.new("UNHANDLED LITERAL TYPE " + newcc.np.toString()));
                    }
                } else {
                  if (emitting("cc")) {
                    newCall = "make_shared<" + newcc.relEmitName(build.libName) + ">()";
                  } else {
                    String newCall = "new " + newcc.relEmitName(build.libName) + "()";
                  }
                }
                target = "(" + newCall + ")";
                callTarget = target + invp;
                
                String stinst = getInitialInst(newcc);
                
                if (node.held.isLiteral) {
                    if (newcc.np == boolNp) {
                        if (onceDeced) {
                          String odinfo = String.new();
                          for (any n in node.container.contained.first.held.allCalls) {
                            odinfo += n.held.name += " ";
                          }
                          throw(System:Exception.new("oh noes once deced " + 
                          odinfo));
                        }
                        if (node.held.literalValue == "true") {
                            target = trueValue;
                            callTarget = trueValue + invp;
                        } else {
                            target = falseValue;
                            callTarget = falseValue + invp;
                        }
                    }
                    if (onceDeced) {
                      onceDecs += odec += callAssign += cast += target += afterCast += ";" += nl;
                    } else {
                        methodBody += callAssign += cast += target += afterCast += ";" += nl;
                    }
                } else {
                    Build:ClassSyn asyn = build.getSynNp(newcc.np);
                    if (asyn.hasDefault) {
                        String initialTarg = stinst;
                    } else {
                        initialTarg = target;
                    }
                    Build:MtdSyn msyn = asyn.mtdMap.get("new_0");
                    if (Text:Strings.notEmpty(callAssign) && node.held.name == "new_0" && msyn.origin.toString() == "System:Object") {
                      //("Found a skippable new for class " + asyn.namepath.toString()).print();
                      methodBody += callAssign += cast += initialTarg += afterCast += ";" += nl;
                    } elseIf (Text:Strings.notEmpty(callAssign) && node.held.name == "new_0" && msyn.origin.toString() == "Math:Int" && emitting("js")!) {
                      //("Found a skippable int new for class " + asyn.namepath.toString()).print();
                      methodBody += callAssign += cast += initialTarg += afterCast += ";" += nl;
                    } else {
                      methodBody += callAssign += cast += initialTarg += invp += emitNameForCall(node) += "(" += callArgs += ")" += afterCast += ";" += nl;
                    }
                }
          } else {
            if (sglIntish || dblIntish) {
              String dbftarg = target + invp + "bevi_int";
              if (emitting("js")! && target == "this") {
                dbftarg = "bevi_int";
              }
            }
            if (dblIntish) {
              String dbstarg = dblIntTarg + invp + "bevi_int";
              if (emitting("js")! && dblIntTarg == "this") {
                dbstarg = "bevi_int";
              }
            }
            if (dblIntish && node.held.name == "setValue_1") {
              //("found setval").print(); 
              methodBody += dbftarg += " = " += dbstarg += ";" += nl;
              if (TS.notEmpty(callAssign)) {
                //("found setval with assign").print();
                methodBody += callAssign += cast += target += afterCast += ";" += nl;
              }
            } elseIf (dblIntish && node.held.name == "addValue_1") {
              //("found addval").print(); 
              methodBody += dbftarg += " += " += dbstarg += ";" += nl;
              if (TS.notEmpty(callAssign)) {
                //("found addval with assign").print();
                methodBody += callAssign += cast += target += afterCast += ";" += nl;
              }
            } elseIf (sglIntish && node.held.name == "incrementValue_0") {
              //("found incval").print(); 
              methodBody += dbftarg += "++;" += nl;
              if (TS.notEmpty(callAssign)) {
                //("found incval with assign").print();
                methodBody += callAssign += cast += target += afterCast += ";" += nl;
              }
            } elseIf (isTyped!) {
                methodBody += callAssign += cast += callTarget += emitNameForCall(node) += "(" += callArgs += ")" += afterCast += ";" += nl;
            } else {
                methodBody += callAssign += cast += callTarget += emitNameForCall(node) += "(" += callArgs += ")" += afterCast += ";" += nl;
            }
          }
      } else {
        if (numargs < mMaxDyn) {
            String dm = numargs.toString();
            String callArgSpill = "";
        } else {
            dm = "x";
            Int spillArgsLen = numargs - mMaxDyn + 1;
            if (spillArgsLen > maxSpillArgsLen) {
                maxSpillArgsLen = spillArgsLen;
            }
            methodBody += spillArgs;
            callArgSpill = ", bevd_x";
        }
        if (numargs > 0) {
            String fc = ", ";
        } else {
            fc = "";
        }
        if (isForward) {
          if (emitting("cs")) {
            methodBody += callAssign += cast += callTarget += "bems_forwardCallCp(new BEC_2_4_6_TextString(System.Text.Encoding.UTF8.GetBytes(\"" += node.held.orgName += "\")), new BEC_2_9_4_ContainerList(bevd_x, " += numargs.toString() += "));" += nl;
          } elseIf (emitting("jv")) {
             methodBody += callAssign += cast += callTarget += "bem_forwardCall_2(new BEC_2_4_6_TextString(\"" += node.held.orgName += "\".getBytes(\"UTF-8\")), (new BEC_2_9_4_ContainerList(bevd_x, " += numargs.toString() += ")).bem_copy_0());" += nl;
          } else {
            methodBody += callAssign += cast += callTarget += "bems_forwardCall(\"" += node.held.orgName += "\"" += callArgSpill += ", " += numargs.toString() += ")" += afterCast += ";" += nl;
          }
        } else {
          methodBody += callAssign += cast += callTarget += "bemd_" += dm += "(" += getCallId(node.held.name).toString() += fc += callArgs += callArgSpill += ")" += afterCast += ";" += nl;
        }
      }
      
      if (isOnce) {
        if (onceDeced!) {
            //{
            methodBody += "}" += nl; //close to check for oany null
            if(emitting("jv") || emitting("cs")) {
              //{
              methodBody += "}" += nl; //close the synchronized or lock on class
            }
        }
        methodBody += postOnceCallAssign;
        if (onceDeced!) {
            if (odec.isEmpty!) {
              onceDecs += odec += oany += ";" += nl;
            }
        }
      }
   
   }
   
   doInitializeIt(String nc) String {
    String ii = "(";
    if(emitting("js")) {
        ii += "be_BECS_Runtime.prototype.initializer.bem_initializeIt_1(" += nc += ")";
    } else {
        ii += "be.BECS_Runtime.initializer.bem_initializeIt_1(" += nc += ")";
    }
    ii += ")";
    return(ii);
   }
   
   getInitialInst(ClassConfig newcc) String {
    auto nccn = newcc.relEmitName(build.libName);
    String bein = "bece_" + nccn + "_bevs_inst";
    return(nccn + "." + bein);
   }
   
   lintConstruct(ClassConfig newcc, Node node) String {
      return("new " + newcc.relEmitName(build.libName) + "(" + node.held.literalValue + ")");
   }
   
   lfloatConstruct(ClassConfig newcc, Node node) String {
      return("new " + newcc.relEmitName(build.libName) + "(" + node.held.literalValue + "f)");
   }
   
   lstringConstruct(ClassConfig newcc, Node node, String belsName, Int lisz, Bool isOnce) String {
      if (isOnce) {
        return("new " + newcc.relEmitName(build.libName) + "(" + belsName + ", " + lisz + ")");
      }
      return("new " + newcc.relEmitName(build.libName) + "(" + lisz + ", " + belsName + ")");
   }
   
   lstringStart(String sdec, String belsName) {
      sdec += "private static byte[] " += belsName += " = {"; //}
   }
   
   lstringByte(String sdec, String lival, Int lipos, Int bcode, String hs) {
        
    }
    
    lstringEnd(String sdec) {
        //{
        //sdec += "0x00};" += nl;
        //{
        sdec += "};" += nl;
    }
   
   isOnceAssign(Node asnCall) Bool {
        if (asnCall.held.isMany) {
            return(false);
        }
        if (asnCall.held.isOnce || asnCall.isLiteralOnce) {
            return(true);
        }
        return(false);
    }
   
   acceptEmit(Node node) {
     if (node.held.langs.has(self.emitLang)) {
        methodBody += emitReplace(node.held.text);
     }
   }
   
   emitReplace(String text) String {
     Int state = 0;
     Text:Tokenizer emitTok = Text:Tokenizer.new("$/", true);
     LinkedList toks = emitTok.tokenize(text);
     if (text.has("/*-attr- -noreplace-*/") || text.has("$")!) {
       return(text);
     }
     String rtext = String.new();
     for (String tok in toks) {
       if (state == 0 && tok == "$") {
         //("FOUND A $ IN AN EMIT!!!!").print();
         state = 1;
       } elseIf (state == 1) {
         if (tok == "class") {
           String type = "class";
           state = 2;
         }
       } elseIf (state == 2) {
         //don't really do anything, / separator
         state = 3;
       } elseIf (state == 3) {
         String value = tok;
         if (type == "class") {
          //("DO CLASS REPLACE FOR " + tok).print();
          NamePath np = NamePath.new(tok);
          String rep = getEmitName(np);
          //("RES IS " + rep).print();
          rtext += rep;
         }
         state = 4;
       } elseIf (state == 4) {
         //don't really do anything, trailing $
         state = 0;
       } else {
         rtext += tok;
       }
     }
     return(rtext);
   }
   
   acceptIfEmit(Node node) {
      Bool include = true;
      if (node.held.value == "ifNotEmit") {
        Bool negate = true;
      } else {
        negate = false;
      }
      if (negate) {
        if (node.held.langs.has(self.emitLang)) {
          include = false;
        }
        if (def(build.emitFlags)) {
          for (String flag in build.emitFlags) {
            if (node.held.langs.has(flag)) {
              include = false;
            }
          }
        }
      } else {
        Bool foundFlag = false;
        if (def(build.emitFlags)) {
          for (flag in build.emitFlags) {
            if (node.held.langs.has(flag)) {
              foundFlag = true;
            }
          }
        }
        if (foundFlag! && node.held.langs.has(self.emitLang)!) {
          include = false;
        }
      }
      if (include) {
        return(node.nextDescend);
      }
      return(node.nextPeer);
   }
      
   accept(Node node) Node {
      if (node.typename == ntypes.CLASS) {
         acceptClass(node);
      } elseIf (node.typename == ntypes.METHOD) {
         acceptMethod(node);
      } elseIf (node.typename == ntypes.RBRACES) {
         acceptRbraces(node);
      } elseIf (node.typename == ntypes.EMIT) {
         acceptEmit(node);
      } elseIf (node.typename == ntypes.IFEMIT) {
         addStackLines(node);
         return(acceptIfEmit(node));
      } elseIf (node.typename == ntypes.CALL) {
         acceptCall(node);
      } elseIf (node.typename == ntypes.BRACES) {
        acceptBraces(node);
      } elseIf (node.typename == ntypes.BREAK) {
         methodBody += "break;" += nl;
      } elseIf (node.typename == ntypes.LOOP) {
         methodBody += "while (true)" += nl;
      } elseIf (node.typename == ntypes.ELSE) {
         methodBody += " else ";
      } elseIf (node.typename == ntypes.FINALLY) {
         //methodBody += " finally ";
         throw(VisitError.new("finally not supported :-(")); //)
      } elseIf (node.typename == ntypes.TRY) {
         methodBody += "try ";
      } elseIf (node.typename == ntypes.CATCH) {
         acceptCatch(node);
      } elseIf (node.typename == ntypes.IF) {
        acceptIf(node);
      }
      addStackLines(node);
      return(node.nextDescend);
   }
   
   addStackLines(Node node) {
      if (def(cnode)) {
      }
   }
   
   buildStackLines(Node node) {
   }
   
   formTarg(Node node) String {
      String tcall;
      if (node.typename == ntypes.NULL) {
         tcall = "null";
      } elseIf (node.held.name == "self") {
         tcall = "this";
      } elseIf (node.held.name == "super") {
         tcall = self.superName;
      } else {
         tcall = nameForVar(node.held);
      }
      return(tcall);
   }
   
   formCallTarg(Node node) String {
      String tcall;
      if (node.typename == ntypes.NULL) {
         throw(VisitError.new("Cannot call on literal null"));
      } elseIf (node.held.name == "self") {
         tcall = "";
      } elseIf (node.held.name == "super") {
         tcall = self.superName + invp;
      } else {
         tcall = nameForVar(node.held) + invp;
      }
      return(tcall);
   }
   
   formIntTarg(Node node) String {
      String tcall;
      if (node.typename == ntypes.NULL) {
         throw(VisitError.new("Cannot call on literal null"));
      } elseIf (node.held.name == "self") {
         tcall = "bevi_int";
      } elseIf (node.held.name == "super") {
         tcall = "bevi_int";
      } else {
         tcall = nameForVar(node.held) + invp + "bevi_int";
      }
      return(tcall);
   }
   
   formBoolTarg(Node node) String {
      String tcall;
      if (node.typename == ntypes.NULL) {
         throw(VisitError.new("Cannot call on literal null"));
      } elseIf (node.held.name == "self") {
         tcall = "bevi_bool";
      } elseIf (node.held.name == "super") {
         tcall = "bevi_bool";
      } else {
         tcall = nameForVar(node.held) + invp + "bevi_bool";
      }
      return(tcall);
   }
      
   end(transi) {
      super.end(transi);
   }
   
   beginNs() String {
      return("");
   }
   
   beginNs(String libName) String {
        return("");
   }
    
   libNs(String libName) String {
        return("");
   }
   
   endNs() String {
      return("");
   }
   
   extend(String parent) String {
        return("");
    }
    
    //Does this emit lang support coanyiant return types
    coanyiantReturnsGet() {
        return(true);
    }
    
    mangleName(NamePath np) String {
      String pref = "";
      String suf = "";
      for (String step in np.steps) {
         if (pref != "") { pref = pref + "_"; }
         //else { suf = "_"; } //old way, no count of steps, has ambiguous cases
         else { pref = np.steps.size.toString() + "_"; suf = "_"; }  //new way, prevents ambiguous cases
         pref = pref + step.size;
         suf = suf + step;
      }
      return(pref + suf);
   }
   
   getEmitName(NamePath np) String {
      return("BEC_" + mangleName(np));
   }
   
   getFullEmitName(String nameSpace, String emitName) {
       return(nameSpace + "." + emitName);
   }
   
   getNameSpace(String libName) String {
      //return("be." + libEmitName(libName));
      return("be");
   }
   
}

use local class Build:ClassConfig {
   
   new(Build:NamePath _np, EmitCommon _emitter, IO:File:Path _emitPath, String _libName) self {
   
      fields {
         
        Build:NamePath np = _np; //name path for class
        EmitCommon emitter = _emitter; //emitter obj
        IO:File:Path emitPath = _emitPath;
        String libName = _libName;
         
        String nameSpace = emitter.getNameSpace(libName);
        String emitName = emitter.getEmitName(np);
        String fullEmitName = emitter.getFullEmitName(nameSpace, emitName);
        IO:File:Path classPath = emitPath.copy().addStep(emitter.emitLang).addStep("be").addStep(emitName + emitter.fileExt);
        IO:File:Path classDir = classPath.parent; 
        IO:File:Path synPath = classDir.copy().addStep(emitName + ".syn");
      }
   }
   
   relEmitName(String forLibName) String {
      //no longer matters
      //if (libName == forLibName) {
         return(emitName);
      //}
      //return(fullEmitName);
   }

}

