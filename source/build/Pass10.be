/*
 * Copyright (c) 2006-2023, the Beysant Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

use Container:LinkedList;
use Container:Map;
use Build:Visit;
use Build:NamePath;
use Build:VisitError;
use Logic:Bool;
use Build:Node;

final class Build:Visit:Pass10(Build:Visit:Visitor) {

   condCall(condany, value) {
      any cnode = Node.new(build);
      cnode.held = Build:Call.new();
      cnode.typename = ntypes.CALL;
      any acc = Node.new(build);
      acc.typename = ntypes.VAR;
      acc.held = condany;
      cnode.addValue(acc);
      cnode.held.name = "assign";
      any nnode = Node.new(build);
      nnode.typename = value;
      cnode.addValue(nnode);
      return(cnode);
   }
   
   accept(Build:Node node) Build:Node {
      if ((node.typename == ntypes.PARENS) && (node.contained.length == 1) && (node.contained.first.typename == ntypes.PARENS)) {
         node.takeContents(node.contained.first);
         return(node);
      }
      
      if (node.typename == ntypes.ID) {
         node.typename = ntypes.VAR;
         node.syncVariable(self);
      }
      
      if ((node.typename == ntypes.CALL) && ((node.held.name == "logicalOr") || (node.held.name == "logicalAnd"))) {
         
         any anchor = node.anchor;
         any condany = anchor.condany;
         //("Anchor is " + anchor.toString()).print();
         if (undef(condany)) {
            condany = anchor.tmpVar("anchor", build);
            condany.isTyped = true;
            any cvnp = Build:NamePath.new();
            cvnp.fromString("Logic:Bool");
            condany.namepath = cvnp;
            anchor.condany = condany;
         }
         
         any inode = Node.new(build);
         inode.typename = ntypes.IF;
         inode.copyLoc(node);
         
         any rinode = inode;
         
         any pnode = Node.new(build);
         pnode.copyLoc(node);
         pnode.typename = ntypes.PARENS;
         inode.addValue(pnode);
         
         pnode.addValue(node.contained.first);
         
         any bnode = Node.new(build);
         bnode.copyLoc(node);
         bnode.typename = ntypes.BRACES;
         inode.addValue(bnode);
         
         if (node.held.name == "logicalOr") {
            bnode.addValue(condCall(condany, ntypes.TRUE));
            //"Appended condCall".print();
         } else {
            //and
            inode = Node.new(build);
            inode.copyLoc(node);
            inode.typename = ntypes.IF;
            inode.condany = condany;
            bnode.addValue(inode);
            
            pnode = Node.new(build);
            pnode.copyLoc(node);
            pnode.typename = ntypes.PARENS;
            inode.addValue(pnode);
            pnode.addValue(node.second);
            bnode = Node.new(build);
            bnode.copyLoc(node);
            bnode.typename = ntypes.BRACES;
            inode.addValue(bnode);
            bnode.addValue(condCall(condany, ntypes.TRUE));
         
            any enode = Node.new(build);
            enode.copyLoc(node);
            enode.typename = ntypes.ELSE;
            bnode = Node.new(build);
            bnode.copyLoc(node);
            bnode.typename = ntypes.BRACES;
            bnode.addValue(condCall(condany, ntypes.FALSE));
            enode.addValue(bnode);
            inode.addValue(enode);
         }
         
         enode = Node.new(build);
         enode.copyLoc(node);
         enode.typename = ntypes.ELSE;
         bnode = Node.new(build);
         bnode.copyLoc(node);
         bnode.typename = ntypes.BRACES;
         rinode.addValue(enode);
         enode.addValue(bnode);
         
         if (node.held.name == "logicalOr") {
            inode = Node.new(build);
            inode.copyLoc(node);
            inode.typename = ntypes.IF;
            inode.condany = condany;
            bnode.addValue(inode);
            
            pnode = Node.new(build);
            pnode.copyLoc(node);
            pnode.typename = ntypes.PARENS;
            inode.addValue(pnode);
            pnode.addValue(node.second);
            bnode = Node.new(build);
            bnode.copyLoc(node);
            bnode.typename = ntypes.BRACES;
            inode.addValue(bnode);
            bnode.addValue(condCall(condany, ntypes.TRUE));
         
            enode = Node.new(build);
            enode.copyLoc(node);
            enode.typename = ntypes.ELSE;
            inode.addValue(enode);
            bnode = Node.new(build);
            bnode.copyLoc(node);
            bnode.typename = ntypes.BRACES;
            bnode.addValue(condCall(condany, ntypes.FALSE));
            enode.addValue(bnode);
         } else {
            bnode.addValue(condCall(condany, ntypes.FALSE));
         }
         
         //("Anchor is " + anchor.toString()).print();
         anchor.beforeInsert(rinode);
         node.contained = null;
         node.typename = ntypes.VAR;
         node.held = condany;
         node.syncAddVariable();
         return(rinode.nextDescend);
      }
      
      return(node.nextDescend);
   }
}

