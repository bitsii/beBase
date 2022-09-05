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

}
