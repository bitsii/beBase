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
      if (beq->beva_org != beq->beva_x) {
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
      BECS_Object* co = beq->beva_org;
      uintptr_t cou = (uintptr_t) co;
      int32_t co3 = (int32_t) cou;
      beq->bevl_toRet->bevi_int = co3;
      """
      }
      return(toRet);
   }

   final createInstance(String cname) {
     return(createInstance(cname, true));
   }

   final createInstance(String cname, Bool throwOnFail) {
      if (undef(cname)) {
         throw(System:InvocationException.new("class name is null"));
      }
      any result = null;

      emit(jv) {
        """
        String key = new String(beva_cname.bevi_bytes, 0, beva_cname.bevp_size.bevi_int, "UTF-8");
        BETS_Object ti = be.BECS_Runtime.typeRefs.get(key);
        if (ti != null) {
            bevl_result = ti.bems_createInstance();
        }
        """
      }
      emit(cs) {
        """
        string key = System.Text.Encoding.UTF8.GetString(beva_cname.bevi_bytes, 0, beva_cname.bevp_size.bevi_int);
        BETS_Object ti = be.BECS_Runtime.typeRefs[key];
        if (ti != null) {
            bevl_result = ti.bems_createInstance();
        }
        """
      }
      emit(js) {
      """
      var ti = be_BECS_Runtime.prototype.typeRefs[this.bems_stringToJsString_1(beva_cname)];
      if (null != ti) {
        bevl_result = ti.bemc_create();
      }
      """
      }
      emit(cc) {
        """
        std::string key = beq->beva_cname->bems_toCcString();
        //cout << key << endl;
        if (BECS_Runtime::typeRefs.count(key) > 0) {
          //cout << "has key" << endl;

          BETS_Object* ti = BECS_Runtime::typeRefs[key];

          //works
          //BETS_Object* ti = static_cast<BETS_Object*>   //(&BEC_2_4_3_MathInt::bece_BEC_2_4_3_MathInt_bevs_type);

          //works
          //BET_2_4_3_MathInt* mi = new BET_2_4_3_MathInt();
          //BETS_Object* ti = dynamic_cast<BETS_Object*> (mi);


          beq->bevl_result = ti->bems_createInstance();

        }
        if (beq->bevl_result == nullptr) {
          //cout << "res nptr" << endl;
        }
        """
      }

      if (undef(result)) {
        if (throwOnFail) {
         throw(System:Exception.new("Class not found " + cname));
        } else {
          return(null);
        }
      }
      return(System:Initializer.new().initializeIfShould(result));
   }

}
