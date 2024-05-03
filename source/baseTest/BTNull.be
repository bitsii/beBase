/*
 * Copyright (c) 2016-2023, the Bennt Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

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

