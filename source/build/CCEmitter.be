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
        }
        //super new depends on some things we set here, so it must follow
        super.new(_build);
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
      
    }
   
   typeDecForVar(String b, Build:Var v) {
      if (v.isTyped!) {
        b += "shared_ptr<" += objectCc.relEmitName(build.libName) += ">";
      } else {
        b += "shared_ptr<" += getClassConfig(v.namepath).relEmitName(build.libName) += ">";
      }
   }
      
      onceDec(String typeName, String anyName) {
      //here could put final for once deced
         return("private static " + typeName + " ");
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
        return(ms);
   }
    
    beginNs() String {
        return(beginNs(build.libName));
    }
    
    beginNs(String libName) String {
        return("package " + libNs(libName) + ";" + nl);
    }
    
    libNs(String libName) String {
        return(getNameSpace(libName));
    }
    
    superNameGet() String {
       return("super");
    }
    
    extend(String parent) String {
        return(" extends "@ + parent);
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
        //end module
    }


}
