// Copyright 2006 Craig Welch
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

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
      rand.getInt(r, 3@).print();
      assertTrue(rand.getInt(r, 2@) < 2); 
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
      List vargs = List.new(6);
      vargs[0] = "-bflag=true";
      vargs[1] = "--skey";
      vargs[2] = "svalue";
      vargs[3] = "sarg";
      vargs[4] = "-bflag2=true";
      vargs[5] = "sargB2";
      Parameters p = Parameters.new(vargs);
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
      
      vargs = List.new(6);
      vargs[0] = "-yo=true";
      vargs[1] = "-t=true";
      vargs[2] = "-f=false";
      vargs[3] = "-yippee=dodah";
      vargs[4] = "-yono=";
      vargs[5] = "hi";
      p = Parameters.new(vargs);
      assertTrue(p.isTrue("yo"));
      assertTrue(p.isTrue("t"));
      assertFalse(p.isTrue("f"));
      //("yip " + p["yippee"].first).print();
      assertEquals(p.getFirst("yippee"), "dodah");
      assertEquals(p.ordered[0], "hi");
      ("Tested newer params").print();
      
      var cargs = System:Process.args;
      if (def(cargs)) {
        ("process args not null").print();
        for (var carg in cargs) {
            ("Got process arg " + carg).print();
        }
      } else {
        ("process args null").print();
      }
      
      var execName = System:Process.execName;
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

