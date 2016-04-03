// Copyright 2006 Craig Welch
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

use Container:Array;

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
   //var hi;
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
