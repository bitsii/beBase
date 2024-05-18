/*
 * Copyright (c) 2006-2023, the Beysant Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

use Container:Stack;
use Container:Stack:Node;
use Container:Queue;

local class Node {

   new() self {
   
      fields {
         Node next;
         Node prior;
         any held;
      }
   
   }
   
}

/*Need trim for these and or automated way of bounding retained free nodes*/
//LIFO
class Stack {
   
   new() self {
      
      fields {
         Node top;
         Node holder;
         Int length = 0;
      }
   
   }
   
   push(item) {
      if (undef(top)) {
         if (undef(holder)) {
            top = Node.new();
         } else {
            top = holder;
            holder = null;
         }
      } elseIf (undef(top.next)) {
         top.next = Node.new();
         top.next.prior = top;
         top = top.next;
      } else {
         top = top.next;
      }
      top.held = item;
      length++;
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
      any item = last.held;
      last.held = null;
      length = length - 1;
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
   
      fields {
         Node top; //top of queue, last of live items where items are enqueued
         Node bottom; //bottom of queue, first of live items where items are dequeued
         Node end; //top of queue where items may or may not be live, where dequeues put nodes for reuse
         Int length = 0;
      }
   
   }
   
   addValue(item) {
      enqueue(item);
   }
   
   enqueue(item) {
      if (undef(top)) {
         top = Node.new();
         end = top;
         bottom = top;
      } elseIf (def(bottom)) {
         if (undef(top.next)) {
            top.next = Node.new();
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
      length++;
   }
   
   dequeue() {
      if (undef(bottom)) {
         return(null);
      }
      any item = bottom.held;
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
      length = length - 1;
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
      fields {
        Int max = 99;
      }
    }
    enqueue(item) {
      super.enqueue(item);
      if (length > max) {
        dequeue();
      }
    }
}

use System:Test:Extendable;

class Extendable {
   new() self {
      fields {
         any propa;
         any propb;
      }
   }
   
   acall() {  }
   
   bcall() {  }
}

use System:Test:InExtending;

class InExtending(Extendable) {

   new() self {
      fields {
         any prop2a;
      }
   }
   
   bcall() { propa.print(); }
   
   ccall() {  }
}
