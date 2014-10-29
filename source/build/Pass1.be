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

use Container:LinkedList;
use Container:Map;
use Text:String;
use Logic:Bool;
use Math:Int;
use Build:Visit;
use Build:NamePath;
use Build:VisitError;

final class Visit:Pass1(Visit:Visitor) {

   new() self {
      properties {
         Bool print = false;
         var f;
      }
   }
   
   new(Bool _print) Visit:Pass1 {
      print = _print;
   }
   
   new(Bool _print, String _fname) Visit:Pass1 {
      print = _print;
      f = IO:File:Path.new(_fname).file.writer.open();
   }

   accept(Build:Node node) Build:Node {
      if (print) {
         if (def(f)) {
            f.write(node.toString());
            f.write(Text:Strings.new().newline);
         } else {
            node.print();
         }
      }
      return(node.nextDescend);
   }
   
}

