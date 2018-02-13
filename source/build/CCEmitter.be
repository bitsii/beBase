// Copyright 2015 Craig Welch
//
// Licensed under the MIT license. See LICENSE.txt file in the project root 
// for full license information.

use Container:Map;
use Container:LinkedList;
use IO:File;
use Build:Visit;
use Build:EmitException;
use Build:Node;
use Build:ClassConfig;

use final class Build:CCEmitter(Build:EmitCommon) {

    
    new(Build:Build _build) {
        emitLang = "cc";
        fileExt = ".cpp";
        exceptDec = "";
        fields {
          String headExt = ".hpp";
          String classHeadBody = String.new();
          String classHeaders = String.new();
          String onceDecRefs = String.new();
          Int onceDecRefsCount = 0;
        }
        
        //super new depends on some things we set here, so it must follow
        super.new(_build);
        
        invp = "->";
        scvp = "::";
        nullValue = "nullptr";
        trueValue = "BECS_Runtime::boolTrue";
        falseValue = "BECS_Runtime::boolFalse";
    }
    
    addClassHeader(String h) {
      classHeaders += h;
    }
    
    classBegin(Build:ClassSyn csyn) String {
       if (def(parentConf)) {
          String extends = extend(parentConf.relEmitName(build.libName));
       } else {
          extends = extend("BECS_Object");
       }
       String begin = "class " += classConf.emitName += extends += " {"; //}
       
       if (def(parentConf)) {
         begin += "\n";
         
         begin += "private:\n";
         
         begin += "typedef " += parentConf.relEmitName(build.libName) += " bevs_super;\n";
      } else {
         begin += "\n";
         
         begin += "private:\n";
         
         begin += "typedef BECS_Object bevs_super;\n";
      }
       
       begin += "\n";
       
       begin += "public:\n";
       
       heow.write(begin);
       
       heow.write(propertyDecs);
       
       heow.write(classHeadBody);
       
       classHeadBody.clear();
       
       heow.write("virtual BEC_2_4_6_TextString* bemc_clnames();\n");
       heow.write("virtual BEC_2_4_6_TextString* bemc_clfiles();\n");
       heow.write("virtual BEC_2_6_6_SystemObject* bemc_create();\n");
       heow.write("static " + classConf.emitName + "* " + getHeaderInitialInst(classConf) + ";\n");
       heow.write("virtual void bemc_setInitial(BEC_2_6_6_SystemObject* becc_inst);\n");
       heow.write("virtual BEC_2_6_6_SystemObject* bemc_getInitial();\n");
       heow.write("virtual void bemg_doMark();\n");
       heow.write("virtual size_t bemg_getSize();\n");
       heow.write("virtual BETS_Object* bemc_getType();\n");
       heow.write("static vector<int32_t> bevs_smnlc;\n");
       heow.write("static vector<int32_t> bevs_smnlec;\n");
       heow.write("virtual ~" + classConf.emitName + "() = default;\n");
       
       deow.write("class " + classConf.emitName + ";\n");
       
       return("");
    }
    
    buildCreate() {
        ccMethods += self.overrideMtdDec += getClassConfig(objectNp).relEmitName(build.libName) += "* " += classConf.emitName += "::bemc_create()" += exceptDec += " {" += nl;  //}
            ccMethods += "return new " += getClassConfig(cnode.held.namepath).relEmitName(build.libName) += "();" += nl;
        //{
        ccMethods += "}" += nl;
    }
    
    classEndGet() String {
       String end = "";
       //{
       heow.write(classHeaders);
       classHeaders.clear();
       heow.write("};\n\n");
       return(end);
    }
   
   baseMtdDec(Build:MtdSyn msyn) String {
     return("");
    }
    
    overrideMtdDec(Build:MtdSyn msyn) String {
       return("");
    }
   
   propDecGet() String {
        return("");
    }
   
   startMethod(String mtdDec, ClassConfig returnType, String mtdName, String argDecs, exceptDec) {
     
       methods += mtdDec += returnType.relEmitName(build.libName) += "* " += classConf.emitName += "::" += mtdName += "(";
        
       methods += argDecs;
        
       methods += ")" += exceptDec += " {" += nl; //}
       
       classHeadBody += "virtual " += returnType.relEmitName(build.libName) += "* " += mtdName += "(";
        
       classHeadBody += argDecs;
        
       classHeadBody += ");\n";
      
    }
    
    formTarg(Node node) String {
      String tcall;
      if (node.typename == ntypes.NULL) {
         tcall = "nullptr";
      } elseIf (node.held.name == "self") {
         tcall = "this";
      } elseIf (node.held.name == "super") {
         tcall = "bee_yosuperthis";
      } else {
         tcall = nameForVar(node.held);
      }
      return(tcall);
   }
   
   formCallTarg(Node node) String {
      if (node.held.name == "super") {
        String tcall = "bevs_super" + scvp;//needs to be parent class
        return(tcall);
      }
      return(super.formCallTarg(node));
   }
   
   acceptThrow(Node node) {
        methodBody += "throw BECS_ThrowBack(" += formTarg(node.second) += ");" += nl;
   }
      
   handleClassEmit(Node node) {
      if (node.held.langs.has("cc_classHead")) {
        classHeaders += node.held.text;
      } else {
        super.handleClassEmit(node);
      }
   }
   
   typeDecGet() String {
   
       String bein = "bece_" + classConf.emitName + "_bevs_type";
   
       String clh = "static " + classConf.typeEmitName + " " + bein + ";\n";
       
       addClassHeader(clh);
       
       String initialDec = String.new();
       
       initialDec += classConf.typeEmitName += " " += classConf.emitName += "::" += bein += ";\n";
       
       initialDec += "BEC_2_6_6_SystemObject** " += classConf.typeEmitName += "::bevs_inst_ref = (BEC_2_6_6_SystemObject**) &" += classConf.emitName += "::bece_" + classConf.emitName + "_bevs_inst;\n";
       
       return(initialDec);
       
  }
   
   acceptCatch(Node node) {
    String catchVar = "beve_" + methodCatch.toString();
    methodCatch++=;
    methodBody += " catch (BECS_ThrowBack " += catchVar += ") {" += nl; //}
    
    methodBody += finalAssign(node.contained.first.contained.first, "BECS_ThrowBack::handleThrow(" + catchVar + ")", null, null);
   }
   
   typeDecForVar(String b, Build:Var v) {
      if (v.isTyped!) {
        b += objectCc.relEmitName(build.libName) += "*";
      } else {
        b += getClassConfig(v.namepath).relEmitName(build.libName) += "*";
      }
   }
   
   formCast(ClassConfig cc, String type) String {
     if (type == "unchecked") {
       String ccall = "static_cast";
     } else {
       ccall = "dynamic_cast";
     }
     return(ccall + "<" + cc.relEmitName(build.libName) + "*>(");//)
   }
   
   afterCast() String {
     //(
     return(")");
   }
   
   buildClassInfoMethod(String bemBase, String belsBase, Int len) {      
      ccMethods += self.overrideMtdDec += "BEC_2_4_6_TextString* " += classConf.emitName += "::bemc_" += bemBase += "s()" += exceptDec += " {" += nl;  //}
      ccMethods += "return new BEC_2_4_6_TextString(" += len += ", becc_" += belsBase += ");" += nl;
      //{
      ccMethods += "}" += nl;
  }
   
   lintConstruct(ClassConfig newcc, Node node, Bool isOnce) String {
      if (isOnce) {
        return("new " + newcc.relEmitName(build.libName) + "(" + node.held.literalValue + ")");
      }
      String newCall = "(" + newcc.relEmitName(build.libName) + "*) (bevs_stackFrame.bevs_lastConstruct = new " + newcc.relEmitName(build.libName) + "(" + node.held.literalValue + "))";
      return(newCall);
   }
   
   lfloatConstruct(ClassConfig newcc, Node node, Bool isOnce) String {
      if (isOnce) {
        return("new " + newcc.relEmitName(build.libName) + "(" + node.held.literalValue + "f)");
      }
      String newCall = "(" + newcc.relEmitName(build.libName) + "*) (bevs_stackFrame.bevs_lastConstruct = new " + newcc.relEmitName(build.libName) + "(" + node.held.literalValue + "f))";
      return(newCall);
   }
   
   lstringConstruct(ClassConfig newcc, Node node, String belsName, Int lisz, Bool isOnce) String {
      if (isOnce) {
        return("new " + newcc.relEmitName(build.libName) + "(" + belsName + ", " + lisz + ")");
      }
      //return("new " + newcc.relEmitName(build.libName) + "(" + lisz + ", " + belsName + ")");
      String litArgs = "" + lisz + ", " + belsName;
      String newCall = "(" + newcc.relEmitName(build.libName) + "*) (bevs_stackFrame.bevs_lastConstruct = new " + newcc.relEmitName(build.libName) + "(" + litArgs + "))";
      return(newCall);
   }
      
      onceDec(String typeName, String anyName) {
         onceDecRefsCount++=;
         if (TS.notEmpty(onceDecRefs)) {
           onceDecRefs += ", ";
         }
         onceDecRefs += "(BEC_2_6_6_SystemObject**) &" += anyName;
         return("static " + typeName + "* ");
      }
      
      lstringByte(String sdec, String lival, Int lipos, Int bcode, String hs) {
        
        lival.getCode(lipos, bcode);
        String bc = bcode.toHexString(hs);
        sdec += "0x"@;
        sdec += bc;
        //sdec += ","@;
    }
      
      
      overrideSpropDec(String typeName, String anyName) {
        return(typeName + " " + anyName);
      }
   
   boolTypeGet() String {
      return("boolean");
   }
   
   mainInClassGet() Bool {
        return(false);
    }
    
   
   mainOutsideNsGet() Bool {
        return(true);
    }
   
   mainStartGet() String {
        String ms = "main(String[] args)" + exceptDec + " {" + nl;//}
        ms += "synchronized (" += libEmitName += ".class) {" += nl;//}
        ms += "be.BECS_Runtime.args = args;" += nl;
        ms += "be.BECS_Runtime.platformName = \"" += build.outputPlatform.name += "\";" += nl;
        //return(ms);
        return("");
   }
    
    superNameGet() String {
       return("super");
    }
    
    extend(String parent) String {
        return(" : public "@ + parent);
    }
    
    preClassOutput() {
      fields {
        Time:Interval setOutputTime;
      }
      setOutputTime = null;
      if (build.singleCC || classConf.classPath.file.exists!) {
        return(self);
      } else {
        Time:Interval outts = classConf.classPath.file.lastUpdated;
        Time:Interval ints = inClass.fromFile.file.lastUpdated;
        if (ints > outts) {
          //("newer outputting " + classConf.classPath).print();
          //("tss " + ints + " " + outts).print();
          return(self);
        }
        //("older not outputting " + classConf.classPath).print();
        setOutputTime = outts;
      }
   }
    
    getClassOutput() IO:File:Writer {
      if (build.singleCC) {
       return(getLibOutput());
      }
      return(super.getClassOutput());
    }
    
   startClassOutput(IO:File:Writer cle) {
     unless (build.singleCC) {
       String clns = "#include \"BEH_4_Base.hpp\"\nnamespace be {\n"; //}
       lineCount += countLines(clns);
       cle.write(clns);
     }
   }

   finishClassOutput(IO:File:Writer cle) {
     unless (build.singleCC) {
       //{
       String clend = "}\n";
       lineCount += countLines(clend);
       cle.write(clend);
       cle.close();
       if (def(setOutputTime)) {
        cle.path.file.lastUpdated = setOutputTime;
        setOutputTime = null;
       }
     }
   }
   
   genMark(String mvn) String {
       String bet = String.new();
       bet += "if (" += mvn += " != nullptr && " += mvn += "->bevg_gcMark != BECS_Runtime::bevg_currentGcMark) {" += nl;
       bet += mvn += "->bemg_doMark();" += nl;
       bet += "}" += nl;
       return(bet);
   }
   
   writeBET() {
        deow.write("class " + classConf.typeEmitName + ";\n");
        String beh = String.new();
        beh += "class " += classConf.typeEmitName += " : public BETS_Object {\n";
        beh += "public:\n";
        beh += classConf.typeEmitName += "();\n";
        beh += "virtual BEC_2_6_6_SystemObject* bems_createInstance();\n";
        beh += "virtual void bemgt_doMark();\n";
        beh += "static BEC_2_6_6_SystemObject** bevs_bevo_refs[" += onceDecRefsCount += "];\n";
        beh += "static size_t bevs_bevo_refs_count;\n";
        beh += "static BEC_2_6_6_SystemObject** bevs_inst_ref;\n";
        beh += "};\n";
        heow.write(beh);
        
        String bet = String.new();
        bet += classConf.typeEmitName += "::" += classConf.typeEmitName += "() {\n";
        bet += "std::vector<std::string> bevs_mtnames = { ";
        Bool firstmnsyn = true;
        for (Build:MtdSyn mnsyn in csyn.mtdList) {
          if (firstmnsyn) {
            firstmnsyn = false;
          } else {
            bet += ", ";
          }
          bet += q += mnsyn.name += q;
         }
         bet += " };\n";
        bet += "bems_buildMethodNames(bevs_mtnames);\n";
        
        bet += "bevs_fieldNames = { ";
        Bool firstptsyn = true;
        for (Build:PtySyn ptySyn in csyn.ptyList) {
          if (firstptsyn) {
            firstptsyn = false;
          } else {
            bet += ", ";
          }
          bet += q += ptySyn.name += q;
        }
        bet += " };\n";
        
        bet += "}\n";
        
        bet += "BEC_2_6_6_SystemObject* " += classConf.typeEmitName += "::bems_createInstance() {\n";
        if (classConf.emitName == "BEC_2_6_6_SystemObject") {
          bet += "return new " += classConf.emitName += "();\n";
        } else {
          bet += "return new " += classConf.emitName += "();\n";
        }
        bet += "}\n";
        
        bet += "void " += classConf.typeEmitName += "::bemgt_doMark() {\n";
        bet += "BEC_2_6_6_SystemObject* bevsl_inst_ref = *bevs_inst_ref;\n";
        bet += genMark("bevsl_inst_ref");
        bet += "for (size_t i = 0; i < bevs_bevo_refs_count; i++) {\n";
        bet += "BEC_2_6_6_SystemObject* bevg_le = *(bevs_bevo_refs[i]);\n";
        bet += genMark("bevg_le");
        bet += "}\n";
        bet += "}\n";
        
        onceDecs += "BEC_2_6_6_SystemObject** " += classConf.typeEmitName += "::bevs_bevo_refs[" += onceDecRefsCount += "] = { " += onceDecRefs += "};" += nl;
        onceDecs += "size_t  " += classConf.typeEmitName += "::bevs_bevo_refs_count = " += onceDecRefsCount += ";\n";
        onceDecRefs.clear();
        onceDecRefsCount = 0;
        //also need the count
        getClassOutput().write(bet);
        lineCount += countLines(bet);
    }
   
   prepHeaderOutput() {
        fields { 
           String deon;
           String heon;
           IO:File:Path deop;
           IO:File:Path heop;
           IO:File:Writer deow;
           IO:File:Writer heow; 
        }
        if (undef(deow)) {
           String libName = build.libName;
           deon = "BED_" + libName.size + "_" + libName + headExt;
           heon = "BEH_" + libName.size + "_" + libName + headExt;
           deop = libEmitPath.parent.addStep(deon);
           heop = libEmitPath.parent.addStep(heon);
           if (libEmitPath.parent.file.exists!) {
              libEmitPath.parent.file.makeDirs();
           }
            deow = deop.file.writer.open();
            heow = heop.file.writer.open();
            
            if (build.params.has("cchImport")) {
                //("got cchinclude").print();
                for (p in build.params["cchImport"]) {
                    //("cchinclude " + p).print();
                    jsi = IO:File:Path.apNew(p).file;
                    inc = jsi.reader.open().readString();
                    jsi.reader.close();
                    //("including " + inc).print();
                    heow.write(inc);
                }
            }
            
            heow.write("#include \"BED_4_Base.hpp\"\n");
            heow.write("using namespace std;\n");
            
            deow.write("namespace be {\n");//}
            heow.write("namespace be {\n");//}
            
            String p;
            File jsi;
            String inc;
            //incorporate base file - ext lib
            if (build.params.has("ccdInclude")) {
                //("got ccdinclude").print();
                for (p in build.params["ccdInclude"]) {
                    //("ccdinclude " + p).print();
                    jsi = IO:File:Path.apNew(p).file;
                    inc = jsi.reader.open().readString();
                    jsi.reader.close();
                    //("including " + inc).print();
                    deow.write(inc);
                }
            }
            if (build.params.has("cchInclude")) {
                //("got cchinclude").print();
                for (p in build.params["cchInclude"]) {
                    //("cchinclude " + p).print();
                    jsi = IO:File:Path.apNew(p).file;
                    inc = jsi.reader.open().readString();
                    jsi.reader.close();
                    //("including " + inc).print();
                    heow.write(inc);
                }
            }
        }
    }
    
    begin (transi) {
      super.begin(transi);
      prepHeaderOutput();
    }

    getLibOutput() IO:File:Writer {
        fields { IO:File:Writer shlibe; }
        if (undef(shlibe)) {
           lineCount = 0;
           if (libEmitPath.parent.file.exists!) {
              libEmitPath.parent.file.makeDirs();
           }
            shlibe = libEmitPath.file.writer.open();
            //incorporate base file - ext lib
            shlibe.write("#include \"BEH_4_Base.hpp\"\n");
            
            if (build.params.has("ccImport")) {
                //("got cchinclude").print();
                for (p in build.params["ccImport"]) {
                    //("cchinclude " + p).print();
                    jsi = IO:File:Path.apNew(p).file;
                    inc = jsi.reader.open().readString();
                    jsi.reader.close();
                    //("including " + inc).print();
                    shlibe.write(inc);
                }
            }
            
            shlibe.write("namespace be {\n");//}
            lineCount++;
            if (build.params.has("ccInclude")) {
                for (String p in build.params["ccInclude"]) {
                    File jsi = IO:File:Path.apNew(p).file;
                    String inc = jsi.reader.open().readString();
                    jsi.reader.close();
                    lineCount += countLines(inc);
                    shlibe.write(inc);
                }
            }
            //incorporate incorporate other libs TODO

        }
        return(shlibe);
    }

    finishLibOutput(IO:File:Writer libe) {
        libe.close();
        shlibe = null;
        //{
        deow.write("}\n");//end namespace
        //{
        heow.write("}\n");//end namespace
        deow.close();
        heow.close();
        //end module
    }
    
    coanyiantReturnsGet() {
        return(false);
    }
    
   lstringStart(String sdec, String belsName) {
      sdec += "static vector<unsigned char> " += belsName += " = {"; //}
   }
   
   buildPropList() {

        Build:ClassSyn syn = cnode.held.syn;
        List ptyList = syn.ptyList;

        ccMethods += classConf.emitName += ".prototype.bepn_pnames = ["; //]

        Bool first = true;
        for (Build:PtySyn ptySyn in ptyList) {
            if (first) {
                first = false;
            } else {
                ccMethods += ", ";
            }
            ccMethods += q += "bevp_" += ptySyn.name += q;
        }

        //[
        ccMethods += "];" += nl;
    }
    
    initialDecGet() String {
       
         String initialDec = String.new();
         
         String bein = "bece_" + classConf.emitName + "_bevs_inst";
         
         initialDec += classConf.emitName += "* " += classConf.emitName += "::" += bein += ";\n";
         
         return(initialDec);
    }
    
    getHeaderInitialInst(ClassConfig newcc) String {
      auto nccn = newcc.relEmitName(build.libName);
      String bein = "bece_" + nccn + "_bevs_inst";
      return(bein);
     }
    
    getInitialInst(ClassConfig newcc) String {
      auto nccn = newcc.relEmitName(build.libName);
      String bein = "bece_" + nccn + "_bevs_inst";
      return(nccn + "::" + bein);
     }
     
    runtimeInitGet() String {
        return("BECS_Runtime::init();" + nl);
    }

    buildInitial() {
        String oname = getClassConfig(objectNp).relEmitName(build.libName);
        ClassConfig newcc = getClassConfig(cnode.held.namepath);
        String stinst = getInitialInst(newcc);
        
        ccMethods += self.overrideMtdDec += "void " += newcc.emitName += "::bemc_setInitial(" += oname += "* becc_inst)" += exceptDec += " {" += nl;  //}
            asnr = "becc_inst";
            if (newcc.emitName != oname) {
                String asnr = formCast(classConf, "unchecked", asnr);//no need for type check
            }
            
            ccMethods += stinst += " = " += asnr += ";" += nl;
        //{
        ccMethods += "}" += nl;
        
        
        ccMethods += self.overrideMtdDec += oname += "* " += newcc.emitName += "::bemc_getInitial()" += exceptDec += " {" += nl;  //}
            
            //if (newcc.emitName != oname) {
            //  ccMethods += "return static_cast<" += oname += "*>(" += stinst += ");" += nl;
            //} else {
              ccMethods += "return " += stinst += ";" += nl;
            //}
        //{
        ccMethods += "}" += nl;
        
        ccMethods += self.overrideMtdDec += "void " += newcc.emitName += "::bemg_doMark()" += exceptDec += " {" += nl;  //}
            if (undef(cnode.held.extends) || cnode.held.extends == objectNp) {
              ccMethods += "bevg_gcMark = BECS_Runtime::bevg_currentGcMark;" += nl;
            } else {
              ccMethods += "bevs_super::bemg_doMark();" += nl;
            }
            ccMethods += gcMarks;
            gcMarks.clear();
            
        //{
        ccMethods += "}" += nl;
        
        ccMethods += self.overrideMtdDec += "size_t " += newcc.emitName += "::bemg_getSize()" += exceptDec += " {" += nl;  //}
              ccMethods += "return sizeof(*this);" += nl;
        //{
        ccMethods += "}" += nl;
        
        String tinst = getTypeInst(newcc);
        
        ccMethods += "BETS_Object* " += newcc.emitName += "::bemc_getType() {" += nl;  //}
            
            ccMethods += "return &" += tinst += ";" += nl;
        //{
        ccMethods += "}" += nl;
        
    }
    
    emitLib() {
      
      deow.write("class BEX_E;\n");
      heow.write("class BEX_E : public BECS_Lib {\npublic:\nstatic void init();\n};\n");
      
      super.emitLib();
      
    }
    
    getTypeInst(ClassConfig newcc) String {
    auto nccn = newcc.relEmitName(build.libName);
    String bein = "bece_" + nccn + "_bevs_type";
    return(nccn + "::" + bein);
   }

}
