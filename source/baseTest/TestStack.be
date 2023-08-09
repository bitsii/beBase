// Copyright 2016 The Bennt Authors. All rights reserved.
// Use of this source code is governed by the BSD-3-Clause
// license that can be found in the LICENSE file.

use Container:Stack;
use Container:Queue;
use Math:Int;

class Test:TestStack {
   
   main() {
      //return(testStack());
      return(testQueue());
   }
   
   testStack() {
      any uux = Stack.new();
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
      any a;
      any b;
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

