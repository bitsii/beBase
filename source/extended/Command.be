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

 use Text:String;
 use Logic:Bool;
 use Container:LinkedList;
 use Math:Int;
 use System:Random;
 use System:Identity;
 
use System:Command;

emit(cs) {
"""
using System;
using System.Diagnostics;
"""
}

final class Command {
   
   new(String _command) self {
      properties {
         String command = _command;
      }
   }
   
   run(String _command) Int {
      new(_command);
      return(run());
   }
   
   run() Int {
   emit(c) {
      """
/*-attr- -dec-*/
void** bevl_toRun;
void** bevl_rvali;
      """
      }
      String _command;
      Int rvali;
      
      _command = command;
      rvali = Int.new();
      
      emit(c) {
      """
      bevl_toRun = $_command&*;
      bevl_rvali = $rvali&*;
      *((BEINT*) bevl_rvali + bercps) = system(((char*) bevl_toRun[bercps]));
      """
      }
      
      emit(cs) {
      """
      
      """
      }
      
      return(rvali);
   }
}

use System:Host;

local class Host {

   create() { }
   
   default() self {
      
   }
   
   hostnameGet() String {
      //Not cached, could change
      String name;
      var r = IO:File:Reader:Command.new("hostname -s").open();
      String o = r.readString();
      r.close();
      var l = o.splitLines();
      name = l.first;
      //("Got name " + name).print();
      return(name);
   }
   
}
