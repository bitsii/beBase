/*
 * Copyright (c) 2006-2023, the Beysant Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

use Container:Single;
use Container:Pair;
use Container:LinkedList;
use Container:LinkedList:Node;
use Container:LinkedList:Iterator;
use Container:NodeList;

Single {
   new() self {
      {
         any first;
      }
   }
   new(_first) self {
      first = _first;
   }
}

Pair {
   new() self {
      {
         any first;
         any second;
      }
   }
   new(_first, _second) self {
      first = _first;
      second = _second;
   }
}

local Node {
   
   new(_held, LinkedList _mylist) self {
   
      {
      
            Node prior;
            Node next;
            any held = _held;
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
   
   remove() {
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
      } elseIf (undef(n)) {
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

local Container:LinkedList:AwareNode(Node) {
   
   new(_held, LinkedList _mylist) self {
      held = _held;
      held.heldBy = self;
      mylist = _mylist;
   }
   
   heldSet(_held) this {
      held = _held;
      held.heldBy = self;
   }
}

local NodeList(LinkedList) {
   
   newNode(toHold) Node {
      return(Container:LinkedList:AwareNode.new(toHold, self));
   }
   
}

local LinkedList {
   
   new() self {
      
      {
         Node firstNode;
         Node lastNode;
      }
      
   }
   
   newNode(toHold) Node {
      return(Node.new(toHold, self));
   }
   
   copy() self {
      // I don't think this works
      LinkedList other = create();
      Iterator iter = self.linkedListIterator;
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
      node.mylist = self;
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
      node.mylist = self;
   }
   
   deleteNode(node) {
      node.remove();
   }
   
   insertBeforeNode(toIns, node) {
      node.insertBefore(toIns);
   }
   
   get(Int pos) {
      Int i = 0;
      for (Iterator iter = self.linkedListIterator; iter.hasNext;;) {
         if (i < pos) {
            iter.next;
         } else {
            break;
         }
         i++;
      }
      if (i != pos) {
         return(null);
      }
      return(iter.next);
   }
   
   put(Int pos, value) {
      pos = pos + 1;
      Int i = 0;
      for (Iterator iter = self.linkedListIterator; iter.hasNext;;) {
         if (i < pos) {
            iter.next;
         } else {
            break;
         }
         i++;
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
      Int i = 0;
      for (Iterator iter = self.linkedListIterator; iter.hasNext;;) {
         if (i < pos) {
            iter.next;
         } else {
            break;
         }
         i++;
      }
      if (i != pos) {
         return(null);
      }
      return(iter.nextNode);
   }
   
   addValueWhole(held) {
     any nn = newNode(held);
     appendNode(nn);
   }
   
   addValue(held) {
      if (def(held) && System:Types.sameType(held, self)) {
         addAll(held);
      } else {
         addValueWhole(held);
      }
   }
   
   iterateAdd(val) {
      if (def(val)) {
         while (val.hasNext) {
            addValueWhole(val.next);
         }
      }
   }
   
   addAll(val) {
      if (def(val)) {
         iterateAdd(val.iterator);
      }
   }
   
   prepend(held) {
      any nn = newNode(held);
      prependNode(nn);
   }
   
   lengthGet() Int {
      Int cnt = 0;
      for (Iterator i = self.linkedListIterator;i.hasNext;;) {
         i.next;
         cnt++;
      }
      return(cnt);
   }
   
   isEmptyGet() Bool {
      if (undef(firstNode)) {
        return(true);
      }
      return(false);
   }
   
   toNodeList() Container:List {
      Int len = self.length;
      Container:List toret = Container:List.new(len);
      Int cnt = 0;
      for (Iterator i = self.linkedListIterator;i.hasNext;;) {
         if (cnt < len) {
            toret.put(cnt, i.nextNode);
         }
         cnt++;
      }
      return(toret);
   }
   
   toList() Container:List {
      Int len = self.length;
      Container:List toret = Container:List.new(len);
      Int cnt = 0;
      for (Iterator i = self.linkedListIterator;i.hasNext;;) {
         if (cnt < len) {
            toret.put(cnt, i.nextNode.held);
         }
         cnt++;
      }
      return(toret);
   }
   
   iteratorGet() {
      return(Iterator.new(self));
   }
   
   linkedListIteratorGet() Iterator {
      return(Iterator.new(self));
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
      Iterator iter = self.linkedListIterator;
      for (Int i = 0;i < end;i++) {
         if (iter.hasNext!) {
            return(res);
         }
         any x = iter.next;
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

local Iterator {
   
   new(LinkedList l) Iterator {
   
      {
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
      for (Int mi = 0;mi < multiNullCount;mi++) {
         self.next = null;
      }
   }

}

