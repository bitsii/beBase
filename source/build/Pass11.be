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
use Build:Node;

final class Visit:Pass11(Visit:Visitor) {

   new() self {
      properties {
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
         for (var it = node.contained.first.contained.iterator;it.hasNext;;) {
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
         Build:Var ts = node.held.varMap.get("self").held;
         ts.isTyped = true;
         ts.namepath = node.classGet().held.namepath;
      }
      //if ((node.typename == ntypes.VAR) && (def(node.held.namepath))) {
      //   ("Found namepath typed var again " + node.held.name + " " + node.held.namepath.toString()).print();
      //}
      if (node.typename == ntypes.CALL) {
         //"AT 1".print();
         if (((node.held.name == "return") || (node.held.name == "throw")) && (node.contained.length > 2)) {
             throw(Build:VisitError.new("This type must have exactly one variable, not " + node.contained.length.toString(), node));
         }
         if (node.held.bound!) {
            var nd = Node.new(build);
            nd.copyLoc(node);
            var v = inMtd.held.varMap.get("self");
            nd.typename = ntypes.VAR;
            nd.held = v.held;
            node.held.bound = true;
            node.prepend(nd);
         }
         //"AT 2".print();
         if (node.held.name == "assign") {
            return(node.nextDescend);  //no unwind for assignments
         }
         var unwind = true;
         var c0 = node.container;
         if (undef(c0)) {
            throw(Build:VisitError.new("Call not in correct position", node));
         }
         //node.print();
         //"AT 3".print();
         if ((c0.typename == ntypes.CALL) && (c0.held.name == "assign") && (node.isSecond)) {
            unwind = false;
         } elif (c0.typename == ntypes.BRACES) {
            unwind = false;
         }
         if (unwind) {
            var cnode = c0;
            var lastStep = null;
            //"cnode unwind".print();
            //cnode.typename.print();
            while (cnode.typename != ntypes.BRACES) {
               //"in cnode unw".print();
               lastStep = cnode;
               cnode = cnode.container;
            }
            //"done cnode unwind".print();
            //print "!!!Unwound call " + node.name + " step " + cnode.typename + " " + cnode.name + " in sub: " + subnode.name + " class: " + clnode.namepath.derName() + " to braces in " + lastStep.container.name + " " + lastStep.container.typename + " " + lastStep.container.container.name + " " + lastStep.container.container.typename
            
            var pholdv = lastStep.tmpVar("phold", build);
            var phold = Node.new(build);
            phold.copyLoc(node);
            phold.typename = ntypes.VAR;
            phold.held = pholdv;
            node.replaceWith(phold);
            phold.addVariable();
            var prc = Node.new(build);
            prc.copyLoc(node);
            prc.typename = ntypes.CALL;
            var prcc = Build:Call.new();
            prcc.name = "assign";
            prc.held = prcc;
            var phold2 = Node.new(build);
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

