/*
Copyright 2006 Craig Welch
All rights reserved.

Developed by:

    Craig Welch

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal with
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

    * Redistributions of source code must retain the above copyright notice,
      this list of conditions and the following disclaimers.

    * Redistributions in binary form must reproduce the above copyright notice,
      this list of conditions and the following disclaimers in the
      documentation and/or other materials provided with the distribution.

    * Neither the name of the Software nor the names of its contributors may be used 
      to endorse or promote products derived from this Software without specific
      prior written permission.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
CONTRIBUTORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS WITH THE
SOFTWARE.
*/

use Container:Map;
use Container:LinkedList;
use Container:Array;
use Container:Set;
use IO:File;
use Build:VisitError;
use Build:Visit;
use Build:EmitException;
use Build:NamePath;
use Build:Node;
use Text:String;
use Text:String;
use Logic:Bool;
use Math:Int;
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
callHash is the hashcode of the string of the name of the call
callId is the runtime genned callId (guaranteed unique/serial) at lib inits
generated classes override and use hash and id to find and dispatch call
could be that if build.onlyCheckCollisions (or somesuch) true, only the switch/hash is used to find the call and callId
is only used when there is a local collision (possible to dispatch in a case which should go to methodNotDefined, but
avoids conditional check on id) might support an attribute for proxy's to avoid this (do the always check regardless of global)

DYNAMIC CALLS

ONCE EVAL
MANY EVAL

Statically initialize for onceeval literal cases
FASTER if a variable assigned to from a once eval is not assigned to any other time just use the once eval var directly and do no assign

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

use local class Build:EmitCommon(Visit:Visitor) {

    new(Build:Build _build) {
        build = _build;
        properties {
          
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
          String q = Text:Strings.quote;
          
          //The ClassConfig cache
          Map ccCache = Map.new();
          
          //Commonly needed namepaths
          NamePath objectNp = NamePath.new("System:Object");
          NamePath boolNp = NamePath.new("Logic:Bool");
          NamePath intNp = NamePath.new("Math:Int");
          NamePath floatNp = NamePath.new("Math:Float");
          NamePath stringNp = NamePath.new("Text:String");
          
          //Commonly needed values
          
          String trueValue = "be.BELS_Base.BECS_Runtime.boolTrue";
          String falseValue = "be.BELS_Base.BECS_Runtime.boolFalse";
          
          String instanceEqual = " == ";
          String instanceNotEqual = " != ";
          
          //Shared library code genned based on lib contents
          String libEmitName = libEmitName(build.libName);
          String fullLibEmitName = fullLibEmitName(build.libName);
          File:Path libEmitPath = build.emitPath.copy().addStep(self.emitLang).addStep("be").addStep(libEmitName(build.libName)).addStep(libEmitName + fileExt);
          
          String methodBody = String.new();
          Int lastMethodBodySize = 0;
          Int lastMethodBodyLines = 0;
          Array methodCalls = Array.new();
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
          
        }
    }
    
    runtimeInitGet() String {
        return("be.BELS_Base.BECS_Runtime.init();" + nl);
    }
    
    libEmitName(String libName) {
        return("BEL_" + libName.size + "_" + libName);
    }
    
    fullLibEmitName(String libName) { 
        return(libNs(libName) + "." + libEmitName(libName));
    }
    
    getClassConfig(NamePath np) ClassConfig {
      String dname = np.toString();
      ClassConfig toRet = ccCache.get(dname);
      if (undef(toRet)) {
         foreach (Build:Library pack in build.usedLibrarys) {
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
      ("Completing class " + clgen.held.name).print();
      var trans = Build:Transport.new(build, clgen.transUnit);
      
      
      var emvisit;
      
      if (build.printVisitors) {
         ". ".echo();
      }
      emvisit = Visit:Rewind.new();
      emvisit.emitter = self;
      emvisit.build = build;
      trans.traverse(emvisit);
      
      if (build.printVisitors) {
         ".. ".echo();
      }
      emvisit = Visit:TypeCheck.new();
      emvisit.emitter = self;
      emvisit.build = build;
      trans.traverse(emvisit);
      
      if (build.printVisitors) {
         "... ".echo();
      }
      
      ("Begin Emit Visit").print();
      trans.traverse(self);
      ("End Emit Visit").print();
      
      ("Begin Stack Lines").print();
      buildStackLines(clgen);
      ("End Stack Lines").print();
      
   }
   
   doEmit() {
        
        //order by depth (of inheritance) to guarantee that a classes ancestors
        //are processed before the class (important for some initialization)
        Map depthClasses = Map.new();
        for (var ci = build.emitData.parseOrderClassNames.iterator;ci.hasNext;;) { 
            String clName = ci.next;
            
            Node clnode = build.emitData.classes.get(clName);
            
            Int depth = clnode.held.syn.depth;
            Array classes = depthClasses.get(depth);
            if (undef(classes)) {
                classes = Array.new();
                depthClasses.put(depth, classes);
            }
            classes += clnode;
        }
        
        Array depths = Array.new();
        for (ci = depthClasses.keyIterator;ci.hasNext;;) { 
            depth = ci.next;
            depths += depth;
        }
        
        depths = depths.sort();
        properties {
            Array classesInDepthOrder = Array.new();
        }
        foreach (depth in depths) {
            classes = depthClasses.get(depth);
            foreach (clnode in classes) {
                classesInDepthOrder += clnode;
            }
        }
        
        for (ci = classesInDepthOrder.iterator;ci.hasNext;;) {   
        
            clnode = ci.next;
            
            classConf = getLocalClassConfig(clnode.held.namepath);
            ("will emit " + classConf.np + " " + classConf.emitName).print();
            
            complete(clnode);
            
            //open the class output file
            File:Writer cle = getClassOutput();
            
            //gen into the file
            
            String bns = self.beginNs();
            lineCount += countLines(bns);
            cle.write(bns);
            
            //things before the class, after the namespace
            lineCount += countLines(preClass);
            cle.write(preClass);
            
            //class declaration
            String cb = self.classBegin;
            lineCount += countLines(cb);
            cle.write(cb);
            
            //the class level emits
            lineCount += countLines(classEmits);
            cle.write(classEmits);
            
            //the once decs (once-assigns, literals)
            //cle.write(onceDecs);
            lineCount += writeOnceDecs(cle, onceDecs);
            
            //the initial instance
            String idec = self.initialDec;
            lineCount += countLines(idec);
            cle.write(idec);
            
            //properties
            lineCount += countLines(propertyDecs);
            cle.write(propertyDecs);
            
            //need offset of cle so far
            //add to all classCalls nlec s
            //could also output them here
            
            String nlcs = String.new();
            String nlecs = String.new();
            
            Bool firstNlc = true;
            
            Int lastNlc;
            Int lastNlec;
            
            String lineInfo = "/* BEGIN LINEINFO " += nl;
            foreach (Node cc in classCalls) {
                cc.nlec += lineCount;
                cc.nlec++=;
                if (undef(lastNlc) || lastNlc != cc.nlc || lastNlec != cc.nlec) {
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
            
            methods += "//int[] bevs_nlcs = {" += nlcs += "};" += nl;
            methods += "//int[] bevs_nlecs = {" += nlecs += "};" += nl;
            
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
    
   getClassOutput() File:Writer {
       properties {
         Int lineCount = 0.copy();
       }
       if (classConf.classDir.file.exists!) {
            classConf.classDir.file.makeDirs();
        } 
        return(classConf.classPath.file.writer.open());
   }
   
   finishClassOutput(File:Writer cle) {
        cle.close();
   }
    
    getLibOutput() File:Writer {
        return(libEmitPath.file.writer.open())
    }
    
    finishLibOutput(File:Writer libe) {
        libe.close();
    }
    
    klassDecGet() String {
        return("public class ");
    }
    
    spropDecGet() String {
        return("public static ");
    }
    
    overrideSmtdDecGet() String {
        return("");
    }
    
    baseSmtdDecGet() String {
        return("public static ");
    }
    
    baseMtdDecGet() String {
        return("");
    }
    
    overrideMtdDecGet() String {
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
        //main += self.procStart;
        main += maincc.fullEmitName += " mc = new " += maincc.fullEmitName += "();" += nl;
        main += "mc.bem_new_0();" += nl;
        main += "mc.bem_main_0();" += nl;
        main += self.mainEnd;
        
        File:Writer libe = getLibOutput();
        libe.write(self.beginNs());
        String extends = extend("be.BELS_Base.BECS_Lib");
        libe.write(self.klassDec + libEmitName + extends + "  {" + nl);
        libe.write(self.spropDec + self.boolType + " isInitted = false;" + nl);
        
        String initLibs = String.new();
        foreach (Build:Library bl in build.usedLibrarys) {
            //bl.libName
            initLibs += fullLibEmitName(bl.libName) += ".init();" += nl;
        }
        
        String typeInstances = String.new();
        String notNullInitConstruct = String.new();
        String notNullInitDefault = String.new();
        for (var ci = classesInDepthOrder.iterator;ci.hasNext;;) {  
        
            var clnode = ci.next;
            
            if(emitting("jv")) {
                typeInstances += "be.BELS_Base.BECS_Runtime.typeInstances.put(" += q += clnode.held.namepath.toString() += q += ", Class.forName(" += q += getClassConfig(clnode.held.namepath).fullEmitName += q += "));" += nl;
            }
            if(emitting("cs")) {
                typeInstances += "be.BELS_Base.BECS_Runtime.typeInstances[" += q += clnode.held.namepath.toString() += q += "] = typeof(" += getClassConfig(clnode.held.namepath).relEmitName(build.libName) += ");" += nl;
                typeInstances += "typeof(" += getClassConfig(clnode.held.namepath).relEmitName(build.libName) += ")";
                typeInstances += ".GetField(" += q += "bevs_inst" += q += ").GetValue(null);" += nl;
            }
            
            if (clnode.held.syn.hasDefault) {
                String nc = "new " + getClassConfig(clnode.held.namepath).relEmitName(build.libName) + "()";
                notNullInitConstruct += "be.BELS_Base.BECS_Runtime.initializer.bem_notNullInitConstruct_1(" += nc += ");" += nl;
                notNullInitDefault += "be.BELS_Base.BECS_Runtime.initializer.bem_notNullInitDefault_1(" += nc += ");" += nl;
            }
        }
        
        foreach (String callName in callNames) {
            libe.write(self.spropDec + "int bevn_" + callName + ";" + nl;);
            getNames += "bevn_" += callName += " = getCallId(" += q += callName += q += ");" += nl;
        }
        libe.write(self.baseSmtdDec + "void init()" += exceptDec += " {" + nl);
        if(emitting("jv")) {
          libe.write("synchronized (" + libEmitName + ".class) {" + nl);//}
        } elif(emitting("cs")) {
          libe.write("lock (typeof(" + libEmitName + ")) {" + nl);//}
        }
        libe.write("if (isInitted) { return; }" + nl;);
        libe.write("isInitted = true;" + nl);
        libe.write(self.runtimeInit);
        libe.write(getNames);
        libe.write(initLibs);
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
    
    procStartGet() String {
        return("(new be.BEL_4_Base.BEC_6_7_SystemProcess()).bem_default_0();" + nl);
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
      properties {
         String methods = String.new();
         Array classCalls = Array.new();
         Int lastMethodsSize = 0;
         Int lastMethodsLines = 0;
      }
   }
   
   nameForVar(Build:Var v) String {
   
      String prefix;
      if (v.isTmpVar) {
        prefix = "bevt_";
      } elif (v.isProperty) {
        prefix = "bevp_";
      } elif (v.isArg) {
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
   
  acceptMethod(Node node) {
      properties {
        Node mnode = node;
        ClassConfig returnType = null;
        Build:MtdSyn msyn;
      }
      msyn = csyn.mtdMap.get(node.held.name);
      
      callNames.put(node.held.name);
      
      String argDecs = String.new();
      String varDecs = String.new();
      
      Bool isFirstArg = true;
      foreach (Node ov in node.held.orderedVars) {
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
                decForVar(varDecs, ov.held);
                if(emitting("js")) {
                    varDecs += ";" += nl;
                } else  {
                    varDecs += " = null;" += nl;
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
         String mtdDec = self.baseMtdDec;
      } else {
         mtdDec = self.overrideMtdDec;
      }
      
      startMethod(mtdDec, returnType, emitNameForMethod(node), argDecs, exceptDec);
      
      methods += varDecs;
      
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
     properties {
        String preClass = String.new();
        String classEmits = String.new();
        String onceDecs = String.new();
        Int onceCount = 0;
        String propertyDecs = String.new();
        Node cnode = node;
        Build:ClassSyn csyn = node.held.syn;
        String dynMethods = String.new();
        String ccMethods = String.new();
        Array superCalls = Array.new();
        Int nativeCSlots = 0;
        String inFilePathed = node.held.fromFile.toStringWithSeparator("/");
     }
     
     var te = node.transUnit.held.emits;
      if (def(te)) {
         for (te = te.iterator;te.hasNext;;) {
            var jn = te.next;
            if (jn.held.langs.has(self.emitLang)) {
                preClass += jn.held.text;
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
          foreach (Node innode in node.held.emits) {
            //figure out what vars are native
            nativeCSlots = getNativeCSlots(innode.held.text);
            if (innode.held.langs.has(inlang)) {
                classEmits += innode.held.text;
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
       for (var ii = node.held.orderedVars.iterator;ii.hasNext;;) {
            var i = ii.next.held;
            if (i.isDeclared) {
                if (ovcount >= nativeCSlots) {
                    propertyDecs += self.propDec;
                    decForVar(propertyDecs, i);
                    propertyDecs += ";" += nl;
                }
                ovcount = ovcount++;
            }
        }
        
      //Its not clear how mtdlist ends up, so just use the map
      Map dynGen = Map.new();
      Container:Set mq = Container:Set.new();
      foreach (Build:MtdSyn msyn in csyn.mtdList) {
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
                Int msh = msyn.name.hash;
                Array dgv = dgm.get(msh);
                if (undef(dgv)) {
                    dgv = Array.new();
                    dgm.put(msh, dgv); 
                }
                dgv.addValue(msyn);
                //("Added dynGen " + msyn.name + " to dynGen numargs " + numargs).print();
              }
          }
      }
      
      foreach (Container:Map:MapNode dnode in dynGen) {
        Int dnumargs = dnode.key;
        
        if (dnumargs < maxDynArgs) {
            String dmname = "bemd_" + dnumargs.toString();
        } else {
            dmname = "bemd_x";
        }
        String superArgs = "callHash, callId";
        String args = "int callHash, int callId";
        Int j = 1;
        while (j < (dnumargs + 1) && j < maxDynArgs) {
            args = args + ", " + objectCc.relEmitName(build.libName) + " bevd_" + (j - 1);
            superArgs = superArgs + ", " + "bevd_" + (j - 1);
            j = j++;
        }
        if (dnumargs >= maxDynArgs) {
            args = args + ", " + objectCc.relEmitName(build.libName) + "[] bevd_x";
            superArgs = superArgs + ", bevd_x";
        }
        dynMethods += self.overrideMtdDec += objectCc.relEmitName(build.libName) += " " += dmname += "(" += args += ")" += exceptDec += " {" += nl;  //}
        dynMethods += "switch (callHash) {" += nl; //}
        
        dgm = dnode.value;
        foreach (Container:Map:MapNode msnode in dgm) {
            Int thisHash = msnode.key;
            dgv = msnode.value;
            dynMethods += "case " += thisHash.toString() += ": ";
            //do we output if checks against call id for this dmname (this dynamic method)?
            //yes if turned on globally (to avoid possible cases of missing calls beings serviced anyway (very unlikely)
            //or if > 1 entry for this same hash code (have to in that case)
            if (dynConditionsAll || dgv.size > 1) {
                Bool dynConditions = true;
            } else {
                dynConditions = false;
            }
            foreach (msyn in dgv) {
                String mcall = String.new();
                if (dynConditions) {
                    String constName = libEmitName + ".bevn_" + msyn.name;
                    mcall += "if (callId == " += constName += ") {" += nl; //}
                } 
                mcall += "return bem_" += msyn.name += "(";
                Int vnumargs = 0;
                foreach (Build:VarSyn vsyn in msyn.argSyns) {
                    if (vnumargs > 0) {
                        if (vsyn.isTyped && vsyn.namepath != objectNp) {
                            String vcast = formCast(getClassConfig(vsyn.namepath)) + " "; //no need for type check here, but need to check types of args somehow (flag for dynamic call? precall check structure? make it free where check not needed)
                        } else {
                            vcast = "";
                        }
                        if (vnumargs > 1) {
                            String vcma = ", ";
                        } else {
                            vcma = "";
                        }
                        if (vnumargs < maxDynArgs) {
                            String varg = "bevd_" + (vnumargs - 1);
                        } else {
                            varg = "bevd_x[" + (vnumargs - maxDynArgs) + "]";
                        }
                        mcall += vcma += vcast += varg;
                    }
                    vnumargs = vnumargs++;
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
        dynMethods += "return " + self.superName + "." += dmname += "(" += superArgs += ");" += nl; 
        dynMethods += "}" += nl; //end of method for this argnum
      }
      
      buildClassInfo();
      
      buildCreate();
      
      buildInitial();
      
      //("dynMethods:" + nl + dynMethods.toString() + nl).print();
      
      
  }
  
  getNativeCSlots(String text) Int {
    Int nativeSlots = 0;
    var ll = text.split("/");
      var isfn = false;
      var nextIsNativeSlots = false;
      foreach (var i in ll) {
         if (nextIsNativeSlots) {
            nextIsNativeSlots = false;
            nativeSlots = Int.new(i);
            isfn = true;
         } elif (i == "*-attr- -firstSlotNative-*") {
            isfn = true;
            nativeSlots = 1;
         } elif (i == "*-attr- -nativeSlots") {
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
                String vcast = formCast(classConf);//no need for type check
            } else {
                vcast = "";
            }
            
            ccMethods += stinst += " = " += vcast += "becc_inst;" += nl;
        //{
        ccMethods += "}" += nl;
        
        
        ccMethods += self.overrideMtdDec += oname += " bemc_getInitial()" += exceptDec += " {" += nl;  //}
            
            ccMethods += "return " += stinst += ";" += nl;
        //{
        ccMethods += "}" += nl;
        
    }

buildClassInfo() self {
    buildClassInfo("clname", cnode.held.namepath.toString());
    buildClassInfo("clfile", inFilePathed);
}
 
buildClassInfo(String belsBase, String lival) self {
    
    String belsName = "becc_" + belsBase;
    
    String sdec = String.new();
    lstringStart(sdec, belsName);
      
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
    
    buildClassInfoMethod(belsBase);

}

buildClassInfoMethod(String belsBase) {
    ccMethods += self.overrideMtdDec += "byte[] bemc_" += belsBase += "()" += exceptDec += " {" += nl;  //}
    ccMethods += "return becc_" += belsBase += ";" += nl;
    //{
    ccMethods += "}" += nl;
}

  initialDecGet() String {
       
       String initialDec = String.new();
       
       if (csyn.namepath == objectNp) {
          initialDec += baseSpropDec(classConf.emitName, "bevs_inst") += ";" += nl;
       } else {
          initialDec += overrideSpropDec(classConf.emitName, "bevs_inst") += ";" += nl;
       }
       
       return(initialDec);
  }
  
  classBeginGet() String {
       if (def(parentConf)) {
          String extends = extend(parentConf.relEmitName(build.libName));
       } else {
          extends = extend("be.BELS_Base.BECS_Object");
       }
       String clb = "/* File: " += inFilePathed += " */" += nl;
       clb += self.klassDec += classConf.emitName += extends += " {" += nl; //}
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
      
  baseSpropDec(String typeName, String varName) {
     return("public static " + typeName + " " + varName);
  }
  
    onceDec(String typeName, String varName) {
        return("");
    }
  
  
  overrideSpropDec(String typeName, String varName) {
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
        var nct = node.container.container;
        var typename = nct.typename;
        if (typename == ntypes.METHOD) {
           if (def(mnode)) {
             if (undef(lastCall) || lastCall.held.orgName != "return") {
                //what about return_1, return_2?
                //TODO check for types in case not ok for self return
                methodBody += "return this;" += nl;//default self return
             }
             
             if (maxSpillArgsLen > 0) {
                methods += objectCc.relEmitName(build.libName) += "[] bevd_x = new " += objectCc.relEmitName(build.libName) += "[" += maxSpillArgsLen.toString() += "];" += nl;
             }
             
             Int methodsOffset = countLines(methods, lastMethodsSize);
             methodsOffset += lastMethodsLines;
             lastMethodsLines = methodsOffset;
             lastMethodsSize = methods.size;
             
             //get methods offset, go through calls in body, add offset, move body calls to class calls
             //Int methodsOffset = countLines(methods);
             foreach (Node mc in methodCalls) {
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
        } elif (typename != ntypes.EXPR && typename != ntypes.PROPERTIES && typename != ntypes.CLASS) {
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
    Int slen = text.size;
    for (Int i = start;i < slen;i++=;) {
      text.getInt(i, cursor);
      if (cursor == nlval) {
        found++=;
      }
    }
    return(found);
  }
  
  acceptIf(Node node) {
         String targs = formTarg(node.contained.first.contained.first);
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
            //ev += targs += " != null && " += targs += ".bevi_bool";
            ev += targs += ".bevi_bool";
         } else {
            //TODO FASTER could drop instof check - this is here now for harmony with c - would change behavior (obviously)
            //TODO FASTER (a little), after default is complete, the null check should not be unneeded anymore for harmony
            //but also make faster for the 99% cases, and these things can be explicitely checked for when needed
            ev += targs += " != null && " += targs += instOf += boolCc.relEmitName(build.libName) += " && ";
            if (emitting("js")!) {
                ev += "(" += formCast(boolCc); //no need for type check
            }
            ev += targs;
            if (emitting("js")!) {
                ev += ")";
            }
            ev += ".bevi_bool";
         }
         if (isUnless) {
            ev += ")";
         }
         methodBody += "if (" += ev += ")";
   }
  
  oldacceptIf(Node node) {
         //True is object equivalence to the "true instance", false is everything else
         String targs = formTarg(node.contained.first.contained.first);
         if (def(node.held) && node.held == "unless") {
            cexpr = instanceNotEqual;
         } else {
            String cexpr = instanceEqual;
         }
         methodBody += "if (" += trueValue += cexpr += targs += ")";
   }
   
   acceptCatch(Node node) {
   }
   
   finalAssign(Node node, String sFrom, NamePath castTo) String {
      return(finalAssignTo(node, castTo) + sFrom + ";" + nl);
   }
   
   //do type check for finalAssignTo usage and for untyped calls (with precheck)
   finalAssignTo(Node node, NamePath castTo) String {
      if (node.typename == ntypes.NULL) {
         throw(VisitError.new("Cannot assign to literal null"));
      }
      if (node.held.name == "self") {
         throw(VisitError.new("Cannot assign to self"));
      }
      if (node.held.name == "super") {
         throw(VisitError.new("Cannot assign to super"));
      }
      String cast = "";
      if (def(castTo)) {
        cast = formCast(getClassConfig(castTo)) + " ";//no need for type check
      }
      return(nameForVar(node.held) + " = " + cast);
   }
   
   superNameGet() String {
       return("super");
    }
   
   formCast(ClassConfig cc) String { //no need for type check
        return("(" + cc.relEmitName(build.libName) + ")");
   }
   
    acceptThrow(Node node) {
        methodBody += "throw new be.BELS_Base.BECS_ThrowBack(" += formTarg(node.second) += ");" += nl;
    }
    
    onceVarDec(String count) String {
        return("bevo_" + count);
    }
   
   acceptCall(Node node) {
   
      callNames.put(node.held.name);
   
      lastCall = node;
      
      methodCalls += node;
      
      //offset of method body, put into node.nlec
      
      Int moreLines = countLines(methodBody, lastMethodBodySize);
      lastMethodBodyLines = lastMethodBodyLines + moreLines;
      lastMethodBodySize = methodBody.size;
      
      node.nlec = lastMethodBodyLines;
      //node.nlec = countLines(methodBody);
      
      if ((node.held.orgName == "assign") && (node.contained.length != 2)) {
         var errmsg = "assignment call with incorrect number of arguments " + node.contained.length.toString();
         for (Int ei = 0;ei < node.contained.length;ei = ei++) {
            errmsg = errmsg + " !!!" + ei + "!! " + node.contained[ei];
         }
         throw(VisitError.new(errmsg, node));
      } elif ((node.held.orgName == "assign") && (node.contained.first.held.name == "self")) {
         throw(VisitError.new("self cannot be assigned to", node));
      } elif (node.held.orgName == "throw") {
         acceptThrow(node);
         return(self);
      } elif (node.held.orgName == "assign") {
         NamePath castTo;
         //FASTER (possibly), for self type do /fast (unchecked) casts/ where possible (not ret self), do the check for correctness in
         //the method instead of at assign and only if not returning "self" (do same type check)
         if (node.held.checkTypes) {
            castTo = node.contained.first.held.namepath;
         }
         if (node.second.typename == ntypes.VAR) {
            //node.held.checkTypes (for casting needed) (legacy became checkAssignTypes)
            methodBody += finalAssign(node.contained.first, formTarg(node.second), castTo);
         } elif (node.second.typename == ntypes.NULL) {
            methodBody += finalAssign(node.contained.first, "null", null);
         } elif (node.second.typename == ntypes.TRUE) {
            methodBody += finalAssign(node.contained.first, trueValue, castTo);
         } elif (node.second.typename == ntypes.FALSE) {
            methodBody += finalAssign(node.contained.first, falseValue, castTo);
         } elif (node.second.held.name == "undef_1" || node.second.held.name == "undefined_1" ||
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
            methodBody += "if (" += formTarg(node.second.second) += " == null) {" += nl;
            methodBody += finalAssign(node.contained.first, nullRes, null);
            methodBody += " } else { " += nl;
            methodBody += finalAssign(node.contained.first, notNullRes, null);
            methodBody += "}" += nl;  
         }
         return(self);
      } elif (node.held.orgName == "return") {
        //node.held.checkTypes for casting, rsub.held.rtype.isSelf for self type 
        String returnCast = "";
        if (node.held.checkTypes) {
            returnCast = formCast(returnType) + " "; //do type check
        }
        methodBody += "return " += returnCast += formTarg(node.second) += ";" += nl; //first is self
        return(self);
      } elif (node.held.name == "def_1" || node.held.name == "defined_1" || node.held.name == "undef_1" || node.held.name == "undefined_1") {
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

      if (node.held.isConstruct) {
         isConstruct = true;
         ClassConfig newcc = getClassConfig(node.held.newNp);
      } elif (node.contained.first.held.name == "self") {
         selfCall = true;
      } elif (node.contained.first.held.name == "super") {
         selfCall = true;
         superCall = true;
         superCalls += node;
         node.held.superCall = true;
      }
      //node.held.checkTypes
      
      //prepare args
      String callArgs = String.new();
      String spillArgs = String.new();
      
      Int numargs = 0;
      for (var it = node.contained.iterator;it.hasNext;;) {
         Array argCasts = node.held.argCasts;
         var i = it.next;
         if (numargs == 0) {
            //var targetOrg = i.held.name;
            String target = formTarg(i);
            Node targetNode = i;
            if (targetNode.held.isTyped) {
                isTyped = true;
            }
         } else {
            if (isTyped || numargs < maxDynArgs || self.useDynMethods!) {
                if (numargs > 1) {
                    callArgs += ", ";
                }
                if (argCasts.length > numargs && def(argCasts.get(numargs))) {
                    callArgs += formCast(getClassConfig(argCasts.get(numargs))) += " "; //do type check
                }
                callArgs += formTarg(i);
            } else {
                //put into call array
                Int spillArgPos = numargs - maxDynArgs;//spill arg array index
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
      
      //Prepare Assignment
      if ((node.container.typename == ntypes.CALL) && (node.container.held.orgName == "assign")) {
        if (isOnceAssign(node.container) && ((isConstruct && newcc.np == boolNp)!)) {
            isOnce = true;
            String ovar = onceVarDec(onceCount.toString());
            onceCount = onceCount++;
            
            if (node.container.contained.first.held.isTyped!) {
               String odec = onceDec(objectCc.relEmitName(build.libName), ovar);
            } else {
               odec = onceDec(getClassConfig(node.container.contained.first.held.namepath).relEmitName(build.libName), ovar);
            }
            
        }
        //node.container.held.checkTypes
        if (node.container.held.checkTypes) {
            //("assign casting").print();
            castTo = node.container.contained.first.held.namepath;
         }
        String callAssign = finalAssignTo(node.container.contained.first, castTo);
      } else {
        callAssign = "";
      }
      
      if (isOnce) {
        //no cast for the post assign, the ovar is always typed based on the type assigned to, so the case when assigning to ovar 
        //is all that's needed and the ovar is always the same type as the assign to target
        String postOnceCallAssign = nameForVar(node.container.contained.first.held) + " = " + ovar + ";" + nl;
        if (def(castTo)) {
           String cast = formCast(getClassConfig(castTo)) + " "; //do type check
        } else {
           cast = "";
        }
        callAssign = ovar + " = " + cast;
      }
      
      //also did include  && odec.isEmpty!
      if ((isTyped || self.useDynMethods!) && isConstruct && node.held.isLiteral && isOnce) {
       onceDeced = true;
      } elif (isOnce) {
        //add flag for warning option later on
        //("!!!Found once not deced for node " + node).print();
        if(emitting("jv")) {
          methodBody += "synchronized (" += classConf.emitName += ".class) {" += nl;//}
        } elif(emitting("cs")) {
          methodBody += "lock (typeof(" += classConf.emitName += ")) {" += nl;//}
        }
        methodBody += "if (" + ovar + " == null) {" += nl; //}
      }
      
      //FASTER if undef or def is inside an if skip the assign and just put it into the if
      //FASTER no-call get and set where possible (typed, lib/final, closelib)
      if (isTyped || self.useDynMethods!) {     
          if (isConstruct) {
                if (node.held.isLiteral) {
                    if (newcc.np == intNp) {
                        newCall = lintConstruct(newcc, node);
                    } elif (newcc.np == floatNp) {
                        newCall = lfloatConstruct(newcc, node);
                    } elif (newcc.np == stringNp) {
                        
                        String belsName = "bels_" + cnode.held.belsCount.toString();
                        cnode.held.belsCount++=;
                        String sdec = String.new();
                        lstringStart(sdec, belsName);
                        
                        String liorg = node.held.literalValue;
                      
                          if (node.wideString) {
                            String lival = liorg;
                          } else {
                            lival = Json:Unmarshaller.new().unmarshall("[" + Text:Strings.quote + liorg + Text:Strings.quote + "]").first;
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
                    } elif (newcc.np == boolNp) {
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
                    String newCall = "new " + newcc.relEmitName(build.libName) + "()";
                }
                target = "(" + newCall + ")";
                
                String stinst = getInitialInst(newcc);
                
                if (node.held.isLiteral) {
                    if (newcc.np == boolNp) {
                        if (onceDeced) {
                          String odinfo = String.new();
                          foreach (var kv in node.container.contained.first.held.allCalls) {
                            odinfo += kv.key.held.name += " ";
                          }
                          throw(System:Exception.new("oh noes once deced " + 
                          odinfo));
                        }
                        if (node.held.literalValue == "true") {
                            target = trueValue;
                        } else {
                            target = falseValue;
                        }
                    }
                    if (onceDeced) {
                        onceDecs += odec += callAssign += target += ";" += nl;
                    } else {
                        methodBody += callAssign += target += ";" += nl;
                    }
                } else {
                    Build:ClassSyn asyn = build.getSynNp(newcc.np);
                    if (asyn.hasDefault) {
                        methodBody += callAssign += stinst += "." += emitNameForCall(node) += "(" += callArgs += ");" += nl;
                    } else {
                        methodBody += callAssign += target += "." += emitNameForCall(node) += "(" += callArgs += ");" += nl;
                    }
                }
          } else {
            if (isTyped!) {
                methodBody += callAssign += target += "." += emitNameForCall(node) += "(" += callArgs += ");" += nl;
            } else {
                methodBody += callAssign += target += "." += emitNameForCall(node) += "(" += callArgs += ");" += nl;
            }
          }
      } else {
        if (numargs < maxDynArgs) {
            String dm = numargs.toString();
            String callArgSpill = "";
        } else {
            dm = "x";
            Int spillArgsLen = numargs - maxDynArgs + 1;
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
        methodBody += callAssign += target += ".bemd_" += dm += "(" += node.held.name.hash.toString() += ", " += libEmitName += ".bevn_" += node.held.name += fc += callArgs += callArgSpill += ");" += nl;
      }
      
      if (isOnce) {
        if (onceDeced!) {
            //{
            methodBody += "}" += nl; //close to check for ovar null
            if(emitting("jv") || emitting("cs")) {
              //{
              methodBody += "}" += nl; //close the synchronized or lock on class
            }
        }
        methodBody += postOnceCallAssign;
        if (onceDeced!) {
            if (odec.isEmpty!) {
                onceDecs += odec += ovar += ";" += nl;
            }
        }
      }
   
   }
   
   doInitializeIt(String nc) String {
    String ii = "(";
    if(emitting("js")) {
        ii += "be_BELS_Base_BECS_Runtime.prototype.initializer.bem_initializeIt_1(" += nc += ")";
    } else {
        ii += "be.BELS_Base.BECS_Runtime.initializer.bem_initializeIt_1(" += nc += ")";
    }
    ii += ")";
    return(ii);
   }
   
   getInitialInst(ClassConfig newcc) String {
    return(newcc.relEmitName(build.libName) + ".bevs_inst");
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
        methodBody += node.held.text;
     }
   }
   
   acceptIfEmit(Node node) {
      if (node.held.langs.has(self.emitLang)!) {
        return(node.nextPeer);
      }
      return(node.nextDescend);
   }
      
   accept(Node node) Node {
      if (node.typename == ntypes.CLASS) {
         acceptClass(node);
      } elif (node.typename == ntypes.METHOD) {
         acceptMethod(node);
      } elif (node.typename == ntypes.RBRACES) {
         acceptRbraces(node);
      } elif (node.typename == ntypes.EMIT) {
         acceptEmit(node);
      } elif (node.typename == ntypes.IFEMIT) {
         addStackLines(node);
         return(acceptIfEmit(node));
      } elif (node.typename == ntypes.CALL) {
         acceptCall(node);
      } elif (node.typename == ntypes.BRACES) {
        acceptBraces(node);
      } elif (node.typename == ntypes.BREAK) {
         methodBody += "break;" += nl;
      } elif (node.typename == ntypes.LOOP) {
         methodBody += "while (true)" += nl;
      } elif (node.typename == ntypes.ELSE) {
         methodBody += " else ";
      } elif (node.typename == ntypes.TRY) {
         methodBody += "try ";
      } elif (node.typename == ntypes.CATCH) {
         acceptCatch(node);
      } elif (node.typename == ntypes.IF) {
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
      } elif (node.held.name == "self") {
         tcall = "this";
      } elif (node.held.name == "super") {
         tcall = self.superName;
      } else {
         tcall = nameForVar(node.held);
      }
      return(tcall);
   }
   
   formRTarg(Node node) String {
      String tcall;
      if (node.typename == ntypes.NULL) {
         tcall = "null";
      } elif (node.held.name == "self") {
         tcall = "this";
      } elif (node.held.name == "super") {
         tcall = self.superName;
      } else {
         tcall = nameForVar(node.held);
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
    
    //Does this emit lang support covariant return types
    covariantReturnsGet() {
        return(true);
    }
    
    mangleName(NamePath np) String {
      String pref = "";
      String suf = "";
      foreach (String step in np.steps) {
         if (pref != "") { pref = pref + "_"; }
         else { suf = "_"; }
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
      return("be." + libEmitName(libName));
   }
   
}

use local class Build:ClassConfig {
   
   new(Build:NamePath _np, EmitCommon _emitter, File:Path _emitPath, String _libName) self {
   
      properties {
         
        Build:NamePath np = _np; //name path for class
        EmitCommon emitter = _emitter; //emitter obj
        File:Path emitPath = _emitPath;
        String libName = _libName;
         
        String nameSpace = emitter.getNameSpace(libName);
        String emitName = emitter.getEmitName(np);
        String fullEmitName = emitter.getFullEmitName(nameSpace, emitName);
        File:Path classPath = emitPath.copy().addStep(emitter.emitLang).addStep("be").addStep(emitter.libEmitName(libName)).addStep(emitName + emitter.fileExt);
        File:Path classDir = classPath.parent; 
        File:Path synPath = classDir.copy().addStep(emitName + ".syn");
      }
   }
   
   relEmitName(String forLibName) {
      if (libName == forLibName) {
         return(emitName);
      }
      return(fullEmitName);
   }

}

