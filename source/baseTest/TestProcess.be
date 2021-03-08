// Copyright 2016 The Abelii Authors. All rights reserved.
// Use of this source code is governed by the BSD-3-Clause
// license that can be found in the LICENSE file.

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

