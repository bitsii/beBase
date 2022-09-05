// Copyright 2006 The Brace Authors. All rights reserved.
// Use of this source code is governed by the BSD-3-Clause
// license that can be found in the LICENSE file.

use Container:NodeList;
use Build:Node;
use Container:LinkedList:AwareNode;

final class Node {
   
   new(Build:Build _build) self {
   
      fields {
         NodeList contained;
         Node container;
         any held;
         AwareNode heldBy;
         any condany;
         Build:NamePath inClassNp;
         String inFile;
         any typeDetail;
         
         Bool delayDelete = false;
         Int nlc = 0;
         Int nlec = 0;
         Bool wideString = false;
         
         Build:Build build = _build;
         Build:Constants constants = build.constants;
         Build:NodeTypes ntypes = constants.ntypes;
         Int typename = ntypes.TOKEN;
         Bool inlined = false;
      }
   }
   
   copyLoc(Node fromNode) {
      nlc = fromNode.nlc.copy();
      nlec = fromNode.nlec.copy();
      inClassNp = fromNode.inClassNp;
      inFile = fromNode.inFile;
   }
   
   nextDescendGet() Node {
      if (def(contained) && def(contained.first)) {
         return(contained.first);
      }
      Node ret = self.nextPeer;
      Node con = self.container;
      while ((undef(ret)) && (def(con)))  {
         ret = con.nextPeer;
         con = con.container;
      }
      return(ret);
   }
   
   nextAscendGet() Node {
      Node ret = self.nextPeer;
      Node con = self.container;
      while ((undef(ret)) && (def(con)))  {
         ret = con.nextPeer;
         con = con.container;
      }
      return(ret);
   }
   
   nextPeerGet() Node {
      if (undef(heldBy)) {
         return(null);
      }
      any hh = heldBy.next;
      if (undef(hh)) {
         return(hh);
      }
      return(hh.held);
   }
   
   priorPeerGet() Node {
      if (undef(heldBy)) {
         return(null);
      }
      any hh = heldBy.prior;
      if (undef(hh)) {
         return(hh);
      }
      return(hh.held);
   }
   
   firstGet() Node {
      return(contained.first);
   }
   
   secondGet() Node {
      return(contained.second);
   }
   
   thirdGet() Node {
      return(contained.third);
   }
   
   isFirstGet() Bool {
      if (undef(heldBy)) {
         return(false);
      }
      return(undef(heldBy.prior));
   }
   
   isSecondGet() Bool {
      if (undef(heldBy) || undef(heldBy.prior)) {
         return(false);
      }
      return(undef(heldBy.prior.prior));
   }
   
   isThirdGet() Bool {
      if (undef(heldBy) || undef(heldBy.prior) || undef(heldBy.prior.prior)) {
         return(false);
      }
      return(undef(heldBy.prior.prior.prior));
   }
   
   delayDelete() {
      delayDelete = true;
   }
   
   delete() {
      if (undef(heldBy)) {
         return(null);
      }
      heldBy.delete();
      self.container = null;
      heldBy = null;
   }
   
   beforeInsert(Node x) {
      if (undef(heldBy)) {
         return(null);
      }
      heldBy.insertBefore(heldBy.mylist.newNode(x));
      x.container = self.container;
   }
   
   prepend(Node node) {
      if (undef(contained)) {
         initContained();
      }
      contained.prepend(node);
      node.container = self;
   }
   
   addValue(Node node) {
      if (undef(contained)) {
         initContained();
      }
      contained.addValue(node);
      node.container = self;
   }
   
   reInitContained() {
      contained = Container:NodeList.new();
   }
   
   initContained() {
      if (undef(contained)) {
         contained = Container:NodeList.new();
      }
   }
   
   toString() Text:String {
     any e;
     try {
       String res = toStringCompact();
     } catch (e) {
       e.print();
       throw(e);
     }
     return(res);
   }
   
   toStringBig() Text:String {
      any prefix = self.prefix;
      any ret = prefix + "<" + typename.toString() + ">";
      ret = ret + Text:Strings.new().newline + prefix + "line: " + nlc.toString();
      if (def(inClassNp) && def(inFile)) {
         ret = ret + Text:Strings.new().newline + prefix + " In Class: " + inClassNp.toString() + " In IO:File: " + inFile + Text:Strings.new().newline;
      }
      if (def(held)) {
         ret = ret + Text:Strings.new().newline + prefix + " ";
         ret = ret + held.toString();
      }
      return(ret);
   }
   
   toStringCompact() Text:String {
      any prefix = self.prefix;
      String ret = prefix + "<" + typename.toString() + ">";
      if (def(nlc)) {
        ret = ret + " line: " + nlc.toString();
      }
      if (def(inClassNp)) {
         ret = ret + " Class: " + inClassNp.toString();
      }
      if (def(held)) {
         ret = ret + " " + held.toString();
      }
      return(ret);
   }
   
   depthGet() Int {
      Int d = 0;
      Node c = self.container;
      while (def(c)) {
         d++=;
         c = c.container;
      }
      return(d);
   }
   
   prefixGet() String {
      Int d = self.depth;
      String p = String.new();
      String q = "  ";
      for (Int i = 0;i < d;i++=) {
         p = p + q;
      }
      return(p);
   }
   
   transUnitGet() {
      any targ = self;
      while (def(targ) && (targ.typename != ntypes.TRANSUNIT)) {
         targ = targ.container;
      }
      return(targ);
   }
   
   tmpVar(suffix, build) {
       any clnode = self.scope;
       if (clnode.typename != ntypes.METHOD) {
          throw(Build:VisitError.new("tmpVar scope not a sub", self));
       }
       any tmpanyn = clnode.held.tmpCnt.toString();
       clnode.held.tmpCnt++=;
       any tmpany = Build:Var.new();
       tmpany.isTmpVar = true;
       tmpany.autoType = true;
       tmpany.suffix = suffix;
       tmpany.name = tmpanyn + "_ta_" + suffix;
       return(tmpany)
   }
   
   inPropertiesGet() Bool {
      Node con = self.container;
      while (def(con)) {
         if (con.typename == ntypes.SLOTS || con.typename == ntypes.FIELDS) {
            return(true);
         }
         con = con.container;
      }
      return(false);
   }

   inSlotsGet() Bool {
      Node con = self.container;
      while (def(con)) {
         if (con.typename == ntypes.SLOTS) {
            return(true);
         }
         con = con.container;
      }
      return(false);
   }
   
   addVariable() {
      any v = held;
      if (v.isAdded!) {
         v.isAdded = true;
         sco = scopeGet();
         if (sco.typename == ntypes.CLASS) {
            throw(Build:VisitError.new("Found a variable incorrectly declared outside a method", self));
         }
         if (self.inProperties && v.isTmpVar!) {
            any sco = classGet();
            v.isProperty = true;
            if (self.inSlots) {
             v.isSlot = true;
            }
         }
         any sc = sco.held;
         if (sc.anyMap.has(v.name)) {
            throw(Build:VisitError.new("Duplicate variable declaration", self));
         }
         sc.anyMap.put(v.name, self);
         sc.orderedVars.addValue(self);
      }
   }
   
   syncAddVariable() {
      any v = held;
      if (v.isAdded!) {
         v.isAdded = true;
         any sco = self.scope;
         any sc = sco.held;
         if (sc.anyMap.has(v.name)) {
            held = sc.anyMap.get(v.name);
         } else {
            any cl = classGet().held;
            if (cl.anyMap.has(v.name)) {
               held = cl.anyMap.get(v.name);
            } else {
               sc.anyMap.put(v.name, self);
               sc.orderedVars.addValue(self);
               if (sco.typename == ntypes.CLASS) {
                  throw(Build:VisitError.new("Found a property in syncAddVariable", self));
                  //v.isProperty = true;
               }
            }
         }
      }
   }
   
   syncVariable(Build:Visit:Visitor visit) {
      any vname = held;
      any sc = self.scope.held;
      if (sc.anyMap.has(vname)) {
         held = sc.anyMap.get(vname).held;
      } else {
         any cl = classGet().held;
         if (cl.anyMap.has(vname)) {
            held = cl.anyMap.get(vname).held;
         } else {
            any tunode = self.transUnit;
            any np = tunode.held.aliased.get(vname);
            if (undef(np)) {
              np = build.emitData.aliased.get(vname);
            }
            if (def(np)) {
               throw(Build:VisitError.new("Found NP too late " + np, self));
            } else {
               //throw(Build:VisitError.new("No such variable exists during syncVariable", self));
               any v = Build:Var.new();
               v.name = vname;
               if (vname == "super") {
                  held = v;
                  v.isTyped = true;
                  v.namepath = cl.extends;
                  sc.anyMap.put(vname, self);
                  sc.orderedVars.addValue(self);
               } else {
                  v.isDeclared = false;
                  v.isProperty = true;
                  held = v;
                  cl.anyMap.put(vname, self);
                  cl.orderedVars.addValue(self);
               }
            }
         }
      }
   }
   
   anchorGet() {
       any node = self;
       if (true) {
       loop {
          if (constants.anchorTypes.has(node.typename)) {
             return(node);
          } else {
             node = node.container;
             if (undef(node)) {
                throw(Build:VisitError.new("No anchor for node", self));
             }
          }
       }
       }
    }
   
   classGet() {
      any targ = self;
      while (def(targ) && (targ.typename != ntypes.CLASS)) {
         targ = targ.container;
      }
      return(targ);
   }
   
   scopeGet() {
      any targ = self;
      while (def(targ) && (targ.typename != ntypes.CLASS) && (targ.typename != ntypes.METHOD) && (targ.typename != ntypes.TRANSUNIT)) {
         targ = targ.container;
      }
      return(targ);
   }
   
   replaceWith(Node other) {
      if (undef(heldBy)) {
         return(null);
      }
      other.container = self.container;
      heldBy.held = other;
   }
   
   deleteAndAppend(Node other) {
      other.delete();
      addValue(other);
   }
   
   takeContents(Node other) {
      contained = other.contained;
      for (any it = contained.iterator;it.hasNext;;) {
         any i = it.next;
         i.container = self;
      }
   }
   
   resolveNp() {
      Build:NamePath np;
      if (typename == ntypes.NAMEPATH) {
         np = held;
         if (def(np)) {
            np.resolve(self);
         }
      }
      if (typename == ntypes.CLASS) {
         np = held.namepath;
         if (def(np)) {
            np.resolve(self);
         }
         np = held.extends;
         if (def(np)) {
            np.resolve(self);
         }
         held.name = held.namepath.toString();
      }
      if (typename == ntypes.VAR) {
         np = held.namepath;
         if (def(np)) {
            np.resolve(self);
            //("After resolve for any, is " + held.namepath.toString()).print();
         }
      }
   }
   
}

