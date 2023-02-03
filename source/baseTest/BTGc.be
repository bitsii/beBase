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

class Test:BaseTest:Gc(BaseTest) {
   
   main() {
      ("Test:BaseTest:Gc:main").print();
      //testGc();
      //testGc();
      //testGc();
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

