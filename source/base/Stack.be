/*
Copyright 2006 Craig Welch
All rights reserved.

Developed by:

    Craig Welch

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal with
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

    * Redistributions of source code must retain the above copyright notice,
      this list of conditions and the following disclaimers.

    * Redistributions in binary form must reproduce the above copyright notice,
      this list of conditions and the following disclaimers in the
      documentation and/or other materials provided with the distribution.

    * Neither the name of the Software nor the names of its contributors may be used 
      to endorse or promote products derived from this Software without specific
      prior written permission.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
CONTRIBUTORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS WITH THE
SOFTWARE.
*/

use Container:Stack;
use Container:Stack:Node;
use Container:Queue;
use Logic:Bool;
use Math:Int;

local class Stack:Node {

   new() self {
   
      properties {
         Node next;
         Node prior;
         var held;
      }
   
   }
   
}

/*Need trim for these and or automated way of bounding retained free nodes*/
//LIFO
class Stack {
   
   new() self {
      
      properties {
         Node top;
         Node holder;
         Int size = 0;
      }
   
   }
   
   push(item) {
      if (undef(top)) {
         if (undef(holder)) {
            top = Stack:Node.new();
         } else {
            top = holder;
            holder = null;
         }
      } elif (undef(top.next)) {
         top.next = Stack:Node.new();
         top.next.prior = top;
         top = top.next;
      } else {
         top = top.next;
      }
      top.held = item;
      size = size++;
   }
   
   pop() {
      if (undef(top)) {
         return(top);
      }
      Node last = top;
      top = top.prior;
      if (undef(top)) {
         holder = last;
      }
      if (undef(last)) {
         return(null);
      }
      var item = last.held;
      last.held = null;
      size = size--;
      return(item);
   }
   
   peek() {
      if (undef(top)) {
         return(top);
      }
      return(top.held);
   }
   
   isEmptyGet() Bool {
      return(undef(top));
   }
   
   addValue(item) {
      push(item);
   }
   
   get() {
      return(pop());
   }
   
   get(Bool pop) {
     if (pop) {
       return(pop());
     }
     return(peek());
   }
   
   put(item) {
      push(item);
   }
   
}

//FIFO
class Queue {

   new() self {
   
      properties {
         Node top; //top of queue, last of live items where items are enqueued
         Node bottom; //bottom of queue, first of live items where items are dequeued
         Node end; //top of queue where items may or may not be live, where dequeues put nodes for reuse
         Int size = 0;
      }
   
   }
   
   addValue(item) {
      enqueue(item);
   }
   
   enqueue(item) {
      if (undef(top)) {
         top = Stack:Node.new();
         end = top;
         bottom = top;
      } elif (def(bottom)) {
         if (undef(top.next)) {
            top.next = Stack:Node.new();
            top.next.prior = top;
            top = top.next;
            end = top;
         } else {
            top = top.next;
         }
      } else {
         bottom = top;
      }
      top.held = item;
      size = size++;
   }
   
   dequeue() {
      if (undef(bottom)) {
         return(null);
      }
      var item = bottom.held;
      bottom.held = null;
      if (bottom == top) {
         bottom = null;
      } else {
         //bottom cannot be end here, end is always after a bottom == top event, bottom.next is not null here
         Node last = bottom;
         bottom = bottom.next;
         last.next = null;
         last.prior = end;
         end.next = last;
         end = last;
      }
      size = size--;
      return(item);
   }
   
   isEmptyGet() Bool {
      return(undef(bottom));
   }
   
   get() {
      return(dequeue());
   }
   
   put(item) {
      return(enqueue(item));
   }
   
}

use Container:BoundedQueue as BQueue;
class BQueue(Queue) {
    new() self {
      super.new();
      vars {
        Int max = 99;
      }
    }
    enqueue(item) {
      super.enqueue(item);
      if (size > max) {
        return(dequeue());
      }
      return(null);
    }
}

use System:Test:Extendable;

class Extendable {
   new() self {
      properties {
         var propa;
         var propb;
      }
   }
   
   acall() {  }
   
   bcall() {  }
}

use System:Test:InExtending;

class InExtending(Extendable) {

   new() self {
      properties {
         var prop2a;
      }
   }
   
   bcall() { propa.print(); }
   
   ccall() {  }
}
