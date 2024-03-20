/*
 * Copyright (c) 2016-2023, the Brace Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

use Container:List;

use System:Parameters;
use Text:String;
use Text:String;

use Test:BaseTest;
use Test:Failure;
use Math:Int;

use Logic:Bool;

use Test:DirectInvoke;
use Test:HasFields;

class Test:BaseTest:Invoke(BaseTest) {
   
   main() {
      ("Test:BaseTest:Invoke:main").print();
      testDirectInvoke();
      testCan();
      testFieldNames();
      
   }
   
   testFieldNames() {
     var o = Object.new();
     assertTrue(System:Types.fieldNames(o).length == 0);
     var hf = HasFields.new();
     assertTrue(System:Types.fieldNames(hf).length == 2);
     assertTrue(System:Types.fieldNames(hf).get(0) == "hi");
     assertTrue(System:Types.fieldNames(hf).get(1) == "there");
   }
   
   testDirectInvoke() {
      any x = DirectInvoke.new();
      List diarg = List.new(2);
      diarg[0] = 3;
      diarg[1] = 2;
      assertEquals(x.invoke("addUp", diarg), 5);
   }
   
   testCan() {
      assertTrue(self.can("print", 0));
      assertFalse(self.can("boohaa", 4));
   }
   
   
}

class DirectInvoke {

   addUp(Int a, Int b) Int {
      return(a + b);
   }
   
}

class HasFields {
  new() {
    fields {
      String hi;
      String there;
    }
  }
}

