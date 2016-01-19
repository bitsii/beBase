// Copyright 2006 Craig Welch
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

use Container:Set:Relations;
use Container:Set:SetNode;
use Container:Set:IdentityRelations;
use Container:Map;
use Container:Set;
use Container:IdentityMap;
use Container:IdentitySet;
use Container:Map:MapNode;
use Container:Array;
use Container:Array;
use Math:Int;
use Math:Float;
use Logic:Bool;
use Text:String;

class SetNode {
   
   new(_hval, _key, _value) self {
   
      properties {
         Int hval = _hval;
         var key = _key;
      }
      
   }
   
   putTo(_key, _value) {
      key = _key;
   }
   
   getFrom() {
      return(key);
   }
   
}

class MapNode(SetNode) {
   
   new(_hval, _key, _value) self {
      super.new(_hval, _key, _value);
      
      properties {
         var value = _value;
      }
      
   }
   
   putTo(_key, _value) {
      key = _key;
      value = _value;
   }
   
   getFrom() {
      return(value);
   }
}

class Relations {

   create() { }
   
   default() self {
      
   }
   
   getHash(k) {
      return(k.hash);
   }
   
   isEqual(k, l) {
      return(k == l);
   }
}

class IdentityRelations(Relations) {
   
   getHash(k) {
      return(k.tag);
   }
   
   isEqual(k, l) {
      return(k.sameObject(l));
   }
   
}

class IdentityMap(Map) {
   
   new() self {
      self.new(11);
   }
   
   new(Int _modu) self {
      slots = Array.new(_modu);
      modu = _modu;
      multi = 2;
      rel = IdentityRelations.new();
      baseNode = MapNode.new();
      size = 0;
   }
}

//FASTER switch to using mutable int and hash(int)
class Map(Set) {

   new() self {
      self.new(11);
   }
   
   new(Int _modu) self {
      slots = Array.new(_modu);
      modu = _modu;
      multi = 2;
      rel = Relations.new();
      baseNode = MapNode.new();
      size = 0;
   }
   
   serializationIteratorGet() {
      return(Map:SerializationIterator.new(self));
   }
   
   contentsEqual(Set _other) Bool {
      Map other = _other;
      if (undef(other) || other.size != self.size) {
         return(false);
      }
      foreach (var i in self) {
         var v = other.get(i.key);
         if (undef(v) || (undef(i.value) && def(v)) || i.value != v) { return(false); }
      }
      return(true);
   }
   
   put(k, v) {
      if (innerPut(k, v, null, slots)!) {
         Array slt = slots;
         slt = rehash(slt);
         while (innerPut(k, v, null, slt)!) {
            slt = rehash(slt);
         }
         slots = slt;
      } 
      if (innerPutAdded) {
         size = size++;
      }
   }
   
   valueIteratorGet() Map:ValueIterator {
      return(Map:ValueIterator.new(self));
   }
   
   valuesGet() Map:ValueIterator {
      return(self.valueIterator);
   }
   
   keyValueIteratorGet() Map:KeyValueIterator {
      return(Map:KeyValueIterator.new(self));
   }
   
   iteratorGet() {
      return(Set:NodeIterator.new(self));
   }
   
   addValue(other) self {
      if (def(other)) {
        if (other.sameType(self)) {
		 Map otherMap = other; //could support adding sets to maps... by keys
         foreach (var x in otherMap) {
            put(x.key, x.value);
         }
         } elif (other.sameType(baseNode)) {
            put(other.key, other.value);
         } else {
            put(other, other);
         }
      }
   }
   
   getMap(String prefix) Map {
     Map toRet = Map.new();
     foreach (var x in self) {
      if (x.key.begins(prefix)) {
        toRet.put(x.key, x.value);
      }
     }
     return(toRet);
   }
}

class IdentitySet(Set) {
   
   new() self {
      self.new(11);
   }
   
   new(Int _modu) self {
      slots = Array.new(_modu);
      modu = _modu;
      multi = 2;
      rel = IdentityRelations.new();
      baseNode = SetNode.new();
      size = 0;
   }
}

class Set {
   
   new() self {
      self.new(11);
   }
   
   new(Int _modu) self {
   
      properties {
         Array slots = Array.new(_modu);
         Int modu = _modu;
         Int multi = 2;
         Relations rel = Relations.new();
         SetNode baseNode = SetNode.new();
         Int size = 0;
         Bool innerPutAdded = false;
      }
      
   }
   
   isEmptyGet() Bool {
      if (size == 0) {
        return(true);
      }
      return(false);
   }
   
   serializeToString() String {
      return(modu.toString());
   }
   
   deserializeFromStringNew(String snw) self {
      self.new(Int.new(snw));
   }
   
   serializationIteratorGet() {
      return(Set:SerializationIterator.new(self));
   }
   
   insertAll(Array ninner, Array ir) {
      for (var i = ir.iterator;i.hasNext;) {
         SetNode ni = i.next;
         if (def(ni)) {
            if (innerPut(ni.key, null, ni, ninner)!) {
               return(false);
            }
         }
      }
      return(true);
   }
   
   rehash(Array slt) {
      /*"Rehashing now".print();*/
      Int nslots = slt.size * multi + 1;
      Array ninner = Array.new(nslots);
      while (insertAll(ninner, slt)!) {
         nslots = nslots++;
         ninner = Array.new(nslots);
      }
      return(ninner);
   }
   
   contentsEqual(Set other) Bool {
      if (undef(other) || other.size != self.size) {
         return(false);
      }
      foreach (var i in self) {
         if (other.has(i)!) { return(false); }
      }
      return(true);
   }
   
   innerPut(k, v, inode, Array slt) {
      Int modu = slt.size;
      if (undef(inode)) {
         Int hval = rel.getHash(k);
         if (hval < 0) {
			hval = hval.abs();
         }
      } else {
         hval = inode.hval;
      }
      Int orgsl = hval % modu;
      Int sl = orgsl;
      loop {
         SetNode n = slt.get(sl);
         if (undef(n)) {
            if (undef(inode)) {
               slt.put(sl, baseNode.create().new(hval, k, v));
            } else {
               slt.put(sl, inode);
            }
            innerPutAdded = true;
            return(true);
         } elif ((n.hval % modu) != orgsl) {
            return(false);
         } elif (rel.isEqual(n.key, k)) {
            n.putTo(k, v);
            //existing equiv, no size++
            innerPutAdded = false;
            return(true);
         } else {
            sl = sl++;
            if (sl >= modu) {
               return(false);
            }
         }
      }
   }
   
   put(k) {
      if (innerPut(k, k, null, slots)!) {
         Array slt = slots;
         slt = rehash(slt);
         while (innerPut(k, k, null, slt)!) {
            slt = rehash(slt);
         }
         slots = slt;
      }
      if (innerPutAdded) {
         size = size++;
      }
   }
   
   get(k) {
      Array slt = slots;
      Int modu = slt.size;
      Int hval = rel.getHash(k);
      if (hval < 0) {
		hval = hval.abs();
   	 }
      Int orgsl = hval % modu;
      Int sl = orgsl;
      loop {
         SetNode n = slt.get(sl);
         if (undef(n)) {
            return(null);
         } elif ((n.hval % modu) != orgsl) {
            return(null);
         } elif (rel.isEqual(n.key, k)) {
            return(n.getFrom());
         } else {
            sl = sl++;
            if (sl >= modu) {
               return(null);
            }
         }
      }
   }
   
   has(k) Bool {
      Array slt = slots;
      Int modu = slt.size;
      Int hval = rel.getHash(k);
      if (hval < 0) {
			hval = hval.abs();
         }
      Int orgsl = hval % modu;
      Int sl = orgsl;
      loop {
         SetNode n = slt.get(sl);
         if (undef(n)) {
            return(false);
         } elif ((n.hval % modu) != orgsl) {
            return(false);
         } elif (rel.isEqual(n.key, k)) {
            return(true);
         } else {
            sl = sl++;
            if (sl >= modu) {
               return(false);
            }
         }
      }
   }
   
   delete(k) {
      Array slt = slots;
      Int modu = slt.size;
      
      Int hval = rel.getHash(k);
      if (hval < 0) {
			hval = hval.abs();
         }
      Int orgsl = hval % modu;
      Int sl = orgsl;
      loop {
         SetNode n = slt.get(sl);
         if (undef(n)) {
            return(false);
         } elif ((n.hval % modu) != orgsl) {
            return(false);
         } elif (rel.isEqual(n.key, k)) {
            slt.put(sl, null);
            size = size--;
            sl = sl++;
            while (sl < modu) {
               n = slt.get(sl);
               if (undef(n) || n.hval % modu != orgsl) {
                  return(true);
               } else {
                  slt.put(sl - 1, n);
                  slt.put(sl, null);
               }
               sl = sl++;
            }
            return(true);
         } else {
            sl = sl++;
            if (sl >= modu) {
               return(false);
            }
         }
      }
   }
   
   copy() {
      var other = create();
      copyTo(other);
      other.slots = slots.copy();
      for (Int i = 0;i < slots.length;i = i++;) {
         SetNode n = slots.get(i);
         if (def(n)) {
            other.slots.put(i, baseNode.create().new(n.hval, n.key, n.getFrom()));
         } else {
            other.slots.put(i, null);
         }
      }
      return(other);
   }

   
   clear() {
      slots.clear();
      size = 0;
   }
   
   iteratorGet() {
      return(Set:KeyIterator.new(self));
   }
   
   keyIteratorGet() Set:KeyIterator {
      return(Set:KeyIterator.new(self));
   }
   
   keysGet() Set:KeyIterator {
      return(self.keyIterator);
   }
   
   nodeIteratorGet() Set:NodeIterator {
      return(Set:NodeIterator.new(self));
   }
   
   nodesGet() Set:NodeIterator {
      return(self.nodeIterator);
   }
   
   intersection(Set other) Set {
      Set i = Set.new();
      if (def(other)) {
         foreach (var x in self) {
            if (other.has(x)) {
               i.put(x);
            }
         }
      }
      return(i);
   }
   
   union(Set other) Set {
      Set i = Set.new();
      foreach (var x in self) {
         i.put(x);
      }
      if (def(other)) {
         foreach (x in other) {
            i.put(x);
         }
      }
      return(i);
   }
   
   add(Set other) self {
      Set x = copy();
      x.addValue(other);
      return(x);
   }
   
   addValue(other) self {
      if (def(other)) {
         if (other.sameType(self)) {
             foreach (var x in other) {
                put(x);
             }
         } elif (other.sameType(baseNode)) {
            put(other.key);
         } else {
            put(other);
         }
      }
   }
   
}

class Set:KeyIterator(Set:NodeIterator) {
   
   nextGet() {
      var tr = super.nextGet();
      if (def(tr)) {
         return(tr.key);
      }
      return(tr);
   }
}

class Set:SerializationIterator(Set:KeyIterator) {

   new(Set _set) Set:SerializationIterator {
      properties {
         Array contents = Array.new();
      }
      super.new(_set);
   }
   
   nextSet(value) {
      contents += value;
   }
   
   skip(Int multiNullCount) {
      for (Int mi = 0;mi < multiNullCount;mi = mi++) {
         self.next = null;
      }
   }
   
   postDeserialize() {
      foreach (var value in contents) {
         set.put(value);
      }
   }
   
}

class Map:SerializationIterator(Map:KeyValueIterator) {

   new(Set _set) Map:SerializationIterator {
      properties {
         Array contents = Array.new();
      }
      super.new(_set);
   }
   
   nextSet(value) {
      contents += value;
   }
   
   skip(Int multiNullCount) {
      for (Int mi = 0;mi < multiNullCount;mi = mi++) {
         self.next = null;
      }
   }
   
   postDeserialize() {
      Map map = set;
      var iter = contents.iterator;
      while (iter.hasNext) {
         var key = iter.next;
         var value = iter.next;
         map.put(key, value);
      }
   }
   
}

class Map:KeyValueIterator(Set:NodeIterator) {
   
   new(Set _set) Map:KeyValueIterator {
      properties {
         var onNode;
      }
      super.new(_set);
   }
   
   hasNextGet() Bool {
      if (def(onNode)) {
         return(true);
      }
      return(super.hasNext);
   }
   
   nextGet() {
      if (def(onNode)) {
         var toRet = onNode.value;
         onNode = null;
         return(toRet);
      }
      onNode = super.nextGet();
      if (def(onNode)) {
         return(onNode.key);
      }
      return(onNode);
   }
   
}

class Map:ValueIterator(Set:NodeIterator) {
   
   nextGet() {
      var tr = super.nextGet();
      if (def(tr)) {
         return(tr.value);
      }
      return(tr);
   }
   
}

class Set:NodeIterator {
   
   new(Set _set) Set:NodeIterator {
      
      properties {
         Set set = _set;
         Array slots = set.slots;
         Int modu = slots.size;
         Int current = 0;
      }
      
   }
   
   containerGet() Set {
       return(set);
   }
   
   hasNextGet() Bool {
      for (Int i = current;i < modu;i = i++;) {
         if (def(slots.get(i))) {
            current = i;
            return(true);
         }
      }
      return(false);
   }
   
   nextGet() {
      for (Int i = current;i < modu;i = i++;) {
         SetNode toRet = slots.get(i);
         if (def(toRet)) {
            current = i + 1;
            return(toRet);
         }
      }
      return(null);
   }
   
   delete() Bool {
      Int i = current - 1;
      if (i >= 0) {
         SetNode sn = slots.get(i);
         if (def(sn)) {
            if (set.delete(sn.key)) {
               current = i;
               return(true);
            }
         }
      }
      return(false);
   }
   
   //to enable foreach for other iterators than the default, foreach b in map.blahiterator
   iteratorGet() {
      return(self);
   }
   
}

