// Copyright 2006 Craig Welch
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

use Math:Int;
use Logic:Bool;
use IO:File;
use Text:String;
use Text:String;
use Container:List;
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
      any it = contents.iterator;
      
      File fout = File.new(pfout);
      any w = fout.writer.open();
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

