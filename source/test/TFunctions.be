// Copyright 2006 Craig Welch
//
// Licensed under the MIT license. See LICENSE.txt file in the project root 
// for full license information.

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
      
      List n = List.new(5);
      
      auto p = getMethod("one");
      
      Mapper.map(n, p);
      
      p = getMethod("addOne");
      Mapper.map(n, p);
      
      p = getMethod("printOne");
      Mapper.map(n, p);
      
      n[3].print();
      assertEquals(n[3], 2);
      
      p = getMethod("addOne");
      List n2 = Mapper.mapCopy(n, p);
      
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
