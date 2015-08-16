// Copyright 2006 Craig Welch
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

use Container:LinkedList;
use Container:Map;
use Container:Stack;
use Text:String;
use Text:String;
use Math:Int;
use Build:Visit;
use Build:NamePath;
use Build:VisitError;
use Build:CallCursor;
use Logic:Bool;
use Build:Node;

/*
Instances have a class def reference
it is both a struct with all kinds of stuff in it
(one def per class, shared amongst all instances)
and tacked on to the end it has a "vtable" (a block used as an array
for holding typed call refs, the whole cldef memory block is cast to an 
array when it needs to be used this way, and the start of the vtable indexes
is arranged to be "after" the cldef struct space)

Property access:
(from within the class the properties belong to and extendors of that class)
* For directProperty cases, which is where the inheritance hierarchy is all within 
close libraries (Object excepted, it doensn't count for that decision (if it is not close
it is still possible to have directProperties)) a direct numeric subscript is used in the code
to get/set the value
* For non-direct properties a twmi_LIBNAME_mangled name is setup at libinit per lib which 
needs it (where a ref occurs, also if needed for initialization of libs (lib where property declared
if not all closelibs/direct properties)) and that is used as the index reference for gets/sets

Typed Calls:
* Optimized calls (an evaluation including closness of libraries, library or 
final modifiers on class and methods, and so on...) will directly call the method
* Typed calls which are not optimized will use a 
block of memory off the end of the cldef has the "vtable" which is indexed
by twmi_LIBNAME_mangled_call_name (it is an array of call pointers, the index is per-library
and values are set a library initialization time) (this is for non-accessor calls)
* 

*/
final class Visit:CEmit(Visit:Visitor) {
   
   new() self {
   
      properties {
      
         Build:Node inClass;
         String inClassNamed;
         String inFileNamed;
         String inMtdNamed;
         Build:ClassSyn inClassSyn;
         Build:ClassInfo superClassInfo;
         Build:ClassSyn superSyn;
         Build:ClassInfo classInfo;
         var mmbers;
         
         Build:CEmitter emitter;
         String nl;
         
         Build:Node inMtdNode;
         String textRbnl;
         Build:CCallAssembler cassem;
         
         String cincl = String.new();
         String methods = String.new();
         String methodsProto = String.new();
         String hfd = String.new();
         String hincl = String.new();
         String cldef = String.new();
         String cldefDecs = String.new();
         String baseH = String.new();
         String cldefH = String.new();
         String objectClname = "System:Object";
         
         Build:NamePath boolNp = Build:NamePath.new();
         boolNp.fromString("Logic:Bool");
         
         Build:NamePath strNp = Build:NamePath.new();
         strNp.fromString("Text:String");
         
         Build:NamePath nullErrNp = Build:NamePath.new();
         nullErrNp.fromString("System:NullObjectCall");
         
         Build:NamePath callErrNp = Build:NamePath.new();
         callErrNp.fromString("System:MethodNotDefined");

         String textQuote = Text:Strings.new().quote;
      
         Map mtdDeclared = Map.new();
         String stackPrep = String.new();
         String stackfsPrep = String.new();
         String postPrep = String.new();
         String mtdDeclares = String.new();
         Map consTypes = Map.new();
         Int consTypesi = 0;
         String thisMtd = String.new();
         Bool lastCallReturn = false;
         Bool inMtd = false;
         String sargs = "int berv_chkt, BERT_Stacks* berv_sts, void** bevs";
         Text:Tokenizer emitTok = Text:Tokenizer.new("$*&=", true);
         String inlBlock = String.new();
      }
   }
   
   emitterSet(Build:CEmitter _emitter) {
      //"Setting Emit".print();
      emitter = _emitter;
      nl = emitter.build.newline;
      //cassem = emitter.build.cassem;
      mmbers = nl.copy();
      //{
      textRbnl = "}" + nl;
      
   }
   
   buildIncludes(node) {
      var h = String.new();
      var maxd = 0;
      var deps = Map.new();
      //("Doing buildIncludes for class " + node.held.namepath.toString()).print();
      Map unq = Map.new();
      for (var it = node.held.used.iterator;it.hasNext;;) {
         var np = it.next;
         if (def(np)) {
            //("Found namepath include " + np.toString()).print();
            var nps = np.toString();
            var syn = build.getSynNp(np);
            if (unq.has(nps)! && build.closeLibraries.has(syn.libName)) {
               unq.put(nps, nps);
               if (syn.depth > maxd){
                  maxd = syn.depth;
               }
               var ll = deps.get(syn.depth);
               if (undef(ll)) {
                  //("LL isnull for " + syn.depth.toString()).print();
                  ll = LinkedList.new();
                  deps.put(syn.depth, ll);
               }
               ll.addValue(emitter.getInfoSearch(np)); 
            }
         }
      }
      maxd = maxd + 1;
      for (var j = 0;j < maxd;j = j++) {
         ll = deps.get(j);
         if (def(ll)) {
            for (it = ll.iterator;it.hasNext;;) {
               var clinfo = it.next;
               //("Adding " + clinfo.classIncH.toString()).print();
               h = h + "#include <" + clinfo.classIncH.toString(emitter.build.platform.separator) + ">" + nl;
            }
         }
      }
      return(h);
   }
   
   clEmit(clnode, node) {
      if (node.held.langs.has("c")!) {
        //diff lang, not for me
        return("");
      }
      var ll = node.held.text.split("/");
      var isfn = false;
      var isfs = false;
      var isar = false;
      var nextIsNativeSlots = false;
      foreach (var i in ll) {
         if (nextIsNativeSlots) {
            nextIsNativeSlots = false;
            nativeSlots = Int.new(i);
            isfn = true;
         } elif (i == "*-attr- -firstSlotNative-*") {
            isfn = true;
            Int nativeSlots = 1;
         } elif (i == "*-attr- -nativeSlots") {
            nextIsNativeSlots = true;
         } elif (i == "*-attr- -freeFirstSlot-*") {
            isfs = true;
         } elif (i == "*-attr- -isArray-*") {
            isar = true;
         }
      }
      if (isfn) {
         clnode.held.firstSlotNative = true;
         clnode.held.nativeSlots = nativeSlots;
         return(String.new());
      } elif (isfs) {
         clnode.held.freeFirstSlot = true;
         return(String.new());
      } elif (isar) {
         clnode.held.isArray = true;
         return(String.new());
      } else {
         return(node.held.text);
      }
   }

   acceptClass(Node node) {
      inClass = node;
      inClassNamed = node.held.namepath.toString();
      inFileNamed = node.held.fromFile.toStringWithSeparator("/");
      inClassSyn = node.held.syn;
      classInfo = emitter.getInfo(node.held.namepath);
      if (def(node.held.extends)) {
         superClassInfo = emitter.getInfoSearch(node.held.extends);
         superSyn = build.getSynNp(inClass.held.extends);
         if (superSyn.libName == build.libName) {
            hincl = hincl + "#include <" + superClassInfo.classIncH.toString(emitter.build.platform.separator) + ">" + nl;
         }
      }
      var j = node.transUnit.held.emits;
      if (def(j)) {
         for (j = j.iterator;j.hasNext;;) {
            var jn = j.next;
            if (jn.held.langs.has("c")) {
                cincl = cincl + jn.held.text;
            }
         }
      }
      cincl = cincl + buildIncludes(node);
      if (classInfo.clName == objectClname) {
         hincl = hincl + "#include <BER_Base.h>" + nl;
      }
      
      j = node.held.orderedVars;
      if (def(j)) {
         for (j = j.iterator;j.hasNext;;) {
            var i = j.next;
         }
      }
      
      j = node.held.emits;
      
      if (def(j)) {
         for (j = j.iterator;j.hasNext;;) {
            jn = j.next;
            mmbers = mmbers + clEmit(inClass, jn);
         }
      }
      
      node.reInitContained();
      
      j = node.held.orderedMethods;
      if (def(j)) {
         for (j = j.iterator;j.hasNext;;) {
            i = j.next;
            node.addValue(i);
         }
      }
      
      buildCldefDecs();
      
      emitter.emitInitialClass(inClass, self);
   }
   
   buildCldefDecs() {
      Build:ClassSyn syn = inClass.held.syn;
      cldefDecs += "BERT_ClassDef* " += classInfo.cldefName += " = NULL;" += nl;
      cldefDecs += "static char* " += classInfo.shClassName += " = (char*) " += textQuote += inClassNamed += textQuote += ";" += nl;
      cldefDecs += "static char* " += classInfo.shFileName += " = (char*) " += textQuote += inFileNamed += textQuote += ";" += nl;
   }
   
   buildCldef() {
      //"In cldef".print();
      Build:ClassSyn syn = inClass.held.syn;
      
      Int firstProperty = build.constants.extraSlots;

      cldefH = build.dllhead(cldefH);
      cldefH = cldefH + "BERT_ClassDef* " + classInfo.cldefBuild + "();" + nl;
      cldefH = build.dllhead(cldefH);
      cldefH = cldefH + "extern BERT_ClassDef* " + classInfo.cldefName + ";" + nl;
      
      String defM = String.new();
      String defmd = String.new();
      String defmds = String.new();
      if (undef(superSyn)) {
         defM += "twst_mrpos = " += build.constants.extraSlots.toString() += ";" += nl;
      } else {
         defM += "twst_mrpos = twst_shared_cd->twst_supercd->maxProperty;" += nl;
      }
      
      foreach (Build:PtySyn bsyn in syn.ptyList) {
         String finName = bsyn.name + "Get_0";
         String mbn = "twnn_" + build.libName + "_" + finName;
         cldefH = build.dllhead(cldefH);
         if (bsyn.origin.toString() == inClassNamed) {
			build.emitData.propertyIndexes.put(Build:PropertyIndex.new(syn, bsyn));
         }
         if (bsyn.origin.toString() == inClassNamed || inClass.held.referencedProperties.has(bsyn.name)) {
            syn.allNames.put(finName);
            build.emitter.registerName(finName);
            if (bsyn.origin.toString() == inClassNamed) {
			   if (syn.directProperties!) {
				String pics = emitter.getPropertyIndexName(bsyn);
				defM += pics += " = twst_mrpos;" + nl;
			   }
               defM += "twst_mrpos++;" += nl;
            }
         }
      }
      
      if (syn.directMethods!) {
		//must have a supersyn, not possible otherwise
		Int superMaxMtdx = superSyn.maxMtdx;
      }
      
      Int newMtds = 0;
      foreach (Build:MtdSyn tsyn in syn.mtdList) {
         //can this be below the orign test?  to be true, propi build needs to change
         //so that indexes are only counted by callers (access to member) like typed calls
         if (tsyn.origin.toString() == inClassNamed) {
			syn.allNames.put(tsyn.name, tsyn.name);
            build.emitter.registerName(tsyn.name);
            String tmn;
            tmn = emitter.getInfoSearch(tsyn.origin).mtdName + tsyn.name;
            //For the method def
            String mdefv = "twst_mdv" + newMtds.toString();
            String mdefStruct = "static BERT_MtdDef " + mdefv + " = { (void**) &" + tmn + ", ";
            if (tsyn.isGenAccessor) {
               //if it is GenAccessor and defined in this class (origin inclass) then
               //pidx is always defined
               if (syn.directProperties) {
                 mdefStruct = mdefStruct + (syn.ptyMap[tsyn.propertyName].mpos + build.constants.extraSlots).toString(); 
               } else {
				mdefStruct = mdefStruct + "0";
				defmds += mdefv += ".pidx = " += emitter.getPropertyIndexName(syn.ptyMap[tsyn.propertyName]) += ";" += nl;
		    	}
            } else {
				mdefStruct = mdefStruct + "0";
            }
            mdefStruct = mdefStruct + ", -1"; 
            mdefStruct = mdefStruct + " };" + nl;
            defmd += mdefStruct;
            
            //setup the twnn value
            defmds += mdefv += ".twnn = twnn_" += build.libName += "_" += tsyn.name += ";" += nl;
            //Add the method to the dmlist
            //defmds += "BERF_Dmlist_Insert_With_Retry(twst_shared_cd, &" += mdefv += ");" += nl;
            
            //if this is the declaration class for a method and it is not directMethods then
            //we need to set our twmi value here
            if (tsyn.declaration.toString() == inClassNamed && syn.directMethods!) {
				Int mtdxDiff = tsyn.mtdx - (superMaxMtdx + 1);
				if (mtdxDiff < 0) {
					throw(VisitError.new("mtdxDiff < 0, this is impossible"));
				}
				String mival = emitter.getMethodIndexName(tsyn);
				defM += mival += " = twst_supercd->mtdArLen + " += build.constants.mtdxPad.toString() += " + " += mtdxDiff.toString() += ";" += nl;
            }
            
            //Put the mtd pointer into the correct spot in the mtd vtable, we treat the whole cldef as an array
            //of pointers for this, the offsets are arranged to be after the struct section of the cldef
            defM += "((void**)twst_shared_cd)[" += getMethodIndex(syn, syn, tsyn.name) += "] = (void*) &" += tmn += ";" += nl;
            //same for mlist
            defM += "twst_shared_cd->mlist[" += getMlistIndex(syn, syn, tsyn.name) += "] = &" += mdefv += ";" += nl;
            newMtds = newMtds++;
         }
      }
      cldef += "BERT_ClassDef* " += classInfo.cldefBuild += "() {" += nl;
      cldef += "BERT_ClassDef* twst_shared_cd;" += nl;
      cldef += "BEINT twst_mrpos = 0;" += nl;
      cldef += "BEINT twst_i = 0;" += nl;
      cldef += defmd;
      
      cldef += "if (" += classInfo.cldefName += " == NULL) {" += nl;
      
      //setup a ref to the superclass cldef, if any
      //we do this here partly so we can figure out how large
      //to make our classdef (to account for the vtable after the cldef
      //proper)
      
      if (def(superClassInfo)) {
         if (superSyn.libName != build.libName) {
            //foreignClass
            //"!!!!!!!!!FOUND FOREIGN CLASS".print();
            String fcn = emitter.foreignClass(inClassSyn.superNp, inClassSyn);
            cldef += "BERT_ClassDef* twst_supercd = " += fcn += ";" += nl;
         } else {
            //("!!! supersyn " + inClassSyn.superNp.toString() + " is in same compile unit").print();
            cldef += "BERT_ClassDef* twst_supercd = " += superClassInfo.cldefBuild += "();" += nl;
         }
         String mtdArSize = "((twst_supercd->mtdArLen + " + syn.newMtds + " + " + build.constants.mtdxPad + ") * sizeof(void*))";
         String mlistSize = "((twst_supercd->mtdArLen + " + syn.newMtds + ") * sizeof(void*))";
         //copy the super's mtd vtable and mlist
         //vtable
         String superMtdCopy = "size_t mtdxi = " + build.constants.mtdxPad + ";" + nl;
         superMtdCopy = superMtdCopy + "size_t mtdxMax = " + build.constants.mtdxPad + " + twst_supercd->mtdArLen;" + nl;
         superMtdCopy = superMtdCopy + "for (;mtdxi < mtdxMax;mtdxi++) {" + nl;
         superMtdCopy = superMtdCopy + "((void**)twst_shared_cd)[mtdxi] = ((void**)twst_supercd)[mtdxi];" + nl;
         superMtdCopy = superMtdCopy + "}" + nl;
         //TODO it would be better to do the above and below with memcpy but attempts to do so have not worked out :-(
         //String superMtdCopy = "memcpy(((void**) twst_shared_cd)[" + build.constants.mtdxPad + "], ((void**) twst_supercd)[" + build.constants.mtdxPad + "], (twst_supercd->mtdArLen * sizeof(void**)));" + nl;
         //mlist
         superMtdCopy = superMtdCopy + "mtdxi = 0;" + nl;
         superMtdCopy = superMtdCopy + "mtdxMax = twst_supercd->mtdArLen;" + nl;
         superMtdCopy = superMtdCopy + "for (;mtdxi < mtdxMax;mtdxi++) {" + nl;
         superMtdCopy = superMtdCopy + "twst_shared_cd->mlist[mtdxi] = twst_supercd->mlist[mtdxi];" + nl;
         superMtdCopy = superMtdCopy + "}" + nl;
      } else {
		 mtdArSize = "((" + syn.newMtds + " + " + build.constants.mtdxPad + ") * sizeof(void*))";
		 mlistSize = "(" + syn.newMtds + " * sizeof(void*))";
		 //no super, no need to copy the super's mtd vtable or mlist
		 superMtdCopy = "";
         cldef += "BERT_ClassDef* twst_supercd = NULL;" += nl;
      }
      
      //malloc this based on cldef size + vtable size
      cldef += "twst_shared_cd = (BERT_ClassDef*) BEMalloc(" += mtdArSize += ");" += nl;
      //create the mlist
      cldef += "twst_shared_cd->mlist = (BERT_MtdDef**) BEMalloc(" += mlistSize += ");" += nl;
      //Do the super mtd vtable copy
      cldef += superMtdCopy;
      cldef += "twst_shared_cd->className = " += classInfo.shClassName += ";" += nl;
      cldef += "BERF_Hash_PutOnce(BERV_proc_glob->classHash, " += inClassNamed.hash.toString() += ", twst_shared_cd->className, (void*) twst_shared_cd);" += nl;
      
      //supercd struct set is here
      cldef += "twst_shared_cd->twst_supercd = twst_supercd;" += nl;
      
      //cldef += "twst_shared_cd->dtEmpty = &twst_dtEmpty;" += nl;
      if (undef(superSyn)) {
         //I am System:Object
         cldef += "twst_shared_cd->minProperty = " += build.constants.extraSlots.toString() += ";" += nl;
         cldef += "twst_shared_cd->maxProperty = " += (build.constants.extraSlots + syn.ptyList.length).toString() += ";" += nl;
      } else {
         if (inClass.held.firstSlotNative) {
            cldef += "twst_shared_cd->minProperty = " += (build.constants.extraSlots + inClass.held.nativeSlots).toString() += ";" += nl;
         } else {
            cldef += "twst_shared_cd->minProperty = twst_shared_cd->twst_supercd->minProperty;" += nl;
         }
         cldef += "twst_shared_cd->maxProperty = twst_shared_cd->twst_supercd->maxProperty + " += (syn.ptyList.length - superSyn.ptyList.length).toString() += ";" += nl;
      }
      cldef += "twst_shared_cd->loneAlloc = (twst_shared_cd->maxProperty + 1) * sizeof(void*);" += nl;
      cldef += "twst_shared_cd->allocSize = twst_shared_cd->maxProperty * sizeof(void*);" += nl;
      cldef += "twst_shared_cd->allocBucket = twst_shared_cd->allocSize / BERV_proc_glob->twrbsz;" += nl;
      cldef += "if (twst_shared_cd->allocSize % BERV_proc_glob->twrbsz == 0) { twst_shared_cd->allocBucket--; }" += nl;
      cldef += "if (twst_shared_cd->allocBucket < berbmax) { twst_shared_cd->allocSize = (twst_shared_cd->allocBucket + 1) * BERV_proc_glob->twrbsz; }" += nl;
      if (inClass.held.freeFirstSlot) {
         cldef += "twst_shared_cd->freeFirstSlot = 1;" += nl;
      } else {
         cldef += "twst_shared_cd->freeFirstSlot = 0;" += nl;
      }
      if (inClass.held.firstSlotNative) {
         cldef += "twst_shared_cd->firstSlotNative = 1;" += nl;
      } else {
         cldef += "twst_shared_cd->firstSlotNative = 0;" += nl;
      }
      if (inClass.held.isArray) {
         cldef += "twst_shared_cd->isArray = 1;" += nl;
      } else {
         cldef += "twst_shared_cd->isArray = 0;" += nl;
      }
      if (inClass.held.isFinal) {
         cldef += "twst_shared_cd->isFinal = 1;" += nl;
      } else {
         cldef += "twst_shared_cd->isFinal = 0;" += nl;
      }
      if (inClass.held.isLocal) {
         cldef += "twst_shared_cd->isLocal = 1;" += nl;
      } else {
         cldef += "twst_shared_cd->isLocal = 0;" += nl;
      }
      cldef += "twst_shared_cd->onceEvalCount = " += inClass.held.onceEvalCount.toString() += ";" += nl;
      cldef += "twst_shared_cd->classId = BERV_proc_glob->nextClassId;" += nl;
      cldef += "BERV_proc_glob->nextClassId++;" += nl;
      if (undef(superSyn)) {
         cldef += "twst_shared_cd->mtdArLen = " += syn.newMtds.toString() += ";" += nl;
      } else {
         cldef += "twst_shared_cd->mtdArLen = twst_shared_cd->twst_supercd->mtdArLen + " += syn.newMtds.toString() += ";" += nl;
      }
      cldef += defM;
      //setup the dmlist, initialize
      //cldef += "BERF_Dmlist_Initialize(twst_shared_cd);" += nl;
      cldef += defmds;
      //cldef += "BERF_Dmlist_FillEmpty(twst_shared_cd);" += nl;
      cldef += "BERF_Dmlist_Setup(twst_shared_cd, 2, 1);" += nl;
      
      cldef += classInfo.cldefName += " = twst_shared_cd;" += nl;
      
      cldef += "}" += nl;
      cldef += "return " += classInfo.cldefName += ";" += nl;
      cldef += "}" += nl;

      //"done cldef".print();
   }
   
   protoMtd(node) {
   
      Int numargs = node.held.numargs;
      if (numargs > build.constants.maxargs) {
        numargs = build.constants.maxargs;
      }
      String abuf = String.new();
      for (Int i = 0;i < numargs;i = i++) {
        abuf += ", void** beav" += i.toString();
      }
      if (node.held.numargs > build.constants.maxargs) {
        abuf += ", void** beax";
      }
      var proto = classInfo.mtdName + node.held.name + "( " + sargs + abuf + " ) ";
      methods += "void** " += proto += "{" += nl; // }
      methods += "/*Begin Mtd, Name: " += classInfo.mtdName += node.held.name += " */" += nl;
      methodsProto = build.dllhead(methodsProto);
      methodsProto = methodsProto + "extern void** " + proto + ";" + nl;
   }
   
   attemptReuse(Node node, Map reum) Int {
      //return(-1);
      Int mymax = node.held.maxCpos;
      Int mymin = node.held.minCpos;
      foreach (var kv in reum) {
         Bool found = true;
         foreach (var lv in kv.value) {
            Int lvmin = lv.held.minCpos;
            Int lvmax = lv.held.maxCpos;
            if ((lvmax >= mymin) && (lvmin <= mymax)) {
               found = false;
               break;
            }
         }
         if (found) {
            //("REUSE").print();
            return(lv.held.vpos);
         }
      }
      //("NOREU").print();
      return(-1);
   }
   
   acceptMtd(Node node) {
      inMtd = true;
      inMtdNamed = node.held.name;
      inMtdNode = node;
      protoMtd(node);
      var ic = 0;
      String tcall = Text:String.new();
      var argCheck = false;
      Map reum = Map.new();
      for (var it = node.held.orderedVars.iterator;it.hasNext;;) {
         var i = it.next;
         if ((i.held.name != "self") && (i.held.name != "super")) {
            Int reuse = -1;
            if (ic > node.held.numargs) {
               if (i.held.isTmpVar && i.held.suffix == "phold") {
                  reuse = attemptReuse(i, reum);
                  if (reuse > -1) {
                     i.held.vpos = reuse;
                  }
               }
               if (reuse == -1) {
                  var hmax = inMtdNode.held.hmax;
                  i.held.vpos = hmax;
                  inMtdNode.held.hmax = hmax++;
               }
               if (i.held.isTmpVar && i.held.suffix == "phold") {
                  LinkedList ll = reum[i.held.vpos];
                  if (undef(ll)) { ll = LinkedList.new(); reum[i.held.vpos] = ll; }
                  ll += i;
               }
            } else {
               var amax = inMtdNode.held.amax;
               i.held.vpos = amax;
               inMtdNode.held.amax = amax++;
               if (i.held.isTyped) {
                  argCheck = true;
                  CallCursor ca = CallCursor.new(self, node, i, true);
                  ca.typeCheckSyn = build.getSynNp(ca.asnR.held.namepath);
                  doTypeCheck(ca, ca.targs); /*is arg, stack frame dropped on fail*/
                  tcall = tcall + ca.assignTypeCheck;
               }
            }
         }
         ic = ic + 1;
      }
      stackPrep += "berv_sts->stackf = &berv_stackfs;" += nl;
      if (argCheck) {
         postPrep += "if (berv_chkt == 1) {" += nl;
         postPrep += tcall;
         postPrep += "}" += nl;
      }
   }
   
   acceptIfEmit(Node node) {
      if (node.held.langs.has("c")!) {
        return(node.nextPeer);
      }
      return(node.nextDescend);
   }
   
   acceptEmit(Node node) {
      if (node.held.langs.has("c")!) {
        return(self);
      }
      var ll = node.held.text.split("/");
      //("Split done").print();
      Bool noRep = false;
      var isdec = false;
      foreach (var i in ll) {
         if (i == "*-attr- -dec-*") {
            isdec = true;
         }
         if (i == "*-attr- -noreplace-*") {
            noRep = true;
         }
      }
      if (isdec) {
         mtdDeclares += node.held.text;
      } else {
        if (noRep) {
         thisMtd += node.held.text;
        } else {
         handleEmitReplace(node);
        }
      }
   }
   
   handleEmitReplace(Node node) {
      
      Bool didArep = false;
      Bool invar = false;
      Bool asn = false;
      Bool vv = false;
      String vname;
      inlBlock.clear();
      
      Container:Queue heldToks = Container:Queue.new();
      
      LinkedList toks = emitTok.tokenize(node.held.text);
      foreach (String tok in toks) {
        if (invar) {
            if (tok == "$") {
                //found a $ but not a *, false case
                until (heldToks.isEmpty) {
                    inlBlock += heldToks.dequeue();
                }
                //stay "invar" though, this one could be valid
                heldToks += tok;
                asn = false;
                vv = false;
                vname = null;
            } elif (tok == "*") {
                if (undef(vname)) {
                   //false case, must follow the name
                   until (heldToks.isEmpty) {
                    inlBlock += heldToks.dequeue();
                    } 
                    inlBlock += tok;
                    invar = false;
                    asn = false;
                    vv = false;
                } else {
                    //do the thing, output the var
                    didArep = true;
                    Node varNode = inMtdNode.held.varMap.get(vname);
                    if (undef(varNode)) {
                        varNode = inClass.held.varMap.get(vname);
                        if (undef(varNode)) {
                            throw(VisitError.new("Unable to find variable for inline replace variable named " + vname));
                        }
                    }
                    if (asn) {
                        vnameval = finalAssignTo(varNode, vv);
                    } else {
                        if (vv) {
                            String vnameval = formTarg(varNode);
                        } else {
                            vnameval = formRTarg(varNode);
                        }
                    }
                    inlBlock += vnameval;
                    //end 
                    invar = false;
                    asn = false;
                    vv = false;
                    vname = null;
                }
            } elif (tok == "&") {
                if (undef(vname)) {
                   //false case, must follow the name
                   until (heldToks.isEmpty) {
                    inlBlock += heldToks.dequeue();
                    } 
                    inlBlock += tok;
                    invar = false;
                    asn = false;
                    vv = false;
                } else {
                    vv = true;
                    heldToks += tok;
                }
            } elif (tok == "=") {
                if (undef(vname)) {
                   //false case, must follow the name
                   until (heldToks.isEmpty) {
                    inlBlock += heldToks.dequeue();
                    } 
                    inlBlock += tok;
                    invar = false;
                    asn = false;
                    vv = false;
                } else {
                    asn = true;
                    heldToks += tok;
                }
            } else {
                vname = tok;
                heldToks += tok;
            }
        } elif (tok == "$") {
            heldToks += tok;
            invar = true;
        } else {
            inlBlock += tok;
        }
      }
      
      //testing
      if (didArep! && inlBlock.toString() != node.held.text) {
        throw(VisitError.new("inlBlock not equal to node.held " + inlBlock.toString() + " " + node.held.text));
      }
      
      thisMtd += inlBlock;
   }
   
   formTarg(Node node) String {
      String tcall;
      if (node.typename == ntypes.NULL) {
         tcall = "((void**) NULL)";
      } elif (node.held.name == "self" || node.held.name == "super") {
         tcall = "bevs";
      } elif (node.held.isProperty) {
         tcall = "((void**) bevs[" + getPropertyIndex(node) + "])";
      } elif (node.held.isArg) {
         tcall = "beav" + node.held.vpos.toString();
      } else {
         tcall = "belv" + node.held.vpos.toString();
      }
      return(tcall);
   }
   
   formRTarg(Node node) String {
      String tcall;
      if (node.typename == ntypes.NULL) {
         tcall = "NULL";
      } elif (node.held.name == "self" || node.held.name == "super") {
         tcall = "((void*) bevs)";
      } elif (node.held.isProperty) {
         tcall = "bevs[" + getPropertyIndex(node) + "]";
      } elif (node.held.isArg) {
         tcall = "((void*)beav" + node.held.vpos.toString() + ")";
      } else {
         tcall = "((void*)belv" + node.held.vpos.toString() + ")";
      }
      return(tcall);
   }
   
   //get the property index, for direct property cases this is a literal numeric (as string), otherwise it is
   //the variable name which holds the runtime determined index 
   getPropertyIndex(node) String {
      if (inClassSyn.directProperties) {
         return((inClassSyn.ptyMap[node.held.name].mpos + build.constants.extraSlots).toString());
      }
      inClass.held.referencedProperties.put(node.held.name);
      build.emitData.propertyIndexes.put(Build:PropertyIndex.new(inClassSyn, inClassSyn.ptyMap[node.held.name]));
      return(emitter.getPropertyIndexName(inClassSyn.ptyMap[node.held.name]));
   }
   
   //get the method index, for direct method cases this is a literal numeric (as string), otherwise it is
   //the variable name which holds the runtime determined index 
   getMethodIndex(Build:ClassSyn asyn, Build:ClassSyn syn, String tsname) String {
      if (asyn.directMethods && build.closeLibraries.has(asyn.libName)) {
		 //mtdxPad becaue this is an array "attached beind" the cldef struct in the same memory space
         return((asyn.mtdMap[tsname].mtdx + build.constants.mtdxPad).toString());
      }
      Build:MethodIndex mi = Build:MethodIndex.new(asyn, asyn.mtdMap[tsname]);
      //this needs to happen based on declaration in lib, not usage
      build.emitData.methodIndexes.put(mi);
      return(emitter.getMethodIndexName(asyn.mtdMap[tsname]));
   }
   
   //get the method def index, for direct method cases this is a literal numeric (as string), otherwise it is
   //the variable name which holds the runtime determined index (- pad)
   //this is like getMethodIndex above but without the mtdxPad, for use with the cldef mlist
   getMlistIndex(Build:ClassSyn asyn, Build:ClassSyn syn, String tsname) String {
      if (asyn.directMethods && build.closeLibraries.has(asyn.libName)) {
         return((asyn.mtdMap[tsname].mtdx).toString());
      }
      Build:MethodIndex mi = Build:MethodIndex.new(asyn, asyn.mtdMap[tsname]);
      //this needs to happen based on declaration in lib, not usage
      build.emitData.methodIndexes.put(mi);
      //TODO maybe? arrange to avoid subtraction with dedicated values
      return(emitter.getMethodIndexName(asyn.mtdMap[tsname]) + " - " + build.constants.mtdxPad.toString());
   }
   
   finalAssignTo(Node node, Bool isVss) String {
	  String sFrom = Text:Strings.empty;
      String vFrom = Text:Strings.empty;
      if (isVss) {
         sFrom = "(void*) ";
      } else {
        vFrom = "(void**) ";
      }
      if (node.held.isProperty) {
         String tcall = String.new();
         tcall = tcall + "bevs[" + getPropertyIndex(node) + "] = " + sFrom;
         return(tcall);
      } elif (node.held.isArg) {
         return("beav" + node.held.vpos.toString() + " = " + vFrom);
      }// else {
         return("belv" + node.held.vpos.toString() + " = " + vFrom);
      //}
      /*
      if (node.typename == ntypes.NULL) {
         throw(VisitError.new("Cannot assign to literal null"));
      }
      if (node.held.name == "self") {
         throw(VisitError.new("Cannot assign to self"));
      }
      if (node.held.name == "super") {
         throw(VisitError.new("Cannot assign to super"));
      }
      return(sFrom);
      */
   }
   
   finalAssign(Node node, String sFrom, Bool isVss) String {
      return(finalAssignTo(node, isVss) + sFrom + ";" + nl);
   }
   
   prepBemxArg(node, orgpos) {
      Int pos = orgpos - build.constants.maxargs;
      String tcall;
      if (node.typename == ntypes.NULL) {
         tcall = "bemx[" + pos.toString() + "] = (void*) NULL;" + nl;
      } elif (node.held.name == "self") {
         tcall = "bemx[" + pos.toString() + "] = (void*) bevs;" + nl;
      } elif (node.held.name == "super") {
         tcall = "bemx[" + pos.toString() + "] = (void*) bevs;" + nl;
      } elif (node.held.isProperty) {
         return("bemx[" + pos.toString() + "] = bevs[" + getPropertyIndex(node) + "];" + nl);
      } elif (node.held.isArg) {
         return("bemx[" + pos.toString() + "] = (void*) beav" + node.held.vpos.toString() + ";" + nl);
      } else {
         return("bemx[" + pos.toString() + "] = (void*) belv" + node.held.vpos.toString() + ";" + nl);
      }
      return(tcall);
   }
   
   getBeavArg(node) {
      String tcall;
      if (node.typename == ntypes.NULL) {
         tcall = "NULL";
      } elif (node.held.name == "self") {
         tcall = "bevs";
      } elif (node.held.name == "super") {
         tcall = "bevs";
      } elif (node.held.isProperty) {
         return("(void**) bevs[" + getPropertyIndex(node) + "]");
      } elif (node.held.isArg) {
         return("beav" + node.held.vpos.toString());
      } else {
         return("belv" + node.held.vpos.toString());
      }
      return(tcall);
   }
   
   doTypeCheck(CallCursor ca, String starg) {
	  return(doTypeCheck(ca, starg, null));
   }
   
   doTypeCheck(CallCursor ca, String starg, Node clearOnFail) {
      String tcall = String.new();
      if (mtdDeclared.has("twtc_cldef")!) {
         mtdDeclared.put("twtc_cldef", true);
         mtdDeclares += "BERT_ClassDef* twtc_cldef;" += nl;
      }
      tcall = tcall + "if (" + starg + " != NULL) {" + nl;
      tcall = tcall + "twtc_cldef = (BERT_ClassDef*) " + starg + "[berdef];" + nl;
      tcall = tcall + "while (twtc_cldef != NULL && ((size_t) " + emitter.classDefTarget(ca.typeCheckSyn, inClassSyn) + ") != ((size_t) twtc_cldef)) {" + nl;
      tcall = tcall + "twtc_cldef = twtc_cldef->twst_supercd;" + nl;
      tcall = tcall + "}" + nl;
      tcall = tcall + "if (twtc_cldef == NULL) {" + nl;
      if (def(clearOnFail)) {
		tcall = tcall + finalAssign(clearOnFail, "NULL", false);
	  }
      tcall = tcall + "BERF_Throw_IncorrectType(berv_sts, " + classInfo.shClassName + ", twrv_stackdef.sname, " + classInfo.shFileName + ", " + ca.node.nlc.toString() + " );" + nl;
      tcall = tcall + "}" + nl;
      tcall = tcall + "}" + nl;
      ca.assignTypeCheck = tcall;
   }
   
   doSelfTypeCheck(CallCursor ca, String starg) {
      String tcall = String.new();
      if (mtdDeclared.has("twtc_cldef")!) {
         mtdDeclared.put("twtc_cldef", true);
         mtdDeclares += "BERT_ClassDef* twtc_cldef;" += nl;
      }
      if (mtdDeclared.has("twtc_cldefself")!) {
         mtdDeclared.put("twtc_cldefself", true);
         mtdDeclares += "BERT_ClassDef* twtc_cldefself;" += nl;
      }
      tcall = tcall + "if (" + starg + " != NULL && bevs != NULL) {" + nl;
      tcall = tcall + "twtc_cldef = (BERT_ClassDef*) " + starg + "[berdef];" + nl;
      tcall = tcall + "twtc_cldefself = (BERT_ClassDef*) bevs[berdef];" + nl;
      
      tcall = tcall + "while (twtc_cldef != NULL && ((size_t) twtc_cldefself) != ((size_t) twtc_cldef)) {" + nl;
      tcall = tcall + "twtc_cldef = twtc_cldef->twst_supercd;" + nl;
      tcall = tcall + "}" + nl;
      tcall = tcall + "if (twtc_cldef == NULL) {" + nl;
      tcall = tcall + "BERF_Throw_IncorrectType(berv_sts, " + classInfo.shClassName + ", twrv_stackdef.sname, " + classInfo.shFileName + ", " + ca.node.nlc.toString() + " );" + nl;
      tcall = tcall + "}" + nl;
      tcall = tcall + "}" + nl;
      ca.assignTypeCheck = tcall;
   }
   
   acceptReturn(Node node) {
      
      lastCallReturn = true;
      CallCursor ca = CallCursor.new(self, node, node.second, node.held.checkTypes);
      ca.tcall = ca.tcall + build.nl;
      if (ca.checkAssignTypes) {
         Node rsub = node.scope;
         if (rsub.held.rtype.isSelf) {
            doSelfTypeCheck(ca, ca.targs);
         } else {
            ca.typeCheckSyn = build.getSynNp(rsub.held.rtype.namepath);
            doTypeCheck(ca, ca.targs);/*is a return, no assignment as a consequence (will not return on fail but raises except)*/
         }
         ca.tcall = ca.tcall + ca.assignTypeCheck;
      }
      
      thisMtd += ca.tcall += "BEVReturn(" + ca.targs + ");" += nl;
      
   }
   
   acceptCall(Node node) {
      
      lastCallReturn = false;
      
      if (node.held.orgName == "throw") {
         //"In earlier throw".print();
         //Already implemented in accept()
         return(self);
      } elif (node.held.orgName == "assign") {
         if (node.second.typename == ntypes.VAR) {
            CallCursor ca = CallCursor.new(self, node, node.contained.first, node.held.checkTypes);
            ca.asnCall = node;
            String sasnL = formTarg(node.second);
            if (ca.checkAssignTypes) {
               ca.typeCheckSyn = build.getSynNp(ca.asnR.held.namepath);
               doTypeCheck(ca, sasnL);/*before the assignment*/
            }
            ca.callAssign = finalAssign(ca.asnR, sasnL, true);
            thisMtd += cassem.processCall(ca);
         } elif (node.second.typename == ntypes.NULL) {
            ca = CallCursor.new(self, node, node.contained.first, false);
            ca.asnCall = node;
            ca.callAssign = finalAssign(ca.asnR, "NULL", false);
            thisMtd += cassem.processCall(ca);
         } elif (node.second.typename == ntypes.TRUE) {
            ca = CallCursor.new(self, node, node.contained.first, false);
            ca.asnCall = node;
            ca.callAssign = finalAssign(ca.asnR, "berv_sts->bool_True", true);
            thisMtd += cassem.processCall(ca);
         } elif (node.second.typename == ntypes.FALSE) {
            ca = CallCursor.new(self, node, node.contained.first, false);
            ca.asnCall = node;
            ca.callAssign = finalAssign(ca.asnR, "berv_sts->bool_False", true);
            thisMtd += cassem.processCall(ca);
         } elif (node.second.typename == ntypes.CALL && (node.second.held.name == "undef_1" || node.second.held.name == "undefined_1")) {
            //if (node.second.second.held.isTyped) {
            //    Build:ClassSyn dsyn = build.getSynNp(node.second.second.held.namepath);
            //    if (dsyn.isNotNull) {
            //        throw(VisitError.new("Check for defined/undefined on non-nullable type"));
            //    }
            //}
            ca = CallCursor.new(self, node, node.contained.first, node.held.checkTypes);
            ca.asnCall = node;
            if (ca.checkAssignTypes) {
               if (ca.asnR.held.namepath.toString != "Logic:Bool") {
                  throw(VisitError.new("Incorrect type for undef/undefined on assignment", node));
               }
            }
            ca.callAssign = ca.callAssign + "if (" + formTarg(node.second.second) + " == NULL) { " + nl;
            ca.callAssign = ca.callAssign + finalAssign(ca.asnR, "berv_sts->bool_True", true);
            ca.callAssign = ca.callAssign + " } else { ";
            ca.callAssign = ca.callAssign + finalAssign(ca.asnR, "berv_sts->bool_False", true);
            ca.callAssign = ca.callAssign + " }" + nl;
            thisMtd += cassem.processCall(ca);
         } elif (node.second.typename == ntypes.CALL && (node.second.held.name == "def_1" || node.second.held.name == "defined_1")) {
            //if (node.second.second.held.isTyped) {
            //    dsyn = build.getSynNp(node.second.second.held.namepath);
            //    if (dsyn.isNotNull) {
            //        throw(VisitError.new("Check for defined/undefined on non-nullable type"));
            //    }
            //}
            ca = CallCursor.new(self, node, node.contained.first, node.held.checkTypes);
            ca.asnCall = node;
            if (ca.checkAssignTypes) {
               if (ca.asnR.held.namepath.toString != "Logic:Bool") {
                  throw(VisitError.new("Incorrect type for def/defined on assignment", node));
               }
            }
            ca.callAssign = ca.callAssign + "if (" + formTarg(node.second.second) + " == NULL) { " + nl;
            ca.callAssign = ca.callAssign + finalAssign(ca.asnR, "berv_sts->bool_False", true);
            ca.callAssign = ca.callAssign + " } else { ";
            ca.callAssign = ca.callAssign + finalAssign(ca.asnR, "berv_sts->bool_True", true);
            ca.callAssign = ca.callAssign + " }" + nl;
            thisMtd += cassem.processCall(ca);
         }
         return(self);
      } elif (node.held.orgName == "return") {
         return(acceptReturn(node));
      } elif (node.held.name == "def_1" || node.held.name == "defined_1" || node.held.name == "undef_1" || node.held.name == "undefined_1") {
         return(self);
      }
      
      Int onceEvalCount;
      
      if (node.held.numargs > inMtdNode.held.mmax) {
         inMtdNode.held.mmax = node.held.numargs;
      }
      if ((node.container.typename == ntypes.CALL) && (node.container.held.orgName == "assign")) {
         ca = CallCursor.new(self, node, node.container.contained.first, node.container.held.checkTypes);
         ca.asnCall = node.container;
      } else {
         ca = CallCursor.new(self, node);
      }
      Bool selfCall = false;
      Bool superCall = false;
      Bool isNew = false;
      Int numargs = node.held.numargs;
      String nname = node.held.name;
      if (node.held.name != node.held.orgName + "_" + node.held.numargs) {
         throw(VisitError.new("Bad name for call " + node.held.name + " " + node.held.orgName + " " + node.held.numargs));
      }
      if (node.held.isConstruct) {
         isNew = true;
      } elif (node.contained.first.held.name == "self") {
         selfCall = true;
      } elif (node.contained.first.held.name == "super") {
         selfCall = true;
         superCall = true;
      }
      if (node.held.checkTypes) { String chkt = "1"; }
      else { chkt = "0"; }
      String beavArgs = String.new();
      String callArgsb = String.new();
      String bemxArg = "";
      Int argNum = 0;
      for (var it = node.contained.iterator;it.hasNext;;) {
         var i = it.next;
         if (argNum == 0) {
            var targetOrg = i.held.name;
            ca.targs = formTarg(i);
            var targetNode = i;
            String becdCast = "becd0";
            String mndCall = "BERF_MethodNotDefined0";
         } else {
            if (argNum - 1 < build.constants.maxargs) {
                beavArgs += ", " += getBeavArg(i);
                becdCast = "becd" + argNum;
                mndCall = "BERF_MethodNotDefined" + argNum;
            } else {
                callArgsb += prepBemxArg(i, argNum - 1);
                bemxArg = ", bemx";
                becdCast = "becdx" + build.constants.maxargs;
                mndCall = "BERF_MethodNotDefinedx" + build.constants.maxargs;
            }
         }
         argNum = argNum++;
      }
      thisMtd += "/*Begin Call, Name: " += node.held.name += " target " += targetOrg += "*/" += nl;
      if (build.putLineNumbersInTrace) {
         thisMtd += "berv_stackfs.twvmp = " += node.nlc.toString() += ";" += nl;
      }
      ca.callArgs = callArgsb.toString();
      Bool doCall = true;
      String ctargs;
      Bool typedCall = false;
      Build:ClassSyn orgsyn;
      if (targetNode.held.isTyped) {
		 ca.isTyped = true;
         if (isNew) {
            ca.asyn = build.getSynNp(node.held.newNp);
            ca.mtds = ca.asyn.mtdMap.get(node.held.name);
            ca.ainfo = emitter.getInfoSearch(ca.asyn.namepath);
            if (mtdDeclared.has("twcv_cdef")!) {
               mtdDeclared.put("twcv_cdef", true);
               mtdDeclares += "BERT_ClassDef* twcv_cdef;" += nl;
            }
            if (build.closeLibraries.has(ca.asyn.libName)) {
               ca.optimizedCall = true;
               ca.ainfo = emitter.getInfoSearch(ca.mtds.origin);
            } else {
               typedCall = true;
               ca.ainfo = emitter.getInfoSearch(ca.mtds.origin);
            }
            if (node.held.isLiteral) {
               String literalCdef = emitter.classDefTarget(ca.asyn, inClassSyn);
               ca.literalCdef = literalCdef;
               if (ca.asyn.namepath.toString() == "Text:String" && (ca.node.typeDetail <= 1 || ca.node.wideString)) {
                  ca.belsName = "bels_" + inClass.held.belsCount.toString();
                  mtdDeclares += "static const unsigned char " += ca.belsName += "[] = {";
                  String liorg = node.held.literalValue;
                  
                  if (ca.node.wideString) {
                    String lival = liorg;
                  } else {
                    lival = Json:Unmarshaller.new().unmarshall("[" + Text:Strings.quote + liorg + Text:Strings.quote + "]").first;
                  }
                  
                  ca.belsValue = lival;
                  Int lisz = lival.size;
                  Int lipos = 0;
                  Int bcode = Int.new();
                  String hs = String.new(2);
                  while (lipos < lisz) {
                    lival.getCode(lipos, bcode);
                    mtdDeclares += "0x"@;
                    mtdDeclares += bcode.toHexString(hs);
                    mtdDeclares += ","@;
                    lipos++=;
                  }
                  mtdDeclares += "0};\n";
                  inClass.held.belsCount = inClass.held.belsCount++;
               }
            } else {
               if (ca.optimizedCall) {
                  ca.prepCldef += "berv_sts->passedClassDef = " += emitter.classDefTarget(ca.asyn, inClassSyn) += ";" += nl;
               } else {
                  ca.prepCldef += "twcv_cdef = " += emitter.classDefTarget(ca.asyn, inClassSyn) += ";" += nl;
                  ca.prepCldef += "berv_sts->passedClassDef = twcv_cdef;" += nl;
               }
            }
         } elif (superCall) {
            ca.asyn = build.getSynNp(inClass.held.extends);
            ca.mtds = ca.asyn.mtdMap.get(node.held.name);
            orgsyn = build.getSynNp(ca.mtds.origin);
            if (build.closeLibraries.has(orgsyn.libName)) {
               ca.optimizedCall = true;
               ca.ainfo = emitter.getInfoSearch(ca.mtds.origin);
            } else {
               typedCall = true;
               ca.ainfo = emitter.getInfoSearch(inClass.held.extends);
               if (mtdDeclared.has("twcv_cdef")!) {
                  mtdDeclared.put("twcv_cdef", true);
                  mtdDeclares += "BERT_ClassDef* twcv_cdef;" += nl;
               }
               ca.prepCldef += "twcv_cdef = " += emitter.classDefTarget(ca.asyn, inClassSyn) += ";" += nl;
            }
         } else {
            ca.asyn = build.getSynNp(targetNode.held.namepath);
            ca.mtds = ca.asyn.mtdMap.get(node.held.name);
            orgsyn = build.getSynNp(ca.mtds.origin);
            if (ca.asyn.isFinal && build.closeLibraries.has(ca.asyn.libName)
             && build.closeLibraries.has(orgsyn.libName)) {
               ca.optimizedCall = true;
               ca.ainfo = emitter.getInfoSearch(ca.mtds.origin);
            } elif (ca.mtds.lastDef && ca.asyn.isLocal && build.closeLibraries.has(ca.asyn.libName) && build.closeLibraries.has(orgsyn.libName)) {
               ca.optimizedCall = true;
               ca.ainfo = emitter.getInfoSearch(ca.mtds.origin);
            } else {
               typedCall = true;
               //if not ca.isGetter omit the twcv_cdef setup
               if (ca.isGetter) {
				   if (mtdDeclared.has("twcv_cdef")!) {
					  mtdDeclared.put("twcv_cdef", true);
					  mtdDeclares += "BERT_ClassDef* twcv_cdef;" += nl;
				   }
				   ca.prepCldef += "twcv_cdef = (BERT_ClassDef*) " += ca.targs += "[berdef];" += nl;
				}
            }
         }
         if (undef(ca.mtds)) {
            throw(VisitError.new("No such call " + node.held.name + " in class " + ca.asyn.namepath.toString()));
         }
      } else {
         if (mtdDeclared.has("twcv_cdef")!) {
            mtdDeclared.put("twcv_cdef", true);
            mtdDeclares += "BERT_ClassDef* twcv_cdef;" += nl;
         }
         ca.prepCldef += "twcv_cdef = (BERT_ClassDef*) " += ca.targs += "[berdef];" += nl;
      }
      if (isNew) {
		if (ca.ainfo.clName == "Logic:Bool" || (def(ca.asnR) && node.held.isLiteral)) {
		   doCall = false;
		} else {
            //ctargs = "NULL";
            ctargs = "bevc_inst";
            if (mtdDeclared.has("bevc_inst")!) {
                mtdDeclared.put("bevc_inst", true);
                mtdDeclares += "void** bevc_inst;" += nl;
             }
             if (ca.asyn.hasDefault) {
                 ca.prepMdef += "bevc_inst = (void**) berv_sts->onceInstances[berv_sts->passedClassDef->classId];" += nl;
                 if (ca.asyn.isNotNull!) {
                     ca.prepMdef += "if (bevc_inst == NULL) {" += nl;
                     //ca.prepMdef += "bevc_inst = BERF_Create_Instance(berv_sts, berv_sts->passedClassDef, 0);" += nl;
                     //construct and call
                     ca.prepMdef += "bevc_inst = BEKF_6_11_SystemInitializer_initializeIt_1(0, berv_sts, NULL, BERF_Create_Instance(berv_sts, berv_sts->passedClassDef, 0));" += nl; 
                     ca.prepMdef += "}" += nl;
                 }
             } else {
                //("No initialize, skipping initial check " + ca.asyn.namepath).print();
                ca.prepMdef += "bevc_inst = BERF_Create_Instance(berv_sts, berv_sts->passedClassDef, 0);" += nl;
             }
             
        }
      }
      if (doCall) {
         if (undef(ctargs)) {
            ctargs = ca.targs;
         }
         var hn = nname.hash;
         inClassSyn.allNames.put(nname, nname);
         emitter.registerName(nname);
         var shn = hn.toString();
         String twname = "twnn_" + build.libName + "_" + nname;
         var snum = numargs.toString();
         if (ca.optimizedCall) {
            ca.tcall = ca.tcall + ca.ainfo.mtdName + nname + "( " + chkt + ", berv_sts, " + ctargs + beavArgs + bemxArg + " );" + nl;
         } else {
            if (typedCall!) {
			   if (mtdDeclared.has("twcv_mtddef")!) {
				  mtdDeclared.put("twcv_mtddef", true);
				  mtdDeclares += "BERT_MtdDef* twcv_mtddef;" += nl;
			   }
            }
            if (typedCall) {
			   String caMtdx = getMethodIndex(ca.asyn,inClassSyn,nname);
			   //twcv_mtddef unneeded when is a typed call and not an accessor get
			   if (ca.isGetter) {
				
				if (mtdDeclared.has("twcv_mtddef")!) {
			      mtdDeclared.put("twcv_mtddef", true);
                  mtdDeclares += "BERT_MtdDef* twcv_mtddef;" += nl; 
                }
				ca.prepMdef += "twcv_mtddef = twcv_cdef->mlist[" += getMlistIndex(ca.asyn,inClassSyn,nname) += "];" += nl;
				
				//good place for DIAGNOSTIC to verify accessor functionality
               }
               
               //good place for DIAGNOSTIC mtd vtable
               
               //TODO make sure there is a specific test in basetest for supercalls (map does depend on it tho)
               if (isNew || superCall) {
			      String cldefGetTarg = "twcv_cdef";
               } else {
				  cldefGetTarg = ca.targs + "[berdef]"
               }
               ca.tcall = ca.tcall + "((" + becdCast + ")((void**)" + cldefGetTarg + ")[" + caMtdx + "])( " + chkt + ", berv_sts, " + ctargs + beavArgs + bemxArg + " );" + nl;

            } else {
               
               //here is a good place for the sameness test
               if (mtdDeclared.has("twcv_mtdi")!) {
                  mtdDeclared.put("twcv_mtdi", true);
                  mtdDeclares += "BEINT twcv_mtdi;" += nl;
               }
               ca.prepMdef += "twcv_mtdi = " += twname += " % twcv_cdef->dmlistlen;" += nl;
               ca.prepMdef += "twcv_mtddef = twcv_cdef->dmlist[twcv_mtdi];" += nl;
               
               //good place for DIAGNOSTIC for mtd vtable
               
               ca.utPreCheck += "if (twcv_mtddef->twnn == " += twname += ") {" += nl; //}
               ca.tcall = ca.tcall + "((" + becdCast + ")twcv_mtddef->mcall)( " + chkt + ", berv_sts, " + ctargs + beavArgs + bemxArg + " );" + nl;
            }
            if (typedCall!) {
                  //{
               ca.utPostCheckBB += "} else {" += nl;
               //Will forward call if appropo
               ca.utPostCheckC += mndCall += "(" += chkt += ", berv_sts, " += ctargs += ", " += numargs.toString() += ", (char*) " += textQuote += node.held.orgName += textQuote += beavArgs += bemxArg += ");" += nl;
               ca.utPostCheckEB += "}" + nl;
            }
         }
      }
      if (def(ca.asnR)) {
		 ca.embedAssign = true;/*make the assign part of the call, also reverses the type check and assign*/
		 ca.embedTarg = formTarg(ca.asnR);
		 ca.embedAssignV = finalAssignTo(ca.asnR, false);
		 ca.embedAssignVV = finalAssignTo(ca.asnR, true);
         ca.callAssign = finalAssign(ca.asnR, "berv_sts->passBack", true); //passBack ok, is not used when not needed
         if (ca.checkAssignTypes) {
            ca.typeCheckSyn = build.getSynNp(ca.asnR.held.namepath);
            doTypeCheck(ca, ca.embedTarg, ca.asnR);/*is after the assign, must null if fails*/
         }
      }
      thisMtd += cassem.processCall(ca); /*need to change order of type check and assign for this case*/
      thisMtd += "/*End Call, Name: " += node.held.name += "*/" + nl;
   }

   accept(Node node) Node {
      //("Visiting node type " + node.toString()).print();
      //if ((node.typename == ntypes.VAR) && (def(node.held.namepath))) {
      //   ("Found namepath typed var again " + node.held.name + " " + node.held.namepath.toString()).print();
      //}
      if (node.typename == ntypes.CLASS) {
         acceptClass(node);
      }
      if (node.typename == ntypes.METHOD) {
         acceptMtd(node);
      }
      if (node.typename == ntypes.EMIT) {
         acceptEmit(node);
      } elif (node.typename == ntypes.IFEMIT) {
         return(acceptIfEmit(node));
      } elif ((node.typename == ntypes.CALL) && (node.held.orgName == "assign") && (node.contained.length != 2)) {
         var errmsg = "assignment call with incorrect number of arguments " + node.contained.length.toString();
         for (Int ei = 0;ei < node.contained.length;ei = ei++) {
            errmsg = errmsg + " !!!" + ei + "!! " + node.contained[ei];
         }
         throw(VisitError.new(errmsg, node));
      } elif ((node.typename == ntypes.CALL) && (node.held.orgName == "assign") && (node.contained.first.held.name == "self")) {
         throw(VisitError.new("self cannot be assigned to", node));
      } elif ((node.typename == ntypes.CALL) && (node.held.orgName == "throw")) {
         thisMtd += "BERF_Throw(berv_sts, " + formTarg(node.second) + ", "  += classInfo.shClassName += ", twrv_stackdef.sname, " += classInfo.shFileName += ", " += node.nlc.toString() += " );" += nl;
      } elif (node.typename == ntypes.CALL) {
         acceptCall(node);
      } elif (node.typename == ntypes.RBRACES) {
         if (def(node.container) && def(node.container.container)) {
            var nct = node.container.container;
            var ncct = nct.typename;
            if (ncct == ntypes.METHOD) {
               if (inMtd) {
                  if (lastCallReturn!) {
                     if (def(inMtdNode.held.rtype)) {
                        //("Node is " + inMtdNode.held.name).print();
                        //("Rtype is " + inMtdNode.held.rtype.toString()).print();
                        if ((inMtdNode.held.rtype.namepath.toString() == inClassNamed || inMtdNode.held.rtype.isSelf)!) {
                           throw(VisitError.new("Return not last in subroutine with return type which is not same type as class, incorrect return type or possible unreachable code", inMtdNode));
                        }
                     }
                     thisMtd += "BEVReturn(bevs);" += nl;
                  }
                  //bevs, self, belv local vars, method call args TWTYPES
                  Int mhmax = inMtdNode.held.hmax;
                  for (Int hi = 0;hi < mhmax;hi = hi++) {
                    mtdDeclares += "void** belv" += hi.toString() += " = NULL;" += nl;
                  }
                  Int bemxLen = inMtdNode.held.mmax - build.constants.maxargs;
                  if (bemxLen > 0) {
                    mtdDeclares += "void* bemx[" += bemxLen.toString() += "];" += nl;
                  }
                  
                  Int beavSpill = inMtdNode.held.numargs - build.constants.maxargs;
                  if (beavSpill > 0) {
                    Int ma = build.constants.maxargs;
                    for (Int bsi = 0;bsi < beavSpill;bsi = bsi++) {
                        mtdDeclares += "void** beav" += (ma + bsi).toString() += " = (void**) beax[" += bsi.toString() += "];" += nl;
                    }
                  }
                  
                  Int hmax = inMtdNode.held.hmax;
                  Int amax = inMtdNode.held.amax;
                  Int fmax = hmax + amax;
                  if (fmax > 0) {
					String pinit = String.new();
					for (Int i = 0;i < fmax;i = i++) {
					    if (i > 0) { pinit += ","; }
                        if (i < amax) {
                            pinit += "&(beav" += i.toString() += ")";
                        } else {
                            pinit += "&(belv" += (i - amax).toString() += ")";
                        }
					}
					mtdDeclares += "void* twvp[" += fmax.toString() += "] = {" += pinit += "};" += nl;
					String twvpval = "twvp";
                  } else {
					twvpval = "NULL";
				  }
                  stackfsPrep += "static BERT_StackDef twrv_stackdef = { (char*) " += textQuote += inClassNamed += textQuote += ", (char*) " += textQuote += inMtdNamed += textQuote += ", " += fmax.toString() += "};" += nl;
                  stackfsPrep += "BERT_Stackf berv_stackfs = { &twrv_stackdef, berv_sts->stackf, (void**) &bevs, " += twvpval += ", -1 };" += nl;
                  methods += mtdDeclares += nl += stackfsPrep += stackPrep += nl += postPrep += nl += thisMtd += nl += "/*End Mtd, Name: " += classInfo.mtdName += inMtdNode.held.name += " */" += nl += textRbnl += nl;
               }
               emitter.emitMtd(self, inClass);
               mtdDeclared = Map.new();
               mtdDeclares = String.new();
               stackPrep = String.new();
               stackfsPrep = String.new();
               postPrep = String.new();
               consTypes = Map.new();
               consTypesi = 0;
               thisMtd = String.new();
               lastCallReturn = false;
               inMtd = false;
            } elif (ncct == ntypes.CLASS) {
               lastCallReturn = false;
               //cleanups plus completions
               methods += nl += nl;
            } elif (ncct == ntypes.TRY) {
               lastCallReturn = false;
               thisMtd += textRbnl;
            } elif (ncct == ntypes.CATCH) {
               lastCallReturn = false;
               thisMtd += textRbnl;
               
               Int tryDepth = inMtdNode.held.tryDepth - 1;
               if (tryDepth > 0) {
                  thisMtd += "berv_stackfs.except = &twrv_except" += tryDepth.toString() += ";" += nl;
               } else {
                  thisMtd += "berv_stackfs.except = NULL;" += nl;
               }
               inMtdNode.held.tryDepth = tryDepth;
         
            } elif (ncct != ntypes.EXPR) {
               lastCallReturn = false;
               thisMtd += textRbnl;
            } else {
               lastCallReturn = false;
            }
         }
      } elif ((node.typename == ntypes.BRACES) && def(node.container) && (node.container.typename != ntypes.METHOD) && (node.container.typename != ntypes.CLASS) && (node.container.typename != ntypes.EXPR) && (node.container.typename != ntypes.TRY) && (node.container.typename != ntypes.CATCH) && (node.container.typename != ntypes.BLOCK)) {
         thisMtd += "{" += nl; //}
      }
      elif (node.typename == ntypes.BREAK) {
         thisMtd += "break;" += nl;
      } elif (node.typename == ntypes.LOOP) {
         thisMtd += "while (1)" += nl;
      } elif (node.typename == ntypes.ELSE) {
         thisMtd += " else ";
      } elif (node.typename == ntypes.TRY) {
         String tryId = "twrv_except" + inMtdNode.held.tryDepth.toString();
         inMtdNode.held.tryDepth = inMtdNode.held.tryDepth++;
         if (mtdDeclared.has(tryId)!) {
            mtdDeclares += "BERT_Except " += tryId += ";" += nl;
            mtdDeclared.put(tryId);
         }
         thisMtd += "if (setjmp(" += tryId += ".env) == 0) {" += nl; //}
         thisMtd += "berv_stackfs.except = &" += tryId += ";" += nl;
      } elif (node.typename == ntypes.CATCH) {
         thisMtd += nl += " else {" += nl; //}
         
         tryDepth = inMtdNode.held.tryDepth - 1;
         if (tryDepth > 0) {
            thisMtd += "berv_stackfs.except = &twrv_except" += tryDepth.toString() += ";" += nl;
         } else {
            thisMtd += "berv_stackfs.except = NULL;" += nl;
         }
         
         thisMtd += "berv_sts->stackf = &berv_stackfs;" += nl;
         
         thisMtd += finalAssign(node.contained.first.contained.first, "berv_sts->passBack", true);//passBack ok, needed for exception
      } elif (node.typename == ntypes.IF) {
         String targs = formTarg(node.contained.first.contained.first);
         //the below automatically deals with non-bool values and nulls (as NOT)
         //if (def(node.held)) { ("!!!!!If node held is " + node.held.toString()).print(); } else { "!!If node held is null".print(); }
         if (def(node.held) && node.held == "unless") {
            thisMtd += "if ((size_t) " += targs += " != (size_t) berv_sts->bool_True)" += nl;
         } else {
            thisMtd += "if ((size_t) " += targs += " == (size_t) berv_sts->bool_True)" += nl;
         }
      }
      return(node.nextDescend);
   }
}

final class CallCursor {
   
   new(Visit:CEmit _emvisit, Node _node) self {
   
      properties {
         Node asnR;
         Node asnCall;
         String targs;
         String rtargs;
         String callArgs;
         //asyn is the class the call is in when it is a typed call
         Build:ClassSyn asyn;
         Build:ClassSyn typeCheckSyn;
         Build:ClassInfo ainfo;
         Build:MtdSyn mtds;
         
         String prepCldef = String.new();
         String prepMdef = String.new();
         String utPreCheck = String.new();
         String tcall = String.new();
         String utPostCheckBB = String.new();
         String utPostCheckC = String.new();
         String utPostCheckEB = String.new();
         Visit:CEmit emvisit = _emvisit;
         Node node = _node;
         Bool checkAssignTypes = false;
         String preOnceEval = String.new();
         String callAssign = String.new();
         String assignTypeCheck = String.new();
         String postOnceEval = String.new();
         Bool optimizedCall = false;
         Bool isTyped = false;
         Bool embedAssign = false; /*make the assign part of the call, also reverses the type check and assign*/
         Bool retainTo = false;/*for cases which are not fully embedassign due to a need to preserve the pre-assign value
                                      but where we need to still do the type check post assign*/
         String embedAssignVV; /*the left hand of the assignment, for cases where the right hand is a void** type */
         String embedAssignV; /*the left hand of the assignment, for cases where the right hand is a void* type */
         String embedTarg = "berv_sts->passBack"; /*passBack ok the formTarg of the var which received final assignment, for later use (literal sets, typecheck, etc)*/
         String literalCdef; /*the class construct call (in C) for "literal" (e.g. Int x = 1; var y = "hi";) cases*/
         String belsName; /*for string literals the name of the method static variable for the char array*/
         String belsValue; /*the final string for the literal (unescaped if it should be)*/
      }
      
   }
   
    hasOnceAssignGet() Bool {
        if (def(asnCall)) {
            if (asnCall.held.isMany) {
                return(false);
            }
            if (asnCall.held.isOnce || asnCall.isLiteralOnce) {
                return(true);
            }
        }
        return(false);
    }
   
   //In cases where there are changes to the assigned to value which depend on it's previous value, 
   //(this is only true for some assemblies, incDec and modify, for example) and
   //in that case embed assign is set back to false, but the type check has already been set to the post assign, so their
   //order is reversed (assign from passBack to final (passBack ok) then type check (if any))
   checkRetainTo() {
		if (embedAssign && targs == embedTarg) { 
			//targs is the target of the call, embedTarg is the targ version of the assign to, if they're the same we're assigning back
			//to our target, and for calls that do this check, that can be an issue as they need the original value to hang around for use
			//in setting the final target value
			
			retainTo = true;
			embedAssign = false;
			embedTarg = "berv_sts->passBack"; //passBack ok
		}
   }
   
   assignToVGet() String {
	if (embedAssign) {
		return(embedAssignV);
	} elif (def(asnR)) {
		return("berv_sts->passBack = (void**) "); //passBack ok
	}
	return("");
   }
   
   assignToVVGet() String {
	if (embedAssign) {
		return(embedAssignVV);
	} elif(def(asnR)) {
		return("berv_sts->passBack = "); //passBack ok
	}
	return("");
   }
   
   assignToCheckGet() String {
	if (embedAssign) {
		return(assignTypeCheck);
	}
	return(typeCheckAssignGet());
   }
   
   isValidGet() Bool {
		if (embedAssign || callAssign == Text:Strings.empty) {
			return(true);
		}
		return(false);
	}
   
   typeCheckAssignGet() String {
       if (embedAssign || retainTo) { return(callAssign + assignTypeCheck); } //swap order when receiving return from a call (embedded assign)
       return(assignTypeCheck + callAssign);
   }
   
   new(Visit:CEmit _emvisit, Node _node, Node _asnR, Bool _checkAssignTypes) self {
      prepCldef = String.new();
      prepMdef = String.new();
      utPreCheck = String.new();
      tcall = String.new();
      utPostCheckBB = String.new();
      utPostCheckC = String.new();
      utPostCheckEB = String.new();
      emvisit = _emvisit;
      node = _node;
      asnR = _asnR;
      if (def(asnR)) {
         targs = emvisit.formTarg(asnR);
         rtargs = emvisit.formRTarg(asnR);
      }
      checkAssignTypes = _checkAssignTypes;
      preOnceEval = String.new();
      callAssign = String.new();
      assignTypeCheck = String.new();
      postOnceEval = String.new();
      optimizedCall = false;
   }
   
   isGetterGet() Bool {
	  if (optimizedCall! && node.held.wasAccessor && node.held.accessorType == "GET" && def(asnR)) {
         return(true);
      }
      return(false);
   }
}
