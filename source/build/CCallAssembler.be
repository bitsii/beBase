// Copyright 2006 Craig Welch
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

use Container:Map;
use Test:Assertions;

use Build:CCallAssembler;
use Build:CAssembleInt;
use Build:CAssembleFloat;
use Build:CAssembleBool;
use Build:CAssembleString;
use Build:Node;
use Build:Visit;
use Build:CallCursor;

local class CCallAssembler {
   
   new(build) self {
   
      loadBuild(build);
      
      fields {
         Map fromTypes;
      }
      
      var il;
      fromTypes = Map.new();
      
      il = CAssembleInt.new(build);
      fromTypes.put("Math:Int", il);
      
      il = CAssembleFloat.new(build);
      fromTypes.put("Math:Float", il);
      
      il = CAssembleBool.new(build);
      fromTypes.put("Logic:Bool", il);
      
      il = CAssembleString.new(build);
      fromTypes.put("Text:String", il);
   }
   
   loadBuild(_build) {
      fields {
         var build = _build;
         String nl = _build.nl;
      }
   }
   
   standardCall(CallCursor ca) String {
      
      if (ca.optimizedCall) {
         if (ca.node.held.wasAccessor && ca.mtds.isGenAccessor) {
            if (ca.node.held.accessorType == "GET") {
               return(processOptimizedGetter(ca));
            } elif (ca.node.held.accessorType == "SET" && ca.node.held.checkTypes! && undef(ca.asnR)) {
               return(processOptimizedSetter(ca));
            }
         }
      } else {
      }
      
      String callRet = String.new();
      callRet += ca.preOnceEval;
      accessorCheckBlock(ca, callRet);
      callRet += ca.postOnceEval;
      return(callRet);
   }
   
   accessorCheckBlock(CallCursor ca, String callRet) {
      String nl = ca.emvisit.build.nl;
      Bool isGetter = ca.isGetter;
      
      callRet += ca.prepCldef;
      callRet += ca.prepMdef;
      callRet += ca.callArgs;
      callRet += ca.utPreCheck;
      
      Assertions.assertTrue(ca.isValid);
      
      if (isGetter) {
         if (ca.isTyped) {
           //notequal compare-to must be value of BERD_PIDX_UNDEF (presently set to literal 0)
           callRet += "if (twcv_mtddef->pidx != 0) {" += nl;
           callRet += ca.assignToV += ca.targs += "[twcv_mtddef->pidx];" += nl;
           //callRet += "printf(" += Text:Strings.quote += "Did a typed direct index get" += Text:Strings.quote += ");" += nl;
           callRet += "} else {" += nl; //} so braces match
         } else {
           callRet += "if (twcv_mtddef->pidx != 0) {" += nl;
           callRet += ca.assignToV += ca.targs += "[twcv_mtddef->pidx];" += nl;
           callRet += "} else {" += nl; //} so braces match
         }
      }
      
      callRet += ca.assignToVV += ca.tcall;
      
      if (isGetter) {
         //{ so braces match
         callRet += "}" += nl;
      }
      
      callRet += ca.utPostCheckBB;
      if (ca.utPostCheckC.size > 0) {
         callRet += ca.assignToVV;
      }
      callRet += ca.utPostCheckC;
      callRet += ca.utPostCheckEB;
      callRet += ca.assignToCheck;
      
   }
   
   standardBlock(CallCursor ca, String callRet) {
      callRet += ca.prepCldef;
      callRet += ca.prepMdef;
      callRet += ca.utPreCheck;
      callRet += ca.assignToVV += ca.tcall;
      callRet += ca.utPostCheckBB;
      if (ca.utPostCheckC.size > 0) {
         callRet += ca.assignToVV;
      }
      callRet += ca.utPostCheckC;
      callRet += ca.utPostCheckEB;
   }
   
   standardBlockAssign(CallCursor ca, String callRet) {
      standardBlock(ca, callRet);
      callRet += ca.assignToCheck;
   }
   
   processCall(CallCursor ca) String {
      if (ca.hasOnceAssign) {
         String nl = ca.emvisit.build.nl;
         Build:Visit:CEmit emvisit = ca.emvisit;
         Int onceEvalCount = emvisit.inClass.held.onceEvalCount;
         emvisit.inClass.held.onceEvalCount = emvisit.inClass.held.onceEvalCount++;
         if (emvisit.mtdDeclared.has("twtc_onceEvalVars")!) {
            emvisit.mtdDeclared.put("twtc_onceEvalVars", true);
            
            emvisit.mtdDeclares += "void** twtc_onceEvalVars;" += nl;
            emvisit.postPrep += "twtc_onceEvalVars = (void**) berv_sts->onceEvalVars[" + emvisit.classInfo.cldefName + "->classId];" += nl;
            
            emvisit.mtdDeclares += "BEINT* twtc_onceEvalFlags;" += nl;
            emvisit.postPrep += "twtc_onceEvalFlags = berv_sts->onceEvalFlags[" + emvisit.classInfo.cldefName + "->classId];" += nl;
         }
         ca.preOnceEval += ca.assignToV += "twtc_onceEvalVars[" += onceEvalCount.toString() += "];" += nl;
         ca.preOnceEval += "if (" += ca.embedTarg += " == NULL && twtc_onceEvalFlags[" += onceEvalCount.toString() += "] == 0) {" += nl;
         ca.postOnceEval += "twtc_onceEvalVars[" += onceEvalCount.toString() += "] = " += emvisit.formRTarg(ca.asnR) += ";" += nl;
         ca.postOnceEval += "twtc_onceEvalFlags[" += onceEvalCount.toString() += "] = 1;" += nl;
         ca.postOnceEval += "BERF_Add_Once(berv_sts, " += ca.embedTarg += ");" += nl; 
         ca.postOnceEval += "}" += nl;
      }
      if (ca.node.held.orgName == "assign") {
         return(processAssign(ca));
      }
      
      if (ca.node.held.isConstruct) {
         fromType = fromTypes.get(ca.ainfo.clName);
         if (def(fromType)) {
            return(fromType.processCall(ca));
         } elif (ca.node.held.isLiteral) {
            throw(Build:VisitError.new("Unknown literal class type " + ca.ainfo.clName));
         }
      }
      
      var np = ca.node.contained.first.held.namepath;
      if (def(np)) {
         CCallAssembler fromType = fromTypes.get(np.toString());
         if (def(fromType)) {
            return(fromType.processCall(ca));
         }
      } elif (ca.node.held.name == "not_0") {
         return(processNot(ca));
      }
      return(standardCall(ca));
   }
   
   processAssign(CallCursor ca) String {
      var nl = ca.emvisit.build.nl;
      String callRet = String.new();
      callRet += ca.preOnceEval;
      callRet += ca.typeCheckAssign;
      callRet += ca.postOnceEval;
      return(callRet);
   }
   
   processOptimizedGetter(CallCursor ca) String {
   
      Assertions.assertTrue(ca.isValid);
      
      var nl = ca.emvisit.build.nl;
      String callRet = String.new();
      callRet += ca.preOnceEval;
      String rhs = String.new() += ca.targs += "[" += (ca.asyn.ptyMap[ca.mtds.propertyName].mpos + ca.emvisit.build.constants.extraSlots).toString() += "]";
      if (ca.checkAssignTypes!) {
         callRet += ca.emvisit.finalAssign(ca.asnR, rhs.toString(), false);
      } else {
         callRet += ca.assignToV += rhs += ";" += nl;
         callRet += ca.assignToCheck;
      }
      callRet += ca.postOnceEval;
      return(callRet);
   }
   
   processOptimizedSetter(CallCursor ca) String {
      var nl = ca.emvisit.build.nl;
      String callRet = String.new();
      callRet += ca.preOnceEval;
      callRet += ca.targs += "[" += (ca.asyn.ptyMap[ca.mtds.propertyName].mpos + ca.emvisit.build.constants.extraSlots).toString() += "] = " += ca.emvisit.formRTarg(ca.node.contained[1]) += ";" += nl;
      callRet += ca.postOnceEval;
      return(callRet);
   }
   
   processNot(CallCursor ca) String {
   
      Assertions.assertTrue(ca.isValid);
   
      var nl = ca.emvisit.build.nl;
      String callRet = String.new();
      callRet += ca.preOnceEval;
      callRet += ca.callArgs;
      callRet += "if ((size_t) " += ca.targs += " == (size_t) berv_sts->bool_True) { " += ca.assignToVV += "berv_sts->bool_False; }" += nl;
      callRet += "else if ((size_t) " += ca.targs += " == (size_t) berv_sts->bool_False) { " += ca.assignToVV += "berv_sts->bool_True; }" += nl;
      callRet += "else {";
      standardBlock(ca, callRet);
      callRet += "}" += nl += ca.assignToCheck;
      callRet += ca.postOnceEval;
      return(callRet);
   }
   
}

final class CAssembleInt(CCallAssembler) {

   new(build) self { loadBuild(build); } //Prevent infinite recursion of super logic
   
   processCall(CallCursor ca) String {
      if (ca.node.held.isConstruct && def(ca.asnR) && ca.node.held.isLiteral) {
         return(processLiteralConstruct(ca));
      }
      if (ca.node.held.name == "equals_1") {
         return(processEquals(ca));
      } elif (ca.node.held.name == "notEquals_1") {
         return(processNotEquals(ca));
      } elif (ca.node.held.name == "lesser_1") {
         return(processCompare(ca, "<"));
      } elif (ca.node.held.name == "greater_1") {
         return(processCompare(ca, ">"));
      } elif (ca.node.held.name == "lesserEquals_1") {
         return(processCompare(ca, "<="));
      } elif (ca.node.held.name == "greaterEquals_1") {
         return(processCompare(ca, ">="));
      }  elif (ca.node.held.name == "add_1") {
         return(processModify(ca, "+"));
      } elif (ca.node.held.name == "subtract_1") {
         return(processModify(ca, "-"));
      } elif (ca.node.held.name == "multiply_1") {
         return(processModify(ca, "*"));
      } elif (ca.node.held.name == "divide_1") {
         return(processModify(ca, "/"));
      } elif (ca.node.held.name == "modulus_1") {
         return(processModify(ca, "%"));
      } elif (ca.node.held.name == "increment_0") {
         return(processIncDec(ca, "+"));
      } elif (ca.node.held.name == "decrement_0") {
         return(processIncDec(ca, "-"));
      }
      return(standardCall(ca));
   }
   
   processLiteralConstruct(CallCursor ca) String {
      ca.tcall = ca.tcall + ca.assignToVV + "BERF_Create_Instance(berv_sts, " + ca.literalCdef + ", 0);" + nl;
      ca.tcall = ca.tcall + "*((BEINT*) ((" + ca.embedTarg + ") + bercps)) = " + ca.node.held.literalValue.toString() + ";" + nl;
      String callRet = String.new();
      callRet += ca.preOnceEval;
      callRet += ca.tcall;
      callRet += ca.assignToCheck;
      callRet += ca.postOnceEval;
      return(callRet);
   }
   
   processEquals(CallCursor ca) String {
   
      Assertions.assertTrue(ca.isValid);
   
      var nl = ca.emvisit.build.nl;
      String callRet = String.new();
      callRet += ca.preOnceEval;
      callRet += ca.callArgs;
      callRet += "if (" + ca.emvisit.getBeavArg(ca.node.contained.get(1)) + " == NULL || ((void**) " + ca.emvisit.getBeavArg(ca.node.contained.get(1)) + ")[berdef] != " += ca.targs += "[berdef]) { " +=  ca.assignToVV += "berv_sts->bool_False; }" += nl;
      callRet += "else {" += nl;
      callRet += "if (*((BEINT*) (" += ca.targs += " + bercps)) == *((BEINT*) (((void**) " + ca.emvisit.getBeavArg(ca.node.contained.get(1)) + ") + bercps))) { " +=  ca.assignToVV += "berv_sts->bool_True; }" += nl;
      callRet += "else { " +=  ca.assignToVV += "berv_sts->bool_False; } }" += nl;
      callRet += ca.assignToCheck;
      callRet += ca.postOnceEval;
      return(callRet);
   }
   
   processNotEquals(CallCursor ca) String {
   
      Assertions.assertTrue(ca.isValid);
      
      var nl = ca.emvisit.build.nl;
      String callRet = String.new();
      callRet += ca.preOnceEval;
      callRet += ca.callArgs;
      callRet += "if (" + ca.emvisit.getBeavArg(ca.node.contained.get(1)) + " == NULL || ((void**) " + ca.emvisit.getBeavArg(ca.node.contained.get(1)) + ")[berdef] != " += ca.targs += "[berdef]) { " +=  ca.assignToVV += "berv_sts->bool_True; }" += nl;
      callRet += "else {" += nl;
      callRet += "if (*((BEINT*) (" += ca.targs += " + bercps)) != *((BEINT*) (((void**) " + ca.emvisit.getBeavArg(ca.node.contained.get(1)) + ") + bercps))) { " +=  ca.assignToVV += "berv_sts->bool_True; }" += nl;
      callRet += "else { " +=  ca.assignToVV += "berv_sts->bool_False; } }" += nl;
      callRet += ca.assignToCheck;
      callRet += ca.postOnceEval;
      return(callRet);
   }
   
   processCompare(CallCursor ca, String action) String {
   
      Assertions.assertTrue(ca.isValid);
   
      var nl = ca.emvisit.build.nl;
      String callRet = String.new();
      callRet += ca.preOnceEval;
      callRet += ca.callArgs;
      if (ca.node.held.checkTypes) {
         callRet += "if (((void**) " + ca.emvisit.getBeavArg(ca.node.contained.get(1)) + ")[berdef] != " += ca.targs += "[berdef]) { " += nl;
         standardBlockAssign(ca, callRet);
         callRet += "} else {" += nl;
      }
      callRet += "if (*((BEINT*) (" += ca.targs += " + bercps)) " += action += " *((BEINT*) (((void**) " + ca.emvisit.getBeavArg(ca.node.contained.get(1)) + ") + bercps))) { " +=  ca.assignToVV += "berv_sts->bool_True; }" += nl;
      callRet += "else { " +=  ca.assignToVV += "berv_sts->bool_False; }" += nl;
      callRet += ca.assignToCheck;
      if (ca.node.held.checkTypes) {
         callRet += "}" += nl;
      }
      callRet += ca.postOnceEval;
      return(callRet);
   }
   
   processModify(CallCursor ca, String action) String {
   
      Assertions.assertTrue(ca.isValid);
      ca.checkRetainTo();
      var nl = ca.emvisit.build.nl;
      String callRet = String.new();
      callRet += ca.preOnceEval;
      callRet += ca.callArgs;
      if (ca.node.held.checkTypes) {
         callRet += "if (((void**) " + ca.emvisit.getBeavArg(ca.node.contained.get(1)) + ")[berdef] != " += ca.targs += "[berdef]) { " += nl;
         standardBlockAssign(ca, callRet);
         callRet += "} else {" += nl;
      }
      callRet += ca.assignToVV += "BERF_Create_Instance(berv_sts, BEUV_4_3_MathInt_clDef, 0);" += nl;
      callRet += "*((BEINT*) ((" += ca.embedTarg += ") + bercps)) = *((BEINT*) (" += ca.targs += " + bercps)) " += action += " *((BEINT*) (((void**) " + ca.emvisit.getBeavArg(ca.node.contained.get(1)) + ") + bercps));" += nl;
      callRet += ca.assignToCheck;
      if (ca.node.held.checkTypes) {
         callRet += "}" += nl;
      }
      callRet += ca.postOnceEval;
      return(callRet);
   }
   
   processIncDec(CallCursor ca, String action) String {
   
      Assertions.assertTrue(ca.isValid);
      ca.checkRetainTo();
      var nl = ca.emvisit.build.nl;
      String callRet = String.new();
      callRet += ca.preOnceEval;
      callRet += ca.callArgs;
      callRet += ca.assignToVV += "BERF_Create_Instance(berv_sts, BEUV_4_3_MathInt_clDef, 0);" += nl;
      callRet += "*((BEINT*) ((" += ca.embedTarg += ") + bercps)) = *((BEINT*) (" += ca.targs += " + bercps)) " += action += " 1;" += nl;
      callRet += ca.assignToCheck;
      callRet += ca.postOnceEval;
      return(callRet);
   }
   
}

final class CAssembleFloat(CCallAssembler) {

   new(build) self { loadBuild(build); } //Prevent infinite recursion of super logic
   
   processCall(CallCursor ca) String {
      if (ca.node.held.isConstruct && def(ca.asnR) && ca.node.held.isLiteral) {
         return(processLiteralConstruct(ca));
      }
      if (ca.node.held.name == "equals_1") {
         return(processEquals(ca));
      } elif (ca.node.held.name == "notEquals_1") {
         return(processNotEquals(ca));
      } elif (ca.node.held.name == "lesser_1") {
         return(processCompare(ca, "<"));
      } elif (ca.node.held.name == "greater_1") {
         return(processCompare(ca, ">"));
      } elif (ca.node.held.name == "lesserEquals_1") {
         return(processCompare(ca, "<="));
      } elif (ca.node.held.name == "greaterEquals_1") {
         return(processCompare(ca, ">="));
      } elif (ca.node.held.name == "add_1") {
         return(processModify(ca, "+"));
      } elif (ca.node.held.name == "subtract_1") {
         return(processModify(ca, "-"));
      } elif (ca.node.held.name == "multiply_1") {
         return(processModify(ca, "*"));
      } elif (ca.node.held.name == "divide_1") {
         return(processModify(ca, "/"));
      } elif (ca.node.held.name == "increment_0") {
         return(processIncDec(ca, "+"));
      } elif (ca.node.held.name == "decrement_0") {
         return(processIncDec(ca, "-"));
      }
      return(standardCall(ca));
   }
   
   processLiteralConstruct(CallCursor ca) String {
      ca.tcall = ca.tcall + ca.assignToVV + "BERF_Create_Instance(berv_sts, " + ca.literalCdef + ", 0);" + nl;
      ca.tcall = ca.tcall + "*((BEFLOAT*) ((" + ca.embedTarg + ") + bercps)) = " + ca.node.held.literalValue.toString() + ";" + nl;
      String callRet = String.new();
      callRet += ca.preOnceEval;
      callRet += ca.tcall;
      callRet += ca.assignToCheck;
      callRet += ca.postOnceEval;
      return(callRet);
   }
   
   processEquals(CallCursor ca) String {
   
      Assertions.assertTrue(ca.isValid);
   
      var nl = ca.emvisit.build.nl;
      String callRet = String.new();
      callRet += ca.preOnceEval;
      callRet += ca.callArgs;
      callRet += "if (" + ca.emvisit.getBeavArg(ca.node.contained.get(1)) + " == NULL || ((void**) " + ca.emvisit.getBeavArg(ca.node.contained.get(1)) + ")[berdef] != " += ca.targs += "[berdef]) { " +=  ca.assignToVV += "berv_sts->bool_False; }" += nl;
      callRet += "else {" += nl;
      callRet += "if (*((BEFLOAT*) (" += ca.targs += " + bercps)) == *((BEFLOAT*) (((void**) " + ca.emvisit.getBeavArg(ca.node.contained.get(1)) + ") + bercps))) { " +=  ca.assignToVV += "berv_sts->bool_True; }" += nl;
      callRet += "else { " +=  ca.assignToVV += "berv_sts->bool_False; } }" += nl;
      callRet += ca.assignToCheck;
      callRet += ca.postOnceEval;
      return(callRet);
   }
   
   processNotEquals(CallCursor ca) String {
   
      Assertions.assertTrue(ca.isValid);
   
      var nl = ca.emvisit.build.nl;
      String callRet = String.new();
      callRet += ca.preOnceEval;
      callRet += ca.callArgs;
      callRet += "if (" + ca.emvisit.getBeavArg(ca.node.contained.get(1)) + " == NULL || ((void**) " + ca.emvisit.getBeavArg(ca.node.contained.get(1)) + ")[berdef] != " += ca.targs += "[berdef]) { " +=  ca.assignToVV += "berv_sts->bool_True; }" += nl;
      callRet += "else {" += nl;
      callRet += "if (*((BEFLOAT*) (" += ca.targs += " + bercps)) != *((BEFLOAT*) (((void**) " + ca.emvisit.getBeavArg(ca.node.contained.get(1)) + ") + bercps))) { " +=  ca.assignToVV += "berv_sts->bool_True; }" += nl;
      callRet += "else { " +=  ca.assignToVV += "berv_sts->bool_False; } }" += nl;
      callRet += ca.assignToCheck;
      callRet += ca.postOnceEval;
      return(callRet);
   }
   
   processCompare(CallCursor ca, String action) String {
   
      Assertions.assertTrue(ca.isValid);
      
      var nl = ca.emvisit.build.nl;
      String callRet = String.new();
      callRet += ca.preOnceEval;
      callRet += ca.callArgs;
      if (ca.node.held.checkTypes) {
         callRet += "if (((void**) " + ca.emvisit.getBeavArg(ca.node.contained.get(1)) + ")[berdef] != " += ca.targs += "[berdef]) { " += nl;
         standardBlockAssign(ca, callRet);
         callRet += "} else {" += nl;
      }
      callRet += "if (*((BEFLOAT*) (" += ca.targs += " + bercps)) " += action += " *((BEFLOAT*) (((void**) " + ca.emvisit.getBeavArg(ca.node.contained.get(1)) + ") + bercps))) { " +=  ca.assignToVV += "berv_sts->bool_True; }" += nl;
      callRet += "else { " +=  ca.assignToVV += "berv_sts->bool_False; }" += nl;
      callRet += ca.assignToCheck; 
      if (ca.node.held.checkTypes) {
         callRet += "}" += nl;
      }
      callRet += ca.postOnceEval;
      return(callRet);
   }
   
   processModify(CallCursor ca, String action) String {
   
      Assertions.assertTrue(ca.isValid);
      ca.checkRetainTo();
      var nl = ca.emvisit.build.nl;
      String callRet = String.new();
      callRet += ca.preOnceEval;
      callRet += ca.callArgs;
      if (ca.node.held.checkTypes) {
         callRet += "if (((void**) " + ca.emvisit.getBeavArg(ca.node.contained.get(1)) + ")[berdef] != " += ca.targs += "[berdef]) { " += nl;
         standardBlockAssign(ca, callRet);
         callRet += "} else {" += nl;
      }
      callRet += ca.assignToVV += "BERF_Create_Instance(berv_sts, BEUV_4_5_MathFloat_clDef, 0);" += nl;
      callRet += "*((BEFLOAT*) ((" += ca.embedTarg += ") + bercps)) = *((BEFLOAT*) (" += ca.targs += " + bercps)) " += action += " *((BEFLOAT*) (((void**) " + ca.emvisit.getBeavArg(ca.node.contained.get(1)) + ") + bercps));" += nl;
      callRet += ca.assignToCheck;
      if (ca.node.held.checkTypes) {
         callRet += "}" += nl;
      }
      callRet += ca.postOnceEval;
      return(callRet);
   }
   
   processIncDec(CallCursor ca, String action) String {
   
      Assertions.assertTrue(ca.isValid);
      ca.checkRetainTo();
      var nl = ca.emvisit.build.nl;
      String callRet = String.new();
      callRet += ca.preOnceEval;
      callRet += ca.callArgs;
      callRet += ca.assignToVV += "BERF_Create_Instance(berv_sts, BEUV_4_5_MathFloat_clDef, 0);" += nl;
      callRet += "*((BEFLOAT*) ((" += ca.embedTarg += ") + bercps)) = *((BEFLOAT*) (" += ca.targs += " + bercps)) " += action += " 1.0;" += nl;
      callRet +=  ca.assignToCheck;
      callRet += ca.postOnceEval;
      return(callRet);
   }
   
}

final class CAssembleBool(CCallAssembler) {

   new(build) self { loadBuild(build); } //Prevent infinite recursion of super logic
   
   processCall(CallCursor ca) String {
      if (ca.node.held.isConstruct) {
         return(processConstruct(ca));
      }
      if (ca.node.held.name == "not_0") {
         return(processNot(ca));
      }
      return(standardCall(ca));
   }
   
   processConstruct(CallCursor ca) String {
      if (def(ca.asnR)) {
         if ((ca.node.held.isLiteral) && (ca.node.held.literalValue == "true")) {
            ca.tcall = ca.tcall + ca.assignToVV + "berv_sts->bool_True;" + nl;
         } elif (ca.node.held.numargs == 1) {
            ca.tcall = ca.tcall + ca.assignToVV + "BEKF_5_5_LogicBools_forString_1(0, berv_sts, berv_sts->bools_singleton, " + ca.emvisit.getBeavArg(ca.node.contained.get(1)) + " );" + nl;
         } else {
            ca.tcall = ca.tcall + ca.assignToVV + "berv_sts->bool_False;" + nl;
         }
      }
      String callRet = String.new();
      callRet += ca.preOnceEval;
      callRet += ca.tcall;
      callRet += ca.assignToCheck;
      callRet += ca.postOnceEval;
      return(callRet);
   }
   
   processNot(CallCursor ca) String {
   
      Assertions.assertTrue(ca.isValid);
   
      var nl = ca.emvisit.build.nl;
      String callRet = String.new();
      callRet += ca.preOnceEval;
      callRet += ca.callArgs;
      callRet += "if ((size_t) " += ca.targs += " == (size_t) berv_sts->bool_True) { " += ca.assignToVV += "berv_sts->bool_False; }" += nl;
      callRet += "else { " += ca.assignToVV += "berv_sts->bool_True; }" += nl;
      callRet += ca.assignToCheck;
      callRet += ca.postOnceEval;
      return(callRet);
   }
}

final class CAssembleString(CCallAssembler) {

   new(build) self { 
      loadBuild(build);
      fields {
         Encode:Url encode = Encode:Url.new(); 
      }
   } //Prevent infinite recursion of super logic
   
   processCall(CallCursor ca) String {
      if (ca.node.held.isConstruct && def(ca.asnR) && ca.node.held.isLiteral) {
         return(processLiteralConstruct(ca));
      }
      return(standardCall(ca));
   }
   
   processLiteralConstruct(CallCursor ca) String {
   
      ca.tcall = ca.tcall + ca.assignToVV + "BERF_String_For_Chars_Size(berv_sts, (char*) &" + ca.belsName + ", " + ca.belsValue.size + ");" + nl;
      
      String callRet = String.new();
      callRet += ca.preOnceEval;
      callRet += ca.tcall;
      callRet += ca.assignToCheck;
      callRet += ca.postOnceEval;
      return(callRet);
   }
}

