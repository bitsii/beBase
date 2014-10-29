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

final class Visit:Pass5(Visit:Visitor) {

   accept(Build:Node node) Build:Node {
         var err;
         var v;
         var ix;
         var vinp;
         if (node.typename == ntypes.TRANSUNIT) {
            node.held = Build:TransUnit.new();
         }
         if (node.typename == ntypes.VAR) {
            if (undef(node.held) || node.held.sameType(Text:Strings.new().empty)) {
               v = Build:Var.new();
               node.held = v;
            }
         }
         ix = node.nextPeer;
         if (def(ix) && (node.typename == ntypes.ID || node.typename == ntypes.NAMEPATH) && ix.typename == ntypes.ID) {
            //("Found typed var two id").print();
            if (node.typename == ntypes.ID) {
               vinp = Build:NamePath.new();
               vinp.addStep(node.held);
            } else {
               vinp = node.held;
            }
            v = Build:Var.new();
            v.isTyped = true;
            //("From Name typed " + vinp.toString() + " " + node.toString()).print();
            v.namepath = vinp;
            node.typename = ntypes.VAR;
            node.held = v;
         }
         if (node.typename == ntypes.USE) {
            //get my name
            var nnode = node.nextPeer;
            while (def(nnode) && (nnode.typename == ntypes.DEFMOD)) {
               nnode = nnode.nextPeer;
            }
            if (def(nnode) && nnode.typename == ntypes.CLASS) {
               var clnode = nnode;
               nnode = clnode.contained.first;
            } else {
               clnode = null;
            }
            
            if (undef(nnode)) {
               throw(VisitError.new("Error improper use statement, target appears to be missing.", node));
            }
            
            if (nnode.typename == ntypes.ID) {
               var namepath = NamePath.new();
               namepath.addStep(nnode.held);
            } elif (nnode.typename == ntypes.NAMEPATH) {
               namepath = nnode.held;
            } else {
               throw(VisitError.new("Error improper use statement, target of incorrect type.", node));
            }
            
            if (undef(clnode)) {
               var gnext = nnode.nextPeer;
               nnode.delete();
               
               if (gnext.typename == ntypes.SEMI) {
                  nnode = gnext;
                  gnext = nnode.nextPeer;
                  nnode.delete();
               }
            } else {
               gnext = clnode;
            }
            node.held = namepath;
            
            var tnode = node.transUnit;
            
            if (undef(tnode)) {
               throw(VisitError.new("Error improper statement, not within translation unit", node));
            }
            
            tnode.held.aliased.put(namepath.label, namepath);
            
            return(gnext);
         }
         if (node.typename == ntypes.CLASS) {
            Bool isFinal = false;
            Bool isLocal = false;
            Bool isNotNull = false;
            Node prp = node.priorPeer;
            for (Int prpi = 0;prpi < 2;prpi = prpi++) {
               if (def(prp)) {
                  if (prp.typename == ntypes.DEFMOD) {
                     if (prp.typename == ntypes.DEFMOD && prp.held == "final") {
                        isFinal = true;
                     } elif (prp.typename == ntypes.DEFMOD && prp.held == "local") {
                        isLocal = true;
                     } elif (prp.typename == ntypes.DEFMOD && prp.held == "notNull") {
                        isNotNull = true;
                     }
                     Node prptmp = prp.priorPeer;
                     prp.delete();
                     prp = prptmp;
                  } else {
                     prp = null;
                  }
               }
            }
            node.held = Build:Class.new();
            node.held.fromFile = build.fromFile;
            try {
               var m = node.contained.first;
               if (m.typename == ntypes.ID) {
                  namepath = NamePath.new();
                  namepath.addStep(m.held);
               } elif (m.typename == ntypes.NAMEPATH) {
                  namepath = m.held;
               } else {
                  throw(VisitError.new("Error, class name type is incorrect", node));
               }
               node.held.namepath = namepath;
               node.held.isFinal = isFinal;
               node.held.isLocal = isLocal;
               node.held.isNotNull = isNotNull;
               m.delete();
            } catch (err) {
               err.print();
               throw(VisitError.new("Error improper class statement, target appears to be missing.", node));
            }
            try {
               nnode = node.contained.first;
               if (nnode.typename == ntypes.PARENS) {
                  if (nnode.contained.length > 2) {
                     throw(VisitError.new("Only single inheritance is allowed", nnode));
                  }
                  try {
                     m = nnode.contained.first;
                     if (m.typename == ntypes.ID) {
                        node.held.extends = NamePath.new();
                        node.held.extends.addStep(m.held);
                     } elif (m.typename == ntypes.NAMEPATH) {
                        node.held.extends = m.held;
                     } else {
                        throw(VisitError.new("Error, parent class name type is incorrect", node));
                     }
                     //m.delete();
                  } catch (err) {
                     err.print();
                     throw(VisitError.new("Error improper class statement, parent target appears to be missing.", node));
                  }
                  nnode.delete();
               }
            } catch (err) {
               err.print();
               throw(VisitError.new("Error improper class statement, braces appear to be missing.", node));
            }
            //this looks like it will break in the explicit System:Object case
            if ((undef(node.held.extends)) && (node.held.namepath.toString() != "System:Object")) {
               node.held.extends = NamePath.new().fromString("System:Object");
            }
            
            return(node.nextDescend);
         }
         if (node.typename == ntypes.METHOD) {
            node.held = Build:Method.new();
            prp = node.priorPeer;
            for (prpi = 0;prpi < 2;prpi = prpi++) {
               if (def(prp)) {
                  if (prp.typename == ntypes.DEFMOD) {
                     if (prp.typename == ntypes.DEFMOD && prp.held == "final") {
                        node.held.isFinal = true;
                     } elif (prp.typename == ntypes.DEFMOD && prp.held == "local") {
                        // local methods not yet meaningful
                        throw (VisitError.new("Local methods not supported", node));
                     }
                     prptmp = prp.priorPeer;
                     prp.delete();
                     prp = prptmp;
                  } else {
                     prp = null;
                  }
               }
            }
            try {
               m = node.contained.first; //name
               if (def(m)) {
                  var mx = m.nextPeer; //parens
                  if (def(mx)) {
                     mx = mx.nextPeer; //return type if any
                     if (mx.typename == ntypes.ID || mx.typename == ntypes.NAMEPATH) {
                        //("Found typed return").print();
                        if (mx.typename == ntypes.ID) {
                           vinp = Build:NamePath.new();
                           vinp.addStep(mx.held);
                        } else {
                           vinp = mx.held;
                        }
                        v = Build:Var.new();
                        v.isTyped = true;
                        v.namepath = vinp;
                        mx.typename = ntypes.VAR;
                        mx.held = v;
                     }
                  }
                  if (m.typename == ntypes.ID) {
                     node.held.name = m.held;
                     if (node.held.name.getPoint(0).isInteger()) {
                        throw(VisitError.new("First character of variables and subroutine names cannot be a numeric digit", node));
                     }
                     m.delete();
                  } else {
                     throw(VisitError.new("Error, subroutine declaration incomplete 1", node));
                  }
               } else {
                  throw(VisitError.new("Error, subroutine declaration incomplete 2", node));
               }
            } catch (err) {
               if (err.className == "Build:VisitError") { throw(err); }
               err.print();
               throw(VisitError.new("Error improper subroutine statement, contents appear to be missing or subroutine declared outside class.", node));
            }
            return(node.nextDescend);
         }
         if (build.constants.parensReq.has(node.typename)) {
            m = node.contained.first;
            if (undef(m) || (m.typename != ntypes.PARENS)) {
               throw(VisitError.new("Error, parensthesis missing (but required) after: ", node));
            }
         }
         
         if (node.typename == ntypes.BRACES) {
            m = node.container;
            if ((def(m)) && (m.typename == ntypes.EXPR)) {
               node.typename = ntypes.PARENS;
            }
         }
         if (node.typename == ntypes.SEMI) {
            var nx = node.priorPeer;
            gnext = node.nextAscend;
            //"semi prior is ".print();
            //nx.print();
            var con;
            while (def(nx) && (nx.typename != ntypes.SEMI) && (nx.typename != ntypes.BRACES) && (nx.typename != ntypes.EXPR)) {
               if (undef(con)) {
                  con = Container:LinkedList.new();
               }
               con.prepend(nx);
               nx = nx.priorPeer;
            }
            if (def(con)) {
               node.typename = ntypes.EXPR;
               node.held = null;
               var lpnode = Node.new(build);
               lpnode.typename = ntypes.PARENS;
               node.addValue(lpnode);
               lpnode.copyLoc(node);
               for (var ii = con.iterator;ii.hasNext;;) {
                  var i = ii.next;
                  i.delete();
                  lpnode.addValue(i);
               }
               //nx = Node.new(build);
               //nx.typename = ntypes.RPARENS;
               //lpnode.addValue(nx);
               //nx.copyLoc(lpnode);
            } else {
               node.delete();
            }
            return(gnext);
         }
         
         return(node.nextDescend);
      }
         
 }
 
