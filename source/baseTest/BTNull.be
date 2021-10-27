// Copyright 2016 The Brace Authors. All rights reserved.
// Use of this source code is governed by the BSD-3-Clause
// license that can be found in the LICENSE file.

use System:Parameters;
use Text:String;
use Text:String;

use Test:BaseTest;
use Test:Failure;
use Math:Int;

class Test:BaseTest:Null(BaseTest) {
   
   main() {
      ("Test:BaseTest:Null:main").print();
      
      String s;
      assertTrue(undef(s));
      assertFalse(def(s));
      s = "Defined";
      assertTrue(def(s));
      assertFalse(undef(s));
      
      //badAccess();//this is signal based and somewhat platform specific at the moment
      
      
   }
   
   badAccess() {
      Int i = null;
      i.toString();
   }
   
}

