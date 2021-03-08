// Copyright 2006 The Abelii Authors. All rights reserved.
// Use of this source code is governed by the BSD-3-Clause
// license that can be found in the LICENSE file.

use Container:LinkedList;
use Container:Map;
use Build:Visit;
use Build:NamePath;
use Build:VisitError;

final class Build:Visit:Pass8(Build:Visit:Visitor) {

   acceptClass(node) {
         build.emitData.addParsedClass(node);
   }
   
   prepOps() {
      any ops = Container:List.new(10);
      for (any i = 0;i < 10;i = i++) {
         ops.put(i,Container:LinkedList.new());
      }
      return(ops);
   }

   accept(Build:Node node) Build:Node {
      //("Visiting " + node.toString() ).print();
      any i;
      any it;
      if (node.typename == ntypes.CLASS) {
         acceptClass(node);
         return(node.nextDescend);
      }
      any prec = const.oper.get(node.typename);
      if (def(prec)) {
         //find range
         //det parens depth
         //bin impl parens
         //"Found prec".print();
         any cont = node.container;
         any ops = prepOps();
         any onode = node;
         any mo;
         node = null;
         while (def(onode) && (def(prec)) && (onode.container == cont)) {
            ops.get(prec).addValue(onode);
            any inode = onode.nextPeer;
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
               for (any mt = i.iterator;mt.hasNext;;) {
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
      any gc = Build:Call.new();
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
      if (gc.name == "get_method") {
         //"GOT A GET METHOD".print();
         gc.name = "getMethod";
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
      if (op.typename == ntypes.GET_METHOD) {
        build.buildLiteral(nx, "Text:String");
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

