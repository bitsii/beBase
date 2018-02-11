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
         for (Int j = 0;j < 5000000;j = j++) { //normally 50000 did 5000000 to stress with threads
            Int k = Int.new();
         }
      }
      "testGc() Done".print();
   }
   
}

