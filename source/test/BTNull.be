// Copyright 2006 Craig Welch
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

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
      assertTrue(undefined(s));
      assertFalse(defined(s));
      s = "Defined";
      assertTrue(def(s));
      assertFalse(undef(s));
      assertTrue(defined(s));
      assertFalse(undefined(s));
      
      //badAccess();//this is signal based and somewhat platform specific at the moment
      
      
   }
   
   badAccess() {
      Int i = null;
      i.toString();
   }
   
}

