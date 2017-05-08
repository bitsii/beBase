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
        }
        //super new depends on some things we set here, so it must follow
        super.new(_build);
    }
    
    classBegin(Build:ClassSyn csyn) String {
       if (def(parentConf)) {
          String extends = extend(parentConf.relEmitName(build.libName));
       } else {
          extends = extend("BECS_Object");
       }
       String begin = "class " += classConf.emitName += extends += " {"; //}
       
       begin += "\n";
       
       begin += "public:\n";
       
       heow.write(begin);
       
       heow.write(propertyDecs);
       
       heow.write(classHeadBody);
       
       classHeadBody.clear();
       
       deow.write("class " + classConf.emitName + ";\n");
       
       return("");
    }
    
    classEndGet() String {
       String end = "";
       //{
       heow.write("};\n\n");
       return(end);
    }
    
    acceptCatch(Node node) {
    String catchVar = "beve_" + methodCatch.toString();
    methodCatch++=;
    methodBody += " catch (Throwable " += catchVar += ") {" += nl; //}
    
    methodBody += finalAssign(node.contained.first.contained.first, "(be.BECS_ThrowBack.handleThrow(" + catchVar + "))", null);

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
     
       methods += mtdDec += "shared_ptr<" += returnType.relEmitName(build.libName) += "> " += classConf.emitName += "::" += mtdName += "(";
        
       methods += argDecs;
        
       methods += ")" += exceptDec += " {" += nl; //}
       
       classHeadBody += "virtual shared_ptr<" += returnType.relEmitName(build.libName) += "> " += mtdName += "(";
        
       classHeadBody += argDecs;
        
       classHeadBody += ");\n";
      
    }
   
   typeDecForVar(String b, Build:Var v) {
      if (v.isTyped!) {
        b += "shared_ptr<" += objectCc.relEmitName(build.libName) += ">";
      } else {
        b += "shared_ptr<" += getClassConfig(v.namepath).relEmitName(build.libName) += ">";
      }
   }
   
   formCast(ClassConfig cc) String { //no need for type check
        return("(static_pointer_cast<" + cc.relEmitName(build.libName) + ">)");
   }
   
   lstringConstruct(ClassConfig newcc, Node node, String belsName, Int lisz, Bool isOnce) String {
      if (isOnce) {
        return("make_shared<" + newcc.relEmitName(build.libName) + ">(" + belsName + ", " + lisz + ")");
      }
      return("make_shared<" + newcc.relEmitName(build.libName) + ">(" + lisz + ", " + belsName + ")");
   }
      
      onceDec(String typeName, String anyName) {
         return("static shared_ptr<" + typeName + "> ");
      }
      
      lstringByte(String sdec, String lival, Int lipos, Int bcode, String hs) {
        
        lival.getInt(lipos, bcode);
        String bc = bcode.toHexString(hs);
        if (bc.begins("-")) {
            bc = bc.substring(1);
            sdec += "-";
        }
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
    
    getClassOutput() IO:File:Writer {
       return(getLibOutput());
   }

   finishClassOutput(IO:File:Writer cle) {
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
            
            heow.write("#include <iostream>\n");
            heow.write("#include <memory>\n");
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
        //{
        libe.write("}\n");//end namespace
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
      sdec += "static unsigned char " += belsName += "[] = {"; //}
   }

}
