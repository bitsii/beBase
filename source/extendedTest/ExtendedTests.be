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

use Test:BaseTest;
use Test:Assertions;
use Test:Failure;



class Test:ExtendedTest:EC(BaseTest) {
   
   main() {
     //try {
       innerMain();
     //} catch (var e) {
     //  if (def(e)) {
     //   e.print();
     //   throw(e);
     //  } else {
     //   throw(System:Exception.new("Failed with null exception"));
     //  }
     //}
   }
   
   innerMain() {
   
      ("Test:ExtendedTest:Ec:main").print();
   
      //now done properly by runtime
      //System:Process.new().platformSet(System:CurrentPlatform.new().setName("mswin"));
      
      //this is manual...
      Array args = System:Process.new().args;
      if (def(args)) {
          foreach (String arg in args) {
            ("Running test  " + arg).print();
            //getInstance(arg).new().main();
          }
      }
      
      if (args.isEmpty!) {
        "Had args, ran tests from args, returning".print();
        return(self);
      }
   
      Test:BaseTest:All.new().main();
      
      

      //try {
      //Test:ExtendedTest:All.new().main();
      
      //works for all
      
      BaseTest:Main.new().main(); 
      Tests:Function.new().main();
      Tests:TestJson.new().main();
      BaseTest:Template.new().main();
      BaseTest:Encode.new().main();
      BaseTest:Text.new().main();
      BaseTest:Serialize.new().main();
      BaseTest:Serialize.new().dirStoreTest();//run here b/c can't be run concurrently, and main is
      //later run concurrently
      
      
      //works for jv, cs
      //BaseTest:Misc.new().main(); //js needs to check types for assignments where called for
      
      //io
      BaseTest:IO.new().main();
      //BaseTest:Log.new().main(); 
      
      //need to get
      BaseTest:Parameters.new().main(); 
         
      BaseTest:Time.new().main();
      
      ifEmit(jv, cs) {
        BaseTest:System.new().main(); //random not impl for all
        testSha256();
        testThreads();
        testLocks();
      }
      
      //} catch (var e) { 
        //e.print();
     //}
     
     testLog();
     
     ("Test:ExtendedTest:Ec:main completed successfully").print();
      
   }
   
   testLog() {
     Int lev = IO:Log.debug;
     IO:Log log = IO:Log.new();
     log.log(lev, "Don't see this");
     log.level = lev;
     log.log(lev, "Do see this");
   }
   
   testLocks() {
      System:Thread:Lock l = System:Thread:Lock.new();
      l.lock();
      Int i = 0;
      System:Thread a = System:Thread.new(Test:Incr.new(l, i, 20000));
      System:Thread b = System:Thread.new(Test:Incr.new(l, i, 30000));
      a.start();
      b.start();
      l.unlock();
      a.wait();
      b.wait();
      assertEqual(i, 50000);
      ("from test incr is " + i).print();
   }
   
   testThreads() {
     ("Start running some tests in threads").print();
     System:Thread a = System:Thread.new(Test:ETThreads.new()).start();
     System:Thread b = System:Thread.new(Test:ETThreads.new()).start();
     System:Thread c = System:Thread.new(Test:ETThreads.new()).start();
     ("Done start running tests in threads").print();
     
     ("Waiting for tests to finish").print();
     a.wait();
     b.wait();
     c.wait();
     ("Done waiting for tests to finish, doing it again").print();
     a.wait();
     b.wait();
     c.wait();
     ("Done waiting for tests to finish again").print();
   }
   
   testSha256() self {
      Digest:SHA256 ds = Digest:SHA256.new();
      String res = ds.digestToHex("foo");
      assertNotNull(res);
      assertEqual(res, ds.digestToHex("foo"));
      ("sha256 of foo " + res).print();
      assertEqual(res,
        "2C26B46B68FFC68FF99B453C1D30413413422D706483BFA0F98A5E886266E7AE");
   }
}

use Math:Int;

class Test:Incr {

  new(System:Thread:Lock _l, Int _toInc, Int _count) self {
    properties {
      System:Thread:Lock l = _l;
      Int toInc = _toInc;
      Int count = _count;
    }
  }
  
  main() {
    for (Int i = 0;i < count;i++=) {
      l.lock();
      toInc++=;
      l.unlock();
    }
  }

}

class Test:ETThreads {

  main() {
  
    Tests:Function.new().main();
    Tests:TestJson.new().main();
    BaseTest:Template.new().main();
    BaseTest:Encode.new().main();
    BaseTest:Text.new().main();
    BaseTest:Serialize.new().main();
  
  }

}

class Test:ExtendedTest:All(BaseTest) {
   
   
}

