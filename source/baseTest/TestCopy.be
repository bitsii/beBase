// Copyright 2016 The Bennt Authors. All rights reserved.
// Use of this source code is governed by the BSD-3-Clause
// license that can be found in the LICENSE file.

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

