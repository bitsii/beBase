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
import IO:File;

class Test:TestProcess{
   
   main() {
      return(TestProcess());
   }
   
   TestProcess() {
      dyn cnt = 0;
      dyn ei = System:Process.new();
      ei.numArgs.print();
      ei.execName.print();
      for (dyn i = ei.args.iterator;i.hasNext;;) {
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

