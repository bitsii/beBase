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

use Math:Int;
use Logic:Bool;
use IO:File;
use Text:String;
use Text:String;
use Container:Array;
use System:Parameters;

class Utility:SRep {
   
   main() {
      ("Utility:SRep:main").print();
      for (Int i = 0;i < args.length;i = i++) {
         if (args[i] == self.className) {
            changeFile(args[i + 1], args[i + 2]);
         }
      }
   }
   
   changeFile(String pfout, String pfin) {
   
      File fin = File.new(pfin);
      String contents = fin.reader.open().readString();
      fin.reader.close();
      
      Int len = contents.size;
      
      String b = String.new();
      var it = contents.iterator;
      
      File fout = File.new(pfout);
      var w = fout.writer.open();
      String ac1 = String.new();
      String ac2 = String.new();
      String ac3 = String.new();
      String s = it.next(b).toString();
      w.write(s);
      for (Int i = 1;i < len;i = i++) {
         s = it.next(b).toString();
         Bool doIt = false;
         if (s == " " || s == "(") {
            ac1.addValue(s);
            s = it.next(b).toString();
            i = i++;
            if (s == "n") {
               ac2.addValue(s);
               s = it.next(b).toString();
               i = i++;
               if (s == "e") {
                  ac2.addValue(s);
                  s = it.next(b).toString();
                  i = i++;
                  if (s == "w") {
                     ac2.addValue(s);
                     s = it.next(b).toString();
                     i = i++;
                     if (s == "(") {
                        ac2.addValue(s);
                        s = it.next(b).toString();
                        i = i++;
                        while (s != "," && s != ")") {
                           if (s != " ") {
                              ac3.addValue(s);
                           }
                           s = it.next(b).toString();
                           i = i++;
                        }
                        w.write(ac1.extractString());
                        w.write(ac3.extractString());
                        w.write(".new(");
                        if (s == ",") {
                           s = it.next(b).toString();
                           i = i++;
                           if (s == " ") {
                              s = it.next(b).toString();
                              i = i++;
                           }
                        }
                        ac2.extractString();
                        ("Found one").print();
                        //w.write(ac1.extractString());
                        //w.write(ac2.extractString());
                     }
                  }
               }
            }
         }
         if (s == "s") {
            ac1.addValue(s);
            s = it.next(b).toString();
            i = i++;
            if (s == "u") {
               ac2.addValue(s);
               s = it.next(b).toString();
               i = i++;
               if (s == "b") {
                  ac2.addValue(s);
                  s = it.next(b).toString();
                  i = i++;
               }
            }
         }
         if (ac1.size > 0) {
            w.write(ac1.extractString());
         }
         if (ac2.size > 0) {
            w.write(ac2.extractString());
         }
         w.write(s);
      }
      fout.writer.close();
   }
   
}

