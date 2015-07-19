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

use Logic:Bool;
use Text:String;

final class Bool {

   emit(jv) {
   """
   
    public boolean bevi_bool;
    public BEC_5_4_LogicBool(boolean bevi_bool) { this.bevi_bool = bevi_bool; }
    
   """
   }
   
   emit(cs) {
   """
   
    public bool bevi_bool;
    public BEC_5_4_LogicBool(bool bevi_bool) { this.bevi_bool = bevi_bool; }
    
   """
   }
   
   emit(js) {
   """
   
    be_BEL_4_Base_BEC_5_4_LogicBool.prototype.beml_set_bevi_bool = function(bevi_bool) {
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
   
   copy() {
      return(self);//Bools are immutable
   }
   
}

final class Logic:Bools {

   create() { }
   
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

