/*
 * Copyright (c) 2016-2023, the Brace Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

class Test:TestCopy:Vars {
   
   prepare() {
      fields {
         dyn a = System:Object.new();
         dyn b = System:Object.new();
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
      
      dyn other = Test:TestCopy:Vars.new();
      other.prepare();
      dyn othercp = other.copy();
      if ((other.a == othercp.a) && (other != othercp)) {
      " PASSED testCopy other any".print();
      } else {
      "!FAILED testCopy other any".print();
      return(false);
      }
      return(true);
   }
   
}

