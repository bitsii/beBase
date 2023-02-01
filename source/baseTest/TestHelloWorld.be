// Copyright 2016 The Brace Authors. All rights reserved.
// Use of this source code is governed by the BSD-3-Clause
// license that can be found in the LICENSE file.

use Text:String;
use Math:Int;
use System:Object;

class Test:TestHelloWorld {
   
   main() {
      "Content-type: text/html\n\n<html><body>Hello there</body></html>".print();
      //Time:Sleep.sleepSeconds(120);
      String yo = "yo";
      String yar = "yar";
      tns(yo, yar);
      tns2(yo, yar);
   }

   tns(String yo, yar) {
     String boo;
     Int hi;
     Object there;
     emit(cc) {
     """
//struct bet { BEC_2_4_6_TextString* bevl_boo; BEC_2_4_3_MathInt* bevl_hi; };
//bes* besp = (bes*) BECS_Runtime::bevs_currentStack.bevs_hs;
     """
     }
   }

   tns2(String yo, yar) {
     String boo;
     Int hi;
     Object there;
     emit(cc) {
     """
//struct bet { BEC_2_4_6_TextString* bevl_boo; BEC_2_4_3_MathInt* bevl_hi; };
     """
     }
   }
   
}

