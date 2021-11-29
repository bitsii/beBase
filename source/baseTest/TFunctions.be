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
use Function:Mapper;

class Tests:Function(BaseTest) {
   main() {
      ("Tests:Function.main").print();
      
      afunc();
      
      List n = List.new(5);
      
      auto p = Method.new(self, "one", 1);
      
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
