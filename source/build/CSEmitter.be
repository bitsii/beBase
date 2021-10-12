// Copyright 2015 The Brace Authors. All rights reserved.
// Use of this source code is governed by the BSD-3-Clause
// license that can be found in the LICENSE file.

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
    
    writeBET() {
       if (classConf.classDir.file.exists!) {
            classConf.classDir.file.makeDirs();
        } 
        auto tout = classConf.typePath.file.writer.open();
        String bet = String.new();
        bet += "namespace be {\n";
        bet += "public class " += classConf.typeEmitName += " : BETS_Object {\n";
        bet += "public " += classConf.typeEmitName += "() {\n";
        
        bet += "string[] bevs_mtnames = new string[] { ";
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
        
        bet += "bevs_fieldNames = new string[] { ";
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
        
        bet += "static " += classConf.typeEmitName += "() { }\n";
        bet += "public override BEC_2_6_6_SystemObject bems_createInstance() {\n";
        bet += "return new " += classConf.emitName += "();\n";
        bet += "}\n";
        bet += "}\n";
        bet += "}\n";
        tout.write(bet);
        tout.close();
    }
    
    acceptCatch(Node node) {
    String catchVar = "beve_" + methodCatch.toString();
    methodCatch++=;
    methodBody += " catch (System.Exception " += catchVar += ") {" += nl; //}
    
    methodBody += finalAssign(node.contained.first.contained.first, "(be.BECS_ThrowBack.handleThrow(" + catchVar + "))", null, "checked");

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
  
  lstringByte(String sdec, String lival, Int lipos, Int bcode, String hs) {
        
        lival.getCode(lipos, bcode);
        String bc = bcode.toHexString(hs);
        sdec += "0x";
        sdec += bc;
        //sdec += ",";
    }
  
  
  overrideSpropDec(String typeName, String anyName) {
    return("public static new " + typeName + " " + anyName);
  }
  
  mainStartGet() String {
        if (build.emitChecks.has("relocMain")) {
          ms = "public static void bems_relocMain(string[] args)" + exceptDec + " {" + nl; //}
        } else {
          String ms = "public static void Main(string[] args)" + exceptDec + " {" + nl; //}
        }
        ms += "lock (typeof(" += libEmitName += ")) {" += nl;//}
        ms += "be.BECS_Runtime.args = args;" += nl;
        ms += "be.BECS_Runtime.platformName = \"" += build.outputPlatform.name += "\";" += nl;
        return(ms);
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
        return(" : " + parent);
    }
    
    covariantReturnsGet() {
        return(false);
    }

}
