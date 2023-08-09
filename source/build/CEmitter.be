// Copyright 2006 The Bennt Authors. All rights reserved.
// Use of this source code is governed by the BSD-3-Clause
// license that can be found in the LICENSE file.

use Container:Map;
use Container:LinkedList;
use IO:File;
use Build:Visit;
use Build:EmitException;
use Text:String;
use Text:String;
use Logic:Bool;

class Build:EmitError(Build:VisitError) {
}

final class Build:ClassInfo {
   
   new(Build:NamePath _np, _emitter, IO:File:Path _emitPath, String _libName) self {
      new(_np, _emitter, _emitPath, _libName, _libName);
   }
   
   new(Build:NamePath _np, _emitter, IO:File:Path _emitPath, String _libName, String _exeName) self {
   
      fields {
         
         Build:NamePath np = _np; //name path for class
         any emitter = _emitter; //emitter obj
         Build:CompilerProfile cpro = emitter.build.compilerProfile; //compiler profile
         Build:NamePath npar = np.parent; //parent namepath
         any nparSteps = npar.steps; //array of steps for parent name path
         String clName = np.toString(); //class name as string
         
         String clBase = np.steps.last; //Final name actual name of class
         
         String midName = emitter.midNameDo(_libName, _np); //the "middle part" of all names for subs, etc
         
         nsDirDo(_libName);
         cext = cpro.cext;
         oext = cpro.oext;
         
         //The define to avoid multiple includes
         String incBlock = "BEKH_" + midName;
         //prefix for subroutines
         String mtdName = "BEKF_" + midName + "_";
         //name of classes class def anyiable
         String cldefName = "BEUV_" + midName + "_clDef";
         //name of anyiable to hold class name in chars
         String shClassName = "BEUV_" + midName + "_shClassName"; 
         //holds name of file which contained code for class
         String shFileName = "BEUV_" + midName + "_shFileName";
         //function for class def
         String cldefBuild = "BEUF_" + midName + "_clDef"; 
         //classdef init for all classes in compile unit
         String libnameInit = "BEUF_" + midName + "_libnameInit"; 
         //is the compile unit init done
         String libnameInitDone = "BEUV_" + midName + "_libnameInitDone";
         //classdata init for all classes in compile unit
         String libnameData = "BEUF_" + midName + "_libnameData"; 
         //is the compile unit class data init done
         String libnameDataDone = "BEUV_" + midName + "_libnameDataDone"; 
         //clear libnameDataDone flags for reuse
         String libnameDataClear = "BEUF_" + midName + "_libnameDataClear"; 
         
         String libNotNullInit = "BEUF_" + midName + "_notNullInit";
         String libNotNullInitDone = "BEUV_" + midName + "_notNullInitDone";
         
         IO:File:Path emitPath = _emitPath;
         //base file path for all files for class
         IO:File:Path basePath = _emitPath + nsDir; 
         IO:File:Path cuBase = _emitPath.copy();
         IO:File:Path nsDir; //path to files as it will appear from compiler include
   
         String xbase = "BEX_" + _libName; //clBase name for executable bits
         String lbase = _libName; //clBase name for lib
         String nbase = clBase; //clBase name for name stuff
         String kbase = "BEK_" + clBase; //clBase name for all class files for this class
         
         IO:File:Path cuinitH = cuBase.copy().addStep(nbase + ".h");
         String namesIncH = nbase + ".h";
         IO:File:Path cuinit = cuBase.copy().addStep(nbase + cext);
         IO:File:Path namesO = cuBase.copy().addStep(nbase + oext);
   
         //File:Path libnameName = cuBase.copy().addStep("name.txt");
         
         IO:File:Path unitShlib = cuBase.copy().addStep(lbase + cpro.libExt);
         IO:File:Path unitExeLink = cuBase.copy().addStep(lbase + cpro.exeLibExt);
         IO:File:Path unitExe = cuBase.copy().addStep(_exeName + cpro.exeExt);
   
         IO:File:Path classExeSrc = basePath.copy().addStep(xbase + cext);
         IO:File:Path classExeO = basePath.copy().addStep(xbase + oext);
         IO:File:Path makeSrc = basePath.copy().addStep(xbase + ".make");
         
         IO:File:Path classSrc = basePath.copy().addStep(kbase + cext);
         IO:File:Path classSrcH = basePath.copy().addStep(kbase + ".h");
         IO:File:Path classIncH = nsDir.copy().addStep(kbase + ".h");
         IO:File:Path classO = basePath.copy().addStep(kbase + oext);
         IO:File:Path synSrc = basePath.copy().addStep(kbase + ".syn");
   
      }
      
      String cext;
      String oext;
      
   }
      
   nsDirDo(String _libName) {
      nsDir = IO:File:Path.new();
      nsDir.addStep(_libName);
      for (any i = nparSteps.iterator;i.hasNext;;) {
         nsDir.addStep(i.next);
      }
   }
   
}

final class Build:CEmitter {
   
   new(Build:Build _build) self {
         fields {
            any classInfo;
            any cEmitF;
            any mainClassNp;
            any mainClassInfo;
            any libnameNp;
            Build:ClassInfo libnameInfo;
            any allInc;
            String ccObjArgsStr;
            any extLib;
            String linkLibArgsStr;
            Build:CompilerProfile cprofile;
            any pci;
            Build:Build build = _build;
            String nl = build.newline;
            Map ciCache = Map.new();
            Build:EmitData emitData = build.emitData;
            String textQuote = Text:Strings.new().quote;
            String libName = build.libName;
         }
   }
   
   midNameDo(String libName, Build:NamePath np) String {
      String pref = "";
      String suf = "";
      for (String step in np.steps) {
         if (pref != "") { pref = pref + "_"; }
         else { suf = "_"; }
         pref = pref + step.size;
         suf = suf + step;
      }
      return(pref + suf);
   }
   
   removeEmitted(np) {
      //("Removing emitted files for " + np.toString()).print();
   }
   
   getInfo(np) Build:ClassInfo {
      any dname = np.toString();
      Build:ClassInfo toRet = ciCache.get(dname);
      if (undef(toRet)) {
         toRet = Build:ClassInfo.new(np, self, build.emitPath, build.libName);
         ciCache.put(dname, toRet);
      }
      return(toRet);
   }
   
   getInfoNoCache(np) Build:ClassInfo {
      return(Build:ClassInfo.new(np, self, build.emitPath, build.libName));
   }
   
   getInfoSearch(np) {
      any dname = np.toString();
      any toRet = ciCache.get(dname);
      if (undef(toRet)) {
         for (any pack in build.usedLibrarys) {
            toRet = Build:ClassInfo.new(np, self, pack.emitPath, pack.libName);
            if (toRet.synSrc.file.exists) {
               ciCache.put(dname, toRet);
               return(toRet);
            }
         }
         toRet = Build:ClassInfo.new(np, self, build.emitPath, build.libName);
         ciCache.put(dname, toRet);
      }
      return(toRet);
   }
   
   prepBasePath(np) {
      any clinfo = getInfo(np);
      any bp = clinfo.basePath;
      if (bp.file.exists!) {
         bp.file.makeDirs();
      }
      return(clinfo);
   }
   
   loadSyn(np) {
      any clinfo = getInfoSearch(np);
      if (clinfo.synSrc.file.exists!) {
         //("BAD LOAD SYN " + np.toString()).print();
         throw(Build:EmitError.new("Class synopsis path does not exist for " + np.toString() + ", verify that this is the name of a class in this library or a used library and that the use declaration is present if using an abbreviated name", null));
      }
      
      any ser = System:Serializer.new();
      
      any syn = ser.deserialize(clinfo.synSrc.file.reader.open());
      clinfo.synSrc.file.reader.close();
      syn.postLoad();
      
      return(syn);
   }
   
   saveSyn(syn) {
      any clinfo = getInfo(syn.namepath);
      clinfo.synSrc.file.delete();
      
      any ser = System:Serializer.new();
      ser.serialize(syn, clinfo.synSrc.file.writer.open());
      clinfo.synSrc.file.writer.close();
      
   }
   
   emitMtd(emvisit, Build:Node clgen) {
      if (clgen.held.shouldWrite) {
         emvisit.methods.writeTo(cEmitF);
      }
      emvisit.methods = Text:String.new();
   }
   
   emitInitialClass(clgen, emvisit) {
      if (clgen.held.shouldWrite!) { return(self); }
      any emitF;
      classInfo = prepBasePath(clgen.held.namepath);
      classInfo.classSrc.file.delete();
      classInfo.classO.file.delete(); //to insure make orders properly, seems not to sometimes
      emitF = classInfo.classSrc.file.writer.open();
      if (def(build.emitFileHeader)) {
         emitF.write(build.emitFileHeader);
      }
      any ninc = "#include <" + libnameInfo.namesIncH.toString() + ">" + nl;
      emitF.write(ninc);
      emitF.write(emvisit.cincl);
      emvisit.cldefDecs.writeTo(emitF);
      cEmitF = emitF;
   }
   
   doEmit(clgen) {
      ("Finishing class " + clgen.held.name).print();
      
      classInfo = getInfo(clgen.held.namepath);
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
      }
      " ".print();
      //emvisit = Build:Visit:CEmit.new();
      emvisit.emitter = self;
      emvisit.build = build;
      trans.traverse(emvisit);
      emvisit.buildCldef();
      
      any emitF;
      
      if (clgen.held.shouldWrite!) { return(self); }
      
      ("Emitting class " + clgen.held.name).print();
      emitF = cEmitF;
      //now classsrch emit
      emvisit.cldef.writeTo(emitF);
      emvisit.methods.writeTo(emitF);
      emitF.close();
      
      
      classInfo.classSrcH.file.delete();
      emitF = classInfo.classSrcH.file.writer.open();
      if (def(build.emitFileHeader)) {
         emitF.write(build.emitFileHeader);
      }
      any thedef = self.classInfo.incBlock;
      emitF.write("#ifndef " + thedef + nl);
      emitF.write("#define " + thedef + nl);
      emitF.write(emvisit.hincl);
      //emitF.write(emvisit.hfd); //commented b/c now this is superclass
      emitF.write(emvisit.cldefH);
      emitF.write(emvisit.baseH);
      emitF.write(emvisit.methodsProto);
      emitF.write(emvisit.mmbers);
      emitF.write("#endif" + nl);
      emitF.close();
      
   }
   
   emitSyn(clgen) {
      if (clgen.held.shouldWrite!) { return(self); }
      ("Emitting syn for " + clgen.held.name).print();
      
      classInfo = getInfo(clgen.held.namepath);
      
      saveSyn(clgen.held.syn);
      
   }
   
   libnameNpGet() {
      if (undef(libnameNp)) {
         any cun = build.libName;
         if (undef(cun)) {
            throw(Build:EmitError.new("Compile unit is null"));
         }
         libnameNp = Build:NamePath.new();
         libnameNp.fromString(cun);
      }
      return(libnameNp);
   }
   
   registerName(nm) {
      emitData.allNames.put(nm, nm);
   }
   
   foreignClass(Build:NamePath np, syn) String {
      String key = np.toString();
      String dcn = emitData.foreignClasses[key];
      if (undef(dcn)) {
         dcn = midNameDo(libName, np);
         dcn = "twnc_" + dcn;
         emitData.foreignClasses.put(key, dcn);
      }
      syn.foreignClasses.put(key, dcn);
      return(dcn);
   }
   
   //The name of the property index anyiable, used when directProperties is false
   //to find the location of a anyiable in the object array (used internally to class (hierarchy) of declaration only)
   getPropertyIndexName(Build:PtySyn pi) String {
      Build:ClassInfo ci = getInfoSearch(pi.origin);
      String pin = "twpi_" + build.libName.size + "_" + ci.midName.size + "_" + build.libName + "_" + ci.midName + "_" + pi.name;
      return(pin);
   }
   
   //For typed calls, the name of the method index when directMethods is false and the call is not an optimized call
   //gives the index of the mtd vtable entry (which is an array beyond the end of the cldef struct which contains
   //pointers to methods for the class)
   getMethodIndexName(Build:MtdSyn pi) String {
      Build:ClassInfo ci = getInfoSearch(pi.declaration);
      String pin = "twmi_" + build.libName.size + "_" + ci.midName.size + "_" + build.libName + "_" + ci.midName + "_" + pi.name;
      return(pin);
   }
   
   libnameInfoGet() {
      if (undef(libnameInfo)) {
         libnameInfo = Build:ClassInfo.new(self.libnameNp, self, build.emitPath, build.libName);
         //libnameInfo = getInfo(libnameNp);
         if (undef(libnameInfo)) {
            "CUNITINFO IS NULL".print();
         }
     }
     return(libnameInfo);
   }
   
   emitCUInit() {
      "Emitting names".print();
      any cun = build.libName;
      any cma = ",";
      if (undef(classInfo)) {
         //I didn't emit anything, no need to emit names
         return(self);
      }
      //"Emit two".print();
      self.libnameInfo;
      any bp = libnameInfo.cuBase;
      ("Base is " + bp.toString()).print();
      if (bp.file.exists!) {
         "Making base".print();
         bp.file.makeDirs();
      }
      libnameInfo.cuinitH.file.delete();
      libnameInfo.cuinit.file.delete();
      //libnameInfo.libnameName.file.delete();
      //any cunf = libnameInfo.libnameName.file.writer.open();
      //cunf.write(build.libName + nl);
      //cunf.close();
      any nH = libnameInfo.cuinitH.file.writer.open();
      any nC = libnameInfo.cuinit.file.writer.open();
      nC.write("#include <" + libnameInfo.namesIncH.toString() + ">" + nl);
      nH.write("#ifndef TWNI_" + libnameInfo.clBase + nl);
      nH.write("#define TWNI_" + libnameInfo.clBase + nl);
      nH.write("#include <BER_Inc.h>" + nl);
      String nuCui = String.new();
      String nuCi = String.new();
      String nuH = String.new();
      String nuC = String.new();
      
      String cdcH = String.new();
      String cdcC = String.new();
      
      String cddH = String.new();
      String cddC = String.new();
      
      String icalls = String.new();
      
      nuH += "extern int " += libnameInfo.libnameInitDone += ";" += nl;
      nuC += "int " += libnameInfo.libnameInitDone += " = 0;" += nl;
      
      nuH += "extern int " += libnameInfo.libNotNullInitDone += ";" += nl;
      nuC += "int " += libnameInfo.libNotNullInitDone += " = 0;" += nl;
      
      cddH += "extern int " += libnameInfo.libnameDataDone += ";" += nl;
      cddC += "int " += libnameInfo.libnameDataDone += " = 0;" += nl;
      
      String fkcdget = String.new();
      String nuCtc = String.new();
      Container:Set tkuniq = Container:Set.new();
      Container:Set fkuniq = Container:Set.new();
      Container:Set anuniq = Container:Set.new();
      for (any tckvs = emitData.synClasses.valueIterator;tckvs.hasNext;;) {
         Build:ClassSyn syn = tckvs.next;
         if (syn.libName == build.libName) {
            for (any fkv in syn.foreignClasses) {
               if (fkuniq.has(fkv.value)!) {
                  fkuniq.put(fkv.value);
                  nuH += "extern BERT_ClassDef* " += fkv.value += ";" += nl;
                  nuC += "BERT_ClassDef* " += fkv.value += " = NULL;" += nl;
                  fkcdget += fkv.value += " = BERF_ClassDef_Get(" += fkv.key.hash.toString() += ", (char*) " += textQuote += fkv.key += textQuote += ");" += nl;
               }
            }
            for (any ankv in syn.allNames) {
               if (anuniq.has(ankv.key)!) {
                  anuniq.put(ankv.key);
                  String nm = ankv.key;
                  
                  //the twnn_ version
                  String nn = "twnn_" + libName + "_" + nm;
                  nuH += "extern BEINT " += nn += ";" += nl;
                  nuC += "BEINT " += nn += " = 0;" += nl;
                  icalls += nn += " = BERF_GetCallIdForName(BERV_proc_glob, (char*)" += textQuote += nm += textQuote += ", " += nm.hash.toString() += ");" += nl;
                  
               }
            }
         }
      }
      
      String dlh = build.dllhead(String.new());
      
      for (Build:PropertyIndex pi in emitData.propertyIndexes) {
         String pin = getPropertyIndexName(pi.psyn);
         Build:ClassInfo ci = getInfoSearch(pi.origin);
         Build:ClassSyn osyn = build.getSynNp(pi.origin);
         if (pi.syn.directProperties) {
            String pinVal = (pi.psyn.mpos + build.constants.extraSlots).toString();
         } else {
            //could make it size_t max if needed for disambiguation...
            pinVal = "0";
         }
         nuH += "extern size_t " += pin += ";" += nl;
         nuC += "size_t " += pin += " = " += pinVal += ";" += nl;
         
         if (osyn.libName == build.libName) {
            //TODO this should not be needed of origin syn is final or local
            nuH += dlh += "extern size_t twpd_" += ci.midName += "_" += pi.psyn.name += "();" += nl;
            nuC += "size_t twpd_" += ci.midName += "_" += pi.psyn.name += "() {" += nl;
            if (pi.syn.directProperties) {
               nuC += "return " += pinVal += ";" += nl;
            } else {
               nuC += "return " += pin += ";" += nl;
            }
            nuC += "}" += nl;
         } elseIf (pi.syn.directProperties!) {
            //need to set pin by calling the origin lib if not direct properties and origin not in current lib
            fkcdget += pin += " = twpd_" += ci.midName += "_" += pi.psyn.name += "();" += nl;
         }
      }
      
      for (Build:MethodIndex mi in emitData.methodIndexes) {
         pin = getMethodIndexName(mi.msyn);
         ci = getInfoSearch(mi.declaration);
         osyn = build.getSynNp(mi.declaration);
         if (mi.syn.directMethods && build.closeLibraries.has(mi.syn.libName)) {
            pinVal = (mi.msyn.mtdx + build.constants.mtdxPad).toString();
         } else {
            //could make it size_t max if needed for disambiguation...
            pinVal = "0";
         }
         //TODO it isn't necessary to have the anyiable ref when
         //directMethods is true and closeLibrary is true
         //(you just need the call to get the index in the declaring lib)
         //(when it's directMethods it won't need the ref)
         nuH += "extern size_t " += pin += ";" += nl;
         nuC += "size_t " += pin += " = " += pinVal += ";" += nl;
         //("twpd libname " + osyn.libName + " decl " + mi.declaration + " pin " + pin).print();
         if (osyn.libName == build.libName) {
            nuH += dlh += "extern size_t twmd_" += ci.midName += "_" += mi.msyn.name += "();" += nl;
            nuC += "size_t twmd_" += ci.midName += "_" += mi.msyn.name += "() {" += nl;
            //I think the closeLibraries check here is redundant, if the method origin
            //is in this library then it is always in closeLibraries...
            if (mi.syn.directMethods && build.closeLibraries.has(mi.syn.libName)) {
               nuC += "return " += pinVal += ";" += nl;
            } else {
               nuC += "return " += pin += ";" += nl;
            }
            nuC += "}" += nl;
         } elseIf (mi.syn.directMethods! || build.closeLibraries.has(mi.syn.libName)!) {
            //need to set pin by calling the origin lib if not direct properties and origin not in current lib
            fkcdget += pin += " = twmd_" += ci.midName += "_" += mi.msyn.name += "();" += nl;
         }
      }
      
      nuH += dlh += "extern void " += libnameInfo.libnameInit += "();" += nl;
      nuH += dlh += "extern void " += libnameInfo.libNotNullInit += "(BERT_Stacks* berv_sts);" += nl;
      nuC += "void " += libnameInfo.libnameInit += "() { " + nl;
      nuC += "if (" += libnameInfo.libnameInitDone += " == 0) {" += nl;
      //nuC += "printf(" += textQuote += "In libnameInit for compile unit " += libnameInfo.clName += "\\n" += textQuote += ");";
      nuC += libnameInfo.libnameInitDone += " = 1;" += nl;
      
      cdcH += dlh += "extern void " += libnameInfo.libnameDataClear += "();" += nl;
      cdcC += "void " += libnameInfo.libnameDataClear += "() { " + nl;
      cdcC += libnameInfo.libnameDataDone += " = 0;" += nl;
      
      cddH += dlh += "extern void " += libnameInfo.libnameData += "(BERT_Stacks* berv_sts);" += nl;
      cddC += "void " += libnameInfo.libnameData += "(BERT_Stacks* berv_sts) { " + nl;
      cddC += "if (" += libnameInfo.libnameDataDone += " == 0) {" += nl;
      cddC += libnameInfo.libnameDataDone += " = 1;" += nl;
      
      nuC += icalls;
      String nniulc = String.new();
      String nniuld = String.new();
      for (any bpu in build.usedLibrarys) {
         nuCui += "#include <" += bpu.libnameInfo.namesIncH.toString() += ">" += nl;
         nuC += bpu.libnameInfo.libnameInit += "();" += nl;
         cdcC += bpu.libnameInfo.libnameDataClear += "();" += nl;
         cddC += bpu.libnameInfo.libnameData += "(berv_sts);" += nl;
         nniulc += bpu.libnameInfo.libNotNullInit += "(berv_sts);" += nl;
      }
      
      nuC += fkcdget;
      
      nuC += "BERV_proc_glob->mainCuData = " += libnameInfo.libnameData += ";" += nl;
      nuC += "BERV_proc_glob->mainCuClear = " += libnameInfo.libnameDataClear += ";" += nl;
      nuC += "BERV_proc_glob->mainNotNullInit = " += libnameInfo.libNotNullInit += ";" += nl;
      for (any it = emitData.synClasses.valueIterator;it.hasNext;;) {
         any tsyn = it.next;
         if (tsyn.libName == build.libName) {
            any clInfo = getInfo(tsyn.namepath);
            nuCi += "#include <" += clInfo.classIncH.toString(build.platform.separator) += ">" += nl;
            nuC += "if (" += clInfo.cldefName += " == NULL) { " += clInfo.cldefBuild += "(); }" += nl;
            cddC += "BERF_PrepareClassData( berv_sts, " += clInfo.cldefName += " );" += nl;
            if (tsyn.isNotNull) {
                  
                  //nniulc += "berv_sts->passedClassDef = " += classDefTarget(tsyn, tsyn) += ";" += nl;
                  //nniulc += "BEKF_6_11_SystemInitializer_notNullInitIt_1(0, berv_sts, NULL, BERF_Create_Instance(berv_sts, //berv_sts->passedClassDef, 0));" += nl; 
                  
                  nniulc += "berv_sts->passedClassDef = " += classDefTarget(tsyn, tsyn) += ";" += nl;
                  nniulc += "BEKF_6_11_SystemInitializer_notNullInitConstruct_1(0, berv_sts, NULL, BERF_Create_Instance(berv_sts, berv_sts->passedClassDef, 0));" += nl; 
                  if (tsyn.hasDefault) {
                    nniuld += "berv_sts->passedClassDef = " += classDefTarget(tsyn, tsyn) += ";" += nl;
                    nniuld += "BEKF_6_11_SystemInitializer_notNullInitDefault_1(0, berv_sts, NULL, BERF_Create_Instance(berv_sts, berv_sts->passedClassDef, 0));" += nl;
                  }
                   
                  
            }
         }
      }
      
      nuC += nuCtc;
      nuC += "}" + nl;
      nuC += "}" + nl;
      cdcC += "}" + nl;
      cddC += "}" + nl;
      cddC += "}" + nl;
      nuCui.writeTo(nC);
      nuCi.writeTo(nC);
      
      nuH.writeTo(nH);
      nuC.writeTo(nC);
      
      cdcH.writeTo(nH);
      cdcC.writeTo(nC);
      cddH.writeTo(nH);
      cddC.writeTo(nC);
      
      String nni = String.new();
      nni += "void " += libnameInfo.libNotNullInit += "(BERT_Stacks* berv_sts) { " + nl;
      nni += "if (" += libnameInfo.libNotNullInitDone += " == 0) {" += nl;
      nni += libnameInfo.libNotNullInitDone += " = 1;" += nl;
      nni += nniulc;
      nni += nniuld;
      nni += "}" += nl;
      nni += "}" += nl;
      nni.writeTo(nC);
      
      nH.write("#endif" + nl);
      nH.close();
      nC.close();
   }
   
   classDefTarget(Build:ClassSyn targSyn, Build:ClassSyn inClassSyn) String {
         if (targSyn.libName != build.libName) {
            //foreignClass
            String targ = foreignClass(targSyn.namepath, inClassSyn);
         } else {
            targ = getInfo(targSyn.namepath).cldefName;
         }
         return(targ);
    }
   
   resolveConflicts() {
      any sb = Text:String.new();
      for (any i = emitData.nameEntries.keyIterator;i.hasNext;;) {
         any nm = i.next;
         any xe = emitData.nameEntries.get(nm);
         any conflicts = xe.findConflicts();
         if (def(conflicts)) {
            System:Classes.className(conflicts).print();
            any v = xe.values.first;
            for (any cu in conflicts) {
               sb = sb + "twnn_" + cu + "_" + nm + " = " + v.toString() + ";";
            }
         }
      }
      return(sb.toString());
   }
   
   make(pack) {
      System:Command.new(build.makeName + " " + build.makeArgs + " -f " + mainClassInfo.makeSrc.toString()).run();
   }
   
   run(pack, runArgs) {
      any packClassInfo = Build:ClassInfo.new(self.libnameNp, self, pack.emitPath, pack.libName, pack.exeName);
      String line = packClassInfo.unitExe.toString() + " " + runArgs;
      ("Running " + line).print();
      return(System:Command.new(line).run());
   }
   
   prepMake(pack) {
      any colon = " : ";
      any tab = Text:Strings.new().tab;
      any cpro = build.compilerProfile;
      String ccout = cpro.ccout;
      String oext = cpro.oext;
      String smac = cpro.smac;
      
      String ccObj = cpro.ccObj + smac + "BENC_" + build.libName + " " + smac + "BENP_" + build.platform.name + " ";
      String ccExe = cpro.ccObj + smac + "BENP_" + build.platform.name + " ";
      
      any psep = build.platform.separator;
      
      any di = " " + cpro.di;
      
      allInc = Text:String.new();
      allInc = cpro.di + build.emitPath.toString() + di + build.includePath.toString();
      for (any it = build.extIncludes.iterator;it.hasNext;;) {
         allInc = allInc + di + it.next;
      }
      
      ccObjArgsStr = Text:String.new();
      for (it = build.ccObjArgs.iterator;it.hasNext;;) {
         ccObjArgsStr = ccObjArgsStr + it.next + " ";
      }
      
      any isBase = true;
      any alibs = build.extLibs.copy();
      for (any bp in build.usedLibrarys) {
         isBase = false;
         allInc = allInc + di + bp.emitPath.toString();
         alibs.addValue(bp.libnameInfo.unitExeLink.toString());
      }
      
      if (build.linkLibArgs.size > 0) {
         linkLibArgsStr = " " + Text:Strings.new().join(Text:Strings.new().space, build.linkLibArgs);
      } else {
         linkLibArgsStr = "";
      }
      extLib = Text:Strings.new().join(Text:Strings.new().space, alibs);
      
      any incPath = build.includePath.toString();
      
      any mn = build.mainName;
      mainClassNp = Build:NamePath.new();
      mainClassNp.fromString(mn);
      mainClassInfo = getInfoNoCache(mainClassNp);
      any packClassInfo = Build:ClassInfo.new(self.libnameNp, self, pack.emitPath, pack.libName, pack.exeName);
      
      any baseBuildObj = Text:String.new();
      any bos = Text:String.new();
      any allos = Text:String.new();
      
      if (isBase) {
         baseBuildObj = baseBuildObj + incPath + psep + build.platform.name + psep + "BER_Base" + oext + " : " + incPath + psep + "BER_Base" + cpro.cext + " " + incPath + psep + "BER_Base.h" + nl + tab + ccObj + ccObjArgsStr + allInc + ccout + incPath + psep + build.platform.name + psep + "BER_Base" + oext + " " + incPath + psep + "BER_Base" + cpro.cext + nl;
      }
      
      baseBuildObj = baseBuildObj + libnameInfo.namesO.toString() + " : " + libnameInfo.cuinit.toString() + " " + libnameInfo.cuinitH.toString() + nl + tab + ccObj + ccObjArgsStr + allInc + ccout + libnameInfo.namesO.toString() + " " + libnameInfo.cuinit.toString() + nl;
      
      if (isBase) {
         allos = allos + " " + incPath + psep + build.platform.name + psep + "BER_Base" + oext;
      }
      
      for (String aloa in build.extLinkObjects) {
         allos = allos + " " + aloa;
      }
      
      //allos = allos + " " + libnameInfo.namesO.toString();
      for (it = emitData.synClasses.keyIterator;it.hasNext;;) {
         //TODO add superclass h to dependent list
         any sname = it.next;
         any syn = emitData.synClasses.get(sname);
         if (syn.libName == build.libName) { //verify same libName
            any clinfo = getInfo(syn.namepath);
            bos = bos + clinfo.classO.toString() + colon + clinfo.classSrc.toString() + nl;
            bos = bos + tab + ccObj + ccObjArgsStr + allInc + ccout + clinfo.classO.toString() + " " + clinfo.classSrc.toString() + nl;
            allos = allos + " " + clinfo.classO.toString();
         }
      }
      bos = bos + baseBuildObj;
      //any libmk = libnameInfo.unitShlib.toString() + colon + allos + " " + libnameInfo.namesO.toString() + nl + tab + cpro.lBuild + libnameInfo.unitShlib.toString();
      //+ tab + cpro.doMakeDirs(packClassInfo.unitShlib.parent.toString()) + nl 
      cpro.doMakeDirs(packClassInfo.unitShlib.parent.toString());
      any libmk = packClassInfo.unitShlib.toString() + colon + allos + " " + libnameInfo.namesO.toString() + nl + tab + cpro.lBuild + packClassInfo.unitShlib.toString();
      libmk = libmk + allos + " " + libnameInfo.namesO.toString() + " " + extLib + linkLibArgsStr + nl;
      //libmk = libmk + tab + cpro.doCopy + packClassInfo.unitShlib.toString() + " " + libnameInfo.unitShlib.toString() + nl;
      
      any exmk = packClassInfo.unitExe.toString() + colon + packClassInfo.unitShlib.toString() + " " + mainClassInfo.classExeSrc.toString() + nl;
      exmk = exmk + tab + ccExe + ccObjArgsStr + allInc + ccout + mainClassInfo.classExeO.toString() + " " + mainClassInfo.classExeSrc.toString() + nl;
      exmk = exmk + tab + cpro.lexe + packClassInfo.unitExe.toString() + " " + mainClassInfo.classExeO.toString() + " " + packClassInfo.unitExeLink.toString() + " " + extLib + nl;
      
      any mkfile = mainClassInfo.makeSrc.file;
      mkfile.delete();
      any emitMk = mkfile.writer.open();
      //make sure the separator is what make likes
      if (build.makeName == "make") {
         exmk = exmk.swap("\\", "/");
         libmk = libmk.swap("\\", "/");
         bos = bos.swap("\\", "/");
      }
      emitMk.write(exmk);
      emitMk.write(libmk);
      emitMk.write(bos);
      emitMk.close();
   }
   
   emitMain() {
      any mn = build.mainName;
      mainClassNp = Build:NamePath.new();
      mainClassNp.fromString(mn);
      mainClassInfo = getInfoNoCache(mainClassNp);
      any realMcl = getInfoSearch(mainClassNp);
      self.libnameInfo;
      if (def(mainClassInfo)) {
         any bp = mainClassInfo.basePath;
         if (bp.file.exists!) {
            bp.file.makeDirs();
         }
         mainClassInfo.classExeSrc.file.delete();
         any emitMp = mainClassInfo.classExeSrc.file.writer.open();
         any ms = Text:String.new();
         ms = ms + "#include <BER_Base.h>" + nl;
         ms = ms + "#include <" + realMcl.classIncH.toString(build.platform.separator) + ">" + nl;
         ms = ms + "#include <" + self.libnameInfo.namesIncH.toString() + ">" + nl;
         ms = ms + "int main(int argc, char **argv) {" + nl;
         ms = ms + "return BERF_Run_Main(argc, argv, (char*) " + textQuote + realMcl.clName + textQuote + ", " + self.libnameInfo.libnameInit + ", (char*) " + textQuote + build.platform.name + textQuote + ");"
         ms = ms + "}" + nl;
         emitMp.write(ms);
         emitMp.close();
      }
   }
   
   deployLibrary(pack) {
      any cpro = build.compilerProfile;
      String ccout = cpro.ccout;
      for (any it = emitData.synClasses.valueIterator;it.hasNext;;) {
         any tsyn = it.next;
         //"A".print();
         if (tsyn.libName == build.libName) {
            any np = tsyn.namepath;
            pci = Build:ClassInfo.new(np, self, pack.emitPath, build.libName, build.exeName);
            any lci = getInfo(tsyn.namepath);
            deployFile(lci.classSrcH.file, pci.classSrcH.file);
            deployFile(lci.synSrc.file, pci.synSrc.file);
         }
      }
      any mn = build.mainName;
      any mainClassNp = Build:NamePath.new();
      mainClassNp.fromString(mn);
      lci = getInfo(mainClassNp);
      pci = Build:ClassInfo.new(mainClassNp, self, pack.emitPath, pack.libName);
      any cuf = self.libnameInfo;
      deployFile(cuf.cuinitH.file, pack.libnameInfo.cuinitH.file);
   }
   
   deployFile(File origin, File dest) {
      origin.copyFile(dest);
   }
   
}

class Build:CompilerProfile {

   new(build) self {
   
      fields {
         String exeExt;
         String libExt;
         String ccObj;
         String cc;
         String cext;
         String oext;
         String lBuild;
         String ccout;
         String doCopy;
         String mkdirs;
         String lexe;
         String exeLibExt;
         String name;
         String di;
         String smac;
         String dialect;
         String compiler;
      }
   
      exeExt = ".exe";
      name = build.platform.name;
      oext = ".o";
      di = "-I ";
      smac = "-D ";
      dialect = "c";
      String dialectMacro = "BENM_DC";
      if (undef(build.compiler)) {
         build.compiler = "gcc";
      }
      compiler = build.compiler;
      if (build.compiler == "gcc") {
         cc = "gcc ";
         cext = ".c";
      } elseIf (build.compiler == "g++") {
         //If you want to use c++
         cc = "g++ ";
         cext = ".cpp";
         dialect = "c++";
         dialectMacro = "BENM_DCPP";
      } elseIf (build.compiler == "apgcc") {
         //If you want to use autopackage
         cc = "apgcc ";
         cext = ".c";
      } elseIf (build.compiler == "apg++") {
         //If you want to use autopackage and c++
         cc = "apg++ ";
         cext = ".cpp";
         dialect = "c++";
         dialectMacro = "BENM_DCPP";
      }
      if (build.platform.name == "macos") {
         libExt = ".dylib";
         ccObj = cc + "-c -D BENM_ISNIX -D " + dialectMacro + " -dynamic ";
         lBuild = "libtool -dynamic -lcc_dynamic -o ";
         ccout = " -o ";
         doCopy = "cp ";
         mkdirs = "mkdir -p ";
         lexe = cc + "-D BENM_ISNIX -D " + dialectMacro + " -o ";
         exeLibExt = libExt;
      }
      if (build.platform.name == "linux" || build.platform.name == "freebsd") {
         libExt = ".so";
         ccObj = cc + "-c -D BENM_ISNIX -D " + dialectMacro + " -fPIC ";
         lBuild = cc + "-D BENM_ISNIX -D " + dialectMacro + " -shared -o ";
         ccout = " -o ";
         doCopy = "cp ";
         mkdirs = "mkdir -p ";
         lexe = cc + "-D BENM_ISNIX -D " + dialectMacro + " -o ";
         exeLibExt = libExt;
      }
      if (build.platform.name == "mswin") {
         exeExt = ".exe";
         if (build.compiler == "msvc") {
            cc = "cl ";
            cext = ".cpp";
            dialect = "c++";
            dialectMacro = "BENM_DCPP";
            libExt = ".dll";
            ccObj = cc + "-nologo -MD -c -D BENM_MSVC -D BENM_ISWIN -D " + dialectMacro + " -D BENM_DLLEXPORT -D _CRT_SECURE_NO_DEPRECATE -D _CRT_NONSTDC_NO_DEPRECATE ";
            lBuild = "link -MANIFEST -DLL -OUT:";
            ccout = " -Fo";
            doCopy = "copy ";
            mkdirs = "mkdir ";
            lexe = "link -MANIFEST -OUT:";
            exeLibExt = ".lib";
         } else {
            libExt = ".dll";
            ccObj = cc + "-c -D BENM_GCC -D BENM_ISWIN -D " + dialectMacro + " -D BENM_DLLEXPORT ";
            lBuild = cc + "-D BENM_GCC -D BENM_ISWIN -shared -o ";
            ccout = " -o ";
            doCopy = "cp ";
            mkdirs = "mkdir -p ";
            lexe = cc + "-D BENM_GCC -D BENM_ISWIN -D " + dialectMacro + " -D BENM_DLLEXPORT -o ";
            exeLibExt = libExt;
         }
      }
      any exeExtOverride = build.params["exeExtOverride_" + build.platform.name];
      if (def(exeExtOverride) && def(exeExtOverride.first)) {
         exeExt = exeExtOverride.first;
      }
   }
   
   doMakeDirs(String path) {
      File.new(path).makeDirs();
   }
}

