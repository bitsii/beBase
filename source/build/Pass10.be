// Copyright 2006 Craig Welch
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

use Container:LinkedList;
use Container:Map;
use Text:String;
use Math:Int;
use Build:Visit;
use Build:NamePath;
use Build:VisitError;
use Logic:Bool;
use Build:Node;

final class Visit:Pass10(Visit:Visitor) {

   condCall(condvar, value) {
      var cnode = Node.new(build);
      cnode.held = Build:Call.new();
      cnode.typename = ntypes.CALL;
      var acc = Node.new(build);
      acc.typename = ntypes.VAR;
      acc.held = condvar;
      cnode.addValue(acc);
      cnode.held.name = "assign";
      var nnode = Node.new(build);
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
         
         var anchor = node.anchor;
         var condvar = anchor.condvar;
         //("Anchor is " + anchor.toString()).print();
         if (undef(condvar)) {
            condvar = anchor.tmpVar("anchor", build);
            condvar.isTyped = true;
            var cvnp = Build:NamePath.new();
            cvnp.fromString("Logic:Bool");
            condvar.namepath = cvnp;
            anchor.condvar = condvar;
         }
         
         var inode = Node.new(build);
         inode.typename = ntypes.IF;
         inode.copyLoc(node);
         
         var rinode = inode;
         
         var pnode = Node.new(build);
         pnode.copyLoc(node);
         pnode.typename = ntypes.PARENS;
         inode.addValue(pnode);
         
         pnode.addValue(node.contained.first);
         
         var bnode = Node.new(build);
         bnode.copyLoc(node);
         bnode.typename = ntypes.BRACES;
         inode.addValue(bnode);
         
         if (node.held.name == "logicalOr") {
            bnode.addValue(condCall(condvar, ntypes.TRUE));
            //"Appended condCall".print();
         } else {
            //and
            inode = Node.new(build);
            inode.copyLoc(node);
            inode.typename = ntypes.IF;
            inode.condvar = condvar;
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
            bnode.addValue(condCall(condvar, ntypes.TRUE));
         
            var enode = Node.new(build);
            enode.copyLoc(node);
            enode.typename = ntypes.ELSE;
            bnode = Node.new(build);
            bnode.copyLoc(node);
            bnode.typename = ntypes.BRACES;
            bnode.addValue(condCall(condvar, ntypes.FALSE));
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
            inode.condvar = condvar;
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
            bnode.addValue(condCall(condvar, ntypes.TRUE));
         
            enode = Node.new(build);
            enode.copyLoc(node);
            enode.typename = ntypes.ELSE;
            inode.addValue(enode);
            bnode = Node.new(build);
            bnode.copyLoc(node);
            bnode.typename = ntypes.BRACES;
            bnode.addValue(condCall(condvar, ntypes.FALSE));
            enode.addValue(bnode);
         } else {
            bnode.addValue(condCall(condvar, ntypes.FALSE));
         }
         
         //("Anchor is " + anchor.toString()).print();
         anchor.beforeInsert(rinode);
         node.contained = null;
         node.typename = ntypes.VAR;
         node.held = condvar;
         node.syncAddVariable();
         return(rinode.nextDescend);
      }
      
      return(node.nextDescend);
   }
}

