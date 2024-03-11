/*
 * Copyright (c) 2006-2023, the Brace Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

use System:ObjectFieldIterator;


final class ObjectFieldIterator {

  new() self { }

  new(_instance) ObjectFieldIterator {
    return(self);
  }

  new(_instance, Bool forceFirstSlot) ObjectFieldIterator {
    return(self);
  }

  hasNextGet() Bool {
    return(false);
  }

  nextGet() dyn {
    return(null);
  }

  nextSet(dyn it) {
  }
}

final class System:Types {

   create() self { }

   default() self { }

      /*
      returns true if this instance (self) is an instance of the same
      class or a subclass of other sameType(Object.new()) is always true
      Object.new().sameType(NotObjectClass.new()) is always false
      (the instance which is the argument to the call is the limiter)
      */

   sameType(org, other) Bool {
      emit(js) {
      """
      if (beva_other !== null && Object.getPrototypeOf(beva_other).isPrototypeOf(beva_org)) {
        return be_BECS_Runtime.prototype.boolTrue;
      }
      """
      }
      emit(jv) {
      """
      if (beva_other != null && beva_other.getClass().isAssignableFrom(beva_org.getClass())) {
        return be.BECS_Runtime.boolTrue;
      }
      """
      }
      emit(cs) {
      """
      if (beva_other != null && beva_other.GetType().IsAssignableFrom(beva_org.GetType())) {
        return be.BECS_Runtime.boolTrue;
      }
      """
      }
      ifNotEmit(noRfl) {
      emit(cc) {
      """
      if (beq->beva_other != nullptr) {
        //if the other type is same or parent type of mine
        BETS_Object* bevs_mt = beq->beva_org->bemc_getType();
        BETS_Object* bevs_ot = beq->beva_other->bemc_getType();
        while (bevs_mt != NULL) {
          if (bevs_mt == bevs_ot) {
            return BECS_Runtime::boolTrue;
          } else {
            bevs_mt = bevs_mt->bevs_parentType;
          }
        }
      }
      """
      }
      }
      return(false);
   }

   otherType(org, other) Bool {
      return(sameType(org, other).not());
   }

}

use System:Exception;

class System:Exception {
   
   new(descr) self {
      
      fields {
         dyn description;
      }
      
      description = descr;
   }
   
   toString() String {
    return(description);
  }

}

final class System:MethodNotDefined(System:Exception) {

}

final class System:InvocationException(System:Exception) {
}
