/*
 * Copyright (c) 2006-2023, the Brace Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

use Container:Set:Relations;
use Container:Set:SetNode;
use Container:Map;
use Container:Set;
use Container:Map:MapNode;
use Container:List;
use Math:Float;

class SetNode {
   
   new(_hval, _key, _value) self {
   
      fields {
         Int hval = _hval;
         any key = _key;
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
      
      fields {
         any value = _value;
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

   create() self { }
   
   default() self {
      
   }
   
   getHash(k) {
      return(k.hash);
   }
   
   isEqual(k, l) {
      return(k == l);
   }
}

//FASTER switch to using mutable int and hash(int)
class Map(Set) {

   new() self {
      self.new(11);
   }
   
   new(Int _modu) self {
      buckets = List.new(_modu);
      modu = _modu;
      multi = 2;
      rel = Relations.new();
      baseNode = MapNode.new();
      length = 0;
   }
   
   serializationIteratorGet() {
      return(Container:Map:SerializationIterator.new(self));
   }
   
   contentsEqual(Set _other) Bool {
      Map other = _other;
      if (undef(other) || other.length != self.length) {
         return(false);
      }
      for (any i in self) {
         any v = other.get(i.key);
         if (def(i.value) && undef(v)) { return(false); }
         if (def(v) && undef(i.value)) { return(false); }
         if (def(v) && def(i.value) && i.value != v) { return(false); }
      }
      return(true);
   }
   
   put(k, v) {
      if (innerPut(k, v, null, buckets)!) {
         List slt = buckets;
         slt = rehash(slt);
         while (innerPut(k, v, null, slt)!) {
            slt = rehash(slt);
         }
         buckets = slt;
      } 
      if (innerPutAdded) {
         length = length + 1;
      }
   }
   
   valueIteratorGet() Container:Map:ValueIterator {
      return(Container:Map:ValueIterator.new(self));
   }
   
   valuesGet() Container:Map:ValueIterator {
      return(self.valueIterator);
   }
   
   keyValueIteratorGet() Container:Map:KeyValueIterator {
      return(Container:Map:KeyValueIterator.new(self));
   }
   
   iteratorGet() {
      return(Container:Set:NodeIterator.new(self));
   }
   
   mapIteratorGet() Container:Set:NodeIterator {
      return(Container:Set:NodeIterator.new(self));
   }
   
   addValue(other) self {
      if (def(other)) {
        if (System:Types.sameType(other, self)) {
		 Map otherMap = other; //could support adding sets to maps... by keys
         for (any x in otherMap) {
            put(x.key, x.value);
         }
         } elseIf (System:Types.sameType(other, baseNode)) {
            put(other.key, other.value);
         } else {
            put(other, other);
         }
      }
   }
   
   getMap(String prefix) Map {
     Map toRet = Map.new();
     for (any x in self) {
      if (x.key.begins(prefix)) {
        toRet.put(x.key, x.value);
      }
     }
     return(toRet);
   }
}

class Set {
   
   new() self {
      self.new(11);
   }
   
   new(Int _modu) self {
   
      slots {
         Int modu = _modu;
         Int multi = 2;
         Relations rel = Relations.new();
         SetNode baseNode = SetNode.new();
         Bool innerPutAdded = false;
      }
      fields {
         List buckets = List.new(_modu);
         Int length = 0;
      }
      
   }
   
   isEmptyGet() Bool {
      if (length == 0) {
        return(true);
      }
      return(false);
   }
   
   notEmptyGet() Bool {
      if (length == 0) {
        return(false);
      }
      return(true);
   }
   
   serializeToString() String {
      return(modu.toString());
   }
   
   deserializeFromStringNew(String snw) self {
      self.new(Int.new(snw));
   }
   
   serializationIteratorGet() {
      return(Container:Set:SerializationIterator.new(self));
   }
   
   insertAll(List ninner, List ir) {
      for (Container:List:Iterator i = ir.iterator;i.hasNext;) {
         SetNode ni = i.next;
         if (def(ni)) {
            if (innerPut(ni.key, null, ni, ninner)!) {
               return(false);
            }
         }
      }
      return(true);
   }
   
   rehash(List slt) {
      /*"Rehashing now".print();*/
      Int nbuckets = slt.length * multi + 1;
      List ninner = List.new(nbuckets);
      while (insertAll(ninner, slt)!) {
         nbuckets = nbuckets + 1;
         ninner = List.new(nbuckets);
      }
      return(ninner);
   }
   
   contentsEqual(Set other) Bool {
      if (undef(other) || other.length != self.length) {
         return(false);
      }
      for (any i in self) {
         if (other.contains(i)!) { return(false); }
      }
      return(true);
   }
   
   innerPut(k, v, inode, List slt) {
      Int modu = slt.length;
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
         } elseIf ((n.hval % modu) != orgsl) {
            return(false);
         } elseIf (rel.isEqual(n.key, k)) {
            n.putTo(k, v);
            //existing equiv, no length++
            innerPutAdded = false;
            return(true);
         } else {
            sl = sl + 1;
            if (sl >= modu) {
               return(false);
            }
         }
      }
   }
   
   put(k) {
      if (innerPut(k, k, null, buckets)!) {
         List slt = buckets;
         slt = rehash(slt);
         while (innerPut(k, k, null, slt)!) {
            slt = rehash(slt);
         }
         buckets = slt;
      }
      if (innerPutAdded) {
         length = length + 1;
      }
   }
   
   get(k) {
      List slt = buckets;
      Int modu = slt.length;
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
         } elseIf ((n.hval % modu) != orgsl) {
            return(null);
         } elseIf (rel.isEqual(n.key, k)) {
            return(n.getFrom());
         } else {
            sl = sl + 1;
            if (sl >= modu) {
               return(null);
            }
         }
      }
   }

   contains(k) Bool {
      List slt = buckets;
      Int modu = slt.length;
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
         } elseIf ((n.hval % modu) != orgsl) {
            return(false);
         } elseIf (rel.isEqual(n.key, k)) {
            return(true);
         } else {
            sl = sl + 1;
            if (sl >= modu) {
               return(false);
            }
         }
      }
   }
   
   remove(k) {
      List slt = buckets;
      Int modu = slt.length;
      
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
         } elseIf ((n.hval % modu) != orgsl) {
            return(false);
         } elseIf (rel.isEqual(n.key, k)) {
            slt.put(sl, null);
            length = length - 1;
            sl = sl + 1;
            while (sl < modu) {
               n = slt.get(sl);
               if (undef(n) || n.hval % modu != orgsl) {
                  return(true);
               } else {
                  slt.put(sl - 1, n);
                  slt.put(sl, null);
               }
               sl = sl + 1;
            }
            return(true);
         } else {
            sl = sl + 1;
            if (sl >= modu) {
               return(false);
            }
         }
      }
   }
   
   copy() self {
      //this is wrong due to ints being changed in place
      any other = create();
      copyTo(other);
      other.buckets = buckets.copy();
      for (Int i = 0;i < buckets.length;i = i + 1;) {
         SetNode n = buckets.get(i);
         if (def(n)) {
            other.buckets.put(i, baseNode.create().new(n.hval, n.key, n.getFrom()));
         } else {
            other.buckets.put(i, null);
         }
      }
      return(other);
   }



   
   clear() this {
      buckets.clear();
      buckets.length = modu;
      length = 0;
   }
   
   iteratorGet() {
      return(Container:Set:KeyIterator.new(self));
   }
   
   setIteratorGet() Container:Set:KeyIterator {
      return(Container:Set:KeyIterator.new(self));
   }
   
   keyIteratorGet() Container:Set:KeyIterator {
      return(Container:Set:KeyIterator.new(self));
   }
   
   keysGet() Container:Set:KeyIterator {
      return(self.keyIterator);
   }
   
   nodeIteratorGet() Container:Set:NodeIterator {
      return(Container:Set:NodeIterator.new(self));
   }
   
   nodesGet() Container:Set:NodeIterator {
      return(self.nodeIterator);
   }
   
   intersection(Set other) Set {
      Set i = Set.new();
      if (def(other)) {
         for (any x in self) {
            if (other.contains(x)) {
               i.put(x);
            }
         }
      }
      return(i);
   }
   
   union(Set other) Set {
      Set i = Set.new();
      for (any x in self) {
         i.put(x);
      }
      if (def(other)) {
         for (x in other) {
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
         if (System:Types.sameType(other, self)) {
             for (any x in other) {
                put(x);
             }
         } elseIf (System:Types.sameType(other, baseNode)) {
            put(other.key);
         } else {
            put(other);
         }
      }
   }
   
}

class Container:Set:KeyIterator(Container:Set:NodeIterator) {
   
   nextGet() {
      any tr = super.nextGet();
      if (def(tr)) {
         return(tr.key);
      }
      return(tr);
   }
}

class Container:Set:SerializationIterator(Container:Set:KeyIterator) {

   new(Set _set) Container:Set:SerializationIterator {
      fields {
         List contents = List.new();
      }
      super.new(_set);
   }
   
   nextSet(value) {
      contents += value;
   }
   
   skip(Int multiNullCount) {
      for (Int mi = 0;mi < multiNullCount;mi++) {
         self.next = null;
      }
   }
   
   postDeserialize() {
      for (any value in contents) {
         set.put(value);
      }
   }
   
}

class Container:Map:SerializationIterator(Container:Map:KeyValueIterator) {

   new(Set _set) Container:Map:SerializationIterator {
      fields {
         List contents = List.new();
      }
      super.new(_set);
   }
   
   nextSet(value) {
      contents += value;
   }
   
   skip(Int multiNullCount) {
      for (Int mi = 0;mi < multiNullCount;mi++) {
         self.next = null;
      }
   }
   
   postDeserialize() {
      Map map = set;
      any iter = contents.iterator;
      while (iter.hasNext) {
         any key = iter.next;
         any value = iter.next;
         map.put(key, value);
      }
   }
   
}

class Container:Map:KeyValueIterator(Container:Set:NodeIterator) {
   
   new(Set _set) Container:Map:KeyValueIterator {
      slots {
         any onNode;
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
         any toRet = onNode.value;
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

class Container:Map:ValueIterator(Container:Set:NodeIterator) {
   
   nextGet() {
      any tr = super.nextGet();
      if (def(tr)) {
         return(tr.value);
      }
      return(tr);
   }
   
}

class Container:Set:NodeIterator {
   
   new(Set _set) Container:Set:NodeIterator {
      
      slots {
         Set set = _set;
         List buckets = set.buckets;
         Int modu = buckets.length;
         Int current = 0;
      }
      
   }
   
   containerGet() Set {
       return(set);
   }
   
   hasNextGet() Bool {
      for (Int i = current;i < modu;i = i + 1;) {
         if (def(buckets.get(i))) {
            current = i;
            return(true);
         }
      }
      return(false);
   }
   
   nextGet() {
      for (Int i = current;i < modu;i = i + 1;) {
         SetNode toRet = buckets.get(i);
         if (def(toRet)) {
            current = i + 1;
            return(toRet);
         }
      }
      return(null);
   }
   
   remove() Bool {
      Int i = current - 1;
      if (i >= 0) {
         SetNode sn = buckets.get(i);
         if (def(sn)) {
            if (set.remove(sn.key)) {
               current = i;
               return(true);
            }
         }
      }
      return(false);
   }
   
   //to enable for for other iterators than the default, for b in map.blahiterator
   iteratorGet() any {
      return(self);
   }
   
   nodeIteratorIteratorGet() Container:Set:NodeIterator {
      return(self);
   }
   
}

class Sets {

  default() self { }

  forwardCall(String name, List args) any {
    name = name + "Handler";
    if (can(name, 1)) {
      List varargs = List.new(1);
      varargs[0] = args;
      any result = invoke(name, varargs);
    }
    return(result);
   }

   fromList(List list) {
     return(fromHandler(list));
   }

  fromHandler(List list) {
    Int ssz = list.length * 2;
    ssz++;
    Set set = Set.new(ssz);
    for (any v in list) {
      set.put(v);
    }
    return(set);
  }

}

class Maps {

  default() self { }

  forwardCall(String name, List args) any {
    name = name + "Handler";
    if (can(name, 1)) {
      List varargs = List.new(1);
      varargs[0] = args;
      any result = invoke(name, varargs);
    }
    return(result);
   }

   fromList(List list) {
     return(fromHandler(list));
   }

  fromHandler(List list) {
    Int ls = list.length;
    Map map = Map.new(ls + 1);
    for (Int i = 0;i < ls;i++) {
      map.put(list[i], list[i++]);
    }
    return(map);
  }

  fieldsIntoMap(any inst, Map res) Map {
    for (any i = System:ObjectFieldIterator.new(inst);i.hasNext;) {
      res.put(i.nextName, i.current);
    }
    return(res);
  }

  mapIntoFields(Map from, any inst) any {
    for (any i = System:ObjectFieldIterator.new(inst);i.hasNext;) {
      i.current = from.get(i.nextName);
    }
    return(inst);
  }

}

