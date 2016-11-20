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

use Container:PropertyMap;
use System:Env;

class Test:BaseTest:PropertyMap(BaseTest) {
   
   main() {
      ("Test:BaseTest:PropertyMap:main").print();
      PropertyMap p = PropertyMap.new();
      testProp(p);
      p = Env.new();
      assertNotNull(p.get("PATH"));
      p.get("PATH").print();
      
      Env e = Env.new();
      for (any kv in e) {
         ("Found " + kv.key + " = " + kv.value).print();
      }
   }
   
   testProp(PropertyMap p) {
      p.set("BOO", "HISS");
      assertEquals(p.get("BOO"), "HISS");
      p.unset("BOO");
      assertIsNull(p.get("BOO"));
   }
   
}

