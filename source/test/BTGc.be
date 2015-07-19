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

class Test:BaseTest:Gc(BaseTest) {
   
   main() {
      ("Test:BaseTest:Gc:main").print();
      testGc();
      testGc();
      testGc();
   }
   
   testGc() {
      "In testGc()".print();
      for (Int i = 0;i < 3;i = i++) {
         for (Int j = 0;j < 50000;j = j++) {
            Int k = Int.new();
         }
      }
      "testGc() Done".print();
   }
   
}

