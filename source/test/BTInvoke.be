// Copyright 2006 Craig Welch
//
// Licensed under the MIT license. See LICENSE.txt file in the project root 
// for full license information.

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
     auto o = Object.new();
     assertTrue(o.fieldNames.size == 0);
     auto hf = HasFields.new();
     assertTrue(hf.fieldNames.size == 2);
     assertTrue(hf.fieldNames[0] == "hi");
     assertTrue(hf.fieldNames[1] == "there");
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

