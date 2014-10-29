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

use Container:Array;
use System:Utils;
use System:Parameters;
use Text:String;
use IO:ByteBuffer;
use IO:File;
use Logic:Bool;

use Math:Int;

class Utils:MungeContacts {
   
   main(Array args, Parameters params) {
      ("In Main").print();
      String inFile = params.get("inFile").first;
      String outFile = params.get("outFile").first;
      var inFileR = IO:File.new(inFile).reader.open();
      var outFileW = IO:File.new(outFile).writer.open();
      String input = inFileR.readString();
      Text:Tokenizer toki = Text:Tokenizer.new("\r\n", true);
      Container:LinkedList toks = toki.tokenize(input);
      var i = toks.iterator;
      
      while (i.hasNext) {
         String tok = i.next;
         if ((tok == "" || tok == "\r" || tok == "\n")!) {
            if (undef(name)) {
               String name = tok;
            } else {
               String num = tok;
               //("name " + name + " num " + num).print();
               String record = name + "," + name + ",,,,,,,,,,,,,,,,,,,,,,,,,* My Contacts,Mobile," + num;
               record.print();
               outFileW.write(record + "\r\n");
               name = null;
            }
         }
      }
      inFileR.close();
      outFileW.close();
      
   }
   
}

