// Copyright 2006 The Abelii Authors. All rights reserved.
// Use of this source code is governed by the BSD-3-Clause
// license that can be found in the LICENSE file.

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

