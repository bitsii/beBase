// Copyright 2015 The Brace Authors. All rights reserved.
// Use of this source code is governed by the BSD-3-Clause
// license that can be found in the LICENSE file.

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
    
    writeBET() {
       if (classConf.classDir.file.exists!) {
            classConf.classDir.file.makeDirs();
        } 
        auto tout = classConf.typePath.file.writer.open();
        String bet = String.new();
        bet += "package be;\n";
        bet += "public class " += classConf.typeEmitName += " extends BETS_Object {\n";
        bet += "public " += classConf.typeEmitName += "() {"
        
        bet += "String[] bevs_mtnames = new String[] { ";
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
        
        bet += "bevs_fieldNames = new String[] { ";
        Bool firstptsyn = true;
        for (Build:PtySyn ptySyn in csyn.ptyList) {
          unless (ptySyn.isSlot) {
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
        
        bet += "public BEC_2_6_6_SystemObject bems_createInstance() {\n";
        bet += "return new " += classConf.emitName += "();\n";
        bet += "}\n";
        bet += "}\n";
        tout.write(bet);
        tout.close();
    }
    
    acceptCatch(Node node) {
    String catchVar = "beve_" + methodCatch.toString();
    methodCatch++=;
    methodBody += " catch (Throwable " += catchVar += ") {" += nl; //}
    
    methodBody += finalAssign(node.contained.first.contained.first, "(be.BECS_ThrowBack.handleThrow(" + catchVar + "))", null, null);

   }

      lstringByte(String sdec, String lival, Int lipos, Int bcode, String hs) {
        
        lival.getInt(lipos, bcode);
        String bc = bcode.toHexString(hs);
        if (bc.begins("-")) {
            bc = bc.substring(1);
            sdec += "-";
        }
        sdec += "0x";
        sdec += bc;
        //sdec += ",";
    }
      
      
      overrideSpropDec(String typeName, String anyName) {
        return("public static " + typeName + " " + anyName);
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
        return(" extends " + parent);
    }

}
