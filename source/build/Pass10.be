/*
Copyright 2006 Craig Welch
All rights reserved.

Developed by:

    Craig Welch

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal with
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

    * Redistributions of source code must retain the above copyright notice,
      this list of conditions and the following disclaimers.

    * Redistributions in binary form must reproduce the above copyright notice,
      this list of conditions and the following disclaimers in the
      documentation and/or other materials provided with the distribution.

    * Neither the name of the Software nor the names of its contributors may be used 
      to endorse or promote products derived from this Software without specific
      prior written permission.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
CONTRIBUTORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS WITH THE
SOFTWARE.
*/

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

