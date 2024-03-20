/*
 * Copyright (c) 2016-2023, the Brace Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

use Container:List;
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
      testInterval();
      testIntervalNow();
      testSleep();
   }
   
   testIntervalNow() {
      Interval.now().print();
      Interval.now().toStringMinutes().print();
      assertTrue(Interval.now().seconds > 0);
   }
   
   testSleep() {
        Interval start = Interval.now();
        start.print();
        ("will sleep").print();
        Time:Sleep.sleepMilliseconds(15);
        Interval end = Interval.now();
        end.print();
        (end - start).print();
        start.addMilliseconds(10);
        assertTrue(start < end);
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

