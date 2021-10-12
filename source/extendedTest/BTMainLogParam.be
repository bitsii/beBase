// Copyright 2006 The Brace Authors. All rights reserved.
// Use of this source code is governed by the BSD-3-Clause
// license that can be found in the LICENSE file.

use Container:List;
use System:Parameters;
use Text:String;
use Text:String;
use Math:Int;

use Test:BaseTest;
use Test:Assertions;
use Test:Failure;

class Test:BaseTest:Main(BaseTest) {
   
   main() {
         ("Test:BaseTest:Main:main").print();
   }
}

class Test:BaseTest:System(BaseTest) {
   
   main() {
      System:Random rand = System:Random.new();
      
      Int r = Int.new();
      rand.getInt(r).print();
      
      //can't always be the same
      Bool worked = false;
      Int dr = Int.new();
      for (Int i = 0;i < 10000;i++=) {
        rand.getInt(dr);
        if (dr != r) {
          worked = true;
          break;
        }
      }
      
      unless(worked) {
        "random value always same".print();
        throw(System:Exception.new("never got different random number"));
      }
      
      rand.getIntMax(r, 3).print();
      assertTrue(rand.getIntMax(r, 2) < 2); 
      String a = rand.getString(255);
      String b = rand.getString(254);
      a.print();
      b.print();
      assertEqual(a.size, 255);
      assertEqual(b.size, 254);
      //assertNotEquals(a, b);
      //throw(System:Exception.new(String.new().addValue("A").getCode(0).toString()));
      assertEqual(String.new().addValue("A").getCode(0), 65);
      assertEqual("A".getCode(0), 65);
      "A".getCode(0).print();
   }
   
}

use Container:List;
class Test:BaseTest:Parameters(BaseTest) {
   
   process(String arg) {
      return(arg.swap("B", "A"));
   }
   
   main() {
      ("Test:BaseTest:Parameters:main").print();
      List anygs = List.new(6);
      anygs[0] = "-bflag=true";
      anygs[1] = "--skey";
      anygs[2] = "svalue";
      anygs[3] = "sarg";
      anygs[4] = "-bflag2=true";
      anygs[5] = "sargB2";
      Parameters p = Parameters.new(anygs);
      assertTrue(p.isTrue("bflag"));
      assertFalse(p.isTrue("noflag"));
      assertEquals(p["skey"].first, "svalue");
      assertTrue(p.isTrue("bflag2"));
      List v = p.ordered;
      assertEquals(v[0], "sarg");
      assertEquals(v[1], "sargB2");
      p.addFile(IO:File.new("test/inputs/params.txt"));
      assertTrue(p.isTrue("ftrue"));
      assertEquals(p["farg1"].first, "fvalue1");
      assertEquals(v[2], "slick");
      assertEquals("Default", p.get("MyDefault", "Default").first);
      p.preProcessor = self;
      assertEquals(v[1], "sargA2");
      
      anygs = List.new(6);
      anygs[0] = "-yo=true";
      anygs[1] = "-t=true";
      anygs[2] = "-f=false";
      anygs[3] = "-yippee=dodah";
      anygs[4] = "-yono=";
      anygs[5] = "hi";
      p = Parameters.new(anygs);
      assertTrue(p.isTrue("yo"));
      assertTrue(p.isTrue("t"));
      assertFalse(p.isTrue("f"));
      //("yip " + p["yippee"].first).print();
      assertEquals(p.getFirst("yippee"), "dodah");
      assertEquals(p.ordered[0], "hi");
      ("Tested newer params").print();
      
      any cargs = System:Process.args;
      if (def(cargs)) {
        ("process args not null").print();
        for (any carg in cargs) {
            ("Got process arg " + carg).print();
        }
      } else {
        ("process args null").print();
      }
      
      any execName = System:Process.execName;
      if (def(execName)) {
        ("got execName " + execName).print();
      } else {
        ("no execName").print();
      }
      
   }
}

class Test:BaseTest:Host(BaseTest) {
   
   main() {
      (self.className + ":main").print();
      System:Host.hostname.print();
   }
}

