// Copyright 2006 The Brace Authors. All rights reserved.
// Use of this source code is governed by the BSD-3-Clause
// license that can be found in the LICENSE file.

use System:Parameters;

use Test:BaseTest;
use Test:Assertions;
use Test:Failure;

class Test:ExtendedTest:DefaultDoesLogs {
  default() {
    fields {
      IO:Log log = IO:Logs.get(self);
    }
  }
  
  doLogging() {
    log.log("Some logging from doeslogs");
  }
}

class Test:ExtendedTest:Log(BaseTest) {
  main() {
    Test:ExtendedTest:EC.testLog();
  }
}

class Test:ExtendedTest:EC(BaseTest) {
   
   main() {
     //innerMain();
     try {
       Int howManyTimes = 1;
       for (Int i = 0;i < howManyTimes;i++=) {
        innerMain();
      }
     } catch (any e) {
       if (def(e)) {
        e.print();
        throw(e);
       } else {
        ("failed null execpt").print();
        throw(System:Exception.new("Failed with null exception"));
       }
     }
   }
   
   innerMain() {
   
      ("Test:ExtendedTest:Ec:main").print();
      
      Test:BaseTest:RunCount.runCount++=;
      
      emit(cs) {
        """
        // HERES THE CLASS REPLACE
        $class/Text:String$ astring = new $class/Text:String$("hi");
        """
      }
   
      //TESTS START HERE
      
      //System:Command.new("echo hi").open().output.readString().print();
      
      //Text:String readBuffer = Text:String.new(4096);
      //Text:String readBuffer = Text:String.new(26000);
      //any toParse = IO:File:Path.apNew("source/base/Object.be");
      //any src = toParse.file.reader.open().readBuffer(readBuffer);
      //toParse.file.reader.close();
      //"got src".print();
      //src.print();
         
      //if (true) { return(null); }
      
      //now done properly by runtime
      //System:Process.new().platformSet(System:CurrentPlatform.new().setName("mswin"));
      //this is manual...
      List args = System:Process.new().args;
      if (def(args)) {
          for (String arg in args) {
            ("Running test  " + arg).print();
            createInstance(arg).new().main();
          }
          if (args.isEmpty!) {
            "Had args, ran tests from args, returning".print();
            return(self);
          }
      }
      
      "past args".print();
      
      //blarg;
      //testNullEquals();
      
      //if (true) { return(self); }
   
      Test:BaseTest:All.new().main();
      ifNotEmit(noSmap) {
      Tests:Exceptions.new().main();
      }

      //try {
      //Test:ExtendedTest:All.new().main();
      
      //works for all
      
      assertTrue(LocalUse.new().rtrue());
      Test:BaseTest:Main.new().main(); 
      Tests:Function.new().main();
      Tests:TestJson.new().main();
      Test:BaseTest:Template.new().main();
      Test:BaseTest:Encode.new().main();
      Test:BaseTest:Text.new().main();
      Test:BaseTest:Serialize.new().main();
      ifEmit(cs,jv) {
        Test:BaseTest:Serialize.new().dirStoreTest();//run here b/c can't be run concurrently, and main is
        //later run concurrently
      }
      
      
      //works for jv, cs
      //BaseTest:Misc.new().main(); //js needs to check types for assignments where called for
      
      
      Test:BaseTest:IO.new().main();
      
      Test:BaseTest:Parameters.new().main(); 
      
      Test:BaseTest:Time.new().main();
      
      ifEmit(jv,cs,js) {
      //io
      //BaseTest:Log.new().main(); 
      
      //need to get
         
      }
      
      testNullEquals();
      
      if (Test:BaseTest:RunCount.runCount < 2) {
        testLog();
      }
      testVarArgs();
      
      ifEmit(jv, cs, cc) {
        Test:BaseTest:System.new().main(); //random not impl for all
      }
      
      ifEmit(jv, cs) {
        testSha256();
        testThreads();
        testLocks();
      }
      
      ifEmit(ccPt) {
        testThreads();
        testLocks();
      }
      
      ifEmit(cc) {
        testSF();
      }
      
      //} catch (any e) { 
        //e.print();
     //}
     
     
     ("Test:ExtendedTest:Ec:main completed successfully").print();
      
   }
   
   testSF() {
    "in testSF".print();
   
   }
   
   testVarArgs() {
   
      List va = Lists.from(1, 2, 3, 4);
      assertEquals(va.size, 4);
      assertEquals(va[1], 2);
      
      Set sa = Sets.from(5, 6, 7, 8);
      assertEquals(sa.size, 4);
      assertTrue(sa.has(5));
      assertTrue(sa.has(8));
      
      Map ma = Maps.from(5, 6, 7, 8);
      assertEquals(ma[5], 6);
      assertEquals(ma[7], 8);
      assertFalse(ma.has(8));
      
      //throw(Exception.new("fail"));
   
   }
   
   testNullEquals() {
     
     System:Object o = System:Object.new();
     assertTrue(o != null);
     assertFalse(o == null);
     
     /*String s = "Hi";
     assertTrue(s != null);
     assertFalse(s == null);*/
     
     //Int i = 10;
     //assertTrue(i != null);
     //assertFalse(i == null);
     
   }
   
   testLog() {
     log = IO:Logs.get(self);
     log.log("Doing a log");
   
     Int lev = IO:Logs.error;
     IO:Log log = IO:Logs.get(self);
     log.log("Don't see this");
     log.log(lev, "Do see this");
     
     any ddl = Test:ExtendedTest:DefaultDoesLogs.new();
     ("ddl levels " + ddl.log.outputLevel + " " + ddl.log.level).print();
     assertNotEqual(ddl.log.outputLevel, ddl.log.level);
     ddl.doLogging();
     IO:Logs.turnOn(ddl);
     assertEqual(ddl.log.outputLevel, ddl.log.level);
     ("ddl levels " + ddl.log.outputLevel + " " + ddl.log.level).print();
     ddl.doLogging();
     assertEqual(ddl.log.hash, IO:Logs.get(ddl).hash);
     ("ddl hashes " + ddl.log.hash + " " + IO:Logs.get(ddl).hash).print();
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

class Test:Incr {

  new(System:Thread:Lock _l, Int _toInc, Int _count) self {
    fields {
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
    Test:BaseTest:Template.new().main();
    Test:BaseTest:Encode.new().main();
    Test:BaseTest:Text.new().main();
    Test:BaseTest:Serialize.new().main();
    Test:BaseTest:Gc.new().main(); 
  
  }

}

class Test:ExtendedTest:All(BaseTest) {
   
   
}

