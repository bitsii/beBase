// Copyright 2006 The Bennt Authors. All rights reserved.
// Use of this source code is governed by the BSD-3-Clause
// license that can be found in the LICENSE file.

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
      if (beq->beva_org != nullptr && beq->beva_other != nullptr) {
        if (beq->beva_org->bemc_getType() == beq->beva_other->bemc_getType()) {
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
      beq->bevl_xi = beq->beva_org->bemc_clnames();
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
