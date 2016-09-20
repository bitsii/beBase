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
      var i;
      var v;
      var nnode = node.nextPeer;
      if (node.typename == ntypes.EMIT) {
         var gnext = node.nextAscend;
         if (def(node.contained) && (node.contained.length > 1) && def(node.contained.first.contained) && (node.contained.first.contained.length > 0) && (node.second.contained.length > 0)) {
            //("inline first held is " + node.contained.first.first.held).print();
            Container:Set langs = Container:Set.new();
            for (Node lang in node.contained.first.contained) {
                //("inline lang is " + lang.held).print();
                langs += lang.held;
            }
            langs.delete(",");
            var doit = true;
            if (doit) {
               doit = false;
               for (i = node.second.contained.iterator;i.hasNext;;) {
                  var si = i.next;
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
         
         var snode = node.scope;
         if (snode.typename == ntypes.METHOD) {
            snode = null;
         }
         
         if (def(snode)) {
            node.delete();
            snode.held.addEmit(node);
         }
        
         return(gnext);
      } elif (node.typename == ntypes.IFEMIT) {
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
      } elif (node.typename == ntypes.IF) {
         if (def(nnode)) {
            var lnode = node;
            while (def(nnode) && (nnode.typename == ntypes.ELIF)) {
               var enode = Node.new(build);
               enode.typename = ntypes.ELSE;
               enode.copyLoc(node);
               var brnode = Node.new(build);
               brnode.copyLoc(node);
               brnode.typename = ntypes.BRACES;
               var inode = Node.new(build);
               inode.copyLoc(node);
               inode.typename = ntypes.IF;
               brnode.addValue(inode);
               enode.addValue(brnode);
               if (def(nnode.contained)) {
                  for (i = nnode.contained.iterator;i.hasNext;;) {
                     inode.addValue(i.next);
                  }
               }
               //var rbrnode = Node.new(build);
               //rbrnode.typename = ntypes.RBRACES;
               //brnode.addValue(rbrnode);
               //rbrnode.copyLoc(node);
               lnode.addValue(enode);
               lnode = inode;
               var nxnode = nnode.nextPeer;
               nnode.delete();
               nnode = nxnode;
            }
            if (def(nnode) && (nnode.typename == ntypes.ELSE)) {
               nnode.delete();
               lnode.addValue(nnode);
            }
         }  
         return(node.nextDescend);
      } elif (node.typename == ntypes.METHOD) {
         var parens = node.contained.first;
         var nd = Node.new(build);
         nd.copyLoc(node);
         nd.typename = ntypes.ID;
         nd.held = "self";
         parens.prepend(nd);
         var toremove = LinkedList.new();
         var numargs = 0;
         for (var ii = parens.contained.iterator;ii.hasNext;;) {
            i = ii.next;
            var ix = i.nextPeer;
            var vid;
            var vinp;
            if (i.typename == ntypes.COMMA) {
               toremove.addValue(i);
            } elif (i.typename == ntypes.ID) {
               numargs = numargs + 1;
               v = Build:Var.new();
               v.name = i.held;
               v.isArg = true;
               i.held = v;
               i.typename = ntypes.VAR;
               i.addVariable();
            } elif (i.typename == ntypes.VAR) {
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
         var s = node.held;
         s.numargs = numargs - 1;
         s.orgName = s.name;
         s.name = s.name + "_" + s.numargs.toString();
         i = node.second;
         if (i.typename == ntypes.VAR) {
            i.resolveNp();
            //("!!!!!!Found return type " + i.toString()).print();
            s.rtype = i.held;
            if (s.rtype.namepath.toString() == "self") {
               s.rtype.isSelf = true;
            }
            i.delete();
         }
         var clnode = node.classGet();
         clnode.held.methods.put(s.name, node); //TODO check to see if already exists
         clnode.held.orderedMethods.addValue(node);
      }
      return(node.nextDescend);
   }
   
}


