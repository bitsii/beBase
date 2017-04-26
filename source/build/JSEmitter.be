// Copyright 2015 Craig Welch
//
// Licensed under the MIT license. See LICENSE.txt file in the project root 
// for full license information.

use IO:File;
use Build:Visit;
use Build:EmitException;
use Build:Node;
use Build:ClassConfig;
use Build:NamePath;

use final class Build:JSEmitter(Build:EmitCommon) {


    new(Build:Build _build) {
        emitLang = "js";
        fileExt = ".js";
        exceptDec = "";
        fields {
        }
        //super new depends on some things we set here, so it must follow
        super.new(_build);

        trueValue = "be_BECS_Runtime.prototype.boolTrue";
        falseValue = "be_BECS_Runtime.prototype.boolFalse";

        instanceEqual = " === ";
        instanceNotEqual = " !== ";
    }

    acceptThrow(Node node) {
        methodBody += "throw new be_BECS_ThrowBack(" += formTarg(node.second) += ", new Error());" += nl;
    }

    acceptCatch(Node node) {
    String catchVar = "beve_" + methodCatch.toString();
    methodCatch++=;
    methodBody += " catch (" += catchVar += ") {" += nl; //}
    
    //try to fix js
    //methodBody += "console.log(new Error().stack);" += nl;
    
    methodBody += finalAssign(node.contained.first.contained.first, "(be_BECS_ThrowBack_handleThrow(" + catchVar + "))", null);

   }

   buildClassInfoMethod(String bemBase, String belsBase) { }

   lstringStart(String sdec, String belsName) {

      sdec += classConf.emitName += ".prototype.becs_insts." += belsName += " = ["; //}
   }

   buildCreate() {
        ccMethods += classConf.emitName += ".prototype.bemc_create = function() {" += nl;  //}
        ccMethods += "return new " += getClassConfig(cnode.held.namepath).relEmitName(build.libName) += "();" += nl;
        //{
        ccMethods += "}" += nl;
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

    buildInitial() {

        ClassConfig newcc = getClassConfig(cnode.held.namepath);
        String stinst = getInitialInst(newcc);

        ccMethods += classConf.emitName += ".prototype.bemc_setInitial = function(becc_inst) {" += nl;  //}


            ccMethods += stinst += " =  becc_inst;" += nl;
        //{
        ccMethods += "}" += nl;

        ccMethods += classConf.emitName += ".prototype.bemc_getInitial = function() {" += nl;  //}


            ccMethods += "return " += stinst += ";" += nl;
        //{
        ccMethods += "}" += nl;

        buildPropList();
    }

   lstringByte(String sdec, String lival, Int lipos, Int bcode, String hs) {

        lival.getCode(lipos, bcode);
        String bc = bcode.toString();
        sdec += bc;
        //sdec += ","@;
    }

    lstringEnd(String sdec) {
        //{
        sdec += "];" += nl;
    }

    nameForVar(Build:Var v) String {

      if (v.isProperty) {
        return("this.bevp_" + v.name);
      }
      return(super.nameForVar(v));

   }

    emitLib() {

        IO:File:Writer libe = getLibOutput();

        String typeInstances = String.new();
        String libInit = String.new();
        String notNullInitConstruct = String.new();
        String notNullInitDefault = String.new();
        for (any ci = classesInDepthOrder.iterator;ci.hasNext;;) {

            any clnode = ci.next;

            typeInstances += "be_BECS_Runtime.prototype.typeInstances[" += q += clnode.held.namepath.toString() += q += "] = " += getClassConfig(clnode.held.namepath).relEmitName(build.libName) += ".prototype;" += nl;

            if (clnode.held.syn.hasDefault) {
                //("Class " + clnode.held.namepath + " isNotNull").print();
                String nc = "new " + getClassConfig(clnode.held.namepath).relEmitName(build.libName) + "()";
                //if (clnode.held.syn.hasDefault) {
                //    ("not null has default").print();
                //} else {
                //    ("not null no default").print();
                //}
                notNullInitConstruct += "be_BECS_Runtime.prototype.initializer.bem_notNullInitConstruct_1(" += nc += ");" += nl;
                if (clnode.held.syn.hasDefault) {
                    notNullInitDefault += "be_BECS_Runtime.prototype.initializer.bem_notNullInitDefault_1(" += nc += ");" += nl;
                }
            }

        }

        String smap = String.new();

        for (String smk in smnlcs.keys) {
          //("nlcs key " + smk + " nlc " + smnlcs.get(smk) + " nlec " + smnlecs.get(smk)).print();
          smap += "be_BECS_Runtime.prototype.putNlcSourceMap(" += TS.quote += smk += TS.quote += ", " += smnlcs.get(smk) += ");" += nl;
          smap += "be_BECS_Runtime.prototype.putNlecSourceMap(" += TS.quote += smk += TS.quote += ", " += smnlecs.get(smk) += ");" += nl;
          //break;
        }

        libe.write(smap);

        libe.write(typeInstances);

        //("Used lib size " + build.usedLibrarys.size).print();
        if (build.usedLibrarys.size == 0) {
            libInit += "be_BECS_Runtime.prototype.boolTrue = new be_BEC_2_5_4_LogicBool().beml_set_bevi_bool(true);" += nl;
            libInit += "be_BECS_Runtime.prototype.boolFalse = new be_BEC_2_5_4_LogicBool().beml_set_bevi_bool(false);" += nl;
            libInit += "be_BECS_Runtime.prototype.initializer = new be_BEC_2_6_11_SystemInitializer();" += nl;
        }

        libe.write(libInit);
        libe.write(notNullInitConstruct);
        //libe.write(notNullInitDefault);

        NamePath mainClassNp = NamePath.new();
        mainClassNp.fromString(build.mainName);
        ClassConfig maincc = getClassConfig(mainClassNp);

        String main = "";
        main += "var mc = new " += maincc.fullEmitName += "();" += nl;
        if (build.ownProcess) {
          main += "be_BECS_Runtime.prototype.args = process.argv;" += nl;
        }
        main += "be_BECS_Runtime.prototype.platformName = \"" += build.outputPlatform.name += "\";" += nl;
        libe.write(main);
        main = "";
        libe.write(allOnceDecs);
        libe.write(notNullInitDefault);
        if (build.ownProcess) {
          main += "mc.bem_new_0();" += nl;
          main += "mc.bem_main_0();" += nl;
        }
        libe.write(main);

        finishLibOutput(libe);
        
        if (build.saveSyns) {
          saveSyns();
        }

    }

   decForVar(String b, Build:Var v) {
      if (v.isProperty) {
        //b += "public bevp_" + v.name;
      } else {
        if (v.isArg!) {
          b += "var ";
        }
        b += nameForVar(v);
      }
   }

   boolTypeGet() String {
      return("boolean");
   }

   mainStartGet() String {
        return("public static void main()" + exceptDec + " {" + nl);
   }

    superNameGet() String {
       return("this"); //handled via including parent calls for super call cases prefixed with "bemp_" instead of "bem_" and calling those
       //names for super cases
    }

    extend(String parent) String {
        String extstr = classConf.emitName + ".prototype = new " + parent + "();" += nl;
        extstr = extstr + classConf.emitName + ".prototype.becs_insts = function() { }" += nl;
        return(extstr);
    }

    lintConstruct(ClassConfig newcc, Node node) String {
      return("new " + newcc.relEmitName(build.libName) + "().beml_set_bevi_int(" + node.held.literalValue + ")");
   }

   lfloatConstruct(ClassConfig newcc, Node node) String {
      return("new " + newcc.relEmitName(build.libName) + "().beml_set_bevi_float(" + node.held.literalValue + ")");
   }

   lstringConstruct(ClassConfig newcc, Node node, String belsName, Int lisz, Bool isOnce) String {
      if (isOnce) {
        return("new " + newcc.relEmitName(build.libName) + "().beml_set_bevi_bytes_len(" + classConf.emitName + ".prototype.becs_insts." + belsName + ", " + lisz + ")");
      }
      return("new " + newcc.relEmitName(build.libName) + "().beml_set_bevi_bytes_len_copy(" + classConf.emitName + ".prototype.becs_insts." + belsName + ", " + lisz + ")");
   }

    classBegin(Build:ClassSyn csyn) String {
       if (def(parentConf)) {
          String extends = extend(parentConf.relEmitName(build.libName));
       } else {
          extends = extend("be_BECS_Object");
       }
       String begin = "var " += classConf.emitName += " = function() {";
       //if (csyn.isNotNull) {
       //   String stinst = getInitialInst(classConf);
       //   begin += nl;
       //   begin += "if (" += stinst += " == null) {" += nl;
       //   begin += stinst += " = this;" += nl;
       //   begin += "}" += nl;
       //}
       begin += "}" += nl;
       begin += extends;
       return(begin);
    }

    emitNameForCall(Node node) String {
        if (node.held.superCall) {
            return("bemp_" + node.held.name);
        }
        return("bem_" + node.held.name);
    }

    classEndGet() String {
       String end = "";
       for (Node node in superCalls) {
          end += classConf.emitName + ".prototype." + "bemp_" + node.held.name + " = " + parentConf.emitName + ".prototype." + "bem_" + node.held.name + ";" + nl;
       }
       return(end);
    }

    writeOnceDecs(cle, onceDecs) {
        fields {
            String allOnceDecs;
        }
        if (undef(allOnceDecs)) {
            allOnceDecs = String.new();
        }
        allOnceDecs += onceDecs;
        return(0);
    }


    getClassOutput() IO:File:Writer {
       return(getLibOutput());
   }

   finishClassOutput(IO:File:Writer cle) {
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
            if (build.params.has("jsInclude")) {
                for (String p in build.params["jsInclude"]) {
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
        //end module
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

    klassDec(Bool isFinal) String {
        return("export class ");
    }

    spropDecGet() String {
        return("");
    }

    propDecGet() String {
        return("");
    }

    initialDecGet() String {

        return("");

    }

      baseSpropDec(String typeName, String anyName) {
         return("");
      }

      overrideSpropDec(String typeName, String anyName) {
        return("static " + anyName + ": " + typeName);
      }

      onceDec(String typeName, String anyName) {
         return("");
      }

       getInitialInst(ClassConfig newcc) String {
        return(newcc.relEmitName(build.libName) + ".prototype.becs_insts.bevs_inst");
       }


      onceVarDec(String count) String {
        return(classConf.emitName + ".prototype.becs_insts." + "bevo_" + count);
      }

      startMethod(String mtdDec, ClassConfig returnType, String mtdName, String argDecs, exceptDec) {

         methods += classConf.emitName += ".prototype." += mtdName += " = function(";

         methods += argDecs;

         methods += ") {" += nl; //}

      }

      formCast(ClassConfig cc) String {
        return("");
      }

      useDynMethodsGet() Bool {
           return(false);
        }

   getFullEmitName(String nameSpace, String emitName) {
       return(nameSpace + "_" + emitName);
   }

   getNameSpace(String libName) String {
      //return("be_" + libEmitName(libName));
      return("be");
   }

   getClassConfig(NamePath np) ClassConfig {
      ClassConfig cc = super.getClassConfig(np);
      cc.emitName = cc.fullEmitName;
      return(cc);
   }

   getLocalClassConfig(NamePath np) ClassConfig {
      ClassConfig cc = super.getLocalClassConfig(np);
      cc.emitName = cc.fullEmitName;
      return(cc);
   }

}
