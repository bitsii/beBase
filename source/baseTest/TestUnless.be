// Copyright 2016 The Bennt Authors. All rights reserved.
// Use of this source code is governed by the BSD-3-Clause
// license that can be found in the LICENSE file.

use Container:List;

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
      any x = 0;
      until(x == 1) {
         "Iter".print();
         x = x++;
      }
   }
   
}

