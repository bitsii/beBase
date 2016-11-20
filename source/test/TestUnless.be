// Copyright 2016 Craig Welch
//
// Licensed under the MIT license. See LICENSE.txt file in the project root 
// for full license information.

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

