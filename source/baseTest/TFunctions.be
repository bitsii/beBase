/*
 * Copyright (c) 2016-2023, the Beysant Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

use Container:List;

use System:Parameters;
use Text:String;
use Text:String;

use Test:BaseTest;
use Test:Failure;
use Math:Int;
use Function:Mapper;
use System:Method;

class Tests:Function(BaseTest) {
   main() {
      ("Tests:Function.main").print();
      
      afunc();
      
      List n = List.new(5);
      
      var p = Method.new(self, "one", 1);
      
      Mapper.map(n, p);
      
      p = Method.new(self, "addOne_1");
      Mapper.map(n, p);
      
      p = Method.new(self, "printOne_1");
      
      //p = Method.new("printOne_1");
      Mapper.map(n, p);
      "gonna print n3".print();
      //return(self);
      n[3].print();
      assertEquals(n[3], 2);
      
      p = Method.new(self, "addOne", 1);
      List n2 = Mapper.mapCopy(n, p);
      
      assertEquals(n2[4], 3);
      assertEquals(n[4], 2);
   }
   
   afunc() {
   
     //useIt(~(String msg){ print("Msg " + msg); });
    
   }
   
   useIt(System:Method mtd) {
     return(mtd.apply("Hi"));
   }
   
   one(x) {
      "in ret1".print();
      return(1);
   }
   
   addOne(x) {
      return(x + 1);
   }
   
   printOne(x) {
      "in printone".print();
      x.print();
      return(x);
   }
}
