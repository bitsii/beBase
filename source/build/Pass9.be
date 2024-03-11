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

final class Build:Visit:Pass9(Build:Visit:Visitor) {

   accept(Build:Node node) Build:Node {
      //dump expr
      dyn it;
      dyn i;
      dyn inode;
      dyn lnode;
      dyn lbrnode;
      dyn loopif;
      dyn enode;
      dyn brnode;
      dyn bnode;
      dyn pnode;
      dyn init;
      dyn cond;
      dyn atStep;
      
      if (node.typename == ntypes.CALL) {
         //to remove no-longer-needed nested "parens"
         //"At for".print();
         //node.held.name.print();
         node.initContained();
         for (it = node.contained.iterator;it.hasNext;;) {
         //"After for".print();
            i = it.next;
            if (i.typename == ntypes.PARENS) {
               if (def(i.contained.firstNode)) {
                  i.beforeInsert(i.contained.first);
                  i.delete();
               } else {
                  dyn estr = "Error, parens length of contained too great " + i.contained.length.toString();
                  throw(VisitError.new(estr, node));
               }
            }
         }
         return(node.nextDescend);
      } elseIf (node.typename == ntypes.ACCESSOR) {
         //for accessors (accessor nodes):
         //if in assign call and in position 0, is set
         //else is get
         dyn ac = node.held;
         dyn c = Build:Call.new();
         c.wasAccessor = true;
         if ((node.container.typename == ntypes.CALL) && (node.container.held.name == "assign") && (node.isFirst)) {
            c.accessorType = "SET";
         } else {
            c.accessorType = "GET";
         }
         c.name = ac.name;
         c.toAccessorName();
         if (c.accessorType == "SET") {
            node.container.held = c;
            dyn ntarg = node.contained.first;
            
            node.typename = ntarg.typename;
            node.held = ntarg.held;
            node.contained = ntarg.contained;
            return(node.container.nextDescend);
         } else {
            node.typename = ntypes.CALL;
            node.held = c;
         }
         return(node.nextDescend);
      } elseIf (node.typename == ntypes.IDXACC) {
         //"!!!!!!!!!!!!!IN NTYPES.IDX PASS9".print();
         ac = node.held;
         c = Build:Call.new();
         if ((node.container.typename == ntypes.CALL) && (node.container.held.name == "assign") && (node.isFirst)) {
            //"IsPut".print();
            dyn isPut = true;
         } else {
            //"IsGet".print();
            isPut = false;
         }
         if (isPut) {
            c.name = "put";
            node.container.held = c;
            ntarg = node.contained.first;
            
            //node.contained.first.nextPeer.print();
            Node narg2 = ntarg.nextPeer;
            Node narg3 = node.nextPeer;
            
            narg2.delete();
            narg3.delete();
            
            node.typename = ntarg.typename;
            node.held = ntarg.held;
            node.contained = ntarg.contained;
            //node.print();
            node.container.addValue(narg2);
            node.container.addValue(narg3);
            return(node.container.nextDescend);
         } else {
            //node.priorPeer.typename.print();
            //node.container.typename.print();
            //node.first.typename.print();
            //node.contained.last.typename.print();
            c.name = "get";
            node.typename = ntypes.CALL;
            node.held = c;
         }
         return(node.nextDescend);
      }
      if (node.typename == ntypes.FOR) {
         //"for found".print();
         Node linn = node.contained.first.contained.first;
         if (linn.typename == ntypes.CALL && linn.held.wasOper) {
          //("found linn").print();
          node.typename = ntypes.FOREACH;
         }
      }
      if (node.typename == ntypes.FOREACH) {
         node.typename = ntypes.WHILE;
         pnode = node.contained.first;
         brnode = node.second;
         dyn lin = pnode.contained.first;
         dyn lany = lin.contained.first;
         dyn toit = lin.second;
         pnode.contained = null;
         /*
         if (undef(lany)) {
            "lany is null".print();
         } else {
            ("lany is " + lany.typename + " " + lany.held.name).print();
         }
         if (undef(lin)) {
            "lin is null".print();
         } else {
            ("lin is " + lin.typename).print();
         }
         if (undef(toit)) {
            "toit is null".print();
         } else {
            ("toit is " + toit.typename).print();
         }
         */
         
         dyn tmpn = Node.new(build);
         tmpn.copyLoc(node);
         tmpn.typename = ntypes.VAR;
         dyn tmpv = node.tmpVar("loop", build);
         tmpn.held = tmpv;
         
         dyn gin = Node.new(build);
         gin.typename = ntypes.CALL;
         dyn gic = Build:Call.new();
         gin.held = gic;
         gic.name = "iteratorGet";
         gic.wasForeachGenned = true;
         gin.addValue(toit);
         
         dyn asn = Node.new(build);
         asn.copyLoc(node);
         asn.typename = ntypes.CALL;
         dyn asc = Build:Call.new();
         asn.held = asc;
         asc.name = "assign";
         asn.addValue(tmpn);
         asn.addValue(gin);
         
         node.beforeInsert(asn);
         tmpn.addVariable();
         
         dyn tmpnt = Node.new(build);
         asn.copyLoc(node);
         tmpnt.typename = ntypes.VAR;
         tmpnt.held = tmpv;
         
         dyn tcn = Node.new(build);
         tcn.copyLoc(node);
         tcn.typename = ntypes.CALL;
         dyn tcc = Build:Call.new();
         tcn.held = tcc;
         tcc.name = "hasNextGet";
         tcn.addValue(tmpnt);
         
         pnode.addValue(tcn);
         
         dyn tmpng = Node.new(build);
         tmpng.copyLoc(node);
         tmpng.typename = ntypes.VAR;
         tmpng.held = tmpv;
         
         dyn iagn = Node.new(build);
         iagn.copyLoc(node);
         iagn.typename = ntypes.CALL;
         dyn iagc = Build:Call.new();
         iagn.held = iagc;
         iagc.name = "nextGet";
         iagn.addValue(tmpng);
         
         dyn iasn = Node.new(build);
         iasn.copyLoc(node);
         iasn.typename = ntypes.CALL;
         dyn iasc = Build:Call.new();
         iasn.held = iasc;
         iasc.name = "assign";
         iasn.addValue(lany);
         iasn.addValue(iagn);
         
         brnode.prepend(iasn);
         return(toit);
      }
      if (node.typename == ntypes.WHILE) {
         lnode = Node.new(build);
         lnode.copyLoc(node);
         lnode.typename = ntypes.LOOP;
         node.replaceWith(lnode);
         lbrnode = Node.new(build);
         lbrnode.copyLoc(node);
         lbrnode.typename = ntypes.BRACES;
         lnode.addValue(lbrnode);
         loopif = node;
         loopif.typename = ntypes.IF;
         lbrnode.addValue(loopif);
         if (def(node.held) && node.held == "until") {
            loopif.held = "unless";
         }
         enode = Node.new(build);
         enode.copyLoc(node);
         enode.typename = ntypes.ELSE;
         loopif.addValue(enode);
         brnode = Node.new(build);
         brnode.copyLoc(node);
         brnode.typename = ntypes.BRACES;
         enode.addValue(brnode);
         bnode = Node.new(build);
         bnode.copyLoc(node);
         bnode.typename = ntypes.BREAK;
         brnode.addValue(bnode);
         return(lnode.nextDescend);
      } elseIf (node.typename == ntypes.FOR) {
         lnode = Node.new(build);
         lnode.copyLoc(node);
         lnode.typename = ntypes.LOOP;
         node.replaceWith(lnode);
         pnode = node.contained.first;
         pnode.delete();
         if (pnode.contained.length < 2) {
            throw(VisitError.new("Insufficient number of for loop arguments, two required", node));
         }
         init = pnode.contained.first;
         cond = pnode.second;
         atStep = null;
         if (pnode.contained.length > 2) {
            atStep = pnode.third;
            atStep.delete();
         }
         init.delete();
         //cond.delete(); //this will drop the conditional in the if
         node.replaceWith(lnode);
         lnode.beforeInsert(init);
         
         lbrnode = Node.new(build);
         lbrnode.copyLoc(node);
         lbrnode.typename = ntypes.BRACES;
         lnode.addValue(lbrnode);
         loopif = Node.new(build);
         loopif.copyLoc(node);
         loopif.typename = ntypes.IF;
         loopif.takeContents(node);
         if (def(atStep)) {
            loopif.contained.first.addValue(atStep);
         }
         loopif.prepend(pnode);
         lbrnode.addValue(loopif);
         enode = Node.new(build);
         enode.copyLoc(node);
         enode.typename = ntypes.ELSE;
         loopif.addValue(enode);
         brnode = Node.new(build);
         brnode.copyLoc(node);
         brnode.typename = ntypes.BRACES;
         enode.addValue(brnode);
         bnode = Node.new(build);
         bnode.copyLoc(node);
         bnode.typename = ntypes.BREAK;
         brnode.addValue(bnode);
         //return(lnode.nextDescend);
         return(init);
      }
      return(node.nextDescend);
   }
}
