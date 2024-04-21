/*
 * Copyright (c) 2016-2023, the Beysant Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

class Test:TestHeq {
   
   main() {
      testHeq();
   }
   
   testHeq() {
      any s2 = self;
      any y = s2.specialHeq1();
      any x = s2.specialHeq2();
      //s2.noCallExists();//will fail
      if (x && (y!)) {
      " PASSED testHeq self id".print();
      } else {
      "!FAILED testHeq self id".print();
      return(false);
      }
      return(true);
   }
   
   specialHeq1() {
      "Call one".print();
      return(false);
   }
   
   specialHeq2() {
      "Call two".print();
      return(true);
   }
   

}

