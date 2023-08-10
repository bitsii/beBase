/*
 * Copyright (c) 2006-2023, the Bennt Authors.
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
use Build:Node;

final class Build:Visit:Pass5(Build:Visit:Visitor) {

   accept(Build:Node node) Build:Node {
         any err;
         any v;
         any ix;
         any vinp;
         if (node.typename == ntypes.TRANSUNIT) {
            node.held = Build:TransUnit.new();
         }
         if (node.typename == ntypes.VAR) {
            if (undef(node.held) || System:Types.sameType(node.held, Text:Strings.new().empty)) {
               v = Build:Var.new();
               if (def(node.held) && System:Types.sameType(node.held, Text:Strings.new().empty) && node.held == "auto") {
                //"FOUND A AUTOTYPE VAR".print();
                v.autoType = true;
               }
               node.held = v;
            }
         }
         ix = node.nextPeer;
         if (def(ix) && (node.typename == ntypes.ID || node.typename == ntypes.NAMEPATH) && ix.typename == ntypes.ID) {
            //("Found typed any two id").print();
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
         
            Node lun = node.priorPeer;
            if (def(lun) && (lun.typename == ntypes.DEFMOD) && lun.held == "local") {
               Bool isLocalUse = true;
               lun.delete();
            } else {
              isLocalUse = false;
            }
         
            //get my name
            any nnode = node.nextPeer;
            while (def(nnode) && (nnode.typename == ntypes.DEFMOD)) {
               nnode = nnode.nextPeer;
            }
            if (def(nnode) && nnode.typename == ntypes.CLASS) {
               any clnode = nnode;
               nnode = clnode.contained.first;
            } else {
               clnode = null;
            }
            
            if (undef(nnode)) {
               throw(VisitError.new("Error improper use statement, target appears to be missing.", node));
            }
            
            if (nnode.typename == ntypes.ID) {
               any namepath = NamePath.new();
               namepath.addStep(nnode.held);
            } elseIf (nnode.typename == ntypes.NAMEPATH) {
               namepath = nnode.held;
            } else {
               throw(VisitError.new("Error improper use statement, target of incorrect type.", node));
            }
            
            String alias = null;
            any mas = nnode.nextPeer;
            if (mas.typename == ntypes.AS) {
              nnode = mas.nextPeer;
              if (nnode.typename != ntypes.ID) {
                throw(VisitError.new("Error improper use statement, alias does not follow -as-.", node));
              }
              alias = nnode.held;
            }
            
            if (undef(clnode)) {
               any gnext = nnode.nextPeer;
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
            
            any tnode = node.transUnit;
            
            if (undef(tnode)) {
               throw(VisitError.new("Error improper statement, not within translation unit", node));
            }
            
            if (undef(alias)) {
              alias = namepath.label;
            }
            tnode.held.aliased.put(alias, namepath);
            if (isLocalUse) {
              build.emitData.aliased.put(alias, namepath);
            }
            
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
                     } elseIf (prp.typename == ntypes.DEFMOD && prp.held == "local") {
                        isLocal = true;
                     } elseIf (prp.typename == ntypes.DEFMOD && prp.held == "notNull") {
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
               any m = node.contained.first;
               if (m.typename == ntypes.ID) {
                  namepath = NamePath.new();
                  namepath.addStep(m.held);
               } elseIf (m.typename == ntypes.NAMEPATH) {
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
                     } elseIf (m.typename == ntypes.NAMEPATH) {
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
                     } elseIf (prp.typename == ntypes.DEFMOD && prp.held == "local") {
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
                  any mx = m.nextPeer; //parens
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
                        throw(VisitError.new("First character of anyiables and subroutine names cannot be a numeric digit", node));
                     }
                     m.delete();
                  } else {
                     throw(VisitError.new("Error, subroutine declaration incomplete 1", node));
                  }
               } else {
                  throw(VisitError.new("Error, subroutine declaration incomplete 2", node));
               }
            } catch (err) {
               if (System:Classes.className(err) == "Build:VisitError") { throw(err); }
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
            any nx = node.priorPeer;
            gnext = node.nextAscend;
            //"semi prior is ".print();
            //nx.print();
            any con;
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
               any lpnode = Node.new(build);
               lpnode.typename = ntypes.PARENS;
               node.addValue(lpnode);
               lpnode.copyLoc(node);
               for (any ii = con.iterator;ii.hasNext;;) {
                  any i = ii.next;
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
 
