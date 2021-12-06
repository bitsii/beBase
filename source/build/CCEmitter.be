// Copyright 2015 The Brace Authors. All rights reserved.
// Use of this source code is governed by the BSD-3-Clause
// license that can be found in the LICENSE file.

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
       
       unless (build.emitChecks.has("noSmap")) {
         heow.write("virtual std::shared_ptr<BEC_2_4_6_TextString> bemc_clnames();\n");
         heow.write("virtual std::shared_ptr<BEC_2_4_6_TextString> bemc_clfiles();\n");
       }
       heow.write("virtual std::shared_ptr<BEC_2_6_6_SystemObject> bemc_create();\n");
       heow.write("static std::shared_ptr<" + classConf.emitName + "> " + getHeaderInitialInst(classConf) + ";\n");
       heow.write("virtual void bemc_setInitial(std::shared_ptr<BEC_2_6_6_SystemObject> becc_inst);\n");
       heow.write("virtual std::shared_ptr<BEC_2_6_6_SystemObject> bemc_getInitial();\n");
       
       heow.write("virtual BETS_Object* bemc_getType();\n");
       unless (build.emitChecks.has("noSmap")) {
        heow.write("static std::vector<int32_t> bevs_smnlc;\n");
        heow.write("static std::vector<int32_t> bevs_smnlec;\n");
       }
       heow.write("virtual ~" + classConf.emitName + "() = default;\n");
       
       deow.write("class " + classConf.emitName + ";\n");
       
       return("");
    }
    
    buildCreate() {
    
    ccMethods += self.overrideMtdDec += "std::shared_ptr<" += getClassConfig(objectNp).relEmitName(build.libName) += "> " += classConf.emitName += "::bemc_create()" += exceptDec += " {" += nl;  //}
    ccMethods += "return std::make_shared<" += getClassConfig(cnode.held.namepath).relEmitName(build.libName) += ">();" += nl;
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
     
       methods += mtdDec += "std::shared_ptr<" += returnType.relEmitName(build.libName) += "> " += classConf.emitName += "::" += mtdName += "(";
        
       methods += argDecs;
        
       methods += ")" += exceptDec += " {" += nl; //}
       
       classHeadBody += "virtual std::shared_ptr<" += returnType.relEmitName(build.libName) += "> " += mtdName += "(";
        
       classHeadBody += argDecs;
        
       classHeadBody += ");\n";
      
    }
    
    formTarg(Node node) String {
      String tcall;
      if (node.typename == ntypes.NULL) {
         tcall = "nullptr";
      } elseIf (node.held.name == "self") {
         tcall = "std::static_pointer_cast<" + classConf.emitName + ">(shared_from_this())";
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
        b += "std::shared_ptr<" += objectCc.relEmitName(build.libName) += ">";
      } else {
        b += "std::shared_ptr<" += getClassConfig(v.namepath).relEmitName(build.libName) += ">";
      }
   }
   
   formCast(ClassConfig cc, String type) String {
     if (type == "unchecked") {
       String ccall = "std::static_pointer_cast";
     } else {
       if (build.emitChecks.has("ccNoRtti")) {
         ccall = "std::static_pointer_cast";
       } else {
         ccall = "std::dynamic_pointer_cast";
       }
     }
     return(ccall + "<" + cc.relEmitName(build.libName) + ">(");//)
   }
   
   afterCast() String {
     //(
     return(")");
   }
   
   buildClassInfoMethod(String bemBase, String belsBase, Int len) { 
      ccMethods += self.overrideMtdDec += "std::shared_ptr<BEC_2_4_6_TextString> " += classConf.emitName += "::bemc_" += bemBase += "s()" += exceptDec += " {" += nl;  //}
      ccMethods += "return std::make_shared<BEC_2_4_6_TextString>(" += len += ", becc_" += belsBase += ");" += nl;
      //{
      ccMethods += "}" += nl;
  }
   
   lintConstruct(ClassConfig newcc, Node node) String {
        String newCall = "std::make_shared<" + newcc.relEmitName(build.libName) + ">(" + node.held.literalValue + ")";
      return(newCall);
   }
   
   lfloatConstruct(ClassConfig newcc, Node node) String {
        String newCall = "std::make_shared<" + newcc.relEmitName(build.libName) + ">(" + node.held.literalValue + "f)";
      return(newCall);
   }
   
   lstringConstruct(ClassConfig newcc, Node node, String belsName, Int lisz, String sdec) String {
      //String litArgs = "" + lisz + ", " + sdec;
      
      String newCall = "std::make_shared<" + newcc.relEmitName(build.libName) + ">(" + lisz + ", std::vector<unsigned char>(" + sdec + "))";
      
      return(newCall);
   }
      
      lstringByte(String sdec, String lival, Int lipos, Int bcode, String hs) {
        
        lival.getCode(lipos, bcode);
        String bc = bcode.toHexString(hs);
        sdec += "0x";
        sdec += bc;
        //sdec += ",";
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
        return("");
   }
    
    superNameGet() String {
       return("super");
    }
    
    extend(String parent) String {
        return(" : public " + parent);
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
   
   writeBET() {
        deow.write("class " + classConf.typeEmitName + ";\n");
        String beh = String.new();
        beh += "class " += classConf.typeEmitName += " : public BETS_Object {\n";
        beh += "public:\n";
        beh += classConf.typeEmitName += "();\n";
        beh += "virtual std::shared_ptr<BEC_2_6_6_SystemObject> bems_createInstance();\n";
        beh += "static BEC_2_6_6_SystemObject** bevs_inst_ref;\n";
        beh += "};\n";
        heow.write(beh);
        
        String bet = String.new();
        bet += classConf.typeEmitName += "::" += classConf.typeEmitName += "() {\n";
        bet += "std::vector<std::string> bevs_mtnames = { ";
        unless (build.emitChecks.has("noRfl")) {
          Bool firstmnsyn = true;
          for (Build:MtdSyn mnsyn in csyn.mtdList) {
            if (firstmnsyn) {
              firstmnsyn = false;
            } else {
              bet += ", ";
            }
            bet += q += mnsyn.name += q;
           }
         }
         bet += " };\n";
         //noRfl
         unless (build.emitChecks.has("noRfl")) {
           bet += "bems_buildMethodNames(bevs_mtnames);\n";
         }
        
        bet += "bevs_fieldNames = { ";
        unless (build.emitChecks.has("noRfl")) {
          Bool firstptsyn = true;
          for (Build:PtySyn ptySyn in csyn.ptyList) {
            if (firstptsyn) {
              firstptsyn = false;
            } else {
              bet += ", ";
            }
            bet += q += ptySyn.name += q;
          }
        }
        bet += " };\n";
        
        bet += "}\n";
        
        bet += "std::shared_ptr<BEC_2_6_6_SystemObject> " += classConf.typeEmitName += "::bems_createInstance() {\n";
        if (classConf.emitName == "BEC_2_6_6_SystemObject") {
          bet += "return std::make_shared<" += classConf.emitName += ">();\n";
        } else {
          bet += "return std::static_pointer_cast<BEC_2_6_6_SystemObject>(std::make_shared<" += classConf.emitName += ">());\n";
        }
        bet += "}\n";
        
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
            //heow.write("using namespace std;\n");
            
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
        
        if (build.emitChecks.has("relocMain")) {
          String mh = String.new();
          mh += "int bems_relocMain(int argc, char **argv);" += nl;
          heow.write(mh); 
        }
        
        deow.close();
        heow.close();
        //end module
    }
    
    covariantReturnsGet() {
        return(false);
    }
    
   lstringStart(String sdec, String belsName) {
      sdec += "{"; //}
   }
   
   lstringEnd(String sdec) {
       sdec += "}";
   }
   
   lstringStartCi(String sdec, String belsName) {
        sdec += "static std::vector<unsigned char> " += belsName += " = {"; //}
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
         
         initialDec += "std::shared_ptr<" += classConf.emitName += "> " += classConf.emitName += "::" += bein += ";\n";
         
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
        
        ccMethods += self.overrideMtdDec += "void " += newcc.emitName += "::bemc_setInitial(std::shared_ptr<" += oname += "> becc_inst)" += exceptDec += " {" += nl;  //}

            asnr = "becc_inst";
            if (newcc.emitName != oname) {
                String asnr = formCast(classConf, "unchecked", asnr);//no need for type check
            }
            
            ccMethods += stinst += " = " += asnr += ";" += nl;
        //{
        ccMethods += "}" += nl;
        
        
        ccMethods += self.overrideMtdDec += "std::shared_ptr<" += oname += "> " += newcc.emitName += "::bemc_getInitial()" += exceptDec += " {" += nl;  //}

            
            if (newcc.emitName != oname) {
              ccMethods += "return std::static_pointer_cast<" += oname += ">(" += stinst += ");" += nl;
            } else {
              ccMethods += "return " += stinst += ";" += nl;
            }
        //{
        ccMethods += "}" += nl;
        
        String tinst = getTypeInst(newcc);
        
        ccMethods += "BETS_Object* " += newcc.emitName += "::bemc_getType() {" += nl;  //}
            
            ccMethods += "return &" += tinst += ";" += nl;
        //{
        ccMethods += "}" += nl;
        
    }
    
    emitLib() {
      
      deow.write("class " + libEmitName + ";\n");
      heow.write("class " + libEmitName + " : public BECS_Lib {\npublic:\nstatic void init();\n};\n");
      
      super.emitLib();
      
    }
    
    getTypeInst(ClassConfig newcc) String {
    auto nccn = newcc.relEmitName(build.libName);
    String bein = "bece_" + nccn + "_bevs_type";
    return(nccn + "::" + bein);
   }

}
