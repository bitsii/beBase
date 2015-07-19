// Copyright 2006 Craig Welch
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

use Container:Array;
use Math:Int;
use Logic:Bool;
use Text:String;

emit(cs) {
    """
using System;
    """
}

final class Array:Iterator {
   
   new() self {
      properties {
         Int pos = -1;
         Array list = Array.new(1);
      }
   }
   
   new(a) self {
      pos = -1;
      list = a;
   }
   
   containerGet() Array {
       return(list);
   }
   
   hasCurrentGet() Bool {
      if ((pos > 0) && (pos < list.length)) {
         return(true);
      }
      return(false);
   }
   
   currentGet() Bool {
      return(list.get(pos));
   }
   
   currentSet(toSet) {
      return(list.put(pos, toSet));
   }
      
   hasNextGet() Bool {
      if ((pos >= -1) && (pos + 1 < list.length)) {
         return(true);
      }
      return(false);
   }
      
   nextGet() {
      pos = pos++;
      return(list.get(pos));
   }
   
   nextSet(toSet) {
      pos = pos++;
      return(list.put(pos, toSet));
   }
   
   skip(Int multiNullCount) {
      pos = pos + multiNullCount;
   }

}

final class Array {
   
   emit(c) {
   """
/*-attr- -firstSlotNative-*/
   """
   }
   
   emit(c) {
   """
/*-attr- -freeFirstSlot-*/
   """
   }
   
   emit(c) {
   """
/*-attr- -isArray-*/
   """
   }
   
   emit(jv,cs) {
   """
   
    public BEC_6_6_SystemObject[] bevi_array;
    
   """
   }
   
   emit(jv) {
   """
   
   public BEC_9_5_ContainerArray(BEC_6_6_SystemObject[] bevi_array) {
        this.bevi_array = bevi_array;
        this.bevp_length = new BEC_4_3_MathInt(bevi_array.length);
        this.bevp_capacity = new BEC_4_3_MathInt(bevi_array.length);
        this.bevp_multiplier = new BEC_4_3_MathInt(2);
    }
    
   """
   }
   
   emit(cs) {
   """
   
   public BEC_9_5_ContainerArray(BEC_6_6_SystemObject[] bevi_array) {
        this.bevi_array = bevi_array;
        this.bevp_length = new BEC_4_3_MathInt(bevi_array.Length);
        this.bevp_capacity = new BEC_4_3_MathInt(bevi_array.Length);
        this.bevp_multiplier = new BEC_4_3_MathInt(2);
    }
    
   """
   }
   
   emit(js) {
   """
   
    be_BEL_4_Base_BEC_9_5_ContainerArray.prototype.beml_new_array = function(bevi_array) {
        this.bevi_array = bevi_array;
        this.bevp_length = new be_BEL_4_Base_BEC_4_3_MathInt().beml_set_bevi_int(bevi_array.length);
        this.bevp_capacity = new be_BEL_4_Base_BEC_4_3_MathInt().beml_set_bevi_int(bevi_array.length);
        this.bevp_multiplier = new be_BEL_4_Base_BEC_4_3_MathInt().beml_set_bevi_int(2);
        return(this);
    }
    
   """
   }
   
   new() self {
      self.new(0, 16);
   }
   
   new(Int leni) self {
      new(leni, leni);
   }
   
   new(Int leni, Int capi) self {
emit(c) {
"""
/*-attr- -dec-*/
void** bevl_leni;
"""
}
if (undef(leni) || undef(capi)) {
   throw(System:Exception.new("Attempt to initialize an array with a null length or capacity"));
}
if (def(length)) {
   //not the first initialization of this instance
   //just use itif the length is equal
   if (length == leni) {
      return(self);
   }
}
      emit(c) {
"""
bevl_leni = $capi&*;
if (bevs[bercps] != NULL) {
    BENoFree(bevs[bercps]);
    bevs[bercps] = NULL;
}
bevs[bercps] = (void**)  BENoMalloc(*((BEINT*) (bevl_leni + bercps)) * sizeof(void**));
"""
      }
      emit(jv,cs) {
      """
      bevi_array = new BEC_6_6_SystemObject[beva_capi.bevi_int];
      """
      }
      emit(js) {
      """
      this.bevi_array = new Array(beva_capi.bevi_int);
      """
      }
      
      properties {
         var varray;
         Int length = leni;
         Int capacity = capi;
         Int multiplier = 2;
      }
   }
   
   sizeGet() Int {
      return(length);
   }
   
   isEmptyGet() Bool {
      if (length == 0) {
        return(true);
      }
      return(false);
   }
   
   varrayGet() {
   }
   
   varraySet() {
   }
   
   serializeToString() String {
      return(length.toString());
   }
   
   deserializeFromStringNew(String snw) self {
      self.new(Int.new(snw));
   }
   
   serializationIteratorGet() {
      return(self.iterator);
   }
   
   firstGet() {
      return(get(0));
   }
   
   lastGet() {
      return(get(length - 1));
   }
   
   put(Int posi, val) {
   emit(c) {
"""
/*-attr- -dec-*/
void** bevl_posi;
"""
}
      if (posi < 0) {
        throw(System:Exception.new("Attempted put with index less than 0"));
      }
      if (posi >= length) {
         lengthSet(posi + 1);
      }
      emit(c) {
"""
bevl_posi = $posi&*;
((void**) bevs[bercps])[*((BEINT*) (bevl_posi + bercps))] = $val*;
"""
      }
      emit(jv,cs,js) {
      """
      this.bevi_array[beva_posi.bevi_int] = beva_val;
      """
      }
   }
   
   get(Int posi) {
emit(c) {
"""
/*-attr- -dec-*/
void** bevl_posi;
"""
}
      var val;
      if ((posi >= 0) && (posi < length)) {
      emit(c) {
"""
bevl_posi = $posi&*;
$val=* ((void**) bevs[bercps])[*((BEINT*) (bevl_posi + bercps))];
"""
      }
      emit(jv,cs,js) {
      """
      bevl_val = this.bevi_array[beva_posi.bevi_int];
      """
      }
      }
      return(val);
   }
   
   delete(Int pos)  {
      if (pos < length) {
         Int fl = length - 1;
         for (Int i = pos;i < fl;i = i++) {
            put(i, get(i + 1));
         }
         put(fl, null);
         lengthSet(length - 1);
         return(true);
      }
      return(false);
   }
   
   iteratorGet() {
      return(Array:Iterator.new(self));
   }
   
   clear() self {
      for (Int i = 0;i < length;i = i++) {
         put(i, null);
      }
   }
   
   copy() {
      Array n = create();
      for (Int i = 0;i < length;i = i++) {
         n[i] = self[i];
      }
      return(n);
   }
   
   create(Int len) { return(Array.new(len)); }
   
   create() { return(Array.new(length)); }
   
   add(Array xi) self {
      Array yi = create(length + xi.length);
      Int i = 0;
      foreach (var c in self) {
         yi.put(i, c);
         i = i++;
      }
      foreach (c in xi) {
         yi.put(i, c);
         i = i++;
      }
      return(yi);
   }
   
   sort() self {
      return(mergeSort());
   }
   
   sortInPlace() self {
      sortInPlace(0, length);
   }
   
   sortInPlace(Int start, Int end) self {
      for (Int i = start;i < end;i = i++) {
         Int c = i;
         for (Int j = i;j < end;j = j++) {
            if (self[j] < self[c]) {
               c = j;
            }
         }
         var hold = self[i];
         self[i] = self[c];
         self[c] = hold;
      }
   }
   
   mergeIn(Array first, Array second) self {
      Int i = 0;
      Int fi = 0;
      Int si = 0;
      Int fl = first.length;
      Int sl = second.length;
      while (i < length) {
         if (fi < fl && si < sl) {
            var fo = first.get(fi);
            var so = second.get(si);
            if (so < fo) {
               si = si++;
               put(i, so);
            } else {
               fi = fi++;
               put(i, fo);
            }
         } elif (si < sl) {
            so = second.get(si);
            si = si++;
            put(i, so);
         } elif (fi < fl) {
            fo = first.get(fi);
            fi = fi++;
            put(i, fo);
         }
         i = i++;
      }
   }
   
   mergeSort() self {
      return(mergeSort(0, length));
   }
   
   mergeSort(Int start, Int end) self {
      Int mlen = end - start;
      if (mlen == 0) {
         return(create(0));
      } elif (mlen == 1) {
         Array ra = create(1);
         ra.put(0, get(start));
         return(ra);
      } else {
         Int shalf = mlen / 2;
         Int fhalf = mlen - shalf;
         Int fend = start + fhalf;
         Array fa = mergeSort(start, fend);
         Array sa = mergeSort(fend, end);
         ra = create(mlen);
         ra.mergeIn(fa, sa);
         return(ra);
      }
   }
   
   lengthSet(Int newlen) {
   emit(c) {
      """
/*-attr- -dec-*/
size_t bevl_newcap;
size_t bevl_oldcap;
void** bevl_ar;
size_t i;
      """
      }
      Int newcap;
      Int oldcap;
      Int i;
      
      emit(c) {
      """
      bevl_ar = (void**) bevs[bercps];
      """
      }
      
      if (newlen >= capacity) {
         newcap = newlen * multiplier;
         oldcap = capacity;
         //realloc
         emit(c) {
         """
            bevl_newcap = *((BEINT*) ($newcap&* + bercps));
            bevl_oldcap = *((BEINT*) ($oldcap&* + bercps));
            bevl_ar = (void**) bevs[bercps];
            bevl_ar = (void**) BENoRealloc(bevl_ar, bevl_newcap * sizeof(void*));
            bevs[bercps] = (void*) bevl_ar;
         """
         }
         emit(jv) {
         """
         this.bevi_array = java.util.Arrays.copyOf(this.bevi_array, bevl_newcap.bevi_int);
         """
         }
         emit(cs) {
         """
         //BEC_6_6_SystemObject[] bevls_array = bevi_array;
         Array.Resize(ref bevi_array, bevl_newcap.bevi_int);
         //this.bevi_array = bevls_array;
         """
         }
         emit(js) {
         """
         this.bevi_array[bevl_newcap.bevi_int - 1] = null;//js arrays grow :-)
         """
         }
         capacity = newcap;
      }
      //zero extra
      i = length;
      length = newlen;
      while (i < newlen) {
         put(i, null);
         i = i++;
      }
   }
   
   iterateAdd(val) self {
      if (def(val)) {
         while (val.hasNext) {
            addValue(val.next);
         }
      }
   }
   
   addAll(val) self {
      if (def(val)) {
         iterateAdd(val.iterator);
      }
   }
   
   addWhole(val) self {
      put(length, val);
   }
   
   addValue(val) self {
      if (def(val) && val.sameType(self)) {
         addAll(val);
      } else {
         put(length, val);
      }
   }
   
   //find (or has) niavely finds
   find(value) Int {
     for (Int i = 0;i < length;i++=) {
       var aval = get(i);
       if (def(aval) && value == aval) {
         return(i);
       }
     }
     return(null);
   }
   
   has(value) Bool {
     if (def(find(value))) {
       return(true);
     }
     return(false);
   }
   
   //find the index of the given value
   //this can only be used if the array is sorted
   sortedFind(value) Int {
     return(sortedFind(value, false));
   }
   
   //like sorted find above, if second argument is true return the nearest lesser value
   //when there is no match
   sortedFind(value, Bool returnNoMatch) Int {
   
     Int high = length;
     Int low = 0;
     Int lastMid;
     
     loop {
       Int mid = ((high - low) / 2) + low;
       var aval = get(mid);
       if (value == aval) {
        return(mid);
       } elif (value > aval) {
        //aval lt
        low = mid;
       } elif (value < aval) {
        //aval gt
        high = mid;
       }
       //("high low mid " + high + " " + low + " " + mid).print();
       if (def(lastMid) && lastMid == mid) {
         if (returnNoMatch && get(low) < value) {
            return(low);
          }
         return(null);
       }
       lastMid = mid;  
        if (false) {
        return(null);
        }
     }
   }
}


