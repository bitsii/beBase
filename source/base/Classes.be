/*
 * Copyright (c) 2006-2023, the Beysant Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

class System:Classes {

  create() self { }

  default() self { }

  sameClass(org, other) Bool {
      emit(js) {
      """
      if (beva_org != null && beva_other !== null && Object.getPrototypeOf(beva_other).isPrototypeOf(beva_org) && Object.getPrototypeOf(beva_org).isPrototypeOf(beva_other)) {
        return be_BECS_Runtime.prototype.boolTrue;
      }
      """
      }
      emit(jv) {
      """
      if (beva_org != null && beva_other != null && beva_org.getClass().equals(beva_other.getClass())) {
        return be.BECS_Runtime.boolTrue;
      }
      """
      }
      emit(cs) {
      """
      if (beva_org != null && beva_other != null && beva_org.GetType() == beva_other.GetType()) {
        return be.BECS_Runtime.boolTrue;
      }
      """
      }
      emit(cc) {
      """
      if (BEQP(beva_org) != nullptr && BEQP(beva_other) != nullptr) {
        if (BEQP(beva_org)->bemc_getType() == BEQP(beva_other)->bemc_getType()) {
          return BECS_Runtime::boolTrue;
        }
      }
      """
      }
      return(false);
   }

   otherClass(org, other) Bool {
      return(sameClass(org, other).not());
   }

   final className(org) String {
      String xi;
      emit(jv) {
      """
      bevl_xi = beva_org.bemc_clnames();
      """
      }
      emit(cs) {
      """
      bevl_xi = beva_org.bemc_clnames();
      """
      }
      ifNotEmit(noSmap) {
      emit(cc) {
      """
      BEQP(bevl_xi) = BEQP(beva_org)->bemc_clnames();
      """
      }
      }
      ifNotEmit(noSmap) {
      emit(js) {
      """
      bevl_xi = new be_$class/Text:String$().beml_set_bevi_bytes_len_copy(beva_org.becs_insts.becc_clname, beva_org.becs_insts.becc_clname.length);
      """
      }
      }
      return(xi);
   }

}
