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

final class Visit:Pass9(Visit:Visitor) {

   accept(Build:Node node) Build:Node {
      //dump expr
      var it;
      var i;
      var inode;
      var lnode;
      var lbrnode;
      var loopif;
      var enode;
      var brnode;
      var bnode;
      var pnode;
      var init;
      var cond;
      var atStep;
      
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
                  var estr = "Error, parens length of contained too great " + i.contained.length.toString();
                  throw(VisitError.new(estr, node));
               }
            }
         }
         return(node.nextDescend);
      } elif (node.typename == ntypes.ACCESSOR) {
         //for accessors (accessor nodes):
         //if in assign call and in position 0, is set
         //else is get
         var ac = node.held;
         var c = Build:Call.new();
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
            var ntarg = node.contained.first;
            
            node.typename = ntarg.typename;
            node.held = ntarg.held;
            node.contained = ntarg.contained;
            return(node.container.nextDescend);
         } else {
            node.typename = ntypes.CALL;
            node.held = c;
         }
         return(node.nextDescend);
      } elif (node.typename == ntypes.IDXACC) {
         //"!!!!!!!!!!!!!IN NTYPES.IDX PASS9".print();
         ac = node.held;
         c = Build:Call.new();
         if ((node.container.typename == ntypes.CALL) && (node.container.held.name == "assign") && (node.isFirst)) {
            //"IsPut".print();
            var isPut = true;
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
      if (node.typename == ntypes.FOREACH) {
         node.typename = ntypes.WHILE;
         pnode = node.contained.first;
         brnode = node.second;
         var lin = pnode.contained.first;
         var lvar = lin.contained.first;
         var toit = lin.second;
         pnode.contained = null;
         /*
         if (undef(lvar)) {
            "lvar is null".print();
         } else {
            ("lvar is " + lvar.typename + " " + lvar.held.name).print();
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
         
         var tmpn = Node.new(build);
         tmpn.copyLoc(node);
         tmpn.typename = ntypes.VAR;
         var tmpv = node.tmpVar("loop", build);
         tmpn.held = tmpv;
         
         var gin = Node.new(build);
         gin.typename = ntypes.CALL;
         var gic = Build:Call.new();
         gin.held = gic;
         gic.name = "iteratorGet";
         gin.addValue(toit);
         
         var asn = Node.new(build);
         asn.copyLoc(node);
         asn.typename = ntypes.CALL;
         var asc = Build:Call.new();
         asn.held = asc;
         asc.name = "assign";
         asn.addValue(tmpn);
         asn.addValue(gin);
         
         node.beforeInsert(asn);
         tmpn.addVariable();
         
         var tmpnt = Node.new(build);
         asn.copyLoc(node);
         tmpnt.typename = ntypes.VAR;
         tmpnt.held = tmpv;
         
         var tcn = Node.new(build);
         tcn.copyLoc(node);
         tcn.typename = ntypes.CALL;
         var tcc = Build:Call.new();
         tcn.held = tcc;
         tcc.name = "hasNextGet";
         tcn.addValue(tmpnt);
         
         pnode.addValue(tcn);
         
         var tmpng = Node.new(build);
         tmpng.copyLoc(node);
         tmpng.typename = ntypes.VAR;
         tmpng.held = tmpv;
         
         var iagn = Node.new(build);
         iagn.copyLoc(node);
         iagn.typename = ntypes.CALL;
         var iagc = Build:Call.new();
         iagn.held = iagc;
         iagc.name = "nextGet";
         iagn.addValue(tmpng);
         
         var iasn = Node.new(build);
         iasn.copyLoc(node);
         iasn.typename = ntypes.CALL;
         var iasc = Build:Call.new();
         iasn.held = iasc;
         iasc.name = "assign";
         iasn.addValue(lvar);
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
      } elif (node.typename == ntypes.FOR) {
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
