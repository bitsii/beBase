/*
 * Copyright (c) 2016-2023, the Brace Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

import Math:Int;
import Logic:Bool;
import IO:File;
import Text:String;
import Text:String;
import Container:List;
import System:Parameters;

class Utility:SRep {
   
   main() {
      ("Utility:SRep:main").print();
      for (Int i = 0;i < args.length;i = i++) {
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
      dyn it = contents.iterator;
      
      File fout = File.new(pfout);
      dyn w = fout.writer.open();
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

