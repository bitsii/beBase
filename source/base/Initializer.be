/*
 * Copyright (c) 2006-2023, the Brace Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

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
      beq->bevl_init = beq->beva_inst->bemc_getInitial();
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
          beq->beva_inst->bemc_setInitial(beq->bevl_init);
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
      beq->bevl_init = beq->beva_inst->bemc_getInitial();
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
