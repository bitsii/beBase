/*
 * Copyright (c) 2016-2023, the Brace Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

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
      for (Int i = 0;i < 200;i++) {
         for (Int j = 0;j < 50000;j++) {
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
      i++;
   }
}

