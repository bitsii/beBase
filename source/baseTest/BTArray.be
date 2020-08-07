// Copyright 2016 The Brace Authors. All rights reserved.
// Use of this source code is governed by the BSD-3-Clause
// license that can be found in the LICENSE file.

use Container:List;

use System:Parameters;
use Text:String;
use Text:String;

use Test:BaseTest;
use Test:Failure;
use Math:Int;

class Test:BaseTest:List(BaseTest) {
   
   mergeSort() {
      List aret = mergeSort(List.new(10));
      List vret = mergeSort(List.new(10));
   }
   
   mergeSort(List ts) List {
   
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
      
      List ts1 = ts.mergeSort();
      for (v in ts1) { if (undef(v)) { "Null".print(); } else { v.print(); } }
      for (Int i = 0;i < ts1.length;i = i++) { 
         assertEquals(ts1[i], i);
      }
      
      return(ts1);
   }
   
   more() {
      
      any uux = List.new(2);
      uux.put(0, "Hi");
      uux[1] = "There";
      "asserting on hi".print();
      assertEquals(uux[0], "Hi");
      "afterhi assert".print();
      uux.put(4, "Last");
      Int x = 0;
      for (any i = uux.iterator;i.hasNext;;) {
         i.next;
         x = x++;
      }
      
      assertEquals(x, 5);
      assertEquals(uux[0], "Hi");
      assertEquals(uux[1], "There");
      assertEquals(uux[4], "Last");
      any uuz = uux.copy();
      for (any j = 0;j < uux.length;j = j++) {
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
     List sf;
     Int i;
     
     sf = List.new(5);
     
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
      ("Test:BaseTest:List:main").print();
      more();
      mergeSort();
      sortedFind();
      //return(self);
      
      List tcr = List.new(1);
      List tap = tcr.create();
      assertEquals(tcr.length, tap.length);
      tap[0] = "Hi";
      assertEquals(tap[0], "Hi");
      assertTrue(undef(tap[1]));
      tcr[0] = "There";
      tap = tap + tcr;
      assertTrue(undef(tap[2]));
      assertEquals(tap[0], "Hi");
      assertEquals(tap[1], "There");
      
      List ta = List.new(10);
      ta.put(2, "EE");
      assertEquals(ta[2], "EE");
      
      any uux = List.new(5);
      uux.put(0, "Hi");
      assertEquals(uux[0], "Hi");
      
      Int x = 0;
      for (any i = uux.iterator;i.hasNext;;) {
         i.next;
         x = x++;
      }
      
      assertEquals(x, 5);
      
      for (i = 0;i < uux.length;i = i++;) {
         uux.put(i, i.copy()); 
      }
      any two = uux.copy();
      for (x = 0;x < uux.length;x = x++;) {
         assertEquals(uux.get(x), two.get(x));
      }
      two.put(3, 9);
      assertNotEquals(two[3], uux[3]);
      assertEquals(two, two);
      assertFalse(two != two);
      
      List ts;
      any v;
      
      ts = List.new(10);
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
      ts.sortValue();
      for (v in ts) { v.print(); }
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
      fields {
         any prop2a;
      }
   }
   
   bcall() { propa.print(); }
   
   ccall() {  }
}

