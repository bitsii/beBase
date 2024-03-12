/*
 * Copyright (c) 2016-2023, the Brace Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

import Container:List;

import System:Parameters;
import Text:String;
import Text:String;

import Test:BaseTest;
import Test:Failure;
import Math:Int;

import Logic:Bool;

import Test:FrontCons;

class Test:FinalsNC {

  final firstDec() { }
  
  firstDec2() { }
  
  final toString() String { return("hi"); }
  
  hashGet() Math:Int { return(super.hash); }

}

final class Test:FinalsFC {

  final firstDec() { }
  
  firstDec2() { }
  
  final toString() String { return("hi"); }
  
  hashGet() Math:Int { return(super.hash); }

}

import Test:BaseTest:ParseCorners as PC;

class PC(BaseTest) {

   amtd() dyn {
   
   }
   
   tmtd() this {
     //return(PC.new()); //should fail
   }
   
   smtd() self {
      PC boo = System:Object.new().create();
      return(PC.new());
   }
   
   main() {
      print("Test:BaseTest:ParseCorners:main");
      
      Int x = 1 + 1;
      
      assertEquals(x, 2);
      
      bool y = 1 + 1 == 2;

      assertTrue("hi" != null);
      assertFalse("hi" == null);
      assertTrue(1 != null);
      assertFalse(1 == null);
      var o = System:Object.new();
      assertTrue(o != null);
      assertFalse(o == null);
      assertTrue(o == o);
      
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
   
   testA() bool {
   
      bool t = true;
      bool f = false;
      bool x;
      
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
   
   retAlt(bool x) bool {
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
      bool a = retAlt(alCa() || false);
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


