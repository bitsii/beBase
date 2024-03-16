/*
 * Copyright (c) 2006-2023, the Brace Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

import Container:LinkedList;
import Container:Map;
import Build:Visit;
import Build:NamePath;
import Build:VisitError;
import Build:Node;
 
final class Build:Visit:Pass6(Build:Visit:Visitor) {

   accept(Build:Node node) Build:Node {
      //also nests ifs
      //("Visiting " + node.toString()).print();
      node.resolveNp();
      dyn i;
      dyn v;
      dyn nnode = node.nextPeer;
      if (node.typename == ntypes.EMIT) {
         dyn gnext = node.nextAscend;
         if (def(node.contained) && (node.contained.length > 1) && def(node.contained.first.contained) && (node.contained.first.contained.length > 0) && (node.second.contained.length > 0)) {
            //("inline first held is " + node.contained.first.first.held).print();
            Container:Set langs = Container:Set.new();
            for (Node lang in node.contained.first.contained) {
                //("inline lang is " + lang.held).print();
                langs += lang.held;
            }
            langs.remove(",");
            dyn doit = true;
            if (doit) {
               doit = false;
               for (i = node.second.contained.iterator;i.hasNext;;) {
                  dyn si = i.next;
                  if (si.typename == ntypes.STRINGL) {
                     node.held = si.held;
                     //"found inline".print();
                     //si.held.print();
                     doit = true;
                  }
               }
            }
            if (doit!) {
               node.remove();
               return(gnext);
            }
            node.contained = null;
            node.held = Build:Emit.new(node.held, langs);
         } else {
            node.remove();
            return(gnext);
         }
         
         dyn snode = node.scope;
         if (snode.typename == ntypes.METHOD) {
            snode = null;
         }
         
         if (def(snode)) {
            node.remove();
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
         langs.remove(",");
         node.held = Build:IfEmit.new(langs, node.held);
         for (ii = toremove.iterator;ii.hasNext;;) {
            i = ii.next;
            i.remove();
         }
         Bool include = true;
         if (node.held.value == "ifNotEmit") {
         Bool negate = true;
         } else {
         negate = false;
         }
         if (negate) {
         if (node.held.langs.contains(build.emitLangs.first)) {
            include = false;
         }
         if (def(build.emitFlags)) {
            for (String flag in build.emitFlags) {
               if (node.held.langs.contains(flag)) {
               include = false;
               }
            }
         }
         } else {
         Bool foundFlag = false;
         if (def(build.emitFlags)) {
            for (flag in build.emitFlags) {
               if (node.held.langs.contains(flag)) {
               foundFlag = true;
               }
            }
         }
         if (foundFlag! && node.held.langs.contains(build.emitLangs.first)!) {
            include = false;
         }
         }
        unless(include) {
          node.contained = null;
        }
      } elseIf (node.typename == ntypes.IF) {
         if (def(nnode)) {
            dyn lnode = node;
            while (def(nnode) && (nnode.typename == ntypes.ELIF)) {
               dyn enode = Node.new(build);
               enode.typename = ntypes.ELSE;
               enode.copyLoc(node);
               dyn brnode = Node.new(build);
               brnode.copyLoc(node);
               brnode.typename = ntypes.BRACES;
               dyn inode = Node.new(build);
               inode.copyLoc(node);
               inode.typename = ntypes.IF;
               brnode.addValue(inode);
               enode.addValue(brnode);
               if (def(nnode.contained)) {
                  for (i = nnode.contained.iterator;i.hasNext;;) {
                     inode.addValue(i.next);
                  }
               }
               //dyn rbrnode = Node.new(build);
               //rbrnode.typename = ntypes.RBRACES;
               //brnode.addValue(rbrnode);
               //rbrnode.copyLoc(node);
               lnode.addValue(enode);
               lnode = inode;
               dyn nxnode = nnode.nextPeer;
               nnode.remove();
               nnode = nxnode;
            }
            if (def(nnode) && (nnode.typename == ntypes.ELSE)) {
               nnode.remove();
               lnode.addValue(nnode);
            }
         }  
         return(node.nextDescend);
      } elseIf (node.typename == ntypes.METHOD) {
         dyn parens = node.contained.first;
         dyn nd = Node.new(build);
         nd.copyLoc(node);
         nd.typename = ntypes.ID;
         nd.held = "self";
         parens.prepend(nd);
         dyn toremove = LinkedList.new();
         dyn numargs = 0;
         for (dyn ii = parens.contained.iterator;ii.hasNext;;) {
            i = ii.next;
            dyn ix = i.nextPeer;
            dyn vid;
            dyn vinp;
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
            i.remove();
         }
         dyn s = node.held;
         s.numargs = numargs - 1;
         s.orgName = s.name;
         s.name = s.name + "_" + s.numargs.toString();
         i = node.second;
         if (i.typename == ntypes.VAR) {
            i.resolveNp();
            //("!!!!!!Found return type " + i.held.name).print();
            s.rtype = i.held;
            if (undef(s.rtype.namepath)) {
              //"FOUND UNDEF RTYPE".print();// (will be "dyn")
              s.rtype = null;
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
            i.remove();
         } else {
           s.rtype = Build:Var.new();
           s.rtype.isTyped = true;
           s.rtype.isSelf = true;
           s.rtype.isThis = true;
           s.rtype.implied = true;
           s.rtype.namepath = Build:NamePath.new("self");
         }
         dyn clnode = node.classGet();
         clnode.held.methods.put(s.name, node); //TODO check to see if already exists
         clnode.held.orderedMethods.addValue(node);
      }
      return(node.nextDescend);
   }
   
}


