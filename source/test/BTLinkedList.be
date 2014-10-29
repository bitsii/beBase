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

use Container:Array;
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
      foreach (String ln in ll) {
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
      foreach (ln in ll) {
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
      foreach (i in ll) {
         i.print();
      }
      ll.firstNode.delete();
      ("First " + ll.length.toString()).print();
      foreach (i in ll) {
         i.print();
      }
      ll.lastNode.delete();
      ("Second " + ll.length.toString()).print();
      foreach (i in ll) {
         i.print();
      }
      ll.getNode(6).delete();
      ("Third " + ll.length.toString()).print();
      foreach (i in ll) {
         i.print();
      }
      ll.getNode(5).insertBefore(ll.newNode(40));
      ("Fourth " + ll.length.toString()).print();
      foreach (i in ll) {
         i.print();
      }
      ll.firstNode.insertBefore(ll.newNode(100));
      ("Fifth " + ll.length.toString()).print();
      foreach (i in ll) {
         i.print();
      }
      ("After " + ll.length.toString()).print();
      foreach (i in ll) {
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

