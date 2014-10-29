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

use Test:FrontCons;

class Test:BaseTest:ParseCorners(BaseTest) {
   
   main() {
      ("Test:BaseTest:ParseCorners:main").print();
      
      Int x = 1 + 1;
      
      assertEquals(x, 2);
      
      Bool y = 1 + 1 == 2;
      
      assertTrue(y);
      
      Int m = callArgRetNull(null);
      
      escapeString();
      
      Test:FunnyOrs.new().main();
      
      doConstructs();
   }

   doConstructs() {
      
      FrontCons i = FrontCons.new();
      FrontCons j = FrontCons.new();
      FrontCons k = Test:FrontCons.new();
      
      
      
      ("!!!!!!!!!!!!!!!!!!!!!!!!!! Parse i " + i).print();
      ("!!!!!!!!!!!!!!!!!!!!!!!!!! Parse j " + j).print();
      ("!!!!!!!!!!!!!!!!!!!!!!!!!! Parse k " + k).print();
   }
   
   callArgRetNull(String v) Int {
      return(null);
   }
   
   escapeString() {
      String s1 = "Hi \n there \n\tboo \n";
      //s1.print();
      
      //String s2 = "Hi \" Boo";
      //s2.print();
      //assertEquals(s2, """Hi \" Boo""");
      
      //String s3 = "\\";
      //s3.getCode(0).print();
      
      //String s4 = String.codeNew(92);
      //s4.print();
      
      String s5 = "\\\"";
      s5.print();
      
   }
   
}

class FrontCons {
}


class Test:FunnyOrs(BaseTest) {
   
   testA() Bool {
   
      Bool t = true;
      Bool f = false;
      Bool x;
      
      if (t || f) {
         "doIt".print();
      }
      
      x = t && f || f;
      x.print();
      doFo(f || f || t && f);
      if (t || t) {
         return(x || t && false);
      }
      return(true);
   
   }
   
   alCa() {
      return(true || false);
   }
   
   retAlt(Bool x) Bool {
      return(x!);
   }
   
   alCab() {
      true && true;
   }
   
   doFo(x) {
      //("X is " + x).print();
   }
   
   doFuss() {
      doFo(alCa() && false || false && false);
   }
   
   doFib() {
      alCa() || alCa() && false;
   }
   
   dooBie() {
      Bool a = retAlt(alCa() || false);
      ("AAA a is a " + a).print();
   }
   
   main() {
      assertFalse(testA());
      assertTrue(alCa());
      alCab();
      doFuss();
      dooBie();
   }
   
}


