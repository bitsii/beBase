/*
Copyright 2006 Craig Welch
All rights reserved.

Developed by:

    Craig Welch

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal with
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

    * Redistributions of source code must retain the above copyright notice,
      this list of conditions and the following disclaimers.

    * Redistributions in binary form must reproduce the above copyright notice,
      this list of conditions and the following disclaimers in the
      documentation and/or other materials provided with the distribution.

    * Neither the name of the Software nor the names of its contributors may be used 
      to endorse or promote products derived from this Software without specific
      prior written permission.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
CONTRIBUTORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS WITH THE
SOFTWARE.
*/

use Container:LinkedList;
use Container:Array;
use Container:Map;
use Container:Set;
use Text:String;
use Math:Int;
use Container:Array;
use Build:Node;
use Logic:Bool;
use Build:ClassSyn;

final class Build:NamePath(System:BasePath) {
   
   new(String spath) self {
      properties {
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
      if (def(par)) {
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
      properties {
         Map aliased = Map.new();
      }
   }
   
   addEmit(node) Build:TransUnit {
      if (undef(emits)) {
         properties {
            Container:LinkedList emits = Container:LinkedList.new();
         }
      }
      emits.addValue(node);
   }
   
}

final class Build:Emit {
    
    new(String _text, Set _langs) self {
        properties {
            String text = _text;
            Set langs = _langs;
        }
    }

}

final class Build:IfEmit {
    
    new(Set _langs) self {
        properties {
            Set langs = _langs;
        }
    }

}

final class Build:Class {
   
   new() self {
   
      properties {
         Build:NamePath extends;
         LinkedList emits; //transEmits are in containing transUnit
         String name;
         Build:NamePath namepath;
         Build:ClassSyn syn;
         var fromFile;
         var libName;
         Map methods = Map.new();
         LinkedList orderedMethods = LinkedList.new();
         LinkedList used = LinkedList.new();
         Map varMap = Map.new();
         LinkedList orderedVars = LinkedList.new();
         Bool isFinal = false;
         Bool isLocal = false;
         Bool isNotNull = false;
         Bool freeFirstSlot = false;
         Bool firstSlotNative = false;
         Int nativeSlots = 0;
         Bool isArray = false;
         Int onceEvalCount = 0;
         Set referencedProperties = Set.new();
         Bool shouldWrite = false;
         Int belsCount = 0;//count for string literal array variable names (bels_#)
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
   
      properties {
         String name;
         String orgName;
         Int numargs;
         var property;
         var rtype;
         var tmpVars;
         Map varMap = Map.new();
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
      properties {
         String name;
         Build:NamePath namepath;
         var refs;
         Map allCalls;
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
         allCalls = Map.new();
      }
      allCalls.put(call, call);
   }
   
   maxCposGet() Int {
      if (maxCpos > -1) { return(maxCpos); }
      foreach (var kv in allCalls) {
         if (kv.key.held.cpos > maxCpos) {
            maxCpos = kv.key.held.cpos;
         }
      }
      return(maxCpos);
   }
   
   minCposGet() Int {
      Int bigun = Math:Ints.new().max;
      //("Bigun is " + bigun).print();
      if (minCpos < bigun) { return(minCpos); }
      foreach (var kv in allCalls) {
         if (kv.key.held.cpos < minCpos) {
            minCpos = kv.key.held.cpos;
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
   
      properties {
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
         
         Array argCasts = Array.new();
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
      properties { String name; }
   }
   
   toString() String {
      String ret = self.className;
      if (def(name)) {
         ret = ret + " name: " + name.toString();
      }
      return(ret);
   }
}

