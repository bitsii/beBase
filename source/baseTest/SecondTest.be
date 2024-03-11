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

import Container:LinkedList;
import IO:File;

import Test:InheritFrom;

class Test:SecondTest {
   
   main() {
      ("SecondTest:main").print();
      Test:CallCloseCall.callCloseCall();
      Test:SecondTest:InheritRefProp.refHi();
     }
}
     
class Test:SecondTest:InheritTo(InheritFrom) {

   //new() self { fields {
   //dyn hi;
   //} }
   
}

class Test:SecondTest:InheritRefProp(InheritFrom) {

   refHi() {
      ("Before assign " + hi).print();
      hi = "boo";
      ("After assign " + hi).print();
   }
   
}

class Test:CallCloseCall {

   callCloseCall() {
      Test:CloseCall cc = Test:CloseCall.new();
      cc.callMeClose();
   }
}
