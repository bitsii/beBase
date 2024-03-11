/*
 * Copyright (c) 2016-2023, the Brace Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

class Test:TAa {
   new() self { fields {
      dyn boo;
      dyn aac;
   } }
}

class Test:TAb (Test:TAa) {
   new() self { fields {
      dyn bat;
      dyn bac;
   } }
   bacSet(_bac) {
      "bacset".print();
      bac = _bac + "x";
   }
   bacGet() {
      "bacget".print();
      return(bac + "l");
   }
}

class Test:TestAccessor {
   
   main() {
      return(testAccessor());
   }
   
   testAccessor() {
      dyn a = Test:TAa.new();
      a.booSet("Hi");
      dyn x = a.boo;
      x.print();
      a.boo = "Goo";
      a.boo.print();
      dyn b = Test:TAb.new();
      b.bac = "Hi";
      b.bac.print();
      //b.bacSet("HiAcc");
      //b.bacGet().print();
      /* 
      if (uux.get(0) == "Hi") {
      (" PASSED put, get ").print();
      } else {
      "!FAILED put, get".print();
      return(false);
      }
      */
      return(true);
   }
   
}

