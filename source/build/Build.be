// Copyright 2006, 2015 Craig Welch
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

use IO:File;
use Build:EmitData;
use Build:Visit;
use Build:JVEmitter;
use Build:CSEmitter;
use Build:JSEmitter;
use System:Parameters;

final class Build:Build {

   new() self {
      fields {
         String mainName;
         String libName;
         String exeName;
         any emitFileHeader;
         LinkedList extIncludes;
         LinkedList ccObjArgs;
         LinkedList extLibs;
         LinkedList linkLibArgs;
         LinkedList extLinkObjects;
         any fromFile;
         any platform;
         any outputPlatform;
         any emitLibrary;
         any usedLibrarysStr;
         any closeLibrariesStr;
         LinkedList deployFilesFrom;
         LinkedList deployFilesTo;
         String nl;
         String newline;
         any runArgs;
         Build:CompilerProfile compilerProfile;
         //Build:CCallAssembler cassem;
         List args;
         Parameters params;
         Bool buildSucceeded;
         String buildMessage;
         Time:Interval startTime;
         Time:Interval parseTime;
         Time:Interval parseEmitTime;
         Time:Interval parseEmitCompileTime;
         IO:File:Path buildPath;
         any includePath;
         Map built = Map.new();
         LinkedList toBuild;
         Bool printSteps = false;
         Bool printPlaces = false;
         Bool printAst = false;
         Bool printAllAst = false;
         Set printAstElements;
         Bool doEmit = false;
         Bool emitDebug = false;
         Bool parse = false;
         Bool prepMake = false;
         Bool make = false;
         Bool genOnly = false;
         Bool deployUsedLibraries = false;
         Build:EmitData emitData;
         IO:File:Path emitPath;
         any code;
         String estr = Text:String.new();
         any sharedEmitter;
         Build:Constants constants = Build:Constants.new(self);
         Build:NodeTypes ntypes = constants.ntypes;
         Text:Tokenizer twtok = constants.twtok;
         Text:Tokenizer lctok = Text:Tokenizer.new(",\r\n");
         Build:Library deployLibrary;
         String deployPath;
         Container:LinkedList usedLibrarys = Container:LinkedList.new();
         //closeLibraries includes all libraries used close and the
         //current library
         Container:Set closeLibraries = Container:Set.new();
         Bool run = false;
         String compiler;
         LinkedList emitLangs;
         LinkedList emitFlags;
         String makeName;
         String makeArgs;
         Bool putLineNumbersInTrace = false;
         Bool dynConditionsAll = false;
         Bool ownProcess = true;
         Bool saveSyns = false;
         Text:String readBuffer = Text:String.new(4096);
         LinkedList loadSyns;
         LinkedList initLibs;
      }
   }

   isNewish(String name) Bool {
      if (def(name) && (name == "new" || name.ends("New"))) {
         return(true);
      }
      return(false);
   }

   process(String arg) {
      return(arg.swap("/", "\\"));
   }

   main() {
      List _args = System:Process.new().args;
      System:Process.exit(main(_args));
   }

   main(List _args) {
      args = _args;
      params = Parameters.new(args);
      Int times = Int.new(params.get("howManyTimes", "1").first);
      for (Int i = 0;i < times;i++=) {
        any res = go();
      }
      return(res);
   }

   go() {
      Int whatResult = 1;//default to fail
      config();
      Bool buildFailed = false;
      try {
         buildMessage = "Build Incomplete";
         whatResult = doWhat();
         buildMessage = "Build Complete";
      } catch (any e) {
         buildMessage = e.toString();
         buildFailed = true;
         buildMessage = "Build Failed with exception " + buildMessage;
         whatResult = 1;//in case of failure post-doWhat()
      }
      if (printSteps || buildFailed) {
        buildMessage.print();
      }
      return(whatResult);
   }

   dllhead(String addTo) String {
      if (platform.name == "mswin") {
      }
      return(addTo);
   }

   config() {
      String istr;
      Set bfiles = Set.new();

      String bkey = "buildFile";
      if (def(params[bkey])) {
      for (istr in params[bkey]) {
         if (bfiles.has(istr)!) {
            bfiles.put(istr);
            params.addFile(File.new(istr));
         }
      }
      }

      if (System:CurrentPlatform.new().name == "mswin") {
         params.preProcessor = self;
      }
      libName = params["libraryName"].first;
      if (params.has("exeName")) {
         exeName = params["exeName"].first;
      } else {
         exeName = libName;
      }
      buildPath = File.new(params.get("buildPath", "target").first).path;
      buildPath.addStep(libName);
      buildPath.addStep("target");
      includePath = File.new(params.get("includePath", "include").first).path;
      platform = System:Platform.new(params.get("platform", System:CurrentPlatform.new().name).first);
      outputPlatform = System:Platform.new(params.get("outputPlatform", platform.name).first);
      dynConditionsAll = Bool.new(params.get("dynConditionsAll", "false").first);
      ownProcess = Bool.new(params.get("ownProcess", "true").first);
      saveSyns = Bool.new(params.get("saveSyns", "false").first);
      loadSyns = params["loadSyns"];
      initLibs = params["initLib"];

      mainName = params["mainClass"].first;
      deployPath = params["deployPath"].first;
      usedLibrarysStr = params["useLibrary"];
      if (undef(usedLibrarysStr)) {
         usedLibrarysStr = LinkedList.new();
      }
      closeLibrariesStr = params["useLibraryClose"];
      if (undef(closeLibrariesStr)) {
         closeLibrariesStr = LinkedList.new();
      }
      deployFilesFrom = params["deployFileFrom"];
      if (undef(deployFilesFrom)) {
         deployFilesFrom = LinkedList.new();
      }
      deployFilesTo = params["deployFileTo"];
      if (undef(deployFilesTo)) {
         deployFilesTo = LinkedList.new();
      }
      extIncludes = params["extInclude"];
      if (undef(extIncludes)) {
         extIncludes = LinkedList.new();
      }
      ccObjArgs = params["ccObjArgs"];
      if (undef(ccObjArgs)) {
         ccObjArgs = LinkedList.new();
      }
      extLibs = params["extLib"];
      if (undef(extLibs)) {
         extLibs = LinkedList.new();
      }
      linkLibArgs = params["linkLibArgs"];
      if (undef(linkLibArgs)) {
         linkLibArgs = LinkedList.new();
      }
      extLinkObjects = params["extLinkObject"];
      if (undef(extLinkObjects)) {
         extLinkObjects = LinkedList.new();
      }
      emitFileHeader = params["emitFileHeader"];
      if (def(emitFileHeader)) {
         emitFileHeader = emitFileHeader.first;
      }
      runArgs = params["runArgs"];
      if (def(runArgs)) {
         runArgs = runArgs.first;
      } else {
         runArgs = String.new();
      }
      printSteps = params.isTrue("printSteps", false);
      printPlaces = params.isTrue("printPlaces", true);
      printAst = params.isTrue("printAst");
      printAllAst = params.isTrue("printAllAst");
      printAstElements = Set.new()
      LinkedList pacm = params["printAstElement"];
      if (def(pacm) && pacm.isEmpty!) {
        for (String pa in pacm) {
          printAstElements.put(pa);
        }
      }
      genOnly = params.isTrue("genOnly");
      deployUsedLibraries = params.isTrue("deployUsedLibraries");
      run = params.isTrue("run");
      putLineNumbersInTrace = params.isTrue("putLineNumbersInTrace", true);
      emitLangs = params["emitLang"];
      emitFlags = params["emitFlag"];
      compiler = params.get("compiler", "gcc").first;
      makeName = params.get("make", "make").first;
      makeArgs = params.get("makeArgs_" + makeName, "").first;
      parse = true;
      emitDebug = true;
      doEmit = true;
      prepMake = true;
      make = true;

      String outLang;
      if (def(emitLangs)) {
        outLang = emitLangs.first;
      } else {
        outLang = "c";
      }

      //So that we can have one set of build files which work for all platforms, we have the ability to
      //add only source files which correspond to our target platform
      //(which is also the current platform unless we are doing a (build4) cross-gen)
      //outLang specific
      any platformSources = params[outLang + "_source_" + platform.name];
      if (def(platformSources)) {
		 params.ordered.addAll(platformSources);
      }

      any langSources = params[outLang + "_source"];
      if (def(langSources)) {
		 params.ordered.addAll(langSources);
      }

      toBuild = LinkedList.new();
      for (istr in params.ordered) {
         toBuild += IO:File:Path.new(istr);
      }
      newline = platform.newline;
      nl = newline;
      compilerProfile = Build:CompilerProfile.new(self);

      emitPath = buildPath.copy();
      if (emitPath.file.exists!) {
         emitPath.file.makeDirs();
      }
      if (def(emitFileHeader)) {
         any emr = File.new(emitFileHeader).reader;
         emitFileHeader = emr.open().readString();
         emr.close();
      }
   }

   toString() Text:String {
      //self.className.print();
      any toRet = self.className;
      toRet = toRet + nl + "buildPath is " + buildPath.toString();
      toRet = toRet + nl + "emitPath is " + emitPath.toString();
      return(toRet);
   }

   setClassesToWrite() {
      Set toEmit = Set.new();
      for (any ci = emitData.classes.valueIterator;ci.hasNext;;) {
            any clnode = ci.next;
            if (emitData.shouldEmit.has(clnode.held.fromFile)) {
				toEmit.put(clnode.held.namepath.toString());
				Set usedBy = emitData.usedBy[clnode.held.namepath.toString()];
				if (def(usedBy)) {
					for (String ub in usedBy) {
						toEmit.put(ub);
					}
				}
				Set subClasses = emitData.subClasses[clnode.held.namepath.toString()];
				if (def(subClasses)) {
					for (String sc in subClasses) {
						toEmit.put(sc);
					}
				}
            }
      }
      for (ci = emitData.classes.valueIterator;ci.hasNext;;) {
            clnode = ci.next;
            clnode.held.shouldWrite = toEmit.has(clnode.held.namepath.toString());
            //("shouldWrite for " + clnode.held.namepath + " is " + clnode.held.shouldWrite).print();
      }
   }

   emitCs() Int {

     return(0);
   }

   emitCommonGet() Build:EmitCommon {
       if (def(emitCommon)) {
          return(emitCommon);
       }
       fields {
            Build:EmitCommon emitCommon;
       }
       if (def(emitLangs)) {
         String emitLang = emitLangs.first;
         if (emitLang == "jv") {
             emitCommon = JVEmitter.new(self);
        } elseIf (emitLang == "cs") {
             emitCommon = CSEmitter.new(self);
        } elseIf (emitLang == "js") {
             emitCommon = JSEmitter.new(self);
        } else {
            throw(System:Exception.new("Unknown emitLang, supported emit langs are cs, jv"));
        }
        emitCommon.dynConditionsAll = dynConditionsAll;
        return(emitCommon);
       }
       return(null);
   }
   
   loadSyns(String lsp) {
      IO:File:Path synEmitPath = IO:File:Path.apNew(lsp);
      //if (synEmitPath.file.exists) {
        ("Loading Syns " + lsp).print();
        Time:Interval sst = Time:Interval.now();
        IO:File:Reader syne = synEmitPath.file.reader.open()
        Map scls = System:Serializer.new().deserialize(syne);
        syne.close();
        emitData.synClasses += scls;
        Time:Interval sse = Time:Interval.now() - sst;
        ("Loading Syns took " + sse).print();
      //}
    }

   doWhat() Int {
      //Start Timer
      startTime = Time:Interval.now();
      emitData = EmitData.new();
      if (def(loadSyns)) {
        for (String lsp in loadSyns) {
          loadSyns(lsp);
        }
      }
      any em = self.emitter;
      if (def(deployPath)) {
         deployLibrary = Build:Library.new(deployPath, self, libName, exeName);
         closeLibraries.put(libName);
         if (printSteps) {
           ("Added closelibrary " + libName).print();
         }
      }
      Set ulibs = Set.new();
      //librarys is a mispelling TODO spell it right libraries
      for (any ups in usedLibrarysStr) {
         if (ulibs.has(ups)!) {
            ulibs.put(ups);
            any pack = Build:Library.new(ups, self);
            usedLibrarys.addValue(pack);
         }
      }
      for (ups in closeLibrariesStr) {
         if (ulibs.has(ups)!) {
            ulibs.put(ups);
            pack = Build:Library.new(ups, self);
            usedLibrarys.addValue(pack);
            closeLibraries.put(pack.libName);
         }
      }
      if (parse) {
         //"In parse".print();
         for (any i = toBuild.iterator;i.hasNext;;) {
            any tb = i.next;
            //("First Pass, Considering file " + tb.toString() + " ").print();
            doParse(tb);
         }
         buildSyns(em);
      }
      //End Timer
      parseTime = Time:Interval.now() - startTime;
      //if (printSteps) {
      //}
      if (def(self.emitCommon)) {
        //ec way, not for old c, exception is caught by caller, exits with fail
        Time:Interval emitStart = Time:Interval.now();
        self.emitCommon.doEmit();
        parseEmitTime = Time:Interval.now() - startTime;
        Time:Interval emitTime = Time:Interval.now() - emitStart;
        ("TIME: Parse phase completed in " + parseTime).print();
        ("TIME: Emit phase completed in " + emitTime).print();
        ("TIME: Parse and emit phases completed in " + parseEmitTime).print();
        return(0);
      }
      if (doEmit) {
		 setClassesToWrite();
         em.libnameInfo;
         //cassem = Build:CCallAssembler.new(self);
         for (any ci = emitData.classes.valueIterator;ci.hasNext;;) {
            any clnode = ci.next;
			em.doEmit(clnode);
         }
         em.emitMain();
         em.emitCUInit();
         for (ci = emitData.classes.valueIterator;ci.hasNext;;) {
            clnode = ci.next;
			em.emitSyn(clnode);
         }

      }
      parseEmitTime = Time:Interval.now() - startTime;
      if (def(parseTime)) {
         ("TIME: Parse phase completed in " + parseTime).print();
      }
      ("TIME: Parse and emit phases completed in " + parseEmitTime).print();
      if (prepMake) {
      //("!!!!!!! prep make deploy library exe " + deployLibrary.exeName).print();
         em.prepMake(deployLibrary);
      }

      if (make) {
         if (genOnly!) {
            em.make(deployLibrary);
            em.deployLibrary(deployLibrary);
            if (deployUsedLibraries) {
               for (any bp in usedLibrarys) {
                  any cpFrom = bp.libnameInfo.unitShlib;
                  any cpTo = deployLibrary.emitPath.copy();
                  cpTo.addStep(cpFrom.steps.last);
                  if (cpTo.file.exists) {
                     cpTo.file.delete();
                  }
                  if (cpTo.file.exists!) {
                     em.deployFile(cpFrom.file, cpTo.file);
                  }
               }
            }
            any fIter = deployFilesFrom.iterator;
            any tIter = deployFilesTo.iterator;
            //("!!!!!!!! deployFiles iter next" + fIter.hasNext + " " + tIter.hasNext).print();
            while (fIter.hasNext && tIter.hasNext) {
               cpFrom = IO:File:Path.apNew(fIter.next);
               cpTo = IO:File:Path.apNew(deployLibrary.emitPath.copy().toString() + "/" + tIter.next);
               //("!!! from to " + cpFrom + " " + cpTo).print();
               if (cpTo.file.exists) {
                  cpTo.file.delete();
               }
               if (cpTo.file.exists!) {
                  em.deployFile(cpFrom.file, cpTo.file);
               }
            }
         }
      }
      parseEmitCompileTime = Time:Interval.now() - startTime;

      if (def(parseTime)) {
         ("TIME: Parse phase completed in " + parseTime).print();
      }
      if (def(parseEmitTime)) {
         ("TIME: Parse and emit phases completed in " + parseEmitTime).print();
      }
      if (def(parseEmitCompileTime)) {
         ("TIME: Parse, emit, and compile phases completed in " + parseEmitCompileTime).print();
      }

      if (run) {
         ("Should now run").print();
         Int result = em.run(deployLibrary, runArgs);
         ("Received exit code " + result + " from run").print();
         return(result);
      }
      return(0);
   }

   buildSyns(em) {
      for (any ci = emitData.justParsed.valueIterator;ci.hasNext;;) {
         any kls = ci.next;
         kls.held.libName = libName;
         any syn = getSyn(kls, em);
         syn.libName = libName;
      }
      for (ci = emitData.justParsed.valueIterator;ci.hasNext;;) {
         kls = ci.next;
         syn = kls.held.syn;
         syn.checkInheritance(self, kls);
         syn.integrate(self);
      }
      emitData.justParsed = Map.new();
   }

   getSyn(klass, em) {
      if (def(klass.held.syn)) {
         return(klass.held.syn);
      }
      klass.held.libName = libName;
      if (undef(klass.held.extends)) {
         any syn = Build:ClassSyn.new(klass);
      } else {
         any pklass = emitData.classes.get(klass.held.extends.toString());
         any psyn;
         if (def(pklass)) {
            pklass.held.libName = libName;
            psyn = getSyn(pklass, em);
         } else {
            //("Need to load syn for " + klass.held.name).print();
            //psyn = em.loadSyn(klass.held.extends);
            psyn = getSynNp(klass.held.extends);
         }
         syn = Build:ClassSyn.new(klass, psyn);
      }
      klass.held.syn = syn;
      emitData.addSynClass(klass.held.namepath.toString(), syn);
      return(syn);
   }

   getSynNp(np) Build:ClassSyn {
      any nps = np.toString();
      any syn = emitData.synClasses.get(nps);
      if (def(syn)) {
         return(syn);
      }// else {
         //("Did not find " + nps).print();
         //for (any kv in emitData.synClasses) {
         //   ("In synclasses " + kv.key + " " + kv.value.namepath.toString()).print();
         //}
         syn = self.emitter.loadSyn(np);
         emitData.addSynClass(nps, syn);
         return(syn);
      //}
      //return(null);
   }


   emitterGet() {
      if (undef(sharedEmitter)) {
         sharedEmitter = Build:CEmitter.new(self);
      }
      return(sharedEmitter);
   }

   doParse(toParse) {
      //"in parse".print();
      any trans = Build:Transport.new(self);
      any blank = String.new();
      any emitter = self.emitter;
      code = null;
      Bool parseThis = true;
      emitData.shouldEmit.put(toParse);
      if (parseThis) {
        if (printSteps || printPlaces) {
         ("Parsing file " + toParse.toString()).print();
        }
         fromFile = toParse;

         any src = toParse.file.reader.open().readBuffer(readBuffer);
         toParse.file.reader.close();
         LinkedList toks = twtok.tokenize(src);

         //PREPARE VISIT
         if (printSteps) {
            ". ".echo();
         }
         nodify(trans.outermost, toks);
         if (printAllAst) {
            "printAst post 1 nodify".print();
            trans.traverse(Build:Visit:Pass1.new(printAstElements, null));
         }
         //VISIT NOW
         if (printSteps) {
            ".. ".echo();
         }
         trans.traverse(Build:Visit:Pass2.new());
         if (printAllAst) {
            "printAst post 2".print();
            trans.traverse(Build:Visit:Pass1.new(printAstElements, null));
         }
         if (printSteps) {
            "... ".echo();
         }
         //INITIAL CONTAIN
         trans.traverse(Build:Visit:Pass3.new());
         trans.contain();
         if (printAllAst) {
            "printAst post 3".print();
            trans.traverse(Build:Visit:Pass1.new(printAstElements, null));
         }

         if (printSteps) {
            ".... ".echo();
         }
         trans.traverse(Build:Visit:Pass4.new());
         if (printAllAst) {
            "printAst post 4".print();
            trans.traverse(Build:Visit:Pass1.new(printAstElements, null));
         }

         if (printSteps) {
            "..... ".echo();
         }
         trans.traverse(Build:Visit:Pass5.new());
         if (printAllAst) {
            "printAst post 5".print();
            trans.traverse(Build:Visit:Pass1.new(printAstElements, null));
         }

         if (printSteps) {
            "...... ".echo();
         }
         trans.traverse(Build:Visit:Pass6.new());
         if (printAllAst) {
            "printAst post 6".print();
            trans.traverse(Build:Visit:Pass1.new(printAstElements, null));
         }

         if (printSteps) {
            "....... ".echo();
         }
         trans.traverse(Build:Visit:Pass7.new());
         if (printAllAst) {
            "printAst post 7".print();
            trans.traverse(Build:Visit:Pass1.new(printAstElements, null));
         }

         if (printSteps) {
            "........ ".echo();
         }
         trans.traverse(Build:Visit:Pass8.new());
         if (printAllAst) {
            "printAst post 8".print();
            trans.traverse(Build:Visit:Pass1.new(printAstElements, null));
         }

         if (printSteps) {
            "......... ".echo();
         }
         trans.traverse(Build:Visit:Pass9.new());
         if (printAllAst) {
            "printAst post 9".print();
            trans.traverse(Build:Visit:Pass1.new(printAstElements, null));
         }

         if (printSteps) {
            ".......... ".echo();
         }
         trans.traverse(Build:Visit:Pass10.new());
         if (printAllAst) {
            "printAst post 10".print();
            trans.traverse(Build:Visit:Pass1.new(printAstElements, null));
         }
         if (printSteps) {
            "........... ".echo();
         }
         trans.traverse(Build:Visit:Pass11.new());
         if (printAllAst) {
            "printAst post 11".print();
            trans.traverse(Build:Visit:Pass1.new(printAstElements, null));
         }

         if (printSteps) {
            "............ ".echo();
            " ".print();
         }
         trans.traverse(Build:Visit:Pass12.new());
         if (printAst || printAllAst) {
            "printAst post 12".print();
            trans.traverse(Build:Visit:Pass1.new(printAstElements, null));
         }
         for (any ci = emitData.classes.valueIterator;ci.hasNext;;) {
            any clnode = ci.next;
            //clnode.held.name.print();
            any tunode = clnode.transUnit;
            any ntunode = Build:Node.new(self);
            ntunode.typename = ntypes.TRANSUNIT;
            any ntt = Build:TransUnit.new();
            ntt.emits = tunode.held.emits;
            ntunode.held = ntt;
            clnode.delete();
            ntunode.addValue(clnode);
            ntunode.copyLoc(clnode);
         }
      }
   }

   nodify(parnode, LinkedList toks) {
      parnode.reInitContained();
      Container:NodeList con = parnode.contained;
      Int nlc = 1;
      String cr = Text:Strings.new().cr;
      for (Container:LinkedList:Iterator i = toks.linkedListIterator;i.hasNext;;) {
         any node = Build:Node.new(self);
         node.held = i.next;
         node.nlc = nlc;
         if (node.held == nl) {
            nlc = nlc++;
         }
         if (node.held != cr) {
            con.addValue(node);
            node.container = parnode;
         }
      }
   }

}
