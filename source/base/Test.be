/*
Copyright 2006 Craig Welch
All rights reserved.

Developed by:

    Craig Welch

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal with
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

    * Redistributions of source code must retain the above copyright notice,
      this list of conditions and the following disclaimers.

    * Redistributions in binary form must reproduce the above copyright notice,
      this list of conditions and the following disclaimers in the
      documentation and/or other materials provided with the distribution.

    * Neither the name of the Software nor the names of its contributors may be used 
      to endorse or promote products derived from this Software without specific
      prior written permission.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
CONTRIBUTORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS WITH THE
SOFTWARE.
*/

use Container:Array;
use System:Parameters;
use Text:String;
use Text:String;

use Test:Assertions;
use Test:Failure;
use Test:RunMethods;

class Failure (System:Exception) {
   
   new(descr) self {
      super.new(descr);
   }
}

class Assertions {

   create() { }
   
   default() self {
      
   }
   assertHas(v1, v2) {
     if (v1.has(v2)!) {
      String msg = "Value which should have another value does not";
      if (def(v1) && def(v2)) {
        msg += " haver: " += v1 += " havee: " += v2;
      }
      throw(Failure.new(msg));
     }
   }
   assertNotHas(v1, v2) {
     if (v1.has(v2)) {
      String msg = "Value which should not have another value does";
      if (def(v1) && def(v2)) {
        msg += " haver: " += v1 += " havee: " += v2;
      }
      throw(Failure.new(msg));
     }
   }
   assertEquals(v1, v2) {
      if (v1 != v2) {
         throw(Failure.new("Values which must be EQUAL are not"));
      }
   }
   assertNotEquals(v1, v2) {
      if (v1 == v2) {
         throw(Failure.new("Values which must be UNEQUAL are not"));
      }
   }
   assertEqual(v1, v2) {
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
   
   main(Array _args, Parameters _params) {
      if (can("argsSet", 1)) {
         var aset = self;
         aset.args = _args;
      }
      if (can("paramsSet", 1)) {
         var pset = self;
         pset.params = _params;
      }
   }

}
*/
