// Copyright 2006 Craig Welch
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

use Container:NodeList;
use Build:Node;

final class Node {
   
   new(Build:Build _build) self {
   
      fields {
         NodeList contained;
         Node container;
         any held;
         any heldBy;
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
      Node con = container;
      while ((undef(ret)) && (def(con)))  {
         ret = con.nextPeer;
         con = con.container;
      }
      return(ret);
   }
   
   nextAscendGet() Node {
      Node ret = self.nextPeer;
      Node con = container;
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
      container = null;
      heldBy = null;
   }
   
   beforeInsert(Node x) {
      if (undef(heldBy)) {
         return(null);
      }
      heldBy.insertBefore(heldBy.mylist.newNode(x));
      x.container = container;
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
   
   depthGet() {
      any d = 0;
      any c = container;
      while (def(c)) {
         d = d++;
         c = c.container;
      }
      return(d);
   }
   
   prefixGet() {
      any d = self.depth;
      any p = String.new();
      any q = "  ";
      for (any i = 0;i < d;i = i++;) {
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
       clnode.held.tmpCnt = clnode.held.tmpCnt++;
       any tmpany = Build:Var.new();
       tmpany.isTmpVar = true;
       tmpany.suffix = suffix;
       tmpany.name = tmpanyn + "_tmpany_" + suffix;
       return(tmpany)
   }
   
   inPropertiesGet() Bool {
      Node con = container;
      while (def(con)) {
         if (con.typename == ntypes.PROPERTIES) {
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
            throw(Build:VisitError.new("Found a anyiable incorrectly declared outside a method", self));
         }
         if (self.inProperties && v.isTmpVar!) {
            any sco = classGet();
            v.isProperty = true;
         }
         any sc = sco.held;
         if (sc.anyMap.has(v.name)) {
            throw(Build:VisitError.new("Duplicate anyiable declaration", self));
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
               //throw(Build:VisitError.new("No such anyiable exists during syncVariable", self));
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
      other.container = container;
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
   
   callIsSafe(Node call) Bool {
   
        //We never want Bools once deced, and they always come from a static t/f anyway, so we force them to not be
        //onced
        if (call.held.isConstruct && call.held.newNp.toString() == "Logic:Bool") {
          return(false);
        }
   
        Set alwaysOkCalls =@ Set.new();
        Set okClasses =@ Set.new();
        Set okCalls =@ Set.new();
        Set okClasses2 =@ Set.new();
        Set okCalls2 =@ Set.new();
        if (okClasses.size == 0) {
            
            //always ok - these are object level defined
            //alwaysOkCalls.put("return_1");//um, no
            //alwaysOkCalls.put("assign_1");//of course not, but for testing during build
            //alwaysOkCalls.put("undef_1");
            //alwaysOkCalls.put("def_1");
            alwaysOkCalls.put("once_0");
            
            //if an ok call in an ok class (the target) (both pass) then is ok
            okClasses.put("Text:String");
            okClasses.put("Math:Int");
            
            okCalls.put("add_1");
            okCalls.put("subtract_1");
            okCalls.put("print_0");
            okCalls.put("echo_0");
            okCalls.put("toString_0");
            okCalls.put("multiply_1");
            okCalls.put("divide_1");
            okCalls.put("power_1");
            okCalls.put("compare_1");
            okCalls.put("greater_1");
            okCalls.put("lesser_1");
            okCalls.put("equals_1");
            okCalls.put("notEquals_1");
            okCalls.put("greaterEquals_1");
            okCalls.put("lesserEquals_1");
            okCalls.put("find_2");
            okCalls.put("find_1");
            okCalls.put("has_1");
            okCalls.put("isInteger_0");
            okCalls.put("getPoint_1");
            okCalls.put("ends_1");
            okCalls.put("begins_1");
            okCalls.put("modulus_1");
            okCalls.put("substring_2");//if it becomse mutable later, then not so much, think should call it (mutable ver) crop instead
            okCalls.put("sizeGet_0");
            //chomp, strip - make them mutations?
            
            //same for diff set of classes, calls
            okClasses2.put("Container:Set");
            okClasses2.put("Container:Map");
            okClasses2.put("Container:List");
            okClasses2.put("Container:List");
            
            //later make more specific to first arg for put TODO FASTER
            //okCalls2.put("put_2");//map, array, vector
            //okCalls2.put("put_1");//set
            okCalls2.put("get_1");//map, array, vector, set
            okCalls2.put("has_1");//map, array, vector, set
            
        } 
        
        if (alwaysOkCalls.has(call.held.name)) {
            //("callIsSafe true alwaysok " + call.held.name).print();
            return(true);
        }
        
        //otherwise, untyped calls are never safe
        if (call.contained.first.held.isTyped!) {
            //("callIsSafe false nottyped").print();
            return(false);
        }
        
        //if (call.contained.first.held.namepath.toString() == "Text:String" && call.held.name == "append_1") {
            //("callIsSafe true bbappend").print();
          //  return(true);
        //}
        
        if (okClasses.has(call.contained.first.held.namepath.toString())) {
            if (okCalls.has(call.held.name)) {
                //("callIsSafe true oknpcall " + call.contained.first.held.namepath.toString() + " " + call.held.name).print();
                return(true);
            } else {
                //("callIsSafe false notokcall " + call.contained.first.held.namepath.toString() + " " + call.held.name).print();
            }
        }
        if (okClasses2.has(call.contained.first.held.namepath.toString())) {
            if (okCalls2.has(call.held.name)) {
                //("callIsSafe true oknpcall2 " + call.contained.first.held.namepath.toString() + " " + call.held.name).print();
                return(true);
            } else {
                //("callIsSafe false notokcall2 " + call.contained.first.held.namepath.toString() + " " + call.held.name).print();
            }
        }
        //("callIsSafe false notokclass " + call.contained.first.held.namepath.toString() + " " + call.held.name).print();
        return(false);
   
   }
   
   //Decides if this call should be a derived literal once
   //a literal can be a literal once if it is assured to never be mutated
   //at the moment this is a simple 80% check for local use (as opposed to a generalized
   //escape analysis)
   //called after Pass12
   isLiteralOnceGet() Bool {
        
        Bool result = false;
        
        //only works after Pass12
        //? can this be a literal isOnce
        //if it is, it is
        if (typename != ntypes.CALL) { return(false); }
        if (held.orgName == "assign") {
            Node c0 = contained.first;
            Node c1 = contained.second;
            if (def(c1) && c1.typename == ntypes.CALL) {
               if (c1.held.isLiteral && c0.held.isProperty!) {
                  result = true;
                  for (Node call in c0.held.allCalls) {
                    if (call != self) {
                        if (callIsSafe(call)!) {
                            return(false);
                        }
                        //("isLiteralOnceGet found call " + call.held.name).print();
                    }
                    //else {
                        //("isLiteralOnceGet found my call").print();
                    //}
                  }
               }
            }
         }
         return(result);
   }

}

