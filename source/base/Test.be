/*
 * Copyright (c) 2006-2023, the Brace Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

import System:Parameters;

import Test:Assertions;
import Test:Failure;
import Test:RunMethods;

class Failure (System:Exception) {
   
   new(descr) self {
      super.new(descr);
   }
}

class Assertions {

   create() self { }
   
   default() self {
      
   }
   assertHas(v1, v2) {
     if (v1.contains(v2)!) {
      String msg = "Value which should have another value does not";
      if (def(v1) && def(v2)) {
        msg += " haver: " += v1 += " havee: " += v2;
      }
      throw(Failure.new(msg));
     }
   }
   assertNotHas(v1, v2) {
     if (v1.contains(v2)) {
      String msg = "Value which should not have another value does";
      if (def(v1) && def(v2)) {
        msg += " haver: " += v1 += " havee: " += v2;
      }
      throw(Failure.new(msg));
     }
   }
   assertEquals(v1, v2) {
      return(assertEqual(v1, v2));
   }
   assertNotEquals(v1, v2) {
      return(assertNotEqual(v1, v2));
   }
   assertEqual(v1, v2) {
     if (undef(v1)) {
       throw(Failure.new("Values which must be EQUAL are not, first value is null."));
     }
      if (v1 != v2) {
         if (def(v1)) {
            String v1v = v1.toString();
         } else {
            v1v = "|null|";
         }
         if (def(v2)) {
            String v2v = v2.toString();
         } else {
            v2v = "|null|";
         }
         throw(Failure.new("Values which must be EQUAL are not, " + v1v + " " + v2v));
      }
   }
   assertNotEqual(v1, v2) {
      if (v1 == v2) {
         throw(Failure.new("Values which must be UNEQUAL are not"));
      }
   }
   assertNull(v) {
      if (def(v)) {
         throw(Failure.new("Value which must be NULL is not"));
      }
   }
   assertIsNull(v) {
      if (def(v)) {
         throw(Failure.new("Value which must be NULL is not"));
      }
   }
   assertNotNull(v) {
      if (undef(v)) {
         throw(Failure.new("Value which must be NOT NULL is not"));
      }
   }
   assertTrue(v) {
      if (v!) {
         throw(Failure.new("Value which must be TRUE is not"));
      }
   }
   assertFalse(v) {
      if (v) {
         throw(Failure.new("Value which must be FALSE is not"));
      }
   }
}

/*
RunMethods {
   
   main(List _args, Parameters _params) {
      if (can("argsSet", 1)) {
         dyn aset = self;
         aset.args = _args;
      }
      if (can("paramsSet", 1)) {
         dyn pset = self;
         pset.params = _params;
      }
   }

}
*/
