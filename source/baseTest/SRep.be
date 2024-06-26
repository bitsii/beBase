/*
 * Copyright (c) 2016-2023, the Beysant Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

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
      for (Int i = 0;i < args.length;i++) {
         if (args[i] == System:Classes.className(self)) {
            changeFile(args[i + 1], args[i + 2]);
         }
      }
   }
   
   changeFile(String pfout, String pfin) {
   
      File fin = File.new(pfin);
      String contents = fin.reader.open().readString();
      fin.reader.close();
      
      Int len = contents.length;
      
      String b = String.new();
      any it = contents.iterator;
      
      File fout = File.new(pfout);
      any w = fout.writer.open();
      String ac1 = String.new();
      String ac2 = String.new();
      String ac3 = String.new();
      String s = it.next(b).toString();
      w.write(s);
      for (Int i = 1;i < len;i++) {
         s = it.next(b).toString();
         Bool doIt = false;
         if (s == " " || s == "(") {
            ac1.addValue(s);
            s = it.next(b).toString();
            i++;
            if (s == "n") {
               ac2.addValue(s);
               s = it.next(b).toString();
               i++;
               if (s == "e") {
                  ac2.addValue(s);
                  s = it.next(b).toString();
                  i++;
                  if (s == "w") {
                     ac2.addValue(s);
                     s = it.next(b).toString();
                     i++;
                     if (s == "(") {
                        ac2.addValue(s);
                        s = it.next(b).toString();
                        i++;
                        while (s != "," && s != ")") {
                           if (s != " ") {
                              ac3.addValue(s);
                           }
                           s = it.next(b).toString();
                           i++;
                        }
                        w.write(ac1.extractString());
                        w.write(ac3.extractString());
                        w.write(".new(");
                        if (s == ",") {
                           s = it.next(b).toString();
                           i++;
                           if (s == " ") {
                              s = it.next(b).toString();
                              i++;
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
            i++;
            if (s == "u") {
               ac2.addValue(s);
               s = it.next(b).toString();
               i++;
               if (s == "b") {
                  ac2.addValue(s);
                  s = it.next(b).toString();
                  i++;
               }
            }
         }
         if (ac1.length > 0) {
            w.write(ac1.extractString());
         }
         if (ac2.length > 0) {
            w.write(ac2.extractString());
         }
         w.write(s);
      }
      fout.writer.close();
   }
   
}

