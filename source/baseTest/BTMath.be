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

import Test:BaseTest;
import Test:Failure;
import Math:Int;
import Math:Float;

class Test:BaseTest:Int(BaseTest) {
   
   main() {
      ("Test:BaseTest:Int:main").print();
      
      //return(self);
      
      testShift();
      testTs();
      testSome();
      testMost();
      
   }
   
   testShift() {
       int i = Int.hexNew("12");
       int j = i.shiftLeft(2);
       j.toHexString().print();
       assertEqual(j, 72);
       assertEqual(i.shiftLeftValue(2), j);
       
       assertEqual(23.shiftLeft(1), 46);
       
       i = -105;
       i.shiftRight(1).print();
       assertEqual(i.shiftRight(1), -53);
       assertEqual(i.shiftRightValue(1), -53);
   }
   
   testTs() {
        0.toString().print();
        assertEqual(0.toString(), "0");
        1.toString().print();
        assertEqual(1.toString(), "1");
        12.toString().print();
        assertEqual(12.toString(), "12");
        123456.toString().print();
        assertEqual(123456.toString(), "123456");
        -1.print();
        assertEqual(-1.toString(), "-1");
        16.toString(2, 16).print();
        126.toString(1, 16).print();
        12.toString(2, 16).print();
        -14.toString(1, 16).print();
        assertEqual(12.toString(2, 16), "0C"); 
   }
   
   testSome() {
      Int.new("1").print();
      assertEqual(Int.new("1"), 1);
      
      /*
      int b = Int.new();
      String one = "1";
      one.print();
      one.length.print();
      one.getInt(0, b);
      ("b is " + b).print();
      */
      
      //-1, 1, 123
      Int.new("1").print();
      assertEqual(Int.new("1"), 1);
      
      Int.new("92").print();
      assertEqual(Int.new("92"), 92);
      
      Int.new("-25").print();
      assertEqual(Int.new("-25"), -25);
      
      assertEqual(Int.new("2048"), 2048);
      assertEqual(Int.new("-4096"), -4096);
      
      Int.hexNew("F").print();
      assertEqual(Int.hexNew("F"), 15);
      assertEqual(Int.hexNew("f"), 15);
      
   }
      
      
   testMost() {
      dyn uux = 1;
      dyn uuy = 2;
      
      int ttx = 1;
      int tty = 2;
      
      assertEquals(uux + uuy, 3);
      assertEquals(ttx + tty, 3);
      assertTrue(ttx < tty);
      assertTrue(tty > ttx);
      assertNotEquals(ttx, tty);
      assertEquals(uuy - uux, 1);
      assertEquals(tty - ttx, 1);     
      
      dyn uuz = Int.new("4");
      
      assertEquals(uuz, 4);
      
      dyn uuw = uuz.copy();
      
      assertEquals(uuw, uuz);
      
      uuz = uuz++;
      
      assertNotEquals(uuw, uuz);
      
      assertEquals(2.power(0), 1);
      assertEquals(2.power(2), 4);
      assertEquals(2.power(3), 8);
      
      assertEquals(2, (0 - 2).abs());

      //999.print();
      assertEquals(997.toString(), 997.toString());
      
   }
}

class Test:BaseTest:Float(BaseTest) {
   
   main() {
      ("Test:BaseTest:Float:main").print();
      dyn uux = 1.5;
      dyn uuy = 2.5;
      
      Float ttx = 1.5;
      Float tty = 2.5;
      
      assertEquals(uux + uuy, 4.0);
      assertEquals(ttx + tty, 4.0);
      assertTrue(ttx < tty);
      assertTrue(tty > ttx);
      assertNotEquals(ttx, tty);
      assertEquals(uuy - uux, 1.0);
      assertEquals(tty - ttx, 1.0);  
      
      assertEquals(1.0, Float.new("1"));
      assertEquals(1.0, Float.new("1."));
      assertEquals(0.1, Float.new(".1"));
      
      uuz = Float.new("-2.4");
      
      assertEquals(uuz, 0.0 - 2.4);   
      
      dyn uuz = Float.new("4.5");
      
      assertEquals(uuz, 4.5);
      
      dyn uuw = uuz.copy();
      
      assertEquals(uuw, uuz);
      
      assertEquals(ttx * tty, 3.75);
      assertEquals(2.5 / 2.0, 1.25);
      assertEquals(2.9++, 3.9);
      2.9.print();
   }
}

