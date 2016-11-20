// Copyright 2006 Craig Welch
//
// Licensed under the MIT license. See LICENSE.txt file in the project root 
// for full license information.

use Container:LinkedList;
use Container:Map;
use Build:Visit;
use Build:NamePath;
use Build:VisitError;

final class Build:Visit:Pass7(Build:Visit:Visitor) {

   new() self {
      fields {
         NamePath inClassNp;
         String inFile;
      }
   }
   
   buildLiteral(node, tName) {
         
         any nlnp = Build:NamePath.new();
         nlnp.fromString(tName);
         
         any nlnpn = Build:Node.new(build);
         nlnpn.typename = ntypes.NAMEPATH;
         nlnpn.held = nlnp;
         nlnpn.copyLoc(node);
         
         any nlc = Build:Call.new();
         nlc.name = "new";
         nlc.wasBound = false;
         nlc.bound = false;
         nlc.isConstruct = true;
         nlc.isLiteral = true;
         nlc.literalValue = node.held;
         
         node.addValue(nlnpn);
         
         node.typename = ntypes.CALL;
         node.held = nlc;
         
         nlnpn.resolveNp();
         
         if ((tName == "Math:Int") || (tName == "Math:Float")) {
            any pn = node.priorPeer;
            if (def(pn) && ((pn.typename == ntypes.SUBTRACT) || (pn.typename == ntypes.ADD))) {
               any pn2 = pn.priorPeer;
               if (undef(pn2) || ((pn2.typename != ntypes.CALL) && (pn2.typename != ntypes.ID) && (pn2.typename != ntypes.VAR) && (pn2.typename != ntypes.ACCESSOR))) {
                  /* if (def(pn2)) {
                     ("!!!SIGN Doing for typename " + pn2.typename).print();
                  } else {
                     ("!!!SIGN Doing for null").print();
                  } */
                  nlc.literalValue = pn.held + nlc.literalValue;
                  pn.delete();
               }
               /*if (undef(pn2)) {
                  "!!!SIGN ISNULL pn2".print();
               } else {
                  ("!!!SIGN pn2 is " + pn2.typename).print();
               }*/
            }
         }
   }

   accept(Build:Node node) Build:Node {
      //any chk = "TypeCheck checking ";
      //if (def(node.inFile)) {
      //   chk = chk + node.inFile;
      //}
      //if (def(node.nlc)) {
      //   chk = chk + " " + node.nlc.toString();
      //}
      //chk.print();
      //node.print();
      any v;
      any np;
      any toremove;
      any i;
      any ii;
      any nnode = node.nextPeer;
      any dnode;
      Build:Node onode;
      if (node.typename == ntypes.CLASS) {
         inClassNp = node.held.namepath;
         inFile = node.held.fromFile.toString();
      }
      if (def(inClassNp)) {
         node.inClassNp = inClassNp;
         node.inFile = inFile;
      }
      if (node.typename == ntypes.INTL) {
         buildLiteral(node, "Math:Int");
      }
      if (node.typename == ntypes.FLOATL) {
         buildLiteral(node, "Math:Float");
      }
      if (node.typename == ntypes.STRINGL) {
         buildLiteral(node, "Text:String");
      }
      if (node.typename == ntypes.WSTRINGL) {
         //"!!!!!!!!!!!!!!!!BUILDING NODE WIDESTRING".print();
         buildLiteral(node, "Text:String");
         node.wideString = true;
      }
      if (node.typename == ntypes.TRUE) {
         node.held = "true";
         buildLiteral(node, "Logic:Bool");
      }
      /* ("DEBUG node typename " + node.typename).print();
      if (def(nnode)) {
         ("DEBUG nnode typename " + nnode.typename).print();
      } */
      if (node.typename == ntypes.FALSE) {
         node.held = "false";
         buildLiteral(node, "Logic:Bool");
      }
      elseIf ((node.typename == ntypes.VAR) && (node.held.isArg!)) {
         if (undef(node.held.name) && (undef(nnode) || (nnode.typename != ntypes.ID))) {
            throw(VisitError.new("Error, anyiable declaration missing name " + node.held.name, node));
         } else {
            node.held.name = nnode.held;
            node.addVariable();
            nnode.delete();
            //if (def(node.held.namepath)) {
            //   ("Found namepath typed any " + node.held.name + " " + node.held.namepath.toString()).print();
            //}
            return(node.nextDescend);
         }
      } elseIf (node.typename == ntypes.ID) {
         if (def(nnode) && (nnode.typename == ntypes.PARENS)) {
            if (def(nnode.contained)) {
               toremove = Container:LinkedList.new();
               for (ii = nnode.contained.iterator;ii.hasNext;;) {
                  i = ii.next;
                  if (i.typename == ntypes.COMMA) {
                     toremove.addValue(i);
                  }
               }
               for (ii = toremove.iterator;ii.hasNext;;) {
                  i = ii.next;
                  i.delete();
               }
            }
            any pc = nnode;
            pc.typename = ntypes.CALL;
            any gc = Build:Call.new();
            gc.name = node.held;
            pc.held = gc;
            node.delete();
            node = pc;
            dnode = node.priorPeer;
            if (def(dnode) && (dnode.typename == ntypes.DOT)) {
               onode = dnode.priorPeer;
               if (undef(onode)) {
                  throw(VisitError.new("Error, missing instance for bound call", node));
               } elseIf (onode.typename == ntypes.NAMEPATH) {
                  if (build.isNewish(gc.name)) {
                     gc.wasBound = false;
                     gc.bound = false;
                     gc.isConstruct = true;
                  } else {
                     createImpliedConstruct(onode, gc);  //was gone
                  }
               } elseIf (onode.typename == ntypes.ID && (node.transUnit.held.aliased.has(onode.held) || build.emitData.aliased.has(onode.held))) {
                  Build:NamePath namepath = Build:NamePath.new();
                  namepath.addStep(onode.held);
                  onode.held = namepath;
                  onode.typename = ntypes.NAMEPATH;
                  onode.resolveNp();
                  if (build.isNewish(gc.name)) {
                     gc.wasBound = false;
                     gc.bound = false;
                     gc.isConstruct = true;
                  } else {
                     createImpliedConstruct(onode, gc);  //was gone
                  }
               } elseIf (gc.name == "return") {
                  throw(VisitError.new("Error, return cannot be a bound call and cannot be called on an object", node));
               } elseIf (gc.name == "throw") {
                  throw(VisitError.new("Error, throw cannot be a bound call cannot be called on an object", node));
               }
               //pc.removeAndPrepend(onode)
               onode.delete();
               pc.prepend(onode);
               dnode.delete();
            } else {
               gc.bound = false;
               gc.wasBound = false;
            }
            //ponode = pc.priorPeer()
         }
      } elseIf (node.typename == ntypes.IDX) {
      //"!!!in idx".print();
      //CHANGE TYPE like accessor to prevent double-traverse
         onode = node.priorPeer;
         if (undef(onode)) {
            throw(VisitError.new("Error, indexed access without call", node));
         }
         onode.delete();
         node.prepend(onode);
         if (onode.typename == ntypes.NAMEPATH) {
            throw(VisitError.new("Error, incorrect syntax for indexed access, invocation target cannot be a class name", node));
         }
         node.typename = ntypes.IDXACC;
      } elseIf (node.typename == ntypes.DOT) {
      //"6".print();
         onode = node.priorPeer;
         //"!!!!!!!!!here".print();
         //onode.print();
         if (undef(nnode) || undef(onode)) {
            throw(VisitError.new("Error, incomplete call or accessor", node));
         }
         if (nnode.typename == ntypes.ID) {
            any pnode = nnode.nextPeer;
            if (undef(pnode) || (pnode.typename != ntypes.PARENS)) {
               any ponode = onode.priorPeer;
               node.typename = ntypes.ACCESSOR;
               any ga = Build:Accessor.new();
               ga.name = nnode.held;
               nnode.delete();
               onode.delete();
               node.held = ga;
               node.addValue(onode);
               if (onode.typename == ntypes.NAMEPATH) {
                  createImpliedConstruct(onode, ga);
               } elseIf (onode.typename == ntypes.ID && (node.transUnit.held.aliased.has(onode.held) || build.emitData.aliased.has(onode.held))) {
                  namepath = Build:NamePath.new();
                  namepath.addStep(onode.held);
                  onode.held = namepath;
                  onode.typename = ntypes.NAMEPATH;
                  onode.resolveNp();
                  createImpliedConstruct(onode, gc);
               }
            }
         }
      }
      return(node.nextDescend);
   }
   
   createImpliedConstruct(Build:Node onode, gc) {
      Build:Node npcnode = Build:Node.new();
      npcnode.held = gc;
      npcnode.typename = ntypes.NAMEPATH;
      npcnode.held = onode.held;
      onode.prepend(npcnode);
      
      Build:Call gnc = Build:Call.new();
      gnc.name = "new";
      gnc.wasBound = false;
      gnc.bound = false;
      gnc.isConstruct = true;
      gnc.wasImpliedConstruct = true;
      onode.held = gnc;
      onode.typename = ntypes.CALL;
   }
}

