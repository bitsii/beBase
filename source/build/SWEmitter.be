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

use final class Build:SWEmitter(Build:EmitCommon) {

    
    new(Build:Build _build) {
        emitLang = "sw";
        fileExt = ".swift";
        exceptDec = "";
        fields {
        }
        //super new depends on some things we set here, so it must follow
        super.new(_build);
    }
    
    onceVarDec(String count) String {
      return(classConf.emitName + "_bevo_" + count);
    }
    
    klassDec(Bool isFinal) String {
        return("class ");
    }
    
    lstringStart(String sdec, String belsName) {
      sdec += "var " += belsName += ":[UInt8] = [";//]
	}
	
  buildClassInfo() self {
    buildClassInfo(classConf.emitName + "_clname", cnode.held.namepath.toString());
    buildClassInfo(classConf.emitName + "_clfile", inFilePathed);
  }
	
	lstringEnd(String sdec) {
        //[
        sdec += "];" += nl;
    }
    
    acceptCatch(Node node) {
    String catchVar = "beve_" + methodCatch.toString();
    methodCatch++=;
    methodBody += " catch (System.Exception " += catchVar += ") {" += nl; //}
    
    methodBody += finalAssign(node.contained.first.contained.first, "(be.BECS_ThrowBack.handleThrow(" + catchVar + "))", null);

   }
    
   boolTypeGet() String {
      return("bool");
   }
   
   baseMtdDec(Build:MtdSyn msyn) String {
     return("func ");
    }
    
    overrideMtdDec(Build:MtdSyn msyn) String {
       return("override func ");
    }
  
  superNameGet() String {
    return("super");
  }
  
  onceDec(String typeName, String anyName) {
     return("var " + anyName + ":" + typeName + "? ");
  }
  
  lstringConstruct(ClassConfig newcc, Node node, String belsName, Int lisz, Bool isOnce) String {
      if (isOnce) {
        return(newcc.relEmitName(build.libName) + "(" + belsName + ", " + lisz + ")");
      }
      return(newcc.relEmitName(build.libName) + "(" + lisz + ", " + belsName + ")");
   }
  
  lstringByte(String sdec, String lival, Int lipos, Int bcode, String hs) {
        
        lival.getCode(lipos, bcode);
        String bc = bcode.toHexString(hs);
        sdec += "0x"@;
        sdec += bc;
        //sdec += ","@;
    }
  
  
  overrideSpropDec(String typeName, String anyName) {
    return("class " + typeName + " " + anyName);
  }
  
  mainStartGet() String {
        String ms = "main(string[] args)" + exceptDec + " {" + nl; //}
        ms += "lock (typeof(" += libEmitName += ")) {" += nl;//}
        ms += "BECS_Runtime.args = args;" += nl;
        ms += "BECS_Runtime.platformName = \"" += build.outputPlatform.name += "\";" += nl;
        return(ms);
   }
    
    extend(String parent) String {
        return(" : "@ + parent);
    }

}
