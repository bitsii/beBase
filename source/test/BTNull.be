// Copyright 2006 Craig Welch
//
// Licensed under the MIT license. See LICENSE.txt file in the project root 
// for full license information.

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

