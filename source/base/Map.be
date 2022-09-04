// Copyright 2006 The Brace Authors. All rights reserved.
// Use of this source code is governed by the BSD-3-Clause
// license that can be found in the LICENSE file.

use Container:Set:Relations;
use Container:Set:SetNode;
use Container:Set:IdentityRelations;
use Container:Map;
use Container:Set;
use Container:IdentityMap;
use Container:IdentitySet;
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
      slots = List.new(_modu);
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
      slots = List.new(_modu);
      modu = _modu;
      multi = 2;
      rel = Relations.new();
      baseNode = MapNode.new();
      size = 0;
   }
   
   serializationIteratorGet() {
      return(Container:Map:SerializationIterator.new(self));
   }
   
   contentsEqual(Set _other) Bool {
      Map other = _other;
      if (undef(other) || other.size != self.size) {
         return(false);
      }
      for (any i in self) {
         any v = other.get(i.key);
         if (undef(v) || (undef(i.value) && def(v)) || i.value != v) { return(false); }
      }
      return(true);
   }
   
   put(k, v) {
      if (innerPut(k, v, null, slots)!) {
         List slt = slots;
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
        if (other.sameType(self)) {
		 Map otherMap = other; //could support adding sets to maps... by keys
         for (any x in otherMap) {
            put(x.key, x.value);
         }
         } elseIf (other.sameType(baseNode)) {
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

class IdentitySet(Set) {
   
   new() self {
      self.new(11);
   }
   
   new(Int _modu) self {
      slots = List.new(_modu);
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
   
      fields {
         List slots = List.new(_modu);
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
   
   notEmptyGet() Bool {
      if (size == 0) {
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
      for (Container:List:Iterator i = ir.arrayIterator;i.hasNext;) {
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
      Int nslots = slt.size * multi + 1;
      List ninner = List.new(nslots);
      while (insertAll(ninner, slt)!) {
         nslots = nslots++;
         ninner = List.new(nslots);
      }
      return(ninner);
   }
   
   contentsEqual(Set other) Bool {
      if (undef(other) || other.size != self.size) {
         return(false);
      }
      for (any i in self) {
         if (other.has(i)!) { return(false); }
      }
      return(true);
   }
   
   innerPut(k, v, inode, List slt) {
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
         } elseIf ((n.hval % modu) != orgsl) {
            return(false);
         } elseIf (rel.isEqual(n.key, k)) {
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
         List slt = slots;
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
      List slt = slots;
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
         } elseIf ((n.hval % modu) != orgsl) {
            return(null);
         } elseIf (rel.isEqual(n.key, k)) {
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
      List slt = slots;
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
         } elseIf ((n.hval % modu) != orgsl) {
            return(false);
         } elseIf (rel.isEqual(n.key, k)) {
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
      List slt = slots;
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
         } elseIf ((n.hval % modu) != orgsl) {
            return(false);
         } elseIf (rel.isEqual(n.key, k)) {
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
   
   copy() self {
      //this is wrong due to ints being changed in place
      any other = create();
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

   
   clear() this {
      slots.clear();
      slots.size = modu;
      size = 0;
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
            if (other.has(x)) {
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
         if (other.sameType(self)) {
             for (any x in other) {
                put(x);
             }
         } elseIf (other.sameType(baseNode)) {
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
      for (Int mi = 0;mi < multiNullCount;mi = mi++) {
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
      for (Int mi = 0;mi < multiNullCount;mi = mi++) {
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
      fields {
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
      
      fields {
         Set set = _set;
         List slots = set.slots;
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

  fromHandler(List list) {
    Int ssz = list.size * 2;
    ssz++=;
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

  fromHandler(List list) {
    Int ls = list.size;
    Map map = Map.new(ls + 1);
    for (Int i = 0;i < ls;i++=) {
      map.put(list[i], list[i++=]);
    }
    return(map);
  }
  
  fieldsIntoMap(any inst, Map res) Map {
    for (any i = inst.fieldIterator;i.hasNext;) {
      res.put(i.nextName, i.current);
    }
    return(res);
  }
  
  mapIntoFields(Map from, any inst) any {
    for (any i = inst.fieldIterator;i.hasNext;) {
      i.current = from.get(i.nextName);
    }
    return(inst);
  }

}

