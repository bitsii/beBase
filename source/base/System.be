// Copyright 2006 The Brace Authors. All rights reserved.
// Use of this source code is governed by the BSD-3-Clause
// license that can be found in the LICENSE file.

 use Container:LinkedList;
 use Container:LinkedList:Node;
 use Container:LinkedList:Iterator as LIter;
 use Container:Map;
 use System:Random;
 use System:Identity;
 
 emit(cs) {
     """
 using System;
 using System.Security.Cryptography;
    """
}

use final class System:Initializer {

    initializeIfShould(inst) {
        if (inst.can("default", 0)) {
            return(initializeIt(inst));
        }
        return(inst.new());
    }
    
    //don't you call this, it's just for use by the lang init TODO expose notNull characteristic on the runtime class and key off that
    //also, this is one of the "special" calls, it can't reference itself (in c it's called with a null self reference)
    //first pass, just construct and set the class inst
    notNullInitConstruct(inst) {
      any init;
      emit(jv,cs,js) {
      """
      bevl_init = beva_inst.bemc_getInitial();
      """
      }
      emit(cc) {
      """
      bevl_init = beva_inst->bemc_getInitial();
      """
      }
      if (undef(init)) {
        init = inst;
          emit(jv,cs,js) {
          """
          beva_inst.bemc_setInitial(bevl_init);
          """
          }
          emit(cc) {
          """
          beva_inst->bemc_setInitial(bevl_init);
          """
          }
      }
      return(init);
    }
    
    //second pass - calling default - can only be called on instances which have the method :-)
    notNullInitDefault(inst) {
      any init;
      emit(jv,cs,js) {
      """
      bevl_init = beva_inst.bemc_getInitial();
      """
      }
      emit(cc) {
      """
      bevl_init = beva_inst->bemc_getInitial();
      """
      }
      init.default();
    }
    
    //don't you call this, it's just for use by the lang init TODO expose notNull characteristic on the runtime class and key off that
    //also, this is one of the "special" calls, it can't reference itself (in c it's called with a null self reference)
    notNullInitIt(inst) {
     emit(c) {
      """
/*-attr- -dec-*/
BERT_ClassDef* bevl_scldef;
      """
      }
      any init;
      emit(c) {
      """
         bevl_scldef = (BERT_ClassDef*) $inst&*[berdef];
         $init=* berv_sts->onceInstances[bevl_scldef->classId];
      """
      }
      emit(jv,cs,js) {
      """
      bevl_init = beva_inst.bemc_getInitial();
      """
      }
      if (undef(init)) {
        init = inst;
        if (init.can("default", 0)) {
            init.default();
        }
        emit(c) {
          """
             berv_sts->onceInstances[bevl_scldef->classId] = $init*;
             BERF_Add_Once(berv_sts, $init&*);
          """
          }
          emit(jv,cs,js) {
          """
          beva_inst.bemc_setInitial(bevl_init);
          """
          }
      }
      return(init);
    }
    
    //this is one of the "special" calls, it can't reference itself (in c it's called with a null self reference)
    initializeIt(inst) {
     emit(c) {
      """
/*-attr- -dec-*/
BERT_ClassDef* bevl_scldef;
      """
      }
      any init;
      emit(c) {
      """
         bevl_scldef = (BERT_ClassDef*) $inst&*[berdef];
         $init=* berv_sts->onceInstances[bevl_scldef->classId];
      """
      } 
      emit(jv,cs,js) {
      """
      bevl_init = beva_inst.bemc_getInitial();
      """
      }
      if (undef(init)) {
        init = inst;
        init.default();
        emit(c) {
          """
             berv_sts->onceInstances[bevl_scldef->classId] = $init*;
             BERF_Add_Once(berv_sts, $init&*);
          """
          }
          emit(jv,cs,js) {
          """
          beva_inst.bemc_setInitial(bevl_init);
          """
          }
      }
      return(init);
    }

}

//have PseudoRandom for faster, no crypto option

final class Random {

   emit(jv) {
   """
   
    public java.security.SecureRandom srand = new java.security.SecureRandom();
    
   """
   }
   
   emit(cs) {
   """
   
   public RandomNumberGenerator srand = RNGCryptoServiceProvider.Create();
   
   """
   }

   create() self { }
   
   default() self {
      
      seedNow();
   }
   
   seedNow() Random {
      emit(c) {
      """
      srand(time(0));
      """
      }
      emit(jv) {
      """
      srand.setSeed(srand.generateSeed(8));
      """
      }
      emit(cs) {
      """
      srand = RNGCryptoServiceProvider.Create();
      """
      }
      emit(cc) {
      """
      srand(time(0));
      """
      }
      
   }
   
   getInt() Int {
     return(getInt(Int.new()));
   }
   
   getInt(Int value) Int {
      emit(c) {
      """
      *((BEINT*) ($value&* + bercps)) = rand();
      """
      }
      emit(jv) {
      """
      beva_value.bevi_int = srand.nextInt();
      """
      }
      emit(cs) {
      """
      byte[] rb = new byte[4];
      srand.GetBytes(rb);
      beva_value.bevi_int = BitConverter.ToInt32(rb, 0);
      """
      }
      emit(cc) {
      """
      beva_value->bevi_int = rand();
      """
      }
      emit(js) {
      """
      beva_value.bevi_int = Math.random() * Number.MAX_SAFE_INTEGER;
      """
      }
      return(value);
   }
   
   getIntMax(Int max) Int {
      return(getInt(Int.new()).absValue().modulusValue(max));
   }
   
   getIntMax(Int value, Int max) Int {
      return(getInt(value).absValue().modulusValue(max));
   }
   
   getString(Int size) String {
      return(getString(String.new(size), size));
   }
   
   getString(String str, Int size) String {
      if (str.capacity < size) {
        str.capacity = size;
      }
      str.size = size.copy();
      ifEmit(c) {
        str.setIntUnchecked(size, 0);
      }
      //TODO for jv, cs could just call nextBytes
      Int value = Int.new();
      for (Int i = 0;i < size;i++=) {
          //TODO lc and ints too
          str.setIntUnchecked(i, getIntMax(value, 26).addValue(65));
      }
      return(str);
   }
   
}

final class System:Thing {
   
   emit(c) {
   """
/*-attr- -firstSlotNative-*/
   """
   }
   
   vthingGet() { }
   
   vthingSet(vthing) { }
   
   new() self {
      
      fields {
         //any vthing;
      }
      
   }
}
