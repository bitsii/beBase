// Copyright 2016 Craig Welch
//
// Licensed under the MIT license. See LICENSE.txt file in the project root 
// for full license information.

class Test:TestCopy:Vars {
   
   prepare() {
      fields {
         any a = System:Object.new();
         any b = System:Object.new();
      }
   }
   
}

class Test:TestCopy {
   
   main() {
      return(testCopy());
   }
   
   testCopy() {
      if (self != copy()) {
      " PASSED testCopy self".print();
      } else {
      "!FAILED testCopy self".print();
      return(false);
      }
      
      any other = Test:TestCopy:Vars.new();
      other.prepare();
      any othercp = other.copy();
      if ((other.a == othercp.a) && (other != othercp)) {
      " PASSED testCopy other any".print();
      } else {
      "!FAILED testCopy other any".print();
      return(false);
      }
      return(true);
   }
   
}
