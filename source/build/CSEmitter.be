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

use final class Build:CSEmitter(Build:EmitCommon) {

    
    new(Build:Build _build) {
        emitLang = "cs";
        fileExt = ".cs";
        exceptDec = "";
        fields {
        }
        //super new depends on some things we set here, so it must follow
        super.new(_build);
    }
    
    acceptCatch(Node node) {
    String catchVar = "beve_" + methodCatch.toString();
    methodCatch = methodCatch++;
    methodBody += " catch (System.Exception " += catchVar += ") {" += nl; //}
    
    methodBody += finalAssign(node.contained.first.contained.first, "(be.BECS_ThrowBack.handleThrow(" + catchVar + "))", null);

   }
    
   boolTypeGet() String {
      return("bool");
   }
   
   baseMtdDec(Build:MtdSyn msyn) String {
     if (csyn.isFinal || (def(msyn) && msyn.isFinal)) {
        return("public ");
     }
     return("public virtual ");
    }
    
    overrideMtdDec(Build:MtdSyn msyn) String {
       if (def(msyn) && msyn.isFinal) {
         return ("public sealed override ");
       }
       return("public override ");
    }
  
  superNameGet() String {
    return("base");
  }
  
  onceDec(String typeName, String anyName) {
     return("private static " + typeName + " ");
  }
  
  lstringByte(String sdec, String lival, Int lipos, Int bcode, String hs) {
        
        lival.getCode(lipos, bcode);
        String bc = bcode.toHexString(hs);
        sdec += "0x"@;
        sdec += bc;
        //sdec += ","@;
    }
  
  
  overrideSpropDec(String typeName, String anyName) {
    return("public static new " + typeName + " " + anyName);
  }
  
  mainStartGet() String {
        String ms = "public static void Main(string[] args)" + exceptDec + " {" + nl; //}
        ms += "lock (typeof(" += libEmitName += ")) {" += nl;//}
        ms += "be.BECS_Runtime.args = args;" += nl;
        ms += "be.BECS_Runtime.platformName = \"" += build.outputPlatform.name += "\";" += nl;
        return(ms);
   }
  
  overrideSmtdDecGet() String {
        return("public new static ");
    }
    
    beginNs() String {
        return(beginNs(build.libName));
    }
    
    beginNs(String libName) String {
        return("namespace " + libNs(libName) + " {" + nl);
    }
    
    libNs(String libName) String {
        return(getNameSpace(libName));
    }
    
    endNs() String {
        return("}"+ nl);
    }
    
    extend(String parent) String {
        return(" : "@ + parent);
    }
    
    //Amazingly, cs doesn't support coanyiant return types
    coanyiantReturnsGet() {
        return(false);
    }

}
