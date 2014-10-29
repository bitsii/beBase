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
use Time:Interval;
use Time:Sleep;

use Test:BaseTest;
use Test:Failure;

class Test:BaseTest:Time(BaseTest) {
   
   main() {
      ("Test:BaseTest:Time:main").print();
      //testInterval();
      testIntervalNow();
      //testSleep();
   }
   
   testIntervalNow() {
      Interval.now().print();
      Interval.now().toStringMinutes().print();
   }
   
   testSleep() {
        Interval start = Interval.now();
        start.print();
        ("will sleep 5 secs").print();
        Time:Sleep.sleepSeconds(5);
        Interval end = Interval.now();
        end.print();
        (end - start).print();
   }
   
   testInterval() {
      ("Test:BaseTest:Time:testInterval").print();
      Interval i1 = Interval.new(500, 40);
      i1.print();
      Interval i2 = Interval.new(700, 20);
      i2.print();
      ("add").print();
      Interval i3 = i1 + i2;
      i3.print();
      assertEquals(i3.secs, 1200);
      assertEquals(i3.millis, 60);
      i3 = i1 - i2;
      i3.print();
      assertEquals(i3.secs, 0 - 199);
      assertEquals(i3.millis, 0 - 980);
      i3 = i2 - i1;
      i3.print();
      assertEquals(i3.secs, 199);
      assertEquals(i3.millis, 980);
      
      i3.secs = i1.secs;
      i3.millis = i1.millis;
      
      i3.addDays(2);
      i3.addHours(2);
      
      i3.print();
      
      i3.subtractHours(2);
      i3.subtractDays(2);
      
      i3.print();
      
      assertEquals(i3.secs, 500);
      assertEquals(i3.millis, 40);
      
      i3.secs = i3.secs - 100;
      i3.millis = i3.millis - 20;
      
      i3.print();
      
      assertEquals(i3.secs, 400);
      assertEquals(i3.millis, 20);
      
      i3.subtractSeconds(100);
      i3.subtractMilliseconds(20);
      
      i3.print();
      
      assertEquals(i3.secs, 300);
      assertEquals(i3.millis, 0);
      
      i3.addSeconds(100);
      i3.addMilliseconds(20);
      
      i3.print();
      
      assertEquals(i3.secs, 400);
      assertEquals(i3.millis, 20);
      
      i1 = Interval.new(500, 40);
      i2 = Interval.new(700, 20);
      
      i1.print();
      i2.print();
      
      assertTrue(i2 > i1);
      
      assertFalse(i1 > i2);
      
      assertTrue(i2 >= i1);
      
      assertFalse(i1 >= i2);
      
      assertFalse(i2 < i1);
      
      assertTrue(i1 < i2);
      
      assertFalse(i2 <= i1);
      
      assertTrue(i1 <= i2);
      
      assertFalse(i1 == i2);
      
      assertTrue(i1 == i1);
      
      assertTrue(i1 != i2);
   }
   
}

