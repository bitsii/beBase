// Copyright 2016 The Brace Authors. All rights reserved.
// Use of this source code is governed by the BSD-3-Clause
// license that can be found in the LICENSE file.

use Container:List;

use System:Parameters;
use Text:String;
use Text:String;

use Test:BaseTest;
use Test:Failure;
use Math:Int;

use Logic:Bool;

use Test:FrontCons;

use Container:LinkedList;
use IO:File;

use Test:InheritFrom;

class Test:SecondTest {
   
   main() {
      ("SecondTest:main").print();
      Test:CallCloseCall.callCloseCall();
      Test:SecondTest:InheritRefProp.refHi();
     }
}
     
class Test:SecondTest:InheritTo(InheritFrom) {

   //new() self { fields {
   //any hi;
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
