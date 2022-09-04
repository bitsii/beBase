// Copyright 2006 The Brace Authors. All rights reserved.
// Use of this source code is governed by the BSD-3-Clause
// license that can be found in the LICENSE file.

use Container:LinkedList;
use Container:LinkedList:Iterator as LIter;
use Container:Map;
use Build:VisitError;
use Build:Node;
use Build:NodeTypes;

final class Build:Transport {
   
   new (Build:Build _build) Build:Transport {
      fields {
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
      } catch (any e) {
         if (def(node)) {
            ("Caught exception during visit to node").print();
            ("Exception:").print();
            e.print();
            ("Node:").print();
            node.print();
            any nc = node.container;
            while (def(nc)) {
              "contained by".print();
              nc.print();
              nc = nc.container;
            }
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
      for (LIter i = bfrom.linkedListIterator;i.hasNext;;) {
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
               mnode.held = "method";
               curr.addValue(mnode);
               curr = mnode;
            }
            
            if (node.typename == ntypes.BRACES && curr.typename == ntypes.BRACES) {
            //&& curr.container.typename == ntypes.METHOD
               mnode = Node.new(build);
               mnode.typename = ntypes.FIELD;
               mnode.held = "fields";
               curr.addValue(mnode);
               curr = mnode;
            }
            
            if (node.typename == ntypes.RPARENS) {
               curr = stepBack(curr);
            } elseIf (node.typename == ntypes.RIDX) {
               curr = stepBack(curr);
            } elseIf (node.typename == ntypes.RBRACES) {
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

