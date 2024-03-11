/*
 * Copyright (c) 2016-2023, the Brace Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

use Container:Stack;
use Container:Queue;
use Math:Int;

class Test:TestStack {
   
   main() {
      //return(testStack());
      return(testQueue());
   }
   
   testStack() {
      dyn uux = Stack.new();
      uux.push(1);
      uux.push(2);
      uux.pop().print();
      uux.push("x");
      uux.pop().print();
      uux.pop().print();
      if (undef(uux.pop())) {
         "Is null".print();
      }
      uux.push(9);
      uux.push(10);
      uux.pop().print();
      uux.pop().print();
   }
   
   testQueue() {
      Queue q = Queue.new();
      //try en/de 1
      dyn a;
      dyn b;
      Int i;
      
      q.enqueue("One");
      q.dequeue().print();
      b = q.dequeue();
      if (undef(b)) {
         "b isnull".print();
      } else {
         "b notnull".print();
      }
      
      q.enqueue("Two");
      q.dequeue().print();
      b = q.dequeue();
      if (undef(b)) {
         "b isnull".print();
      } else {
         "b notnull".print();
      }
      
      q.enqueue("Four");
      q.enqueue("Five");
      q.enqueue("Six");
      for (i = 0;i < 5;i = i++) {
         b = q.dequeue();
         if (undef(b)) {
            "b isnull".print();
         } else {
            ("b notnull, is:" + b).print();
         }
      }
      
   }
   
}

