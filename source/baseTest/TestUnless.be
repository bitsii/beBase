/*
 * Copyright (c) 2016-2023, the Brace Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

import Container:List;

class Test:TestUnless {
   
   main() {
      return(testUnless());
   }
   
   testUnless() {
      unless(true) {
         "First".print();
      } else {
         "Second".print();
      }
      dyn x = 0;
      until(x == 1) {
         "Iter".print();
         x = x++;
      }
   }
   
}

