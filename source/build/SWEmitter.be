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
        exceptDec = " throws";
        fields {
        }
        //super new depends on some things we set here, so it must follow
        super.new(_build);
        
        trueValue = "BECS_Runtime.prototype.boolTrue";
        falseValue = "BECS_Runtime.prototype.boolFalse";
    }
    
    acceptThrow(Node node) {
        methodBody += "throw new BECS_ThrowBack(" += formTarg(node.second) += ", new Error());" += nl;
    }
    
    classBegin(Build:ClassSyn csyn) String {
       if (def(parentConf)) {
          String extends = extend(parentConf.relEmitName(build.libName));
       } else {
          extends = extend("BECS_Object");
       }
       String clb = "/* IO:File: " += inFilePathed += " */" += nl;
       clb += self.klassDec(csyn.isFinal) += classConf.emitName += extends += " {" += nl; //}
       clb += "override init() { }" += nl;
       return(clb)
    }
    
    onceVarDec(String count) String {
      return("bece_" + classConf.emitName + "_bevo_" + count);
    }
    
    propDecGet() String {
        return("");
    }
    
    decForVar(String b, Build:Var v, Bool isArg) {
      unless (isArg) {
        b += "var ";
      }
      b += nameForVar(v);
      b += ":";
      typeDecForVar(b, v);
      b += "?";
   }
    
    initialDecGet() String {
       
         String initialDec = String.new();
         
         if (csyn.namepath == objectNp) {
            initialDec += baseSpropDec(classConf.emitName, "bece_" + classConf.emitName + "_bevs_inst") += ";" += nl;
         } else {
            initialDec += overrideSpropDec(classConf.emitName, "bece_" + classConf.emitName + "_bevs_inst") += ";" += nl;
         }
         
         return(initialDec);
    }
    
    getInitialInst(ClassConfig newcc) String {
      return(newcc.relEmitName(build.libName) + "." + "bece_" + newcc.emitName + "_bevs_inst");
     }
    
    klassDec(Bool isFinal) String {
        return("class ");
    }
    
    lstringStart(String sdec, String belsName) {
      sdec += "var " += belsName += ":[UInt8] = [";//]
	}
	
  baseSpropDec(String typeName, String anyName) {
     return("static var " + anyName + ":" + typeName + " ");
  }
  
    buildCreate() {
        ccMethods += self.overrideMtdDec += " bemc_create()" += exceptDec += " -> " += getClassConfig(objectNp).relEmitName(build.libName) += " {" += nl;  //}
            ccMethods += "return " += getClassConfig(cnode.held.namepath).relEmitName(build.libName) += "();" += nl;
        //{
        ccMethods += "}" += nl;
    }
  
  buildInitial() {
        String oname = getClassConfig(objectNp).relEmitName(build.libName);
        String tname = getClassConfig(objectNp).typeEmitName;
        String mname = classConf.emitName;
        ClassConfig newcc = getClassConfig(cnode.held.namepath);
        String stinst = getInitialInst(newcc);
        
        ccMethods += self.overrideMtdDec += "bemc_setInitial( becc_inst:" += oname += " )" += exceptDec += " {" += nl;  //}
            
            if (mname != oname) {
                String vcast = formCast(classConf, "unchecked", "becc_inst");//no need for type check
            } else {
                vcast = "becc_inst";
            }
            
            ccMethods += stinst += " = " += vcast += ";" += nl;
        //{
        ccMethods += "}" += nl;
        
        
        ccMethods += self.overrideMtdDec += " bemc_getInitial()" += exceptDec += " -> " += oname += " {" += nl;  //}
            
            ccMethods += "return " += stinst += ";" += nl;
        //{
        ccMethods += "}" += nl;
        
        String tinst = getTypeInst(newcc);
        
        ccMethods += self.overrideMtdDec += " bemc_getType()" += exceptDec += " -> BETS_Object {" += nl;  //}
            
            ccMethods += "return " += tinst += ";" += nl;
        //{
        ccMethods += "}" += nl;
        
    }
  
  buildClassInfoMethod(String bemBase, String belsBase, Int len) {
      /*ccMethods += self.overrideMtdDec += "byte[] bemc_" += bemBase += "()" += exceptDec += " {" += nl;  //}
      ccMethods += "return becc_" += belsBase += ";" += nl;
      //{
      ccMethods += "}" += nl;*/
      
      ccMethods += self.overrideMtdDec += "bemc_" += bemBase += "s()" += exceptDec += " -> BEC_2_4_6_TextString {" += nl;  //}
      ccMethods += "return BEC_2_4_6_TextString(" += len += ", becc_" += belsBase += ");" += nl;
      //{
      ccMethods += "}" += nl;
  }
  
  overrideSpropDec(String typeName, String anyName) {
    return("static var " + anyName + ":" + typeName + " ");
  }
  
	lstringEnd(String sdec) {
        //[
        sdec += "];" += nl;
    }
    
    acceptCatch(Node node) {
    String catchVar = "beve_" + methodCatch.toString();
    methodCatch++=;
    methodBody += " catch (System.Exception " += catchVar += ") {" += nl; //}
    
    methodBody += finalAssign(node.contained.first.contained.first, "(BECS_ThrowBack.handleThrow(" + catchVar + "))", null, null);

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
    
    newDecGet() String {
    return("");
   }
   
   formCast(ClassConfig cc, String type) String { //no need for type check
        return(" as " + cc.relEmitName(build.libName));
   }
   
   formCast(ClassConfig cc, String type, String targ) String {
        return(targ + formCast(cc, type));
   }
    
  startMethod(String mtdDec, ClassConfig returnType, String mtdName, String argDecs, exceptDec) {
     
     methods += mtdDec += mtdName += "(";
      
     methods += argDecs;
      
     methods += ")" += exceptDec += " -> " += returnType.relEmitName(build.libName) += " {" += nl; //}
    
  }
  
  superNameGet() String {
    return("super");
  }
  
  onceDec(String typeName, String anyName) {
     return("static var " + anyName + ":" + typeName + "? ");
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
