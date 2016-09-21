// Copyright 2006 Craig Welch
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

use Container:LinkedList;
use Container:Map;
use Build:Visit;
use Build:NamePath;
use Build:VisitError;
use Build:Node;
 
final class Build:Visit:Pass6(Build:Visit:Visitor) {

   accept(Build:Node node) Build:Node {
      //also nests ifs
      //("Visiting " + node.toString()).print();
      node.resolveNp();
      any i;
      any v;
      any nnode = node.nextPeer;
      if (node.typename == ntypes.EMIT) {
         any gnext = node.nextAscend;
         if (def(node.contained) && (node.contained.length > 1) && def(node.contained.first.contained) && (node.contained.first.contained.length > 0) && (node.second.contained.length > 0)) {
            //("inline first held is " + node.contained.first.first.held).print();
            Container:Set langs = Container:Set.new();
            for (Node lang in node.contained.first.contained) {
                //("inline lang is " + lang.held).print();
                langs += lang.held;
            }
            langs.delete(",");
            any doit = true;
            if (doit) {
               doit = false;
               for (i = node.second.contained.iterator;i.hasNext;;) {
                  any si = i.next;
                  if (si.typename == ntypes.STRINGL) {
                     node.held = si.held;
                     //"found inline".print();
                     //si.held.print();
                     doit = true;
                  }
               }
            }
            if (doit!) {
               node.delete();
               return(gnext);
            }
            node.contained = null;
            node.held = Build:Emit.new(node.held, langs);
         } else {
            node.delete();
            return(gnext);
         }
         
         any snode = node.scope;
         if (snode.typename == ntypes.METHOD) {
            snode = null;
         }
         
         if (def(snode)) {
            node.delete();
            snode.held.addEmit(node);
         }
        
         return(gnext);
      } elseIf (node.typename == ntypes.IFEMIT) {
         langs = Container:Set.new();
         toremove = LinkedList.new()
         for (lang in node.contained.first.contained) {
            //("ifEmit lang is " + lang.held).print();
            langs += lang.held;
            toremove.addValue(lang);
         }
         langs.delete(",");
         node.held = Build:IfEmit.new(langs, node.held);
         for (ii = toremove.iterator;ii.hasNext;;) {
            i = ii.next;
            i.delete();
         }
      } elseIf (node.typename == ntypes.IF) {
         if (def(nnode)) {
            any lnode = node;
            while (def(nnode) && (nnode.typename == ntypes.ELIF)) {
               any enode = Node.new(build);
               enode.typename = ntypes.ELSE;
               enode.copyLoc(node);
               any brnode = Node.new(build);
               brnode.copyLoc(node);
               brnode.typename = ntypes.BRACES;
               any inode = Node.new(build);
               inode.copyLoc(node);
               inode.typename = ntypes.IF;
               brnode.addValue(inode);
               enode.addValue(brnode);
               if (def(nnode.contained)) {
                  for (i = nnode.contained.iterator;i.hasNext;;) {
                     inode.addValue(i.next);
                  }
               }
               //any rbrnode = Node.new(build);
               //rbrnode.typename = ntypes.RBRACES;
               //brnode.addValue(rbrnode);
               //rbrnode.copyLoc(node);
               lnode.addValue(enode);
               lnode = inode;
               any nxnode = nnode.nextPeer;
               nnode.delete();
               nnode = nxnode;
            }
            if (def(nnode) && (nnode.typename == ntypes.ELSE)) {
               nnode.delete();
               lnode.addValue(nnode);
            }
         }  
         return(node.nextDescend);
      } elseIf (node.typename == ntypes.METHOD) {
         any parens = node.contained.first;
         any nd = Node.new(build);
         nd.copyLoc(node);
         nd.typename = ntypes.ID;
         nd.held = "self";
         parens.prepend(nd);
         any toremove = LinkedList.new();
         any numargs = 0;
         for (any ii = parens.contained.iterator;ii.hasNext;;) {
            i = ii.next;
            any ix = i.nextPeer;
            any vid;
            any vinp;
            if (i.typename == ntypes.COMMA) {
               toremove.addValue(i);
            } elseIf (i.typename == ntypes.ID) {
               numargs = numargs + 1;
               v = Build:Var.new();
               v.name = i.held;
               v.isArg = true;
               i.held = v;
               i.typename = ntypes.VAR;
               i.addVariable();
            } elseIf (i.typename == ntypes.VAR) {
               if (ix.typename == ntypes.ID) {
                  numargs = numargs + 1;
                  i.held.name = ix.held;
                  i.held.isArg = true;
                  i.addVariable();
                  ix.typename = ntypes.COMMA; //make sure not redeclared
               } else {
                  throw(Build:VisitError.new("Incorrect argument declaration", i)); 
               }
            }
         }
         for (ii = toremove.iterator;ii.hasNext;;) {
            i = ii.next;
            i.delete();
         }
         any s = node.held;
         s.numargs = numargs - 1;
         s.orgName = s.name;
         s.name = s.name + "_" + s.numargs.toString();
         i = node.second;
         if (i.typename == ntypes.VAR) {
            i.resolveNp();
            //("!!!!!!Found return type " + i.held.name).print();
            s.rtype = i.held;
            if (undef(s.rtype.namepath)) {
              //"FOUND UNDEF RTYPE".print(); (will be "any")
            } elseIf (s.rtype.namepath.toString() == "this") {
              //"FOUND THIS RTYPE".print();
              s.rtype.isTyped = true;
              s.rtype.isSelf = true;
              s.rtype.isThis = true;
              s.rtype.namepath.path = "self";
            } elseIf (s.rtype.namepath.toString() == "self") {
              s.rtype.isTyped = true;
              s.rtype.isSelf = true;
            }
            i.delete();
         } else {
           s.rtype = Build:Var.new();
           s.rtype.isTyped = true;
           s.rtype.isSelf = true;
           s.rtype.isThis = true;
           s.rtype.implied = true;
           s.rtype.namepath = Build:NamePath.new("self");
         }
         any clnode = node.classGet();
         clnode.held.methods.put(s.name, node); //TODO check to see if already exists
         clnode.held.orderedMethods.addValue(node);
      }
      return(node.nextDescend);
   }
   
}


