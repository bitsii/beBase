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

      BETS_Object* bevs_cano = beva_org.bemc_getType();
      std::vector<std::string>* fnames = &bevs_cano->bevs_fieldNames;

      for (int i = 0;i < fnames->size();i++) {

       bevl_names->bem_addValue_1(new BEC_2_4_6_TextString(fnames->at(i)));

      }

      """
      }

     return(names);

   }

}
