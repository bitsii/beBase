// Copyright 2006 Craig Welch
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

use Logic:Bool;
use Text:String;

final class Bool {

   emit(jv) {
   """
   
    public boolean bevi_bool;
    public $class/Logic:Bool$(boolean bevi_bool) { this.bevi_bool = bevi_bool; }
    
   """
   }
   
   emit(cs) {
   """
   
    public bool bevi_bool;
    public $class/Logic:Bool$(bool bevi_bool) { this.bevi_bool = bevi_bool; }
    
   """
   }
   
   emit(js) {
   """
   
    be_$class/Logic:Bool$.prototype.beml_set_bevi_bool = function(bevi_bool) {
        this.bevi_bool = bevi_bool;
        return this;
    }
    
   """
   }
   
   new() self {   }
   
   new(str) Bool {
      if (str == "true") {
         return(true);
      }
      return(false);
   }
   
   checkDefNew(str) Bool {
      if (def(str) && str == "true") {
         return(true);
      }
      return(false);
   }
   
   serializeContents() Bool {
      return(false);
   }
   
   serializeToString() String {
      if (self) {
         return("1");
      }
      return("0");
   }
   
   deserializeClassNameGet() String {
      return("Logic:Bools");
   }
   
   hashGet() Math:Int {
      if (self) {
         return(1);
      }
      return(0);
   }
   
   increment() Bool {
      return(true);
   }
   
   decrement() Bool {
      return(false);
   }
   
   not() Bool {
      if (self) {
         return(false);
      }
      return(true);
   }
   
   toString() Text:String {
      if (self) {
         return("true");
      }
      return("false");
   }
   
   copy() self {
      return(self);//Bools are immutable
   }
   
}

final class Logic:Bools {

   create() self { }
   
   default() self {
      
   }
   
   forString(str) Bool {
      if (str == "true") {
         return(true);
      }
      return(false);
   }
   
   deserializeFromString(String str) {
      if (str == "1") {
         return(true);
      }
      return(false);
   }
   
}

