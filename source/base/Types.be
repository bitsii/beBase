// Copyright 2006 The Brace Authors. All rights reserved.
// Use of this source code is governed by the BSD-3-Clause
// license that can be found in the LICENSE file.

final class System:Types {

   create() self { }

   default() self { }

   final fieldNames(org) List {

     List names = List.new();

     emit(cs) {
     """
     BETS_Object bevs_cano = beva_org.bemc_getType();
     string[] fnames = bevs_cano.bevs_fieldNames;

     for (int i = 0;i < fnames.Length;i++) {

       bevl_names.bem_addValue_1(new $class/Text:String$(System.Text.Encoding.UTF8.GetBytes(fnames[i])));

     }
     """
     }

     emit(jv) {
     """
     BETS_Object bevs_cano = beva_org.bemc_getType();
     String[] fnames = bevs_cano.bevs_fieldNames;

     for (int i = 0;i < fnames.length;i++) {

       bevl_names.bem_addValue_1(new $class/Text:String$(fnames[i].getBytes("UTF-8")));

     }
     """
     }


     emit(js) {
     """
     var fnames = beva_org.bepn_pnames;

     for (var i = 0;i < fnames.length;i++) {

       bevl_names.bem_addValue_1(new be_$class/Text:String$().bems_new(fnames[i].substring(5)));

     }
     """
     }

     emit(cc) {
      """

      BETS_Object* bevs_cano = beva_org->bemc_getType();
      std::vector<std::string>* fnames = &bevs_cano->bevs_fieldNames;

      for (int i = 0;i < fnames->size();i++) {

       beq->bevl_names->bem_addValue_1(new BEC_2_4_6_TextString(fnames->at(i)));

      }

      """
      }

     return(names);

   }

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
      return(false);
   }

   otherType(org, other) Bool {
      return(sameType(org, other).not());
   }

}
