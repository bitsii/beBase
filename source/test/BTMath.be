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
use Math:Float;

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
       Int i = Int.hexNew("12");
       Int j = i.shiftLeft(2);
       j.toHexString().print();
       assertEqual(j, 72@);
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
      Int b = Int.new();
      String one = "1";
      one.print();
      one.size.print();
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
      var uux = 1;
      var uuy = 2;
      
      Int ttx = 1;
      Int tty = 2;
      
      assertEquals(uux + uuy, 3);
      assertEquals(ttx + tty, 3);
      assertTrue(ttx < tty);
      assertTrue(tty > ttx);
      assertNotEquals(ttx, tty);
      assertEquals(uuy - uux, 1);
      assertEquals(tty - ttx, 1);     
      
      var uuz = Int.new("4");
      
      assertEquals(uuz, 4);
      
      var uuw = uuz.copy();
      
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
      var uux = 1.5;
      var uuy = 2.5;
      
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
      
      var uuz = Float.new("4.5");
      
      assertEquals(uuz, 4.5);
      
      var uuw = uuz.copy();
      
      assertEquals(uuw, uuz);
      
      uuz = uuz++;
      
      assertNotEquals(uuw, uuz);
      
      assertEquals(ttx * tty, 3.75);
      assertEquals(2.5 / 2.0, 1.25);
      assertEquals(2.9++, 3.9);
      2.9.print();
   }
}

