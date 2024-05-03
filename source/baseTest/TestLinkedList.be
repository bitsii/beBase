/*
 * Copyright (c) 2016-2023, the Bennt Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

use Container:LinkedList;
use Math:Int;

class Test:TestLinkedList {
   
   main() {
      if (testModify()) {
         return(testLinkedList());
      }
   }
   
   testModify() {
      LinkedList ll = LinkedList.new();
      for (Int i = 0;i < 16;i++) {
         ll.addValue(i);
      }
      ("Before " + ll.length.toString()).print();
      for (i in ll) {
         i.print();
      }
      ll.firstNode.remove();
      ("First " + ll.length.toString()).print();
      for (i in ll) {
         i.print();
      }
      ll.lastNode.remove();
      ("Second " + ll.length.toString()).print();
      for (i in ll) {
         i.print();
      }
      ll.getNode(6).remove();
      ("Third " + ll.length.toString()).print();
      for (i in ll) {
         i.print();
      }
      ll.getNode(5).insertBefore(ll.newNode(40));
      ("Fourth " + ll.length.toString()).print();
      for (i in ll) {
         i.print();
      }
      ll.firstNode.insertBefore(ll.newNode(100));
      ("Fifth " + ll.length.toString()).print();
      for (i in ll) {
         i.print();
      }
      ("After " + ll.length.toString()).print();
      for (i in ll) {
         i.print();
      }
   }
   
   testLinkedList() {
      any uux = LinkedList.new();
      //if (undef(uux.firstItem)) { "isnull first".print(); } else { "notnull first".print(); }
      //return(false);
      if (testIter(uux, 0)) {
         uux.addValue("Hi");
         uux.addValue(" There");
         uux.addValue(" Mac");
         if (testIter(uux, 3)!) {
            return(false);
         }
      } else {
         return(false);
      }
      
      any uuy = uux.copy();
      any ix = uux.iterator;
      any iy = uuy.iterator;
      while (ix.hasNext) {
         if (ix.next != iy.next) {
            "!FAILED copy 1".print();
            return(false);
         }
      }
      
      uuy.put(1, "Boo");
      
      if (uux.get(1) == uuy.get(1)) {
            "!FAILED copy 2".print();
            return(false);
         }
      " PASSED copy".print();
      
      return(true);
   }
   
   testIter(uux, should) {
      any x = 0;
      any i = uux.iterator;
      //if (i.hasNext) { "ihasnext".print(); } else { "inothavenext".print(); }
      for (any h;i.hasNext;;) {
         //("In loop " + x.toString()).print();
         //i.next.print();
         i.next;
         x = x++;
      }
      
      //x.print();
      if (x == should) {
      (" PASSED iterate " + should.toString()).print();
      } else {
      ("!FAILED iterate " + x.toString() + " " + should.toString()).print();
      return(false);
      }
      
      return(true);
   }
   
}

