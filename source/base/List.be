/*
 * Copyright (c) 2006-2023, the Beysant Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

use Container:List;

emit(cs) {
    """
using System;
    """
}

final class Container:List:Iterator {
   
   new() self {
      slots {
         Int pos = -1;
         List list = List.new(1);
         Int npos = Int.new();
         Int none = -1;
         Int zero = 0;
      }
   }
   
   new(a) self {
      pos = -1;
      list = a;
      npos = Int.new();
      none = -1;
      zero = 0;
   }
   
   containerGet() List {
       return(list);
   }
   
   hasCurrentGet() Bool {
      if ((pos > zero) && (pos < list.length)) {
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
      npos.setValue(pos);
      npos++;
      if ((pos >= none) && (npos < list.length)) {
         return(true);
      }
      return(false);
   }
      
   nextGet() {
      pos++;
      return(list.get(pos));
   }
   
   nextSet(toSet) {
      pos++;
      return(list.put(pos, toSet));
   }
   
   skip(Int multiNullCount) {
      pos += multiNullCount;
   }

}

final class List {
   
   emit(jv,cs) {
   """
   
    public $class/System:Object$[] bevi_list;
    
   """
   }
   
   emit(jv) {
   """
   
   public $class/Container:List$($class/System:Object$[] bevi_list) {
        this.bevi_list = bevi_list;
        this.bevp_length = new $class/Math:Int$(bevi_list.length);
        this.bevp_capacity = new $class/Math:Int$(bevi_list.length);
        this.bevp_multiplier = new $class/Math:Int$(2);
    }
    
   public $class/Container:List$($class/System:Object$[] bevi_list, int len) {
        this.bevi_list = bevi_list;
        this.bevp_length = new $class/Math:Int$(len);
        this.bevp_capacity = new $class/Math:Int$(bevi_list.length);
        this.bevp_multiplier = new $class/Math:Int$(2);
    }
    
   """
   }
   
   emit(cs) {
   """
   
   public $class/Container:List$($class/System:Object$[] bevi_list) {
        this.bevi_list = bevi_list;
        this.bevp_length = new $class/Math:Int$(bevi_list.Length);
        this.bevp_capacity = new $class/Math:Int$(bevi_list.Length);
        this.bevp_multiplier = new $class/Math:Int$(2);
    }
    
   public $class/Container:List$($class/System:Object$[] bevi_list, int len) {
        this.bevi_list = bevi_list;
        this.bevp_length = new $class/Math:Int$(len);
        this.bevp_capacity = new $class/Math:Int$(bevi_list.Length);
        this.bevp_multiplier = new $class/Math:Int$(2);
    }
    
   """
   }
   
   emit(cc_classHead) {
  """

#ifdef BEDCC_SGC
    std::vector<BEC_2_6_6_SystemObject*> bevi_list;
#endif

   BEC_2_9_4_ContainerList() {  
#ifdef BEDCC_SGC
#ifdef BECC_SS
      BEC_2_6_6_SystemObject** bevls_stackRefs[0] = { };
      BECS_StackFrame bevs_stackFrame(bevls_stackRefs, 0, this);
#endif
#ifdef BECC_HS
      struct bes {  BEC_2_6_6_SystemObject* bevr_this;  };
      BECS_FrameStack* bevs_myStack = &BECS_Runtime::bevs_currentStack;
      bes* beq = (bes*) bevs_myStack->bevs_hs;
      BEQP(bevr_this) = this;
      BECS_StackFrame bevs_stackFrame(1);
#endif
#endif
   }

#ifdef BEDCC_SGC
    BEC_2_9_4_ContainerList(std::vector<BEC_2_6_6_SystemObject*> a_bevi_list) {
#endif    
#ifdef BEDCC_SGC
#ifdef BECC_SS
      BEC_2_6_6_SystemObject** bevls_stackRefs[0] = { };
      BECS_StackFrame bevs_stackFrame(bevls_stackRefs, 0, this);
#endif
#ifdef BECC_HS
      struct bes {  BEC_2_6_6_SystemObject* bevr_this;  };
      BECS_FrameStack* bevs_myStack = &BECS_Runtime::bevs_currentStack;
      bes* beq = (bes*) bevs_myStack->bevs_hs;
      BEQP(bevr_this) = this;
      BECS_StackFrame bevs_stackFrame(1);
#endif
#endif
        bevi_list = a_bevi_list;
        bevp_length = nullptr;
        bevp_capacity = nullptr;
        bevp_multiplier = nullptr;
        bevp_length = new BEC_2_4_3_MathInt(bevi_list.size());
        bevp_capacity = new BEC_2_4_3_MathInt(bevi_list.size());
        bevp_multiplier = new BEC_2_4_3_MathInt(2);
    } //}

#ifdef BEDCC_SGC
    BEC_2_9_4_ContainerList(std::vector<BEC_2_6_6_SystemObject*> a_bevi_list, int32_t len) {
#endif
#ifdef BEDCC_SGC
#ifdef BECC_SS
      BEC_2_6_6_SystemObject** bevls_stackRefs[0] = { };
      BECS_StackFrame bevs_stackFrame(bevls_stackRefs, 0, this);
#endif
#ifdef BECC_HS
      struct bes {  BEC_2_6_6_SystemObject* bevr_this;  };
      BECS_FrameStack* bevs_myStack = &BECS_Runtime::bevs_currentStack;
      bes* beq = (bes*) bevs_myStack->bevs_hs;
      BEQP(bevr_this) = this;
      BECS_StackFrame bevs_stackFrame(1);
#endif
#endif
        bevi_list = a_bevi_list;
        bevp_length = nullptr;
        bevp_capacity = nullptr;
        bevp_multiplier = nullptr;
        bevp_length = new BEC_2_4_3_MathInt(len);
        bevp_capacity = new BEC_2_4_3_MathInt(bevi_list.size());
        bevp_multiplier = new BEC_2_4_3_MathInt(2);
    } //}
    
    void bemg_markContent() {
      for (size_t i = 0; i < bevi_list.size(); i++) {
        BEC_2_6_6_SystemObject* bevg_le = bevi_list[i];
        if (bevg_le != nullptr && bevg_le->bevg_gcMark != BECS_Runtime::bevg_currentGcMark) {
          bevg_le->bemg_doMark();
        }
      }
    }
    
  """
  }
   
   emit(js) {
   """
   
    be_$class/Container:List$.prototype.bems_new_array = function(bevi_list, len) {
        this.bevi_list = bevi_list;
        this.bevp_length = new be_$class/Math:Int$().beml_set_bevi_int(len);
        this.bevp_capacity = new be_$class/Math:Int$().beml_set_bevi_int(bevi_list.length);
        this.bevp_multiplier = new be_$class/Math:Int$().beml_set_bevi_int(2);
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
      emit(jv,cs) {
      """
      bevi_list = new $class/System:Object$[beva_capi.bevi_int];
      """
      }
      emit(js) {
      """
      this.bevi_list = new Array(beva_capi.bevi_int);
      """
      }
      emit(cc) {
      """
      if (bevi_list.size() > 0) {
        bevi_list.resize(0); //the others clear in this case, this preps for that
      }
      bevi_list.resize(BEQP(beva_capi)->bevi_int);
      """
      }
      
      fields {
         Int length = leni.copy();
         Int multiplier = 2;
      }
      slots {
        Int capacity = capi.copy();
      }
   }
   
   isEmptyGet() Bool {
      if (length == 0) {
        return(true);
      }
      return(false);
   }
   
   serializeToString() String {
      return(length.toString());
   }
   
   deserializeFromStringNew(String snw) self {
      self.new(Int.new(snw));
   }
   
   firstGet() {
      return(get(0));
   }
   
   lastGet() {
      return(get(length - 1));
   }
   
   put(Int posi, val) {
      if (posi < 0) {
        throw(System:Exception.new("Attempted put with index less than 0"));
      }
      if (posi >= length) {
         lengthSet(posi + 1);
      }
      emit(jv,cs,js) {
      """
      this.bevi_list[beva_posi.bevi_int] = beva_val;
      """
      }
      emit(cc) {
      """
      bevi_list[BEQP(beva_posi)->bevi_int] = BEQP(beva_val);
      """
      }
   }
   
   get(Int posi) {
      any val;
      if ((posi >= 0) && (posi < length)) {
      emit(jv,cs,js) {
      """
      bevl_val = this.bevi_list[beva_posi.bevi_int];
      """
      }
      emit(cc) {
      """
      BEQP(bevl_val) = bevi_list[BEQP(beva_posi)->bevi_int];
      """
      }
      }
      return(val);
   }
   
   remove(Int pos)  {
      if (pos < length) {
         Int fl = length - 1;
         Int j = pos + 1;
         for (Int i = pos.copy();i < fl;i++) {
            put(i, get(j));
            j++;
         }
         put(fl, null);
         lengthSet(length - 1);
         return(true);
      }
      return(false);
   }
   
   iteratorGet() {
      return(Container:List:Iterator.new(self));
   }
   
   clear() this {
      for (Int i = 0;i < length;i++) {
         put(i, null);
      }
      length = 0;
   }
   
   copy() self {
      List n = create();
      for (Int i = 0;i < length;i++) {
         n[i] = self[i];
      }
      return(n);
   }
   
   create(Int len) { return(List.new(len)); }
   
   create() self { return(List.new(length)); }
   
   add(List xi) self {
      List yi = List.new(0, length + xi.length);
      for (any c in self) {
         yi.addValueWhole(c);
      }
      for (c in xi) {
         yi.addValueWhole(c);
      }
      return(yi);
   }
   
   sort() self {
      return(mergeSort());
   }
   
   sortValue() self {
      sortValue(0, length);
   }
   
   sortValue(Int start, Int end) self {
      for (Int i = start.copy();i < end;i++) {
         Int c = i.copy();
         for (Int j = i.copy();j < end;j++) {
            if (self[j] < self[c]) {
               c = j.copy();
            }
         }
         any hold = self[i];
         self[i] = self[c];
         self[c] = hold;
      }
   }
   
   mergeIn(List first, List second) self {
      Int i = 0;
      Int fi = 0;
      Int si = 0;
      Int fl = first.length;
      Int sl = second.length;
      while (i < length) {
         if (fi < fl && si < sl) {
            any fo = first.get(fi);
            any so = second.get(si);
            if (so < fo) {
               si++;
               put(i, so);
            } else {
               fi++;
               put(i, fo);
            }
         } elseIf (si < sl) {
            so = second.get(si);
            si++;
            put(i, so);
         } elseIf (fi < fl) {
            fo = first.get(fi);
            fi++;
            put(i, fo);
         }
         i++;
      }
   }
   
   mergeSort() self {
      return(mergeSort(0, length));
   }
   
   mergeSort(Int start, Int end) self {
      Int mlen = end - start;
      if (mlen == 0) {
         return(create(0));
      } elseIf (mlen == 1) {
         List ra = create(1);
         ra.put(0, get(start));
         return(ra);
      } else {
         Int shalf = mlen / 2;
         Int fhalf = mlen - shalf;
         Int fend = start + fhalf;
         List fa = mergeSort(start, fend);
         List sa = mergeSort(fend, end);
         ra = create(mlen);
         ra.mergeIn(fa, sa);
         return(ra);
      }
   }
   
   lengthSet(Int newlen) {
      
      if (newlen > capacity) {
         Int newcap = newlen * multiplier;
         emit(jv) {
         """
         this.bevi_list = java.util.Arrays.copyOf(this.bevi_list, bevl_newcap.bevi_int);
         """
         }
         emit(cs) {
         """
         Array.Resize(ref bevi_list, bevl_newcap.bevi_int);
         """
         }
         emit(js) {
         """
         this.bevi_list[bevl_newcap.bevi_int - 1] = null;//js arrays grow :-)
         """
         }
         emit(cc) {
         """
         bevi_list.resize(BEQP(bevl_newcap)->bevi_int);
         """
         }
         capacity = newcap;
      }
      //zero extra
      while (length < newlen) {
        emit(jv,cs,js) {
         """
         this.bevi_list[this.bevp_length.bevi_int] = null;
         """
         }
         emit(cc) {
         """
         bevi_list[bevp_length->bevi_int] = nullptr;
         """
         }
         length++;
      }
      length.setValue(newlen);//for length decreasing cases
   }
   
   iterateAdd(val) self {
      if (def(val)) {
         while (val.hasNext) {
            addValueWhole(val.next);
         }
      }
   }
   
   addAll(val) self {
      if (def(val)) {
         iterateAdd(val.iterator);
      }
   }
   
   addValueWhole(val) self {
     if (length < capacity) {
       emit(jv,cs,js) {
       """
       this.bevi_list[this.bevp_length.bevi_int] = beva_val;
       """
       }
       emit(cc) {
       """
       bevi_list[bevp_length->bevi_int] = BEQP(beva_val);
       """
       }
       length++;
     } else {
       //length may change before put completes, must copy
       put(length.copy(), val);
     }
   }
   
   addValue(val) self {
      if (def(val) && System:Types.sameType(val, self)) {
        addAll(val);
      } else {
        addValueWhole(val);
      }
   }
   
   //find (or has) niavely finds
   find(value) Int {
     for (Int i = 0;i < length;i++) {
       any aval = get(i);
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
       any aval = get(mid);
       if (value == aval) {
        return(mid);
       } elseIf (value > aval) {
        //aval lt
        low = mid;
       } elseIf (value < aval) {
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

class Lists {

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
    return(list);//use varargs for convenient list creation
  }

}


