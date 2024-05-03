/*
 * Copyright (c) 2016-2023, the Bennt Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

use Math:Int;
use IO:File;

class Test:TestProcess{
   
   main() {
      return(TestProcess());
   }
   
   TestProcess() {
      any cnt = 0;
      any ei = System:Process.new();
      ei.numArgs.print();
      ei.execName.print();
      for (any i = ei.args.iterator;i.hasNext;;) {
         cnt = cnt++;
         i.next.print();
         //i.next;
      }
      if ((cnt == ei.numArgs) && (ei.execName != Text:String.new()))  {
         " PASSED TestProcess".print();
      } else {
         "!FAILED TestProcess".print();
         return(false);
      }
      return(true);
   }
   
}

