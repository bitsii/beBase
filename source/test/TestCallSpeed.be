// Copyright 2016 Craig Welch
//
// Licensed under the MIT license. See LICENSE.txt file in the project root 
// for full license information.

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

