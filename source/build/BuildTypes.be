// Copyright 2006 Craig Welch
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

use Build:Node;
use Build:ClassSyn;

final class Build:NamePath(System:BasePath) {
   
   new(String spath) self {
      fields {
         String label;
      }
      separator = Text:Strings.new().colon;
      fromString(spath);
   }
   
   labelGet() {
      if (undef(label)) {
         return(path.split(separator).last);
      }
      //("For " + path + " Label is " + label).print();
      return(label);
   }
   
   resolve(node) Build:NamePath {
      String oldpath = self.path;
      if (oldpath == "self") { return(self); }
      String fstep = self.firstStep;
      Node tunode = node.transUnit;
      System:BasePath par = tunode.held.aliased.get(fstep);
      if (undef(par)) {
        par = node.build.emitData.aliased.get(fstep);
      }
      if (def(par) && self.path.has(":")!) {
         System:BasePath np2 = self.deleteFirstStep();
         System:BasePath np = par + np2;
         path = np.path;
      }
      Node clnode = node.classGet();
      if (def(clnode)) {
         clnode.held.addUsed(self);
      }
      //("Resolved " + oldpath + " to " + path).print();
   }
   
}

final class Build:TransUnit {
   
   new() self {
      fields {
         Map aliased = Map.new();
      }
   }
   
   addEmit(node) Build:TransUnit {
      if (undef(emits)) {
         fields {
            Container:LinkedList emits = Container:LinkedList.new();
         }
      }
      emits.addValue(node);
   }
   
}

final class Build:Emit {
    
    new(String _text, Set _langs) self {
        fields {
            String text = _text;
            Set langs = _langs;
        }
    }

}

final class Build:IfEmit {
    
    new(Set _langs, String _value) self {
        fields {
            Set langs = _langs;
            String value = _value; //original value, ifEmit, ifNotEmit
        }
    }

}

final class Build:Class {
   
   new() self {
   
      fields {
         Build:NamePath extends;
         LinkedList emits; //transEmits are in containing transUnit
         String name;
         Build:NamePath namepath;
         Build:ClassSyn syn;
         any fromFile;
         any libName;
         Map methods = Map.new();
         LinkedList orderedMethods = LinkedList.new();
         LinkedList used = LinkedList.new();
         Map anyMap = Map.new();
         LinkedList orderedVars = LinkedList.new();
         Bool isFinal = false;
         Bool isLocal = false;
         Bool isNotNull = false;
         Bool freeFirstSlot = false;
         Bool firstSlotNative = false;
         Int nativeSlots = 0;
         Bool isList = false;
         Int onceEvalCount = 0;
         Set referencedProperties = Set.new();
         Bool shouldWrite = false;
         Int belsCount = 0;//count for string literal array anyiable names (bels_#)
      }
      
      Build:NamePath np;
      
      np = Build:NamePath.new();
      np.fromString("Logic:Bool");
      addUsed(np);
      
      np = Build:NamePath.new();
      np.fromString("Logic:Bools");
      addUsed(np);
   }
   
   addUsed(touse) {
      used.addValue(touse);
   }
   
   addEmit(node) {
      if (undef(emits)) {
         emits = Container:LinkedList.new();
      }
      emits.addValue(node);
   }
   
   toString() String {
      String ret = self.className;
      if (def(namepath)) {
         ret = ret + " namepath: " + namepath.toString();
         if (def(extends)) {
            ret = ret + " extends: " + extends.toString();
         }
      }
      return(ret);
   }
}

final class Build:Method {
   
   new() self {
   
      fields {
         String name;
         String orgName;
         Int numargs;
         any property;
         any rtype;
         any tmpVars;
         Map anyMap = Map.new();
         LinkedList orderedVars = LinkedList.new();
         Int tmpCnt = 0;
         Bool isGenAccessor = false;
         Int tryDepth = 0;
         Bool isFinal = false;
               
         Int amax = 0; //max value for arg vpos
         Int hmax = 0; //max value for h (here, local) vpos
         Int mmax = 0; //max number of arguments for call made within subroutine
      }
      
   }
   
   toString() String {
      String ret = self.className + " ";
      if (def(name)) {
         ret = ret + " name: " + name.toString();
      }
      if (def(numargs)) {
         ret = ret + " numargs: " + numargs.toString();
      }
      return(ret);
   }
}

final class Build:Var {
   
   new() self {
      fields {
         String name;
         Build:NamePath namepath;
         any refs;
         Set allCalls;
         String suffix;
         
         Bool isArg = false;
         Bool isAdded = false;
         Bool isTmpVar = false;
         Bool isDeclared = true;
         Bool isProperty = false;
         Int numAssigns = 0;
         Bool isTyped = false;
         Int vpos = -1;
         Bool isSelf = false;
         Int maxCpos = -1;
         Int minCpos = Math:Ints.new().max;
         String nativeName;
      }
   }
   
   synNew(Build:Var full) self {
      //Creates a summary with basic type info, for Syns and such
      isArg = full.isArg;
      name = full.name;
      isAdded = full.isAdded;
      isTmpVar = full.isTmpVar;
      isProperty = full.isProperty;
      numAssigns = 0;
      namepath = full.namepath;
      isTyped = full.isTyped;
      vpos = full.vpos;
      isSelf = full.isSelf;
   }
   
   addCall(Node call) {
      if (undef(allCalls)) {
         allCalls = Set.new();
      }
      allCalls.addValue(call);
   }
   
   maxCposGet() Int {
      if (maxCpos > -1) { return(maxCpos); }
      for (any n in allCalls) {
         if (n.held.cpos > maxCpos) {
            maxCpos = n.held.cpos;
         }
      }
      return(maxCpos);
   }
   
   minCposGet() Int {
      Int bigun = Math:Ints.new().max;
      //("Bigun is " + bigun).print();
      if (minCpos < bigun) { return(minCpos); }
      for (any n in allCalls) {
         if (n.held.cpos < minCpos) {
            minCpos = n.held.cpos;
         }
      }
      return(minCpos);
   }
   
   toString() String {
      String ret = self.className;
      if (def(name)) {
         ret = ret + " name: " + name.toString();
      }
      if (isArg) {
         ret = ret + " isArg"
      }
      if (isTmpVar) {
         ret = ret + " isTmpVar";
      }
      if (isDeclared!) {
         ret = ret + " notDeclared";
      }
      if (isProperty) {
         ret = ret + " isProperty";
      }
      return(ret);
   }
   
}

final class Build:Call {
   
   new() self {
   
      fields {
         String name;
         String orgName;
         String accessorType;
         Int numargs;
         String literalValue;
         Build:NamePath newNp;
         Int cpos;
         
         Bool isConstruct = false;
         Bool bound = true;
         Bool wasBound = true;
         Bool wasAccessor = false;
         Bool wasOper = false;
         Bool isLiteral = false;
         Bool isOnce = false; //explicit isonce (=@)
         Bool isMany = false; //explicit ismany (=#)
         Bool checkTypes = true;
         Bool superCall = false; //set late, in emitcommon
         Bool wasImpliedConstruct = false;
         Bool wasForeachGenned = false;
         
         List argCasts = List.new();
         //args which need to be cast for the call, if any, have entries here with namepath (otherwise, null).  starts at 1 as args do elsewhere (target is always 0)
      }
      
   }
   
   toString() String {
      String ret = self.className;
      if (def(name)) {
         ret = ret + " name: " + name.toString();
      }
      if (def(orgName)) {
         ret = ret + " orgName: " + orgName.toString();
      }
      if (def(numargs)) {
         ret = ret + " numargs: " + numargs.toString();
      }
      if (bound!) {
         ret = ret + " notBound";
      }
      if (wasAccessor) {
         ret = ret + " wasAccessor";
      }
      return(ret);
   }
   
   toAccessorName() {
      if (accessorType == "GET") {
         name = name + "Get";
      } else {
         name = name + "Set";
      }
   }
   
   
}

final class Build:Accessor {
   
   new() self {
      fields { String name; }
   }
   
   toString() String {
      String ret = self.className;
      if (def(name)) {
         ret = ret + " name: " + name.toString();
      }
      return(ret);
   }
}

