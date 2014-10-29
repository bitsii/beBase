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
use Text:String;
use Text:String;

use Test:BaseTest;
use Test:Failure;
use Math:Int;

class Test:BaseTest:Array(BaseTest) {
   
   mergeSort() {
      Array aret = mergeSort(Array.new(10));
      Array vret = mergeSort(Array.new(10));
   }
   
   mergeSort(Array ts) Array {
   
      Math:Int v;
      
      ts[0] = 6;
      ts[1] = 8;
      ts[2] = 3;
      ts[3] = 2;
      ts[4] = 9;
      ts[5] = 7;
      ts[6] = 5;
      ts[7] = 0;
      ts[8] = 1;
      ts[9] = 4;
      
      Array ts1 = ts.mergeSort();
      foreach (v in ts1) { if (undef(v)) { "Null".print(); } else { v.print(); } }
      for (Int i = 0;i < ts1.length;i = i++) { 
         assertEquals(ts1[i], i);
      }
      
      return(ts1);
   }
   
   more() {
      
      var uux = Array.new(2);
      uux.put(0, "Hi");
      uux[1] = "There";
      assertEquals(uux[0], "Hi");
      uux.put(4, "Last");
      Int x = 0;
      for (var i = uux.iterator;i.hasNext;;) {
         i.next;
         x = x++;
      }
      
      assertEquals(x, 5);
      assertEquals(uux[0], "Hi");
      assertEquals(uux[1], "There");
      assertEquals(uux[4], "Last");
      var uuz = uux.copy();
      for (var j = 0;j < uux.length;j = j++) {
         assertFalse(undef(uux.get(j)) && def(uuz.get(j)));
         if (def(uux[j])) {
            assertFalse(uux.get(j) != uux.get(j));
         }
      }
      
      uux.put(25, "Boo");
      assertEquals(uux[25], "Boo");
      uux.length.print();
      uux.delete(1);
      uux.delete(0);
      assertEquals(uux[2], "Last");
      assertEquals(uux.length, 24);
      
   }
   
   sortedFind() {
     //test
     //lt all values FX, TX
     //gt all values FX, TX
     //in mid, but not in values - TX
     //in values, first, last, inbetween - FX, TX
     
     "sortedFind".print();
     Array sf;
     Int i;
     
     sf = Array.new(5);
     
     for (i = 0;i < 5;i = i++) {
        sf[i] = i;
     }
     for (i = 0;i < 5;i = i++) {
        ("find i " + i).print();
        assertEqual(sf.sortedFind(i), i);
        assertEqual(sf.sortedFind(i, true), i);
     }
     for (i = -10;i < 0;i = i++) {
        assertNull(sf.sortedFind(i));
     }
     
     for (i = 6;i < 10;i = i++) {
        assertNull(sf.sortedFind(i));
     }
     
     for (i = 0;i < 5;i = i++) {
        sf[i] = i * 2;
     }
     for (i = 0;i < 5;i = i++) {
        ("find i " + i).print();
        assertEqual(sf.sortedFind(i * 2), i);
        assertEqual(sf.sortedFind(i * 2, true), i);
     }
     
     assertNull(sf.sortedFind(5));
     
     assertNull(sf.sortedFind(-10, true));
     assertEqual(sf.sortedFind(1, true), 0);
     assertEqual(sf.sortedFind(3, true), 1);
     assertEqual(sf.sortedFind(5, true), 2);
     assertEqual(sf.sortedFind(7, true), 3);
     assertEqual(sf.sortedFind(9, true), 4);
     assertEqual(sf.sortedFind(10, true), 4);
     
   }
   
   main() {
      ("Test:BaseTest:Array:main").print();
      more();
      mergeSort();
      sortedFind();
      //return(self);
      
      Array tcr = Array.new(1);
      Array tap = tcr.create();
      assertEquals(tcr.length, tap.length);
      tap[0] = "Hi";
      assertEquals(tap[0], "Hi");
      assertTrue(undef(tap[1]));
      tcr[0] = "There";
      tap = tap + tcr;
      assertTrue(undef(tap[2]));
      assertEquals(tap[0], "Hi");
      assertEquals(tap[1], "There");
      
      Array ta = Array.new(10);
      ta.put(2, "EE");
      assertEquals(ta[2], "EE");
      
      var uux = Array.new(5);
      uux.put(0, "Hi");
      assertEquals(uux[0], "Hi");
      
      Int x = 0;
      for (var i = uux.iterator;i.hasNext;;) {
         i.next;
         x = x++;
      }
      
      assertEquals(x, 5);
      
      for (i = 0;i < uux.length;i = i++;) {
         uux.put(i, i.copy()); 
      }
      var two = uux.copy();
      for (x = 0;x < uux.length;x = x++;) {
         assertEquals(uux.get(x), two.get(x));
      }
      two.put(3, 9);
      assertNotEquals(two[3], uux[3]);
      assertEquals(two, two);
      assertFalse(two != two);
      
      Array ts;
      var v;
      
      ts = Array.new(10);
      ts[0] = 6;
      ts[1] = 8;
      ts[2] = 3;
      ts[3] = 2;
      ts[4] = 9;
      ts[5] = 7;
      ts[6] = 5;
      ts[7] = 0;
      ts[8] = 1;
      ts[9] = 4;
      ts.sortInPlace();
      foreach (v in ts) { v.print(); }
      for (i = 0;i < ts.length;i = i++) { 
         assertEquals(ts[i], i);
      }
      
   }
   
}

use Test:CREComPar;

class CREComPar { }

use Test:CREComp;

class CREComp(CREComPar) {
   
   more(Logic:Bool yin) CREComp { }
   
   yo() CREComp { }
}

use System:Test:Extendable;

use System:Test:OutExtending;

class OutExtending(Extendable) {

   new() self {
      properties {
         var prop2a;
      }
   }
   
   bcall() { propa.print(); }
   
   ccall() {  }
}

