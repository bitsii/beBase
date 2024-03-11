/*
 * Copyright (c) 2016-2023, the Brace Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

class Test:TestBool {
   
   main() {
      return(testBool());
   }
   
   testBool() {
      dyn t = true;
      t = t!;
      if (t) {
         "!FAILED not".print();
         return(false);
      }
      " PASSED not".print();
      
      t = true;
      dyn f = false;
      if (t == f) {
         "!FAILED equals".print();
         return(false);
      }
      " PASSED equals".print();
      dyn ts = Logic:Bool.new("true");
      if (ts) {
         " PASSED str cons".print();
      } else {
         "!FAILED str cons".print();
         return(false);
      }
      return(true);
   }
   
}

