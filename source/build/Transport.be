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
use Build:VisitError;
use Build:Node;
use Build:NodeTypes;

final class Build:Transport {
   
   new (Build:Build _build) Build:Transport {
      properties {
         Build:Build build = _build;
         NodeTypes ntypes = build.constants.ntypes;
         Node outermost = Node.new(build);
         Node current = outermost;
      }
      outermost.typename = ntypes.TRANSUNIT;
      outermost.held = "transunit";
   } 
   
   new (Build:Build _build, Node _outermost) Build:Transport {
      build = _build;
      ntypes = build.constants.ntypes;
      outermost = _outermost;
      current = outermost;
   }

   //non-recursive
   traverse(Build:Visit:Visitor visitor) {
      try {
         visitor.begin(self);
         
         Node node = visitor.accept(outermost);
         
         while (def(node)) {
            node = visitor.accept(node);
         }
         
         visitor.end(self);
      } catch (var e) {
         if (def(node)) {
            ("Caught exception during visit to node:").print();
            node.print();
            ("Exception:").print();
            e.print();
         } else {
            ("Caught exception during visit, node is undef").print();
            ("Exception:").print();
            e.print();
         }
         throw(e);
      }
   }
   
   contain() {
      Map conTypes = build.constants.conTypes;
      Node curr = outermost;
      LinkedList bfrom = outermost.contained;
      outermost.contained = null;
      for (var i = bfrom.iterator;i.hasNext;;) {
         //LinkedList:Node lnode = i.nextNode;
         //Node node = lnode.held;
         Node node = i.next;
         if ((node.delayDelete)!) {
            if (curr.typename == ntypes.TRANSUNIT && node.typename == ntypes.ID) {
               //if we walk forward to the end of a possible classname (id, colons and spaces)
               //and find either braces or parens, we are a class name
               Node wf = node;
               while (def(wf) && (wf.typename == ntypes.ID || wf.typename == ntypes.COLON
                  || wf.typename == ntypes.SPACE)) {
                  wf = wf.nextPeer;
               }
               if (def(wf) && (wf.typename == ntypes.PARENS || wf.typename == ntypes.BRACES)) {
                  //throw(VisitError.new("found classless classname ", node));
                  //("Found new classless class " + node).print();
                  Node cnode = Node.new(build);
                  cnode.typename = ntypes.CLASS;
                  cnode.held = "class";
                  curr.addValue(cnode);
                  curr = cnode;
               }
            }
            if (curr.typename == ntypes.BRACES && curr.container.typename == ntypes.CLASS && node.typename == ntypes.ID) {
               //("Found new method").print();
               Node mnode = Node.new(build);
               mnode.typename = ntypes.METHOD;
               mnode.held = "mtd";
               curr.addValue(mnode);
               curr = mnode;
            }
            if (node.typename == ntypes.RPARENS) {
               curr = stepBack(curr);
            } elif (node.typename == ntypes.RIDX) {
               curr = stepBack(curr);
            } elif (node.typename == ntypes.RBRACES) {
               curr = stepBack(curr);
               if (undef(curr)) {
                  throw(VisitError.new("Missing container during stepout", node));
               }
               curr = stepBack(curr);
               if (undef(curr)) {
                  throw(VisitError.new("Missing container during stepout", node));
               }
            } else {
               curr.addValue(node);
            }
            if (conTypes.has(node.typename)) {
               curr = node;
            }
         }
      }
   }
   
   stepBack(Node curr) Node {
      Node hop = curr.container;
      if (undef(hop)) {
         throw(VisitError.new("Missing container during stepout", curr));
      }
      return(hop);
   }

}

