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
use Test:Failure;
use Math:Int;
use Logic:Bool;

use Container:Stack;
use Test:BaseTest:ImpliedNew;
use Test:BaseTest:ImpliedNewSingle;

local class Test:BaseTest:Calls(BaseTest) {
   
   main() {
      ("Test:BaseTest:Calls:main").print();
      Test:BaseTest:Calls:ClassWith cw = Test:BaseTest:Calls:ClassWith.new();
      assertEquals(cw.i, 20);
      //doMNDN();
      doOnceEval();
      Bool caught = false;
      try {
         var x = ImpliedNew.new();
         x.notAble();
      } catch (var e) {
         caught = true;
      }
      assertTrue(caught);
   }
   
   doMNDN() {
      var s = self;
      var res = s.noWay("BooBoo");
      var fcall = res.first;
      assertEquals(fcall.name, "noWay");
      assertEquals(fcall.args.length, 1);
      assertEquals(fcall.args[0], "BooBoo");
      assertEquals(res.second, 26);
      res = s.getMyShirt;
      assertEquals(res.first.name, "getMyShirtGet");
      assertEquals(res.first.args.length, 0);
      assertEquals(res.second, 26);
   }
   
   forward(System:ForwardCall fcall) {
      "In forward".print();
      fcall.name.print();
      fcall.args.length.print();
      foreach (var i in fcall.args) {
         ("fcall.arg " + i).print();
      }
      return(Container:Pair.new(fcall, 26));
   }
   
   doOnceEval() {
      ("Doing OnceEval").print();
      
      Int lastHash;
      for (Int i = 0; i < 2;i = i++) {
         Stack one =@ Stack.new();
         one.hash.print();
         if (undef(lastHash)) { lastHash = one.hash; }
      }
      assertEquals(lastHash, one.hash);
      
   }
   
}

local class Test:BaseTest:Calls:ClassWith {

   new() self {
      properties {
         Int i = 0;
      }
      new(20);
   }
   
   new(Int _i) Test:BaseTest:Calls:ClassWith {
      i = _i;
   }

}

class ImpliedNew {
   
   new() self { properties { String lx = "AmLx"; Int five = 5; Bool isTrue = true; } }
   
   doSomething() {
      "Doing Something".print();
   }
}

class ImpliedNewSingle {
   create() { }
   default() self {  properties { Int myProp = 1; } };
}

//Testing call handling for arg values, before at and after maxargs
class Tests:CallArgs(BaseTest) {

    new() self {
        properties {
            Int fifteen;
            Int sixteen;
            Int seventeen;
        }
        Int count = 0;
        for (Int i = 1;i <= 15;i = i++) {
            count = count + i;
        }
        fifteen = count;
        count = count + 16;
        sixteen = count;
        count = count + 17;
        seventeen = count;
    }
    
    main() {
      ("Tests:CallArgs").print();
      //typed but not optimized (final) cases
      assertEqual(fifteen(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15), fifteen);
      assertEqual(sixteen(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16), sixteen);
      assertEqual(seventeen(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17), seventeen);
            
      var x = self; //for untyped cases
      assertEqual(x.fifteen(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15), fifteen);
      assertEqual(x.sixteen(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16), sixteen);
      assertEqual(x.seventeen(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17), seventeen);
      
      Array args15 = Array.new(15);
      Array args16 = Array.new(16);
      Array args17 = Array.new(17);
      
      args15.put(0, 1);
      args15.put(1, 2);
      args15.put(2, 3);
      args15.put(3, 4);
      args15.put(4, 5);
      args15.put(5, 6);
      args15.put(6, 7);
      args15.put(7, 8);
      args15.put(8, 9);
      args15.put(9, 10);
      args15.put(10, 11);
      args15.put(11, 12);
      args15.put(12, 13);
      args15.put(13, 14);
      args15.put(14, 15);
      
      args16.put(0, 1);
      args16.put(1, 2);
      args16.put(2, 3);
      args16.put(3, 4);
      args16.put(4, 5);
      args16.put(5, 6);
      args16.put(6, 7);
      args16.put(7, 8);
      args16.put(8, 9);
      args16.put(9, 10);
      args16.put(10, 11);
      args16.put(11, 12);
      args16.put(12, 13);
      args16.put(13, 14);
      args16.put(14, 15);
      args16.put(15, 16);
      
      args17.put(0, 1);
      args17.put(1, 2);
      args17.put(2, 3);
      args17.put(3, 4);
      args17.put(4, 5);
      args17.put(5, 6);
      args17.put(6, 7);
      args17.put(7, 8);
      args17.put(8, 9);
      args17.put(9, 10);
      args17.put(10, 11);
      args17.put(11, 12);
      args17.put(12, 13);
      args17.put(13, 14);
      args17.put(14, 15);
      args17.put(15, 16);
      args17.put(16, 17);
      
    }
    
    testInvocation() {
    
      Array args15 = Array.new(15);
      Array args16 = Array.new(16);
      Array args17 = Array.new(17);
      
      args15.put(0, 1);
      args15.put(1, 2);
      args15.put(2, 3);
      args15.put(3, 4);
      args15.put(4, 5);
      args15.put(5, 6);
      args15.put(6, 7);
      args15.put(7, 8);
      args15.put(8, 9);
      args15.put(9, 10);
      args15.put(10, 11);
      args15.put(11, 12);
      args15.put(12, 13);
      args15.put(13, 14);
      args15.put(14, 15);
      
      args16.put(0, 1);
      args16.put(1, 2);
      args16.put(2, 3);
      args16.put(3, 4);
      args16.put(4, 5);
      args16.put(5, 6);
      args16.put(6, 7);
      args16.put(7, 8);
      args16.put(8, 9);
      args16.put(9, 10);
      args16.put(10, 11);
      args16.put(11, 12);
      args16.put(12, 13);
      args16.put(13, 14);
      args16.put(14, 15);
      args16.put(15, 16);
      
      args17.put(0, 1);
      args17.put(1, 2);
      args17.put(2, 3);
      args17.put(3, 4);
      args17.put(4, 5);
      args17.put(5, 6);
      args17.put(6, 7);
      args17.put(7, 8);
      args17.put(8, 9);
      args17.put(9, 10);
      args17.put(10, 11);
      args17.put(11, 12);
      args17.put(12, 13);
      args17.put(13, 14);
      args17.put(14, 15);
      args17.put(15, 16);
      args17.put(16, 17);
      
      assertEqual(invoke("fifteen", args15), fifteen);
      assertEqual(invoke("sixteen", args16), sixteen);
      assertEqual(invoke("seventeen", args17), seventeen);
      
    }

    fifteen(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15) Int {
        return (a1 + a2 + a3 + a4 + a5 + a6 + a7 + a8 + a9 + a10 + a11 + a12 + a13 + a14 + a15);
    }
    
    sixteen(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16) Int {
        return (a1 + a2 + a3 + a4 + a5 + a6 + a7 + a8 + a9 + a10 + a11 + a12 + a13 + a14 + a15 + a16);
    }
    
    seventeen(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17) Int {
        return (a1 + a2 + a3 + a4 + a5 + a6 + a7 + a8 + a9 + a10 + a11 + a12 + a13 + a14 + a15 + a16 + a17);
    }

}

final class Tests:CallArgsFinal(Tests:CallArgs) { 

    main() {
      ("Tests:CallArgsFinal").print();
      //bool with an arg is special
      Logic:Bool t = Logic:Bool.new("true");
      Logic:Bool f = Logic:Bool.new("false");
      assertTrue(t);
      assertFalse(f);
      
      //final (optimized) cases
      assertEqual(fifteen(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15), fifteen);
      assertEqual(sixteen(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16), sixteen);
      assertEqual(seventeen(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17), seventeen);
    }
    
}

class Tests:Exceptions(BaseTest) {

    main() {
      ("Tests:Exceptions").print();
      Logic:Bool caught = false;
      try {
        thrower();
      } catch (var e) {
        caught = true;
        e.print();
      }
      assertTrue(caught);
      testNEType();
      testEType();
    }
    
    thrower() {
        if (true) {
            throw(System:Exception.new("My Throw"));
        }
    }
    
    testNEType() {
        try {
            throw(NotExcept.new());
        } catch (var e) {
            if (e.sameClass(NotExcept.new())!) {
                throw(System:Exception.new("didn't get nonexcept"));
            }
            if (true) { return(self) };
        }
        if (true) {
            throw(System:Exception.new("Got no except"));
        }
    }
    
    testEType() {
        try {
            throw(AnExcept.new());
        } catch (var e) {
            if (e.sameClass(AnExcept.new())!) {
                throw(System:Exception.new("didn't get anexcept"));
            }
            if (true) { return(self); }
        }
        if (true) {
            throw(System:Exception.new("Got no except"));
        }
    }

}

use class Test:NotExcept { }

use class Test:AnExcept(System:Exception) { }

