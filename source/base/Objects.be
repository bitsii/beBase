// Copyright 2006 The Brace Authors. All rights reserved.
// Use of this source code is governed by the BSD-3-Clause
// license that can be found in the LICENSE file.

class System:Objects {

  create() self { }

  default() self { }

   final sourceFileName(org) String {
      String xi;
      emit(jv) {
      """
      //byte[] bevls_clname = bemc_clfile();
      //bevl_xi = new $class/Text:String$(bevls_clname.length, bevls_clname);
      bevl_xi = beva_org.bemc_clfiles();
      """
      }
      emit(cs) {
      """
      //byte[] bevls_clname = bemc_clfile();
      //bevl_xi = new $class/Text:String$(bevls_clname.Length, bevls_clname);
      bevl_xi = beva_org.bemc_clfiles();
      """
      }
      ifNotEmit(noSmap) {
      emit(js) {
      """
      bevl_xi = new be_$class/Text:String$().beml_set_bevi_bytes_len_copy(beva_org.becs_insts.becc_clfile, beva_org.becs_insts.becc_clfile.length);
      """
      }
      }
      return(xi);
   }

   final sameObject(org, x) Bool {
      emit(jv,cs) {
      """
      if (beva_org != beva_x) {
        return be.BECS_Runtime.boolFalse;
      }
      """
      }
      emit(js) {
      """
      if (beva_org !== beva_x) {
        return be_BECS_Runtime.prototype.boolFalse;
      }
      """
      }
      emit(cc) {
      """
      if (beva_org != beva_x) {
        return BECS_Runtime::boolFalse;
      }
      """
      }
      return(true);
   }

   final tag(org) Math:Int {
      Math:Int toRet = Math:Int.new();
      emit(jv) {
      """
      bevl_toRet.bevi_int = beva_org.hashCode();
      """
      }
      emit(cs) {
      """
      bevl_toRet.bevi_int = beva_org.GetHashCode();
      """
      }
      emit(js) {
      """
      if (beva_org.becc_hash == null) {
        beva_org.becc_hash = be_BECS_Runtime.prototype.hashCounter++;
      }
      bevl_toRet.bevi_int = beva_org.becc_hash;
      """
      }
      emit(cc) {
      """
      BECS_Object* co = beva_org;
      uintptr_t cou = (uintptr_t) co;
      int32_t co3 = (int32_t) cou;
      bevl_toRet->bevi_int = co3;
      """
      }
      return(toRet);
   }

}
