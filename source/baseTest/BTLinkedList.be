/*
 * Copyright (c) 2016-2023, the Brace Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

import Container:List;
import System:Parameters;
import Math:Int;
import Text:String;
import Text:String;
import System:Serializer;
import Container:Set;
import Container:Map;
import Container:LinkedList;

import Test:BaseTest;
import Test:Failure;
import Logic:Bool;

class Test:BaseTest:LinkedList(BaseTest) {
   
   main() {
      ("Test:BaseTest:Serialize:main").print();
      //testModify();
      //testLinkedList();
      testIteration();
   }
   
   testIteration() {
   
      ll = LinkedList.new();
      ll.iterator.next = "First One";
      
      Bool found = false;
      for (String ln in ll) {
         assertFalse(found);
         found = true;
         assertEquals(ln, "First One");
      }
      
      assertTrue(found);
   
      LinkedList ll = LinkedList.new();
      
      ll += "hi";
      ll += "there";
      
      dyn i = ll.iterator;
      while (i.hasNext) {
         i.next = "boo";
      }
      i.next = "boo";
      
      Int count = 0;
      for (ln in ll) {
         count++;
         //("Found ln " + ln).print();
         assertEquals(ln, "boo");
      }
      assertEquals(count, 3);
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
      dyn uux = LinkedList.new();
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
      
      dyn uuy = uux.copy();
      dyn ix = uux.iterator;
      dyn iy = uuy.iterator;
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
      dyn x = 0;
      dyn i = uux.iterator;
      //if (i.hasNext) { "ihasnext".print(); } else { "inothavenext".print(); }
      for (dyn h;i.hasNext;;) {
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

