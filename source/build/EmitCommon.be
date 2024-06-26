/*
 * Copyright (c) 2015-2023, the Beysant Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

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
callId is the random code genned at link time for the call
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
          
          IO:File:Path idToNamePath = build.emitPath.copy().addStep(self.emitLang).addStep("be").addStep(libEmitName + "_itn.ids");
          
          IO:File:Path nameToIdPath = build.emitPath.copy().addStep(self.emitLang).addStep("be").addStep(libEmitName + "_nti.ids");
          
          String methodBody = String.new();
          Int lastMethodBodySize = 0;
          Int lastMethodBodyLines = 0;
          List methodCalls = List.new();
          Int methodCatch = 0;
          
          Int maxDynArgs = 8; //was 2
          Int maxSpillArgsLen = 0;
          
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
          Build:Class inClass;
        }

        slots {
          Bool ccHs = false;
          Bool ccSs = false;
        }
        if (build.emitChecks.has("ccHs")) {
          ccHs = true;
        }
        if (build.emitChecks.has("ccSs")) {
          ccSs = true;
        }
        
        if (build.saveIds) {
          loadIds();
        }
        
        if (def(build.loadIds)) {
          for (String loadPref in build.loadIds) {
            loadIds(loadPref);
          }
        }
    }
    
    loadIds(String loadPref) {
      loadIdsInner(loadPref, "_itn.ids", idToName);
      loadIdsInner(loadPref, "_nti.ids", nameToId);
    }
    
    loadIdsInner(String loadPref, String loadEnd, Map addto) {
       IO:File:Path synEmitPath = IO:File:Path.apNew(loadPref + loadEnd);
       ("Loading Ids " + synEmitPath).print();
       Time:Interval sst = Time:Interval.now();
       IO:File:Reader syne = synEmitPath.file.reader.open()
       Map scls = System:Serializer.new().deserialize(syne);
       syne.close();
       addto += scls;
       Time:Interval sse = Time:Interval.now() - sst;
       ("Loading Ids took " + sse).print();
     }
    
    runtimeInitGet() String {
        return("be.BECS_Runtime.init();" + nl);
    }
    
    libEmitName(String libName) {
        //return("BEX_E");
        return("BEL_" + libName);
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
         ". ".output();
      }
      emvisit = Build:Visit:Rewind.new();
      emvisit.emitter = self;
      emvisit.build = build;
      trans.traverse(emvisit);
      
      if (build.printSteps) {
         ".. ".output();
      }
      emvisit = Build:Visit:TypeCheck.new();
      emvisit.emitter = self;
      emvisit.build = build;
      trans.traverse(emvisit);
      
      if (build.printSteps) {
         "... ".output();
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
   
   preClassOutput() { }
   
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
            
            inClass = clnode.held;
            
            //open the class output file, TODO could check writes, clear it here (for incr)
            
            preClassOutput();
            
            IO:File:Writer cle = getClassOutput();
            
            startClassOutput(cle);
            
            writeBET();
            
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
            String idec = self.initialDec + "\n" + self.typeDec + "\n";
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
                cc.nlec++;
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
            
            if(emitting("cc")) {
              nlcNName = getClassConfig(clnode.held.namepath).relEmitName(build.libName) + "::";
            } else {
              String nlcNName = getClassConfig(clnode.held.namepath).relEmitName(build.libName) + ".";
            }
            
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
              unless (build.emitChecks.has("noSmap")) {
                methods += smpref += "bevs_smnlc";
                methods += " = [" += nlcs += "];" += nl;
              }
            }
            if(emitting("cc")) {
               //header too
               unless (build.emitChecks.has("noSmap")) {
                 methods += "std::vector<int32_t> " += classConf.emitName += "::bevs_smnlc" += nl;
                 methods += " = {" += nlcs += "};" += nl;
               }
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
              unless (build.emitChecks.has("noSmap")) {
                methods += smpref += "bevs_smnlec";
                methods += " = [" += nlecs += "];" += nl;
              }
            }
            if(emitting("cc")) {
               //header too
               unless (build.emitChecks.has("noSmap")) {
                methods += "std::vector<int32_t> " += classConf.emitName += "::bevs_smnlec" += nl;
                methods += " = {" += nlecs += "};" += nl;
              }
            }
            
            unless (build.emitChecks.has("noSmap")) {
            methods += lineInfo;
            }
            
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
    
    writeBET() {
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
   
   startClassOutput(IO:File:Writer cle) {
   
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
    
    saveIds() {
        "Saving Ids".print();
        Time:Interval sst = Time:Interval.now();
        IO:File:Writer idf;
        
        idf = nameToIdPath.file.writer.open()
        System:Serializer.new().serialize(nameToId, idf);
        idf.close();
        
        idf = idToNamePath.file.writer.open()
        System:Serializer.new().serialize(idToName, idf);
        idf.close();
        
        Time:Interval sse = Time:Interval.now() - sst;
        ("Saving Ids took " + sse).print();
    }
    
    loadIds() {
        "Loading Ids".print();
        Time:Interval sst = Time:Interval.now();
        IO:File:Reader idf;
        
        if (nameToIdPath.file.exists) {
          idf = nameToIdPath.file.reader.open();
          nameToId = System:Serializer.new().deserialize(idf);
          idf.close();
        }
        
        if (idToNamePath.file.exists) {
          idf = idToNamePath.file.reader.open();
          idToName = System:Serializer.new().deserialize(idf);
          idf.close();
        }
        
        Time:Interval sse = Time:Interval.now() - sst;
        ("Loading Ids took " + sse).print();
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
        if(emitting("cc")) {
          if (build.emitChecks.has("relocMain")) {
            main += "int bems_relocMain(int argc, char **argv) {" += nl;
          } else {
            main += "int main(int argc, char **argv) {" += nl;
          }
          //main += "be.BECS_Runtime.args = args;" += nl;
          main += "be::BECS_Runtime::platformName = std::string(\"" += build.outputPlatform.name += "\");" += nl;
          main += "be::BECS_Runtime::argc = argc;" += nl;
          main += "be::BECS_Runtime::argv = argv;" += nl;
          main += "be::BECS_Runtime::bemg_beginThread();" += nl;
          main += "be::" + libEmitName + "::init();" += nl;
          main += "be::" += maincc.emitName += "* mc = new be::" += maincc.emitName += "();" += nl;
          main += "be::BECS_Runtime::maino = mc;" += nl;
          main += "mc->bem_new_0();" += nl;
          main += "mc->bem_main_0();" += nl;
          unless (build.emitChecks.has("holdMain")) {
            main += "be::BECS_Runtime::bemg_endThread();" += nl;
          }
          main += "return 0;" += nl;
          main += "}\n";
        } else {
          main += self.mainStart;
          main += fullLibEmitName += ".init();" += nl;
          main += maincc.fullEmitName += " mc = new " += maincc.fullEmitName += "();" += nl;
          main += "mc.bem_new_0();" += nl;
          main += "mc.bem_main_0();" += nl;
          main += self.mainEnd;
        }
        
        if (build.saveSyns) {
          saveSyns();
        }
        
        IO:File:Writer libe = getLibOutput();
          
        unless(emitting("cc")) {
        
          libe.write(self.beginNs());
          if (emitting("sw")) {
            extends = extend("BECS_Lib");
          } else {            
            String extends = extend("be.BECS_Lib");
          }
          libe.write(self.klassDec(true) + libEmitName + extends + "  {" + nl); //}
          
        }
        
        String notNullInitConstruct = String.new();
        String notNullInitDefault = String.new();
        
        if(emitting("cc")) {
          String initRef = "BECS_Runtime::initializer->";
        } else {
          initRef = "be.BECS_Runtime.initializer.";
        }
        
        for (any ci = classesInDepthOrder.iterator;ci.hasNext;;) {
        
            any clnode = ci.next;
            
            if (def(clnode.held.extends)) {
              Build:ClassSyn psyn = build.getSynNp(clnode.held.extends);
              String pti = getTypeInst(getClassConfig(psyn.namepath));
            }
            
            if (clnode.held.syn.hasDefault) {
                if(emitting("cc")) {
                  nc = "new " + getClassConfig(clnode.held.namepath).relEmitName(build.libName) + "()";
                //} elseIf (emitting("js")) {
                //  nc = "Object.create(" + getClassConfig(clnode.held.namepath).relEmitName(build.libName) + ")";
                } else {
                  String nc = "new " + getClassConfig(clnode.held.namepath).relEmitName(build.libName) + "()";
                }
                notNullInitConstruct += initRef += "bem_notNullInitConstruct_1(" += nc += ");" += nl;
                notNullInitDefault += initRef += "bem_notNullInitDefault_1(" += nc += ");" += nl;
            }
            
            unless(emitting("cc")) {
              notNullInitConstruct += getTypeInst(getClassConfig(clnode.held.namepath)) += " = new " += getClassConfig(clnode.held.namepath).typeEmitName += "();\n";
            }
            if(emitting("cs")) {
              notNullInitConstruct += "be.BECS_Runtime.typeRefs[" += q += clnode.held.namepath += q += "] = " += getTypeInst(getClassConfig(clnode.held.namepath)) += ";\n";
            } elseIf(emitting("jv")) {
              notNullInitConstruct += "be.BECS_Runtime.typeRefs.put(" += q += clnode.held.namepath += q += ", " += getTypeInst(getClassConfig(clnode.held.namepath)) += ");\n";
            } elseIf(emitting("cc")) {
              unless (build.emitChecks.has("noRfl") && clnode.held.syn.hasDefault!) {
                notNullInitConstruct += "BECS_Runtime::typeRefs[" += q += clnode.held.namepath += q += "] = static_cast<BETS_Object*>   (&" += getTypeInst(getClassConfig(clnode.held.namepath)) += ");\n";
                if (def(pti)) {
                  notNullInitConstruct += getTypeInst(getClassConfig(clnode.held.namepath)) += ".bevs_parentType = &" += pti += ";\n";
                } else {
                  notNullInitConstruct += getTypeInst(getClassConfig(clnode.held.namepath)) += ".bevs_parentType = NULL;\n";
                }
              }
            }
        }
        
        unless (build.emitChecks.has("noRfl")) {
          for (String callName in callNames) {
              getNames += "putCallId(" += TS.quote += callName += TS.quote += ", " += getCallId(callName) += ");" += nl;
          }
        }
        
        String smap = String.new();
        
        for (String smk in smnlcs.keys) {
          //("nlcs key " + smk + " nlc " + smnlcs.get(smk) + " nlec " + smnlecs.get(smk)).print();
          smap += "putNlcSourceMap(" += TS.quote += smk += TS.quote += ", " += smnlcs.get(smk) += ");" += nl;
          smap += "putNlecSourceMap(" += TS.quote += smk += TS.quote += ", " += smnlecs.get(smk) += ");" += nl;
          //break;
        }
        
        if(emitting("cc")) {
          libe.write("void " + libEmitName + "::init() {" + nl); //}
          if (build.emitChecks.has("ccPt")) {
            libe.write("BECS_Runtime::bevs_initLock.lock();\n");
            libe.write("if (BECS_Runtime::isInitted) { BECS_Runtime::bevs_initLock.unlock(); return; }" + nl);
          } else {
            libe.write("if (BECS_Runtime::isInitted) { return; }" + nl);
          }
        } elseIf (emitting("sw")) {
          libe.write("func " + libEmitName + "_init() {" + nl); //}
          libe.write("if (BECS_Runtime.isInitted) { return; }" + nl);
        } else {
          if(emitting("jv")) {
            libe.write("static boolean initted = false;" + nl);
            libe.write(self.baseSmtdDec + "void init()" += exceptDec += " {" + nl); //}
            libe.write("synchronized (be.BECS_Runtime.class) {" + nl);//}
          } elseIf(emitting("cs")) {
            libe.write("static bool initted = false;" + nl);
            libe.write(self.baseSmtdDec + "void init()" += exceptDec += " {" + nl); //}
            libe.write("lock (typeof(be.BECS_Runtime)) {" + nl);//}
          }
          libe.write("if (initted) { return; }" + nl);
          libe.write("initted = true;" + nl);
          if (def(build.initLibs)) {
            for (String lib in build.initLibs) {
              libe.write("be.BEL_" + lib + ".init();" + nl);
            }
          }
        }
        libe.write(self.runtimeInit);
        libe.write(getNames);
        unless (build.emitChecks.has("noSmap")) {
          libe.write(smap);
        }
        libe.write(notNullInitConstruct);
        libe.write(notNullInitDefault);
        if(emitting("jv") || emitting("cs")) {
          //{
          libe.write("}" + nl);
        } elseIf(emitting("cc")) {
          if (build.emitChecks.has("ccPt")) {
            libe.write("BECS_Runtime::bevs_initLock.unlock();\n");
          }
        }
        //{
        libe.write("}" + nl);
        
        if (emitting("sw")) {
          main = "";
        }
        
        if (self.mainInClass && build.doMain) {
            libe.write(main);
        }
        
        //{
        libe.write("}" + nl);
        
        libe.write(self.endNs());
        
        if (self.mainOutsideNs && build.doMain) {
            libe.write(main);
        }
        
        finishLibOutput(libe);
        
        if (build.saveIds) {
          saveIds();
        }
        
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
      return(prefix + v.name);//weak here?
      
   }

   decNameForVar(Build:Var v) String {
     //some langs need diff names for var refs than for declarations (cc)
     return(nameForVar(v));
   }
   
   typeDecForVar(String b, Build:Var v) {
      if (v.isTyped!) {
        b += objectCc.relEmitName(build.libName);
      } else {
        b += getClassConfig(v.namepath).relEmitName(build.libName);
      }
   }
   
   decForVar(String b, Build:Var v, Bool isArg) {
      typeDecForVar(b, v);
      b += " ";
      b += decNameForVar(v);
   }
   
   emitNameForMethod(Node node) String {
       return("bem_" + node.held.name);
   }
   
   emitCall(String callTarget, Node node, String callArgs) String {
        return( callTarget + "bem_" + node.held.name + "(" + callArgs + ")" );
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
      String locDecs = String.new();
      
      //for (Node ovlc in node.held.orderedVars) {
      //  lookatComp(ovlc);
      //}
      
      if (ccSs) {
        String stackRefs = String.new();
      }
      if (ccHs) {
        String besDef = String.new();
        String beqAsn = String.new();
      }
      Bool isFirstRef = true;
      Int numRefs = 0;
      
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
                 if(emitting("cc")) {
                    unless(isFirstRef) {
                      if (ccSs) {
                        stackRefs += ", ";
                      }
                      if (ccHs) {
                        besDef += "; ";
                      }
                    }
                    isFirstRef = false;
                    if (ccSs) {
                      stackRefs += "(BEC_2_6_6_SystemObject**) &" += nameForVar(ov.held);
                    }
                    numRefs++;
                    if (ccHs) {
                      //decForVar(besDef, ov.held, true);

                      typeDecForVar(besDef, ov.held);
                      besDef += " ";
                      if (ov.held.isTmpVar) {
                        besDef += "bevt_" += ov.held.name;
                      } else {
                        besDef += "beva_" += ov.held.name;
                      }

                      //besDef += " = " += nameForVar(ov.held);
                      beqAsn += nameForVar(ov.held) += " = " += decNameForVar(ov.held) += ";" += nl;
                    }
                 }
                decForVar(argDecs, ov.held, true);
             } else {
                unless(ccHs) {
                  decForVar(locDecs, ov.held, false);
                }
                if(emitting("js")) {
                    locDecs += ";" += nl;
                } elseIf(emitting("cc")) {
                    if (ccSs) {
                      locDecs += " = nullptr;" += nl;
                    }
                    unless(isFirstRef) {
                      if (ccSs) {
                        stackRefs += ", ";
                      }
                      if (ccHs) {
                        besDef += "; ";
                      }
                    }
                    isFirstRef = false;
                    if (ccSs) {
                      stackRefs += "(BEC_2_6_6_SystemObject**) &" += nameForVar(ov.held);
                    }
                    numRefs++;
                    if (ccHs) {
                      decForVar(besDef, ov.held, false);
                      //besDef += " = " += "nullptr";
                      beqAsn += nameForVar(ov.held) += " = nullptr;" += nl;
                    }
                } elseIf(emitting("sw")) {
                    locDecs += " = nil;" += nl;
                } else  {
                    locDecs += " = null;" += nl;
                }
             }
             ov.held.nativeName = nameForVar(ov.held);
         }
      }
      
      if(emitting("cc")) {
        if (build.emitChecks.has("ccSgc")) {
          if (ccSs) {
            locDecs += "BEC_2_6_6_SystemObject** bevls_stackRefs[" += numRefs.toString() += "] = { " += stackRefs += " };" += nl;
            locDecs += "BECS_StackFrame bevs_stackFrame(bevls_stackRefs, " += numRefs.toString() += ", this);" += nl;
          }
          if (ccHs) {
            if (Text:Strings.notEmpty(besDef)) { besDef += ";" }
            besDef += " BEC_2_6_6_SystemObject* bevr_this; ";
            locDecs += "struct bes { " += besDef += " };" += nl;
            locDecs += "BECS_FrameStack* bevs_myStack = &BECS_Runtime::bevs_currentStack;" += nl;
            locDecs += "bes* beq = (bes*) bevs_myStack->bevs_hs;" += nl;
            locDecs += beqAsn;
            locDecs += "beq->bevr_this = this;" += nl;
            //("besDef " += besDef).print();
            //stackframe
            //for hstack numRefs bigger for "this" ref
            numRefs++;
            locDecs += "BECS_StackFrame bevs_stackFrame(" += numRefs.toString() += ");" += nl;
          }
        }
        //BEC_2_4_3_MathInt** xa[2] = { &bevl_x0, &bevl_x1 };
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
      
      methods += locDecs;
      
  }
  
  startMethod(String mtdDec, ClassConfig returnType, String mtdName, String argDecs, exceptDec) {
     
     methods += mtdDec += returnType.relEmitName(build.libName) += " " += mtdName += "(";
      
     methods += argDecs;
      
     methods += ")" += exceptDec += " {" += nl; //}
    
  }
  
  addClassHeader(String h) {
  
  }
  
  handleTransEmit(Node jn) {
    if (jn.held.langs.has(self.emitLang)) {
        preClass += emitReplace(jn.held.text);
    }
  }
  
  handleClassEmit(Node innode) {
    if (innode.held.langs.has(self.emitLang)) {
        classEmits += emitReplace(innode.held.text);
    }
  }
  
  acceptClass(Node node) {
     fields {
        String preClass = String.new();
        String classEmits = String.new();
        String onceDecs = String.new();
        String propertyDecs = String.new();
        String gcMarks = String.new();
        Node cnode = node;
        Build:ClassSyn csyn = node.held.syn;
        String dynMethods = String.new();
        String ccMethods = String.new();
        List superCalls = List.new();
        Int nativeCSlots = 0;
        String inFilePathed = node.held.fromFile.toStringWithSeparator("/");
        Map belslits = Map.new();
     }
     
     any te = node.transUnit.held.emits;
      if (def(te)) {
         for (te = te.iterator;te.hasNext;;) {
            any jn = te.next;
            handleTransEmit(jn);
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
          for (Node innode in node.held.emits) {
            //figure out what anys are native
            nativeCSlots = getNativeCSlots(innode.held.text);
            handleClassEmit(innode);
          }
       }
       
       if (def(psyn) && nativeCSlots > 0) {
            nativeCSlots = nativeCSlots - psyn.ptyList.length;
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
                    decForVar(propertyDecs, i, false);
                    if (emitting("cc")) {
                      propertyDecs += " = nullptr;" += nl;
                    } else {
                      propertyDecs += ";" += nl;
                    }
                    if(emitting("cc")) {
                      String mvn = nameForVar(i);
                      gcMarks += "if (" += mvn += " != nullptr && " += mvn += "->bevg_gcMark != BECS_Runtime::bevg_currentGcMark) {" += nl;
                      gcMarks += mvn += "->bemg_doMark();" += nl;
                      gcMarks += "}" += nl;
                    }
                }
                ovcount++;
            }
        }
        if (node.held.namepath.toString() == "Container:List") {
          gcMarks += "this->bemg_markContent();\n";
        } 
        
      //Its not clear how mtdlist ends up, so just use the map
      Map dynGen = Map.new();
      Container:Set mq = Container:Set.new();
      for (Build:MtdSyn msyn in csyn.mtdList) {
         unless(mq.has(msyn.name)) {
             mq.put(msyn.name);
             msyn = csyn.mtdMap.get(msyn.name);
             if (undef(build.emitChecks.get("bemdSmall")) || msyn.origin == csyn.namepath) {
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
        
        String superArgs = "callId";
        if(emitting("cc")) {
          args = "int32_t callId";
        } elseIf (emitting("sw")) {
          args = "callId:Int";
        } else {
          String args = "int callId";
        }
        Int j = 1;
          
        if(emitting("cc")) {
        
          while (j < (dnumargs + 1) && j < maxDynArgs) {
              args = args + ", " + objectCc.relEmitName(build.libName) + "* bevd_" + (j - 1);
              superArgs = superArgs + ", " + "bevd_" + (j - 1);
              j++;
          }
          if (dnumargs >= maxDynArgs) {
            if (build.emitChecks.has("ccSgc")) {
              args = args + ", std::vector<" + objectCc.relEmitName(build.libName) + "*> bevd_x";
              superArgs = superArgs + ", bevd_x";
            }
          }
          
          String dmh = "virtual " + objectCc.relEmitName(build.libName) + "* " + dmname + "(" + args + ");" + nl;
          addClassHeader(dmh);
          dynMethods += objectCc.relEmitName(build.libName) += "* " += classConf.emitName += "::" += dmname += "(" += args += ") {" += nl; //}
        } else {
          
          while (j < (dnumargs + 1) && j < maxDynArgs) {
              if (emitting("sw")) {
                args = args + ", bevd_" + (j - 1) + ":" + objectCc.relEmitName(build.libName) + "?";
              } else {
                args = args + ", " + objectCc.relEmitName(build.libName) + " bevd_" + (j - 1);
              }
              superArgs = superArgs + ", " + "bevd_" + (j - 1);
              j++;
          }
          if (dnumargs >= maxDynArgs) {
            if (emitting("sw")) {
               args = args + ", bevd_x:[" + objectCc.relEmitName(build.libName) + "]";
            } else {
              args = args + ", " + objectCc.relEmitName(build.libName) + "[] bevd_x";
             
            }
            superArgs = superArgs + ", bevd_x";
          }
          
          if (emitting("sw")) {
            dynMethods += self.overrideMtdDec += dmname += "(" += args += ")" += exceptDec += " -> " += objectCc.relEmitName(build.libName) += "? {" += nl;  //}
          } else {
            dynMethods += self.overrideMtdDec += objectCc.relEmitName(build.libName) += " " += dmname += "(" += args += ")" += exceptDec += " {" += nl;  //}
          }
        }
        dynMethods += "switch (callId) {" += nl; //}
        
        dgm = dnode.value;
        for (Container:Map:MapNode msnode in dgm) {
            Int thisHash = msnode.key;
            dgv = msnode.value;
            dynMethods += "case " += thisHash.toString() += ": ";
            for (msyn in dgv) {
                String mcall = String.new();
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
                    vnumargs++;
                }
                mcall += ");" += nl;
                //("mcall built: " + mcall.toString()).print();
                dynMethods += mcall;
            }
        }
        if (emitting("sw")) {
          dynMethods += "default: return " + self.superName + invp += dmname += "(" += superArgs += ");" += nl; 
        }
        dynMethods += "}" += nl; //end of switch
        if(emitting("cc")) {
          dynMethods += "return bevs_super::" += dmname += "(" += superArgs += ");" += nl; 
        } elseIf (emitting("sw")!) {
          dynMethods += "return " + self.superName + invp += dmname += "(" += superArgs += ");" += nl; 
        }
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
        String tname = getClassConfig(objectNp).typeEmitName;
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
        
        String tinst = getTypeInst(newcc);
        
        ccMethods += self.overrideMtdDec += "BETS_Object" += " bemc_getType()" += exceptDec += " {" += nl;  //}
            
            ccMethods += "return " += tinst += ";" += nl;
        //{
        ccMethods += "}" += nl;
        
    }

buildClassInfo() self {
    unless (build.emitChecks.has("noSmap") && (emitting("js") || emitting("cc"))) {
      buildClassInfo("clname", classConf.emitName + "_clname", cnode.held.namepath.toString());
      buildClassInfo("clfile", classConf.emitName + "_clfile", inFilePathed);
    }
  }
 
buildClassInfo(String bemBase, String belsBase, String lival) self {
    
    String belsName = "becc_" + belsBase;
    
    String sdec = String.new();
    if(emitting("js")) {
      lstringStartCi(sdec, "becc_" + bemBase);
    } else {
      lstringStartCi(sdec, belsName);
    }
      
      Int lisz = lival.length;
      Int lipos = 0;
      Int bcode = Int.new();
      String hs = String.new(2);
      while (lipos < lisz) {
        if (lipos > 0) {
            sdec += ",";
        }
        lstringByte(sdec, lival, lipos, bcode, hs);
        lipos++;
      }
      lstringEndCi(sdec);
    
    buildClassInfoMethod(bemBase, belsBase, lival.length);

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
  
  typeDecGet() String {
       
       String initialDec = String.new();
       
       String bein = "bece_" + classConf.emitName + "_bevs_type";
       
       if (csyn.namepath == objectNp) {
          initialDec += baseSpropDec(classConf.typeEmitName, bein) += ";" += nl;
       } else {
          initialDec += overrideSpropDec(classConf.typeEmitName, bein) += ";" += nl;
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

  overrideSpropDec(String typeName, String anyName) {
    return("");
  }
  
  getTraceInfo(Node node) {
    String trInfo = String.new();
    if (def(node) && def(node.nlc)) {
      unless (build.emitChecks.has("noSmap")) {
        trInfo += "/* Line: " += node.nlc.toString() += "*/";
      }
    }
    return(trInfo);
  }
  
  acceptBraces(Node node) {
      if (def(node.container)) {
         Int typename = node.container.typename;
         if (typename != ntypes.METHOD && typename != ntypes.CLASS && typename != ntypes.EXPR && typename != ntypes.FIELDS && typename != ntypes.SLOTS && typename != ntypes.CATCH && typename != ntypes.IFEMIT) {
            
            methodBody += getTraceInfo(node) += " {" += nl; //}
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
                  if (emitting("sw")) {
                    methodBody += "return self;" += nl;//default self return
                  } else {
                    methodBody += "return this;" += nl;//default self return
                  }
                } else {
                  methodBody += "return this;" += nl;//default self return
                }
             }
             
             if (maxSpillArgsLen > 0) {
               if (emitting("js")) {
                methods += "var bevd_x = new Array(" += maxSpillArgsLen.toString() += ");" += nl;
               } elseIf (emitting("cc")) {
                 if (build.emitChecks.has("ccSgc")) {
                   methods += "std::vector<" += objectCc.relEmitName(build.libName) += "*> bevd_x(" += maxSpillArgsLen.toString() += ");" += nl;
                 }
               } else {
                methods += objectCc.relEmitName(build.libName) += "[] bevd_x = new " += objectCc.relEmitName(build.libName) += "[" += maxSpillArgsLen.toString() += "];" += nl;
               }
             }
             
             Int methodsOffset = countLines(methods, lastMethodsSize);
             methodsOffset += lastMethodsLines;
             lastMethodsLines = methodsOffset;
             lastMethodsSize = methods.length.copy();
             
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
             methods += "}";
             unless (build.emitChecks.has("noSmap")) {
               methods += " /*method end*/";
             }
             methods += nl;
             msyn = null;
             mnode = null;
           }
        } elseIf (typename != ntypes.EXPR && typename != ntypes.FIELDS && typename != ntypes.SLOTS && typename != ntypes.CLASS && typename != ntypes.IFEMIT) {
            //{
           methodBody += "} " += getTraceInfo(node) += nl;
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
    Int slen = text.length.copy();
    for (Int i = start.copy();i < slen;i++;) {
      text.getInt(i, cursor);
      if (cursor == nlval) {
        found++;
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
      lastMethodBodySize = methodBody.length.copy();
      
      node.nlec = lastMethodBodyLines;
      //node.nlec = countLines(methodBody);
      
      if ((node.held.orgName == "assign") && (node.contained.length != 2)) {
         any errmsg = "assignment call with incorrect number of arguments " + node.contained.length.toString();
         for (Int ei = 0;ei < node.contained.length;ei++) {
            errmsg = errmsg + " !!!" + ei + "!! " + node.contained[ei];
         }
         throw(VisitError.new(errmsg, node));
      } elseIf ((node.held.orgName == "assign") && (node.contained.first.held.name == "self")) {
         throw(VisitError.new("self cannot be assigned to", node));
      } elseIf (node.held.orgName == "throw") {
         acceptThrow(node);
         return(self);
      } elseIf (node.held.orgName == "assign") {
      
        if (def(node.second) && def(node.second.contained) && node.second.contained.length == 2 && node.second.contained.first.held.isTyped && node.second.contained.first.held.namepath == intNp && node.second.contained.second.typename == ntypes.VAR && node.second.contained.second.held.isTyped && node.second.contained.second.held.namepath == intNp) {
          Bool isIntish = true;
        } else {
          isIntish = false;
        }
        
        if (def(node.second) && def(node.second.contained) && node.second.contained.length == 1 && node.second.contained.first.held.isTyped && node.second.contained.first.held.namepath == boolNp) {
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
         } elseIf (node.second.held.name == "undef_1" ||
            node.second.held.name == "def_1") {
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
      } elseIf (node.held.name == "def_1" || node.held.name == "undef_1" || node.inlined) {
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
      if (node.inlined! && def(node.contained) && node.contained.length > 0 && node.contained.first.held.isTyped && node.contained.first.held.namepath == intNp) {
        sglIntish = true;
        if (node.contained.length > 1 && node.contained.second.typename == ntypes.VAR && node.contained.second.held.isTyped && node.contained.second.held.namepath == intNp) {
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
         numargs++;
      }
      
      //numargs has been incremented higher than the actual number of args by one
      numargs--;
      
      if (isConstruct && isTyped!) {
        throw(VisitError.new("isConstruct but not isTyped", node));
      }
      
      String cast = "";
      String afterCast = "";
      
      //Prepare Assignment
      if ((node.container.typename == ntypes.CALL) && (node.container.held.orgName == "assign")) {
        String oany;
        String odec;
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
                    
                      String liorg = node.held.literalValue;
                  
                      if (node.wideString) {
                        String lival = liorg;
                      } else {
                        lival = Json:Unmarshaller.unmarshall("[" + TS.quote + liorg + TS.quote + "]").first;
                      }
                      
                      String belsName;
                      Int lisz;
                      
                      unless((emitting("js") && build.emitChecks.has("jsStrInline")) || emitting("cc")) {
                      String exname = belslits.get(lival);
                      }
                      if (Text:Strings.notEmpty(exname)) {
                        belsName = exname;
                        lisz = lival.length;
                      } else {
                        belsName = "bece_" + classConf.emitName + "_bels_" + cnode.held.belsCount.toString();                        
                        cnode.held.belsCount++;
                        belslits.put(lival, belsName);
                        String sdec = String.new();
                        lstringStart(sdec, belsName);
                          
                          lisz = lival.length;
                          Int lipos = 0;
                          Int bcode = Int.new();
                          String hs = String.new(2);
                          while (lipos < lisz) {
                            if (lipos > 0) {
                                sdec += ",";
                            }
                            lstringByte(sdec, lival, lipos, bcode, hs);
                            lipos++;
                          }
                          lstringEnd(sdec);
                        }
                        newCall = lstringConstruct(newcc, node, belsName, lisz, sdec);
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
                    if (build.emitChecks.has("ccSgc")) {
                      newCall = "(" + newcc.relEmitName(build.libName) + "*) (new " + newcc.relEmitName(build.libName) + "())";
                    } else {
                      newCall = "(" + newcc.relEmitName(build.libName) + "*) (new " + newcc.relEmitName(build.libName) + "())";
                    }
                  } else {
                    String newCall = self.newDec + newcc.relEmitName(build.libName) + "()";
                  }
                }
                target = "(" + newCall + ")";
                callTarget = target + invp;
                
                String stinst = getInitialInst(newcc);
                
                if (node.held.isLiteral) {
                    if (newcc.np == boolNp) {
                        if (node.held.literalValue == "true") {
                            target = trueValue;
                            callTarget = trueValue + invp;
                        } else {
                            target = falseValue;
                            callTarget = falseValue + invp;
                        }
                    }
                    methodBody += callAssign += cast += target += afterCast += ";" += nl;
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
                      if (emitting("sw") && def(castTo)) {
                        methodBody += callAssign += formCast(getClassConfig(castTo), castType, initialTarg) += afterCast += ";" += nl;
                      } else {
                        methodBody += callAssign += cast += initialTarg += afterCast += ";" += nl;
                      }
                    } elseIf (Text:Strings.notEmpty(callAssign) && node.held.name == "new_0" && msyn.origin.toString() == "Math:Int" && emitting("js")!) {
                      if (emitting("sw") && def(castTo)) {
                        methodBody += callAssign += formCast(getClassConfig(castTo), castType, initialTarg) += afterCast += ";" += nl;
                      } else {
                        //("Found a skippable int new for class " + asyn.namepath.toString()).print();
                        methodBody += callAssign += cast += initialTarg += afterCast += ";" += nl;
                      }
                    } else {
                      methodBody += callAssign += cast += emitCall(initialTarg + invp, node, callArgs) += afterCast += ";" += nl;
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
                methodBody += callAssign += cast += emitCall(callTarget, node, callArgs) += afterCast += ";" += nl;
            } else {
                methodBody += callAssign += cast += emitCall(callTarget, node, callArgs) += afterCast += ";" += nl;
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
    var nccn = newcc.relEmitName(build.libName);
    String bein = "bece_" + nccn + "_bevs_inst";
    return(nccn + "." + bein);
   }
   
   getTypeInst(ClassConfig newcc) String {
    var nccn = newcc.relEmitName(build.libName);
    String bein = "bece_" + nccn + "_bevs_type";
    return(nccn + "." + bein);
   }
   
   newDecGet() String {
    return("new ");
   }
   
   lintConstruct(ClassConfig newcc, Node node) String {
      return(self.newDec + newcc.relEmitName(build.libName) + "(" + node.held.literalValue + ")");
   }
   
   lfloatConstruct(ClassConfig newcc, Node node) String {
      return(self.newDec + newcc.relEmitName(build.libName) + "(" + node.held.literalValue + "f)");
   }
   
   lstringConstruct(ClassConfig newcc, Node node, String belsName, Int lisz, String sdec) String {
      return(self.newDec + newcc.relEmitName(build.libName) + "(" + lisz + ", " + belsName + ")");
   }
   
   lstringStart(String sdec, String belsName) {
      sdec += "private static byte[] " += belsName += " = {"; //}
   }
   
   lstringStartCi(String sdec, String belsName) {
      sdec += "private static byte[] " += belsName += " = {"; //}
   }
   
   lstringByte(String sdec, String lival, Int lipos, Int bcode, String hs) {
        
    }
    
    lstringEnd(String sdec) {
        //{
        //sdec += "0x00};" += nl;
        //{
        sdec += "};" += nl;
        onceDecs += sdec;
    }
    
    lstringEndCi(String sdec) {
        //{
        //sdec += "0x00};" += nl;
        //{
        sdec += "};" += nl;
        onceDecs += sdec;
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
      //now handled in Pass6
      return(node.nextDescend);
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
    
    //Does this emit lang support covariant return types
    covariantReturnsGet() {
        return(true);
    }
    
    mangleName(NamePath np) String {
      String pref = "";
      String suf = "";
      for (String step in np.steps) {
         if (pref != "") { pref = pref + "_"; }
         //else { suf = "_"; } //old way, no count of steps, has ambiguous cases
         else { pref = np.steps.length.toString() + "_"; suf = "_"; }  //new way, prevents ambiguous cases
         pref = pref + step.length;
         suf = suf + step;
      }
      return(pref + suf);
   }
   
   getEmitName(NamePath np) String {
      return("BEC_" + mangleName(np));
   }
   
   getTypeEmitName(NamePath np) String {
      return("BET_" + mangleName(np));
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
        String typeEmitName = emitter.getTypeEmitName(np);
        String fullEmitName = emitter.getFullEmitName(nameSpace, emitName);
        IO:File:Path classPath = emitPath.copy().addStep(emitter.emitLang).addStep("be").addStep(emitName + emitter.fileExt);
        IO:File:Path typePath = emitPath.copy().addStep(emitter.emitLang).addStep("be").addStep(typeEmitName + emitter.fileExt);
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

