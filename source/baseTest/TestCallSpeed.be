// Copyright 2016 The Brace Authors. All rights reserved.
// Use of this source code is governed by the BSD-3-Clause
// license that can be found in the LICENSE file.

use Container:Stack;
use Container:Queue;
use Math:Int;
use Test:Speeder;

class Test:TestCallSpeed {
   
   main() {
      testCallSpeed();
      testCallSpeed();
      testCallSpeed();
   }
   
   testCallSpeed() {
      any x = Speeder.new();
      "In TestCallSpeed()".print();
      for (Int i = 0;i < 200;i = i++) {
         for (Int j = 0;j < 50000;j = j++) {
            x.doIt();
         }
      }
      "TestCallSpeed() Done".print();
   }
   
}

class Speeder {
   new() self {
      fields {
         Int i = 0;
      }
   }
   doIt() {
      i = i++;
   }
}

