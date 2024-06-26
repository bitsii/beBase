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
use Text:String;
use Logic:Bool;
use Container:Map;
use Container:LinkedList;

class Test:TestFindDup {
   
   main() {
      any x = self;
      aa("3");
      bB("4");
      x.aa("1");
      x.bB("2");
      //return(TestFindDup());
   }
   
   aa(String x) {
      ("aa " + x).print();
   }
   
   bB(String x) {
      ("bB " + x).print();
   }
   
   TestFindDup() {
      Int i;
      LinkedList seeds = LinkedList.new();
      Int start = "A".getCode(0);
      Int end = "Z".getCode(0);
      for (i = start;i <= end;i++) {
         seeds += String.codeNew(i);
      }
      start = "a".getCode(0);
      end = "z".getCode(0);
      for (i = start;i <= end;i++) {
         seeds += String.codeNew(i);
      }
      Map bunch = Map.new();
      for (String soFar in seeds) {
         Int sh = soFar.hash;
         if (bunch.has(sh) && soFar != bunch.get(sh)) {
            (soFar + " matches " + bunch.get(sh)).print();
            return(true);
         }
         bunch.put(sh, soFar);
      }
      for (Int j = 0;j < 3;j++) {
         LinkedList ll = LinkedList.new();
         for (any x = bunch.valueIterator;x.hasNext;) {
            ll += x.next;
         }
         for (String toAdd in seeds) {
            for (x in ll) {
               soFar = x + toAdd;
               sh = soFar.hash;
               //soFar.print();
               if (bunch.has(sh) && soFar != bunch.get(sh)) {
                  (soFar + " matches " + bunch.get(sh)).print();
                  return(true);
               }
               bunch.put(sh, soFar);
            }
         }
      }
      "NotFound".print();
   }
}

