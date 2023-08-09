// Copyright 2016 The Bennt Authors. All rights reserved.
// Use of this source code is governed by the BSD-3-Clause
// license that can be found in the LICENSE file.

class Test:TestBool {
   
   main() {
      return(testBool());
   }
   
   testBool() {
      any t = true;
      t = t!;
      if (t) {
         "!FAILED not".print();
         return(false);
      }
      " PASSED not".print();
      
      t = true;
      any f = false;
      if (t == f) {
         "!FAILED equals".print();
         return(false);
      }
      " PASSED equals".print();
      any ts = Logic:Bool.new("true");
      if (ts) {
         " PASSED str cons".print();
      } else {
         "!FAILED str cons".print();
         return(false);
      }
      return(true);
   }
   
}

