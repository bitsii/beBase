// Copyright 2006 Craig Welch
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

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

