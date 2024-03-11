/*
 * Copyright (c) 2006-2023, the Brace Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

import Container:Map;
import Container:Set;
import Container:LinkedList;
import Build:ClassSyn;
import Text:String;

final class Build:EmitData {
   
   new() self {
   
      fields {
      
         Map ptsp = Map.new();
         Map allNames = Map.new();
         Map foreignClasses = Map.new();
         Map nameEntries = Map.new();
         Map classes = Map.new();
         LinkedList parseOrderClassNames = LinkedList.new();
         Map justParsed = Map.new();
         Map synClasses = Map.new();
         Map midNames = Map.new();
         //(String, Set) Key is the name of the class, value is the classes which import it
         Map usedBy = Map.new();
         //(String, Set) Key is the name of the class, value is the the classes which subclass it
         Map subClasses = Map.new();
         Set propertyIndexes = Set.new();
         Set methodIndexes = Set.new();
         Set shouldEmit = Set.new();
         Map aliased = Map.new();
      }
   }
   
   addSynClass(String npstr, ClassSyn syn) {
      synClasses.put(npstr, syn);
      String myname = syn.namepath.toString();
      for (String s in syn.uses) {
         Set ub = usedBy[s];
         if (undef(ub)) {
            ub = Set.new();
            usedBy[s] = ub;
         }
         ub.put(myname);
      }
      for (dyn iu = syn.superList.iterator;iu.hasNext;;) {
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
      fields {
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
      if (undef(x) || System:Classes.sameClass(self, x)!) { return(false); }
      if (origin == x.origin && name == x.name) {
         return(true);
      }
      return(false);
   }
}

final Build:MethodIndex {
   new(Build:ClassSyn _syn, Build:MtdSyn _msyn) self {
      fields {
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
      if (undef(x) || System:Classes.sameClass(self, x)!) { return(false); }
      if (declaration == x.declaration && name == x.name) {
         return(true);
      }
      return(false);
   }
}

