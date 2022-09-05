// Copyright 2006 The Brace Authors. All rights reserved.
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
      if (beva_org != nullptr && beva_other != nullptr) {
        if (beva_org->bemc_getType() == beva_other->bemc_getType()) {
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

}
