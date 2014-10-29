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

final class Visit:Pass8(Visit:Visitor) {

   acceptClass(node) {
         build.emitData.addParsedClass(node);
   }
   
   prepOps() {
      var ops = Container:Array.new(10);
      for (var i = 0;i < 10;i = i++) {
         ops.put(i,Container:LinkedList.new());
      }
      return(ops);
   }

   accept(Build:Node node) Build:Node {
      //("Visiting " + node.toString() ).print();
      var i;
      var it;
      if (node.typename == ntypes.CLASS) {
         acceptClass(node);
         return(node.nextDescend);
      }
      var prec = const.oper.get(node.typename);
      if (def(prec)) {
         //find range
         //det parens depth
         //bin impl parens
         //"Found prec".print();
         var cont = node.container;
         var ops = prepOps();
         var onode = node;
         var mo;
         node = null;
         while (def(onode) && (def(prec)) && (onode.container == cont)) {
            ops.get(prec).addValue(onode);
            var inode = onode.nextPeer;
            if (def(inode)) {
               inode = inode.nextPeer;
               if (def(inode)) {
                  if (inode.typename == ntypes.COMMA) {
                     inode = inode.nextPeer;
                     if (def(inode)) {
                        inode = inode.nextPeer;
                     }
                  }
               }
            }
            onode = inode;
            if (def(onode)) {
               prec = const.oper.get(onode.typename);
            } else {
               prec = null;
            }
         }
         prec = 0;
         for (it = ops.iterator;it.hasNext;;) {
            i = it.next;
            if (i.length > 0) {
               for (var mt = i.iterator;mt.hasNext;;) {
                  mo = mt.next;
                  mo = callFromOper(mo, prec, mo.priorPeer, mo.nextPeer);
                  node = mo;
               }
            }
            prec = prec++;
         }
         //return(node);
      }
   
      return(node.nextDescend);
   }
   
   callFromOper(op, prec, pr, nx) {
      var gc = Build:Call.new();
      gc.wasOper = true;
      gc.name = const.operNames.get(op.typename).lower();
      if (gc.name == "not_equals") {
         gc.name = "notEquals";
      }
      if (gc.name == "lesser_equals") {
         gc.name = "lesserEquals";
      }
      if (gc.name == "greater_equals") {
         gc.name = "greaterEquals";
      }
      if (gc.name == "add_value") {
         gc.name = "addValue";
      }
      if (gc.name == "subtract_value") {
         gc.name = "subtractValue";
      }
      if (gc.name == "increment_value") {
         gc.name = "incrementValue";
      }
      if (gc.name == "decrement_value") {
         gc.name = "decrementValue";
      }
      if (gc.name == "multiply_value") {
         gc.name = "multiplyValue";
      }
      if (gc.name == "divide_value") {
         gc.name = "divideValue";
      }
      if (gc.name == "modulus_value") {
         gc.name = "modulusValue";
      }
      if (gc.name == "logical_and") {
         gc.name = "logicalAnd";
      }
      if (gc.name == "logical_or") {
         gc.name = "logicalOr";
      }
      if (gc.name == "and_value") {
         gc.name = "andValue";
      }
      if (gc.name == "or_value") {
         gc.name = "orValue";
      }
      //TODO change x_y to xY without custom logic
      gc.wasBound = true;
      if (op.typename == ntypes.ASSIGN && op.held == "=@") {
         //("FOUND once assign !!!").print();
         gc.isOnce = true;
      }
      if (op.typename == ntypes.ASSIGN && op.held == "=#") {
         //("FOUND many assign !!!").print();
         gc.isMany = true;
      }
      op.typename = ntypes.CALL;
      op.held = gc;
      pr.delete();
      op.addValue(pr);
      if (prec > 0) {
         nx.delete();
         op.addValue(nx);
      }
      return(op);
   }
}

