// Copyright 2006 Craig Welch
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

use Container:Array;

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
      
      Array n = Array.new(5);
      
      Function:MapProxy p = Function:MapProxy.new(self, "one");
      
      Mapper.map(n, p);
      
      p.callName = "addOne";
      Mapper.map(n, p);
      
      p.callName = "printOne";
      Mapper.map(n, p);
      
      n[3].print();
      assertEquals(n[3], 2);
      
      p.callName = "addOne";
      Array n2 = Mapper.mapCopy(n, p);
      
      assertEquals(n2[4], 3);
      assertEquals(n[4], 2);
   }
   
   one(x) {
      return(1);
   }
   
   addOne(x) {
      return(x + 1);
   }
   
   printOne(x) {
      x.print();
      return(x);
   }
}
