/*
Copyright 2006 Craig Welch
All rights reserved.

Developed by:

    Craig Welch

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal with
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

    * Redistributions of source code must retain the above copyright notice,
      this list of conditions and the following disclaimers.

    * Redistributions in binary form must reproduce the above copyright notice,
      this list of conditions and the following disclaimers in the
      documentation and/or other materials provided with the distribution.

    * Neither the name of the Software nor the names of its contributors may be used 
      to endorse or promote products derived from this Software without specific
      prior written permission.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
CONTRIBUTORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS WITH THE
SOFTWARE.
*/

use Container:Array;
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


use IO:Log;
use IO:Logs;
use IO:LogLevels;

class Test:BaseTest:Log(BaseTest) {
   
   main() {
         ("Test:BaseTest:Log:main").print();
         String comp1 = String.new();
         String app1 = String.new();
         String nl = Text:Strings.new().newline;
         
         Log log1 = Log.new();
         log1.clearAppenders();
         log1.addAppender(app1);
         //log1.level = LogLevels.new().warn;
         
         log1.debug("NoOutput");
         log1.warn("Output");
         comp1 += "Output" += nl;
         assertEquals(comp1, app1);
         
         Log log2 = Log.new();
         Logs logs = Logs.new();
         logs["test"] = log2;
         Log log3 = logs["test"];
         assertEquals(log2, log3);
         
         Log log4 = logs["not"];
         assertNotEquals(log4, log3);
         
         Log log = log1;
         comp1 = app1.copy();
         try {
            throwHereForStack();
         } catch (var e) {
            log.log(0, "Caught Exception " + e.toString());
         }
         assertNotEquals(comp1, app1);
         
         "Should now output something".print();
         log2.warn("SOMETHING");
         "output something done".print();
   }
   
   throwHereForStack() {
      if (true) {
      throw(System:Exception.new("Thrown from here"));
      }
   }
   
}

use Container:Array;
class Test:BaseTest:Parameters(BaseTest) {
   
   process(String arg) {
      return(arg.swap("B", "A"));
   }
   
   main() {
      ("Test:BaseTest:Parameters:main").print();
      Array vargs = Array.new(6);
      vargs[0] = "-bflag";
      vargs[1] = "--skey";
      vargs[2] = "svalue";
      vargs[3] = "sarg";
      vargs[4] = "-bflag2";
      vargs[5] = "sargB2";
      Parameters p = Parameters.new(vargs);
      assertTrue(p.isTrue("bflag"));
      assertFalse(p.isTrue("noflag"));
      assertEquals(p["skey"].first, "svalue");
      assertTrue(p.isTrue("bflag2"));
      Array v = p.ordered;
      assertEquals(v[0], "sarg");
      assertEquals(v[1], "sargB2");
      p.addFile(IO:File.new("test/inputs/params.txt"));
      assertTrue(p.isTrue("ftrue"));
      assertEquals(p["farg1"].first, "fvalue1");
      assertEquals(v[2], "slick");
      assertEquals("Default", p.get("MyDefault", "Default").first);
      p.preProcessor = self;
      assertEquals(v[1], "sargA2");
      
      vargs = Array.new(6);
      vargs[0] = "-yo";
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
        foreach (var carg in cargs) {
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

