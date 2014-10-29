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

use Container:Single;
use Container:Pair;
use Container:LinkedList;
use Container:LinkedList:Node;
use Container:NodeList;
use Logic:Bool;
use Math:Int;

class Single {
   new() self {
      properties {
         var first;
      }
   }
   new(_first) self {
      first = _first;
   }
}

class Pair {
   new() self {
      properties {
         var first;
         var second;
      }
   }
   new(_first, _second) self {
      first = _first;
      second = _second;
   }
}

local class LinkedList:Node {
   
   new(_held, LinkedList _mylist) self {
   
      properties {
      
            Node prior;
            Node next;
            var held = _held;
            LinkedList mylist = _mylist;
      
      }
      
   }
   
   insertBefore(toIns) {
      toIns.prior = null;
      toIns.next = self;
      toIns.mylist = mylist;
      Node p = prior;
      prior = toIns;
      if (undef(p)) {
         //I am first
         mylist.firstNode = toIns;
      } else {
         p.next = toIns;
         toIns.prior = p;
      }
   }
   
   delete() {
      Node p = prior;
      Node n = next;
      next = null;
      prior = null;
      if (undef(p)) {
         //I am first
         mylist.firstNode = n;
         if (def(n)) {
            n.prior = null;
         } else {
            //I am also last
            mylist.lastNode = n;
         }
      } elif (undef(n)) {
         //I am last
         p.next = n;
         mylist.lastNode = p;
      } else {
         //I am surrounded
         p.next = n;
         n.prior = p;
      }
      mylist = null;
   }
   
}

local class LinkedList:AwareNode(LinkedList:Node) {
   
   new(_held, LinkedList _mylist) self {
      held = _held;
      held.heldBy = self;
      mylist = _mylist;
   }
   
   heldSet(_held) {
      held = _held;
      held.heldBy = self;
   }
}

local class NodeList(LinkedList) {
   
   newNode(toHold) LinkedList:Node {
      return(LinkedList:AwareNode.new(toHold, self));
   }
   
}

local class LinkedList {
   
   new() self {
      
      properties {
         Node firstNode;
         Node lastNode;
      }
      
   }
   
   newNode(toHold) LinkedList:Node {
      return(LinkedList:Node.new(toHold, self));
   }
   
   copy() {
      // I don't think this works
      LinkedList other = create();
      LinkedList:Iterator iter = self.iterator;
      Node f = iter.nextNode;
      if (undef(f)) {
         return(other);
      }
      Node fnode;
      Node last;
      while (def(f)) {
         f = f.copy();
         if (def(last)) {
            last.next = f;
            //f.prior = last;
         }
         if (undef(fnode)) {
            fnode = f;
         }
         last = f;
         f = iter.nextNode;
      }
      other.firstNode = fnode;
      other.lastNode = last;
      return(other);
   }
   
   appendNode(node) {
      node.next = null;
      if (def(lastNode)) {
         node.prior = lastNode;
         lastNode.next = node;
         lastNode = node;
      } else {
         lastNode = node;
         firstNode = node;
      }
   }
   
   prependNode(node) {
      node.next = null;
      if (def(firstNode)) {
         node.next = firstNode;
         firstNode.prior = node;
         firstNode = node;
      } else {
         lastNode = node;
         firstNode = node;
      }
   }
   
   deleteNode(node) {
      node.delete();
   }
   
   insertBeforeNode(toIns, node) {
      node.insertBefore(toIns);
   }
   
   get(Int pos) {
      if (pos == 0) {
         return(firstNode.held);
      }
      Int i = 0;
      for (LinkedList:Iterator iter = self.iterator; iter.hasNext;;) {
         if (i < pos) {
            iter.next;
         } else {
            break;
         }
         i = i++;
      }
      if (i != pos) {
         return(null);
      }
      return(iter.next);
   }
   
   put(Int pos, value) {
      pos = pos + 1;
      Int i = 0;
      for (LinkedList:Iterator iter = self.iterator; iter.hasNext;;) {
         if (i < pos) {
            iter.next;
         } else {
            break;
         }
         i = i++;
      }
      if (i != pos) {
         return(false);
      }
      return(iter.currentSet(value));
   }
   
   firstGet() {
      if (undef(firstNode)) { return(null); }
      return(firstNode.held);
   }
   
   secondGet() {
      if (def(firstNode) && def(firstNode.next)) {
         return(firstNode.next.held);
      }
      return(null);
   }
   
   thirdGet() {
      if (def(firstNode) && def(firstNode.next) && def(firstNode.next.next)) {
         return(firstNode.next.next.held);
      }
      return(null);
   }
   
   lastGet() {
      if (undef(lastNode)) { return(null); }
      return(lastNode.held);
   }
   
   getNode(pos) {
      if (pos == 0) {
         return(firstNode);
      }
      Int i = 0;
      for (LinkedList:Iterator iter = self.iterator; iter.hasNext;;) {
         if (i < pos) {
            iter.next;
         } else {
            break;
         }
         i = i++;
      }
      if (i != pos) {
         return(null);
      }
      return(iter.nextNode);
   }
   
   addWhole(held) {
      var nn = newNode(held);
      appendNode(nn);
   }
   
   addValue(held) {
      if (def(held) && held.sameType(self)) {
         addAll(held);
      } else {
         var nn = newNode(held);
         appendNode(nn);
      }
   }
   
   iterateAdd(val) {
      if (def(val)) {
         while (val.hasNext) {
            addValue(val.next);
         }
      }
   }
   
   addAll(val) {
      if (def(val)) {
         iterateAdd(val.iterator);
      }
   }
   
   prepend(held) {
      var nn = newNode(held);
      prependNode(nn);
   }
   
   lengthGet() Int {
      Int cnt = 0;
      for (var i = self.iterator;i.hasNext;;) {
         i.next;
         cnt = cnt++;
      }
      return(cnt);
   }
   
   sizeGet() Int {
      return(lengthGet());
   }
   
   isEmptyGet() Bool {
      if (undef(firstNode)) {
        return(true);
      }
      return(false);
   }
   
   toNodeArray() Container:Array {
      Int len = self.length;
      Container:Array toret = Container:Array.new(len);
      Int cnt = 0;
      for (LinkedList:Iterator i = self.iterator;i.hasNext;;) {
         if (cnt < len) {
            toret.put(cnt, i.nextNode);
         }
         cnt = cnt++;
      }
      return(toret);
   }
   
   toArray() Container:Array {
      Int len = self.length;
      Container:Array toret = Container:Array.new(len);
      Int cnt = 0;
      for (LinkedList:Iterator i = self.iterator;i.hasNext;;) {
         if (cnt < len) {
            toret.put(cnt, i.nextNode.held);
         }
         cnt = cnt++;
      }
      return(toret);
   }
   
   iteratorGet() {
      return(LinkedList:Iterator.new(self));
   }
   
   serializationIteratorGet() {
      return(self.iterator);
   }
   
   subList(Int start) LinkedList {
      return(subList(start, Math:Ints.max));
   }
   
   subList(Int start, Int end) LinkedList {
      LinkedList res = create();
      if (end <= start) {
         return(res);
      }
      var iter = self.iterator;
      for (Int i = 0;i < end;i = i++) {
         if (iter.hasNext!) {
            return(res);
         }
         var x = iter.next;
         if (i >= start) {
            res += x;
         }
      }
      return(res);
   }
   
   reverse() LinkedList {
      /*
      //sll
      c = h
      while notnull c
       n = c.n
       if notnull l c.n = l
       l = c
       c = n
      h = l
      
      1 2 3
          1
        2
      3
      
      //dll
      c = first
      last = c
      while notnull c
       n = c.n
       c.n = c.p
       c.p = n
       nl = c
       c = n
      first = nl
      
      1 2 3
      
          1
        2
      3
      
      */
      
      Node current = firstNode;
      lastNode = current;
      while (def(current)) {
         Node next = current.next;
         current.next = current.prior;
         current.prior = next;
         Node nextLast = current;
         current = next;
      }
      firstNode = nextLast;
   }
   
}

local class LinkedList:Iterator {
   
   new(LinkedList l) LinkedList:Iterator {
   
      properties {
         LinkedList list = l;
         Node currNode;
         Bool starting = true;
      }
      
   }
   
   containerGet() LinkedList {
      return(list);
   }
   
   hasCurrentGet() {
      if (undef(currNode)) {
         return(false);
      }
      return(true);
   }
   
   hasNextGet() {
      if (starting) {
         if (undef(list.firstNode)) {
            return(false);
          } else {
            return(true);
          }
      }
      if (undef(currNode) || undef(currNode.next)) {
         return(false);
      }
      return(true);
   }
   
   nextSet(value) {
      Node nxnode = self.nextNode;
      if (undef(nxnode)) {
         list += value;
         self.nextNode;
      } else {
         nxnode.held = value;
      }
   }
   
   nextNodeGet() {
      Node nxnode;
      if (starting) {
         starting = false;
         nxnode = list.firstNode;
      } else {
         if (def(currNode)) {
            nxnode = currNode.next;
         }
      }
      currNode = nxnode;
      return(currNode);
   }
   
   currentNodeGet() {
      return(currNode);
   }
   
   currentNodeSet(_currNode) {
      starting = false;
      currNode = _currNode;
   }
   
   currentGet() {
      if (undef(currNode)) {
         return(null);
      }
      return(currNode.held);
   }
   
   currentSet(x) {
      if (undef(currNode)) {
         return(false);
      }
      currNode.held = x;
      return(true);
   }
   
   nextGet() {
      Node nxnode;
      if (starting) {
         starting = false;
         nxnode = list.firstNode;
      } else {
         if (def(currNode)) {
            nxnode = currNode.next;
         }
      }
      currNode = nxnode;
      if (def(currNode)) {
         return(currNode.held);
      }
      return(currNode);
   }
   
   skip(Int multiNullCount) {
      for (Int mi = 0;mi < multiNullCount;mi = mi++) {
         self.next = null;
      }
   }

}

