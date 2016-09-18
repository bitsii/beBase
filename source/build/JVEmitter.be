// Copyright 2015 Craig Welch
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

use Container:Map;
use Container:LinkedList;
use IO:File;
use Build:Visit;
use Build:EmitException;
use Build:Node;

use final class Build:JVEmitter(Build:EmitCommon) {

    
    new(Build:Build _build) {
        emitLang = "jv";
        fileExt = ".java";
        exceptDec = " throws Throwable";
        fields {
        }
        //super new depends on some things we set here, so it must follow
        super.new(_build);
    }
    
    acceptCatch(Node node) {
    String catchVar = "beve_" + methodCatch.toString();
    methodCatch = methodCatch++;
    methodBody += " catch (Throwable " += catchVar += ") {" += nl; //}
    
    methodBody += finalAssign(node.contained.first.contained.first, "(be.BECS_ThrowBack.handleThrow(" + catchVar + "))", null);

   }
      
      onceDec(String typeName, String varName) {
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
      
      
      overrideSpropDec(String typeName, String varName) {
        return("public static " + typeName + " " + varName);
      }
    
    overrideSmtdDecGet() String {
        return("public static ");
    }
    
    baseMtdDec(Build:MtdSyn msyn) String {
      if (def(msyn) && msyn.isFinal) {
        return("public final ");
      }
      return("public ");
    }
    
    overrideMtdDec(Build:MtdSyn msyn) String {
      if (def(msyn) && msyn.isFinal) {
        return("public final ");
      }
      return("public ");
    }
   
   boolTypeGet() String {
      return("boolean");
   }
   
   mainStartGet() String {
        String ms = "public static void main(String[] args)" + exceptDec + " {" + nl;//}
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

}
