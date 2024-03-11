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

final class Build:Visit:Pass11(Build:Visit:Visitor) {

   new() self {
      fields {
         Build:Node inMtd;
      }
   }
   
   accept(Build:Node node) Build:Node {
      //("Visiting " + node.toString()).print();
      if (node.typename == ntypes.EXPR) {
         Node fnode = null;
         if (undef(node.contained.first.contained.firstNode)) {
            fnode = node.nextDescend;
         }
         for (dyn it = node.contained.first.contained.iterator;it.hasNext;;) {
            Node inode = it.next;
            if (undef(fnode)) {
               fnode = inode;
            }
            node.beforeInsert(inode);
         }
         node.delete();
         return(fnode);
      }
      if (node.typename == ntypes.METHOD) {
         inMtd = node;
         Build:Var ts = node.held.anyMap.get("self").held;
         ts.isTyped = true;
         ts.namepath = node.classGet().held.namepath;
      }
      //if ((node.typename == ntypes.VAR) && (def(node.held.namepath))) {
      //   ("Found namepath typed any again " + node.held.name + " " + node.held.namepath.toString()).print();
      //}
      if (node.typename == ntypes.CALL) {
         //"AT 1".print();
         if (((node.held.name == "return") || (node.held.name == "throw")) && (node.contained.length > 2)) {
             throw(Build:VisitError.new("This type must have exactly one variable, not " + node.contained.length.toString(), node));
         }
         if (node.held.name == "return") {
            if (def(inMtd.held.rtype) && (inMtd.held.rtype.implied)) {
              /*if (inMtd.held.name == "iteratorGet_0") {
              ("return stuff").print();
              for (dyn nc in node.contained) {
                ("return contents " + nc).print();
              }
              }*/
              Node nsc = node.first;
              if (def(nsc) && nsc.typename == ntypes.VAR && nsc.held.name == "self") {
                //("found a not remove implied").print();
              } else {
                //("removing rtype").print();
                inMtd.held.rtype = null;
              }
            }
         }
         if (node.held.bound!) {
            dyn nd = Node.new(build);
            nd.copyLoc(node);
            dyn v = inMtd.held.anyMap.get("self");
            nd.typename = ntypes.VAR;
            nd.held = v.held;
            node.held.bound = true;
            node.prepend(nd);
         }
         //"AT 2".print();
         if (node.held.name == "assign") {
            return(node.nextDescend);  //no unwind for assignments
         }
         dyn unwind = true;
         dyn c0 = node.container;
         if (undef(c0)) {
            throw(Build:VisitError.new("Call not in correct position", node));
         }
         //node.print();
         //"AT 3".print();
         if ((c0.typename == ntypes.CALL) && (c0.held.name == "assign") && (node.isSecond)) {
            unwind = false;
         } elseIf (c0.typename == ntypes.BRACES) {
            unwind = false;
         }
         if (unwind) {
            dyn cnode = c0;
            dyn lastStep = null;
            //"cnode unwind".print();
            //cnode.typename.print();
            while (cnode.typename != ntypes.BRACES) {
               //"in cnode unw".print();
               lastStep = cnode;
               cnode = cnode.container;
            }
            //"done cnode unwind".print();
            //print "!!!Unwound call " + node.name + " step " + cnode.typename + " " + cnode.name + " in sub: " + subnode.name + " class: " + clnode.namepath.derName() + " to braces in " + lastStep.container.name + " " + lastStep.container.typename + " " + lastStep.container.container.name + " " + lastStep.container.container.typename
            
            dyn pholdv = lastStep.tmpVar("ph", build);
            dyn phold = Node.new(build);
            phold.copyLoc(node);
            phold.typename = ntypes.VAR;
            phold.held = pholdv;
            node.replaceWith(phold);
            phold.addVariable();
            dyn prc = Node.new(build);
            prc.copyLoc(node);
            prc.typename = ntypes.CALL;
            dyn prcc = Build:Call.new();
            prcc.name = "assign";
            prc.held = prcc;
            dyn phold2 = Node.new(build);
            phold2.copyLoc(node);
            phold2.typename = ntypes.VAR;
            phold2.held = pholdv;
            prc.addValue(phold2);
            prc.addValue(node);
            lastStep.beforeInsert(prc);
            return(node.nextDescend);
         }
      }
      return(node.nextDescend);
   }
   
}

