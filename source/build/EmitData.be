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

use Container:Map;
use Container:Set;
use Container:LinkedList;
use Build:ClassSyn;
use Text:String;

final class Build:EmitData {
   
   new() self {
   
      properties {
      
         Map ptsp = Map.new();
         Map allNames = Map.new();
         Map foreignClasses = Map.new();
         Map nameEntries = Map.new();
         Map classes = Map.new();
         LinkedList parseOrderClassNames = LinkedList.new();
         Map justParsed = Map.new();
         Map synClasses = Map.new();
         Map midNames = Map.new();
         //(String, Set) Key is the name of the class, value is the classes which use it
         Map usedBy = Map.new();
         //(String, Set) Key is the name of the class, value is the the classes which subclass it
         Map subClasses = Map.new();
         Set propertyIndexes = Set.new();
         Set methodIndexes = Set.new();
         Set shouldEmit = Set.new();
      }
   }
   
   addSynClass(String npstr, ClassSyn syn) {
      synClasses.put(npstr, syn);
      String myname = syn.namepath.toString();
      foreach (String s in syn.uses) {
         Set ub = usedBy[s];
         if (undef(ub)) {
            ub = Set.new();
            usedBy[s] = ub;
         }
         ub.put(myname);
      }
      for (var iu = syn.superList.iterator;iu.hasNext;;) {
         s = iu.next.toString();
         ub = subClasses[s];
         if (undef(ub)) {
            ub = Set.new();
            subClasses[s] = ub;
         }
         ub.put(myname);
      }
   }
   
   addParsedClass(node) {
      if (classes.has(node.held.name)!) {
        parseOrderClassNames += node.held.name;
      }
      classes.put(node.held.name, node);
      justParsed.put(node.held.name, node);
   }

}

final Build:PropertyIndex {
   new(Build:ClassSyn _syn, Build:PtySyn _psyn) self {
      properties {
         //for directProperties, if true or false for one should be true or false 
         //for all in lib
         Build:ClassSyn syn = _syn; 
         Build:PtySyn psyn = _psyn;
         Build:NamePath origin = psyn.origin;
         String name = psyn.name;
      }
   }
   
   hashGet() Math:Int {
      return((origin.toString() + name).hashGet());
   }
   
   equals(x) Logic:Bool {
      if (undef(x) || sameClass(x)!) { return(false); }
      if (origin == x.origin && name == x.name) {
         return(true);
      }
      return(false);
   }
}

final Build:MethodIndex {
   new(Build:ClassSyn _syn, Build:MtdSyn _msyn) self {
      properties {
         //for directMethods, if true or false for one should be true or false 
         //for all in lib
         Build:ClassSyn syn = _syn; 
         Build:MtdSyn msyn = _msyn;
         Build:NamePath declaration = msyn.declaration;
         String name = msyn.name;
      }
   }
   
   hashGet() Math:Int {
      return((declaration.toString() + name).hashGet());
   }
   
   equals(x) Logic:Bool {
      if (undef(x) || sameClass(x)!) { return(false); }
      if (declaration == x.declaration && name == x.name) {
         return(true);
      }
      return(false);
   }
}

