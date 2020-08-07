// Copyright 2016 The Brace Authors. All rights reserved.
// Use of this source code is governed by the BSD-3-Clause
// license that can be found in the LICENSE file.

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

