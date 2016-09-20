// Copyright 2006 Craig Welch
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

use Container:List;
use System:Parameters;
use Math:Int;
use Text:String;
use Text:String;
use System:Serializer;
use Container:Set;
use Container:Map;
use Container:LinkedList;

use Test:BaseTest;
use Test:Failure;
use Logic:Bool;

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
      
      var i = ll.iterator;
      while (i.hasNext) {
         i.next = "boo";
      }
      i.next = "boo";
      
      Int count = 0;
      for (ln in ll) {
         count = count++;
         //("Found ln " + ln).print();
         assertEquals(ln, "boo");
      }
      assertEquals(count, 3);
   }
   
   testModify() {
      LinkedList ll = LinkedList.new();
      for (Int i = 0;i < 16;i = i++) {
         ll.addValue(i);
      }
      ("Before " + ll.length.toString()).print();
      for (i in ll) {
         i.print();
      }
      ll.firstNode.delete();
      ("First " + ll.length.toString()).print();
      for (i in ll) {
         i.print();
      }
      ll.lastNode.delete();
      ("Second " + ll.length.toString()).print();
      for (i in ll) {
         i.print();
      }
      ll.getNode(6).delete();
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
      var uux = LinkedList.new();
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
      
      var uuy = uux.copy();
      var ix = uux.iterator;
      var iy = uuy.iterator;
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
      var x = 0;
      var i = uux.iterator;
      //if (i.hasNext) { "ihasnext".print(); } else { "inothavenext".print(); }
      for (var h;i.hasNext;;) {
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

