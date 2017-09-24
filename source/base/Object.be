// Copyright 2006 Craig Welch
//
// Licensed under the MIT license. See LICENSE.txt file in the project root 
// for full license information.

use Container:Pair;
use System:NonIterator;
use System:ObjectFieldIterator;
use System:CustomFieldIterator;

emit(cs) {
    """
using System;
    """
}


class System:Object {

   new() self { }
   
   //EmitCommon has def/undef inline, so no implementation here
   final undefined(ref) Bool {
      emit(c) {
      """
      if ($ref* == NULL) {
         BEVReturn(berv_sts->bool_True);
      }
      """
      }
      return(false);
   }
   
   final defined(ref) Bool {
      emit(c) {
      """
      if ($ref* == NULL) {
         BEVReturn(berv_sts->bool_False);
      }
      """
      }
      return(true);
   }
   
   final undef(ref) Bool {
      emit(c) {
      """
      if ($ref* == NULL) {
         BEVReturn(berv_sts->bool_True);
      }
      """
      }
      return(false);
   }
   
   final def(ref) Bool {
      emit(c) {
      """
      if ($ref* == NULL) {
         BEVReturn(berv_sts->bool_False);
      }
      """
      }
      return(true);
   }
   
   final toAny() any {
     return(self);
   }
   
   methodNotDefined(String name, List args) any {
     if(true) {
       throw(System:MethodNotDefined.new("Method: " + name + " not defined for class " + self.className));
     }
   }
   
   forwardCall(String name, List args) any {
     if(true) {
       throw(System:MethodNotDefined.new("Method: " + name + " not defined for class " + self.className));
     }
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
        string key = beva_cname->bems_toCcString();
        //cout << key << endl;
        if (BECS_Runtime::typeRefs.count(key) > 0) {
          //cout << "has key" << endl;
          
          BETS_Object* ti = BECS_Runtime::typeRefs[key];
          
          //works
          //BETS_Object* ti = static_cast<BETS_Object*>   //(&BEC_2_4_3_MathInt::bece_BEC_2_4_3_MathInt_bevs_type);
          
          //works
          //BET_2_4_3_MathInt* mi = new BET_2_4_3_MathInt();
          //BETS_Object* ti = dynamic_cast<BETS_Object*> (mi);
          
          
          bevl_result = ti->bems_createInstance();
          //bevl_result = //static_pointer_cast<BEC_2_6_6_SystemObject>(make_shared<BEC_2_4_3_MathInt>());
          
        } 
        if (bevl_result == nullptr) {
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
   
   final fieldNamesGet() List {
     
     List names = List.new();
     
     emit(cs) {
     """
     BETS_Object bevs_cano = bemc_getType();
     string[] fnames = bevs_cano.bevs_fieldNames;
     
     for (int i = 0;i < fnames.Length;i++) {
     
       bevl_names.bem_addValue_1(new $class/Text:String$(System.Text.Encoding.UTF8.GetBytes(fnames[i])));

     }
     """
     }
     
     emit(jv) {
     """
     BETS_Object bevs_cano = bemc_getType();
     String[] fnames = bevs_cano.bevs_fieldNames;
     
     for (int i = 0;i < fnames.length;i++) {
     
       bevl_names.bem_addValue_1(new $class/Text:String$(fnames[i].getBytes("UTF-8")));

     }
     """
     }
     
     
     emit(js) {
     """
     var fnames = this.bepn_pnames;
     
     for (var i = 0;i < fnames.length;i++) {
     
       bevl_names.bem_addValue_1(new be_$class/Text:String$().bems_new(fnames[i].substring(5)));

     }
     """
     }
     
     emit(cc) {
      """
      
      BETS_Object* bevs_cano = bemc_getType();
      std::vector<std::string>* fnames = &bevs_cano->bevs_fieldNames;

      for (int i = 0;i < fnames->size();i++) {

       bevl_names->bem_addValue_1(static_pointer_cast<BEC_2_6_6_SystemObject>(make_shared<BEC_2_4_6_TextString>(fnames->at(i))));

      }
      
      """
      }
     
     return(names);
   
   }
   
   final invoke(String name, List args) {
      String cname;
      any rval;
      Int numargs;
      
      if (undef(name)) {
         throw(System:InvocationException.new("invocation name is null"));
      }
      if (undef(args)) {
         throw(System:InvocationException.new("invocation argument List is null"));
      }
      numargs = args.length;
      cname = name + "_" + numargs.toString();
      
      ifEmit(c,js) {
        args = args.copy(); //do we still need to do this? - yes for js, to be sure the array is exactly the length of the args
      }
      ifEmit(jv,cs,cc) {
        if (numargs > 7) { 
            List args2 = List.new(numargs - 7); 
            for (Int i = 7;i < numargs;i++=) {
                args2[i - 7] = args[i];
            }
        }
      }
      emit(jv) {
        """
        int ci = be.BECS_Ids.callIds.get(bevl_cname.bems_toJvString());
        """
      }
      emit(cs) {
        """
        int ci = be.BECS_Ids.callIds[bevl_cname.bems_toCsString()];
        """
      }
      emit(cc) {
        """
        int32_t ci = BECS_Ids::callIds[bevl_cname->bems_toCcString()];
        //check for count first?  this inserts the val
        """
      }
      emit(jv,cs) {
        """
        if (bevl_numargs.bevi_int == 0) {
            bevl_rval = bemd_0(ci);
        } else if (bevl_numargs.bevi_int == 1) {
            bevl_rval = bemd_1(ci, beva_args.bevi_list[0]);
        } else if (bevl_numargs.bevi_int == 2) {
            bevl_rval = bemd_2(ci, beva_args.bevi_list[0], beva_args.bevi_list[1]);
        } else if (bevl_numargs.bevi_int == 3) {
            bevl_rval = bemd_3(ci, beva_args.bevi_list[0], beva_args.bevi_list[1], beva_args.bevi_list[2]);
        } else if (bevl_numargs.bevi_int == 4) {
            bevl_rval = bemd_4(ci, beva_args.bevi_list[0], beva_args.bevi_list[1], beva_args.bevi_list[2], beva_args.bevi_list[3]);
        } else if (bevl_numargs.bevi_int == 5) {
            bevl_rval = bemd_5(ci, beva_args.bevi_list[0], beva_args.bevi_list[1], beva_args.bevi_list[2], beva_args.bevi_list[3], beva_args.bevi_list[4]);
        } else if (bevl_numargs.bevi_int == 6) {
            bevl_rval = bemd_6(ci, beva_args.bevi_list[0], beva_args.bevi_list[1], beva_args.bevi_list[2], beva_args.bevi_list[3], beva_args.bevi_list[4], beva_args.bevi_list[5]);
        } else if (bevl_numargs.bevi_int == 7) {
            bevl_rval = bemd_7(ci, beva_args.bevi_list[0], beva_args.bevi_list[1], beva_args.bevi_list[2], beva_args.bevi_list[3], beva_args.bevi_list[4], beva_args.bevi_list[5], beva_args.bevi_list[6]);
        } else {
            bevl_rval = bemd_x(ci, beva_args.bevi_list[0], beva_args.bevi_list[1], beva_args.bevi_list[2], beva_args.bevi_list[3], beva_args.bevi_list[4], beva_args.bevi_list[5], beva_args.bevi_list[6], bevl_args2.bevi_list);
        }
        """
      }
      emit(cc) {
        """
        if (bevl_numargs->bevi_int == 0) {
            bevl_rval = bemd_0(ci);
        } else if (bevl_numargs->bevi_int == 1) {
            bevl_rval = bemd_1(ci, beva_args->bevi_list[0]);
        } else if (bevl_numargs->bevi_int == 2) {
            bevl_rval = bemd_2(ci, beva_args->bevi_list[0], beva_args->bevi_list[1]);
        } else if (bevl_numargs->bevi_int == 3) {
            bevl_rval = bemd_3(ci, beva_args->bevi_list[0], beva_args->bevi_list[1], beva_args->bevi_list[2]);
        } else if (bevl_numargs->bevi_int == 4) {
            bevl_rval = bemd_4(ci, beva_args->bevi_list[0], beva_args->bevi_list[1], beva_args->bevi_list[2], beva_args->bevi_list[3]);
        } else if (bevl_numargs->bevi_int == 5) {
            bevl_rval = bemd_5(ci, beva_args->bevi_list[0], beva_args->bevi_list[1], beva_args->bevi_list[2], beva_args->bevi_list[3], beva_args->bevi_list[4]);
        }  else if (bevl_numargs->bevi_int == 6) {
            bevl_rval = bemd_6(ci, beva_args->bevi_list[0], beva_args->bevi_list[1], beva_args->bevi_list[2], beva_args->bevi_list[3], beva_args->bevi_list[4], beva_args->bevi_list[5]);
        }  else if (bevl_numargs->bevi_int == 7) {
            bevl_rval = bemd_7(ci, beva_args->bevi_list[0], beva_args->bevi_list[1], beva_args->bevi_list[2], beva_args->bevi_list[3], beva_args->bevi_list[4], beva_args->bevi_list[5], beva_args->bevi_list[6]);
        }  else {
            bevl_rval = bemd_x(ci, beva_args->bevi_list[0], beva_args->bevi_list[1], beva_args->bevi_list[2], beva_args->bevi_list[3], beva_args->bevi_list[4], beva_args->bevi_list[5], beva_args->bevi_list[6], bevl_args2->bevi_list);
        }
        """
      }
      emit(js) {
      """
        var tf = this["bem_" + this.bems_stringToJsString_1(bevl_cname)];
        //console.log("name is bem_" + s);
      if (tf != null) {
        //console.log("tf is not null");
        bevl_rval = tf.apply(this, beva_args.bevi_list);
      } else {
        //console.log("tf is null");
      }
      """
      }
      
      if (false) {
         //This is here so that dynamic call bits which we need get declared (twcv_mtdi)
         rval.toString();
      }
      return(rval);
   }
   
   final can(String name, Int numargs) Bool {
      String cname;
      Int chash;
      any rval;
      
      if (undef(name)) {
         throw(System:InvocationException.new("can() name is null"));
      }
      if (undef(numargs)) {
         throw(System:InvocationException.new("can() numargs is null"));
      }
      cname = name + "_" + numargs.toString();
      
      emit(jv) {
      """
      
      String name = "" + new String(bevl_cname.bevi_bytes, 0, bevl_cname.bevp_size.bevi_int, "UTF-8");
      
      BETS_Object bevs_cano = bemc_getType();
      
      if (bevs_cano.bevs_methodNames.containsKey(name)) {
        return be.BECS_Runtime.boolTrue;
      }
      
      """
      }
      emit(cs) {
      """
      
      string name = System.Text.Encoding.UTF8.GetString(bevl_cname.bevi_bytes, 0, bevl_cname.bevp_size.bevi_int);
      
      BETS_Object bevs_cano = bemc_getType();
      
      if (bevs_cano.bevs_methodNames.ContainsKey(name)) {
        return be.BECS_Runtime.boolTrue;
      }
      
      """
      }
      emit(js) {
      """
      if (this["bem_" + this.bems_stringToJsString_1(bevl_cname)] != null) {
        return be_BECS_Runtime.prototype.boolTrue;
      }
      """
      }
      emit(cc) {
      """
      
      string name = bevl_cname->bems_toCcString();
      
      BETS_Object* bevs_cano = bemc_getType();
      
      if (bevs_cano->bevs_methodNames.count(name) > 0) {
        return BECS_Runtime::boolTrue;
      }
      
      """
      }
      if (false) {
         rval.toString();
      }
      if (def(rval)) {
         return(true);
      }
      return(false);
   }
   
   final classNameGet() String {
   emit(c) {
      """
/*-attr- -dec-*/
BERT_ClassDef* bevl_cldef;
      """
      }
      String xi;
      emit(c) {
"""
bevl_cldef = (BERT_ClassDef*) bevs[berdef];
$xi=* BERF_String_For_Chars(berv_sts, bevl_cldef->className);
"""
      }
      emit(jv) {
      """
      //byte[] bevls_clname = bemc_clname();
      //bevl_xi = new $class/Text:String$(bevls_clname.length, bevls_clname);
      bevl_xi = bemc_clnames();
      """
      }
      emit(cs) {
      """
      //byte[] bevls_clname = bemc_clname();
      //bevl_xi = new $class/Text:String$(bevls_clname.Length, bevls_clname);
      bevl_xi = bemc_clnames();
      """
      }
      emit(cc) {
      """
      bevl_xi = bemc_clnames();
      """
      }
      emit(js) {
      """
      bevl_xi = new be_$class/Text:String$().beml_set_bevi_bytes_len_copy(this.becs_insts.becc_clname, this.becs_insts.becc_clname.length);
      """
      }
      return(xi);
   }
   
   final sourceFileNameGet() String {
      String xi;
      emit(jv) {
      """
      //byte[] bevls_clname = bemc_clfile();
      //bevl_xi = new $class/Text:String$(bevls_clname.length, bevls_clname);
      bevl_xi = bemc_clfiles();
      """
      }
      emit(cs) {
      """
      //byte[] bevls_clname = bemc_clfile();
      //bevl_xi = new $class/Text:String$(bevls_clname.Length, bevls_clname);
      bevl_xi = bemc_clfiles();
      """
      }
      emit(js) {
      """
      bevl_xi = new be_$class/Text:String$().beml_set_bevi_bytes_len_copy(this.becs_insts.becc_clfile, this.becs_insts.becc_clfile.length);
      """
      }
      return(xi);
   }
   
   equals(x) Bool {
   emit(c) {
      """
/*-attr- -dec-*/
void** bevl_x;
      """
      }
      emit(c) {
      """
      bevl_x = $x&*;
      if ((bevl_x == NULL) || ((size_t) bevl_x != (size_t) bevs)) {
         BEVReturn(berv_sts->bool_False);
      }
      """
      }
      emit(jv,cs) {
      """
      if (this != beva_x) {
        return be.BECS_Runtime.boolFalse;
      }
      """
      }
      emit(js) {
      """
      if (this !== beva_x) {
        return be_BECS_Runtime.prototype.boolFalse;
      }
      """
      }
      emit(cc) {
      """
      if (dynamic_cast<BECS_Object*>(this) != dynamic_cast<BECS_Object*>(beva_x.get())) {
        return BECS_Runtime::boolFalse;
      }
      """
      }
      return(true);
   }
   
   final sameObject(x) Bool {
   emit(c) {
      """
/*-attr- -dec-*/
void** bevl_x;
      """
      }
      emit(c) {
      """
      bevl_x = $x&*;
      if ((bevl_x == NULL) || ((size_t) bevl_x != (size_t) bevs)) {
         BEVReturn(berv_sts->bool_False);
      }
      """
      }
      emit(jv,cs) {
      """
      if (this != beva_x) {
        return be.BECS_Runtime.boolFalse;
      }
      """
      }
      emit(js) {
      """
      if (this !== beva_x) {
        return be_BECS_Runtime.prototype.boolFalse;
      }
      """
      }
      emit(cc) {
      """
      if (dynamic_cast<BECS_Object*>(this) != dynamic_cast<BECS_Object*>(beva_x.get())) {
        return BECS_Runtime::boolFalse;
      }
      """
      }
      return(true);
   }
   
   final tagGet() Math:Int {
      emit(c) {
      """
/*-attr- -dec-*/
void** bevl_toRetv;
BEINT* bevl_toRet;
      """
      }
      Math:Int toRet = Math:Int.new();
      emit(c) {
      """
      bevl_toRetv = $toRet&*;
      bevl_toRet = (BEINT*) (bevl_toRetv + bercps);
      *bevl_toRet = (BEINT) bevs;
      """
      }
      emit(jv) {
      """
      bevl_toRet.bevi_int = hashCode();
      """
      }
      emit(cs) {
      """
      bevl_toRet.bevi_int = GetHashCode();
      """
      }
      emit(js) {
      """
      if (this.becc_hash == null) {
        this.becc_hash = be_BECS_Runtime.prototype.hashCounter++;
      }
      bevl_toRet.bevi_int = this.becc_hash;
      """
      }
      emit(cc) {
      """
      BECS_Object* co = dynamic_cast<BECS_Object*>(this);
      uintptr_t cou = (uintptr_t) co;
      int32_t co3 = (int32_t) cou;
      bevl_toRet->bevi_int = co3;
      """
      }
      return(toRet);
   }
   
   hashGet() Math:Int {
      emit(c) {
      """
/*-attr- -dec-*/
void** bevl_toRetv;
BEINT* bevl_toRet;
      """
      }
      Math:Int toRet = Math:Int.new();
      emit(c) {
      """
      bevl_toRetv = $toRet&*;
      bevl_toRet = (BEINT*) (bevl_toRetv + bercps);
      *bevl_toRet = (BEINT) bevs;
      """
      }
      emit(jv) {
      """
      bevl_toRet.bevi_int = hashCode();
      """
      }
      emit(cs) {
      """
      bevl_toRet.bevi_int = GetHashCode();
      """
      }
      emit(js) {
      """
      if (this.becc_hash == null) {
        this.becc_hash = be_BECS_Runtime.prototype.hashCounter++;
      }
      bevl_toRet.bevi_int = this.becc_hash;
      """
      }
      emit(cc) {
      """
      BECS_Object* co = dynamic_cast<BECS_Object*>(this);
      uintptr_t cou = (uintptr_t) co;
      int32_t co3 = (int32_t) cou;
      bevl_toRet->bevi_int = co3;
      """
      }
      return(toRet);
   }
   
   notEquals(x) Bool {
      return(equals(x)!);
   }
   
   toString() String {
      return(self.className);
   }
   
   print() {
      toString().print();
   }
   
   echo() {
      toString().echo();
   }
   
   copy() self {
     return(copyTo(create()));
   }
   
    copyTo(copy) self {
        if (undef(copy)) {
            return(copy);
        }
        ObjectFieldIterator siter = ObjectFieldIterator.new(self, true);
        ObjectFieldIterator citer = ObjectFieldIterator.new(copy, true);
        while (siter.hasNext) {
            citer.next = siter.next;
        }
    }
   
   //Serialization related
   deserializeClassNameGet() String {
      return(self.className);
   }
   
   deserializeFromString(String snw) any { }
   
   serializeToString() String {
      return(null);
   }
   
   deserializeFromStringNew(String snw) self { }
   
   serializationIteratorGet() {
      return(System:ObjectFieldIterator.new(self));
   }
   
   iteratorGet() any {
      return(System:ObjectFieldIterator.new(self));
   }
   
   final fieldIteratorGet() System:ObjectFieldIterator {
      return(System:ObjectFieldIterator.new(self));
   }
   
   serializeContents() Bool {
      return(true);
   }
   //end serialization related
   
   create() self {
   any copy;
   emit(c) {
      """
/*-attr- -dec-*/
BERT_ClassDef* bevl_scldef;
      """
      }
      emit(c) {
      """
         bevl_scldef = (BERT_ClassDef*) bevs[berdef];
         $copy=* BERF_Create_Instance(berv_sts, bevl_scldef, 0);
      """
      }
      emit(jv,cs,js) {
      """
      bevl_copy = this.bemc_create();
      """
      }
      emit(cc) {
      """
      bevl_copy = this->bemc_create();
      """
      }
      return(copy);
   }
   
   sameClass(other) Bool {
   emit(c) {
      """
/*-attr- -dec-*/
BERT_ClassDef* bevl_scldef;
BERT_ClassDef* bevl_ocldef;
void** bevl_other;
      """
      }
      emit(c) {
      """
      bevl_other = $other&*;
      if (bevl_other != NULL) {
         bevl_scldef = (BERT_ClassDef*) bevs[berdef];
         bevl_ocldef = (BERT_ClassDef*) bevl_other[berdef];
         if ((size_t) bevl_scldef == (size_t) bevl_ocldef) {
            BEVReturn(berv_sts->bool_True);
         } else {
            BEVReturn(berv_sts->bool_False);
         }
      }
      """
      }
      emit(js) {
      """
      if (beva_other !== null && Object.getPrototypeOf(beva_other).isPrototypeOf(this) && Object.getPrototypeOf(this).isPrototypeOf(beva_other)) {
        return be_BECS_Runtime.prototype.boolTrue;
      }
      """
      }
      emit(jv) {
      """
      if (beva_other != null && this.getClass().equals(beva_other.getClass())) {
        return be.BECS_Runtime.boolTrue;
      }
      """
      }
      emit(cs) {
      """
      if (beva_other != null && this.GetType() == beva_other.GetType()) {
        return be.BECS_Runtime.boolTrue;
      }
      """
      }
      emit(cc) {
      """
      if (beva_other != nullptr) {
        if (this->bemc_getType() == beva_other->bemc_getType()) {
          return BECS_Runtime::boolTrue;
        }
      }
      """
      }
      return(false);
   }
   
   otherClass(other) Bool {
      return(sameClass(other).not());
   }
      
   /* 
      returns true if this instance (self) is an instance of the same
      class or a subclass of other sameType(Object.new()) is always true
      Object.new().sameType(NotObjectClass.new()) is always false 
      (the instance which is the argument to the call is the limiter)
      */
      
   sameType(other) Bool {
      emit(js) {
      """
      if (beva_other !== null && Object.getPrototypeOf(beva_other).isPrototypeOf(this)) {
        return be_BECS_Runtime.prototype.boolTrue;
      }
      """
      }
      emit(jv) {
      """
      if (beva_other != null && beva_other.getClass().isAssignableFrom(this.getClass())) {
        return be.BECS_Runtime.boolTrue;
      }
      """
      }
      emit(cs) {
      """
      if (beva_other != null && beva_other.GetType().IsAssignableFrom(this.GetType())) {
        return be.BECS_Runtime.boolTrue;
      }
      """
      }
      emit(cc) {
      """
      if (beva_other != nullptr) {
        //if the other type is same or parent type of mine
        BETS_Object* bevs_mt = bemc_getType();
        BETS_Object* bevs_ot = beva_other->bemc_getType();
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
   
   otherType(other) Bool {
      return(sameType(other).not());
   }
   
   final getMethod(String nameac) Method {
     Int cd = nameac.rfind("_");
     String name = nameac.substring(0, cd);
     Int ac = Int.new(nameac.substring(cd + 1));
     return(getMethod(name, ac));
   }
   
   final getMethod(String name, Int ac) Method {
      return(Method.new(self, name, ac));
   }
   
   final getInvocation(String name, List args) System:Invocation {
      return(System:Invocation.new(self, name, args));
   }

    //below two methods for handling x@ x#
    final once() self { }

    final many() self { }
    
   emit(cs) {
   """
   public virtual BEC_2_6_6_SystemObject bems_methodNotDefined(string name, $class/System:Object$[] args) { 
     name = name.Substring(0, name.LastIndexOf("_"));
     return bem_methodNotDefined_2(new $class/Text:String$(System.Text.Encoding.UTF8.GetBytes(name)), new $class/Container:List$(args));
   }
   public virtual BEC_2_6_6_SystemObject bems_forwardCallCp(BEC_2_4_6_TextString name, BEC_2_9_4_ContainerList args) { 
     args = (BEC_2_9_4_ContainerList) args.bem_copy_0();
     return bem_forwardCall_2(name, args);
   }
   """
   }
   
   emit(jv) {
   """
   public BEC_2_6_6_SystemObject bems_methodNotDefined(String name, $class/System:Object$[] args) throws Throwable { 
     name = name.substring(0, name.lastIndexOf("_"));
     return bem_methodNotDefined_2(new $class/Text:String$(name.getBytes("UTF-8")), new $class/Container:List$(args));
   }
   """
   }
   
   emit(js) {
   """
   be_$class/System:Object$.prototype.bems_forwardCall = function(name, args, len) {
       return this.bem_forwardCall_2(new be_$class/Text:String$().bems_new(name), new be_$class/Container:List$().bems_new_array(args, len));
    }
   """
   }

emit(cc_classHead) {
   """
virtual shared_ptr<BEC_2_6_6_SystemObject> bems_forwardCall(string mname, vector<shared_ptr<BEC_2_6_6_SystemObject>> bevd_x, int32_t numargs);
  """
}

emit(cc) {
   """

shared_ptr<BEC_2_6_6_SystemObject> BEC_2_6_6_SystemObject::bems_forwardCall(string mname, vector<shared_ptr<BEC_2_6_6_SystemObject>> bevd_x, int32_t numargs) {
  //cout << "in sfwdcall " << endl;
  shared_ptr<BEC_2_4_6_TextString> name = make_shared<BEC_2_4_6_TextString>(mname);
  shared_ptr<BEC_2_9_4_ContainerList> args = make_shared<BEC_2_9_4_ContainerList>(bevd_x, numargs);
  //args = args->bem_copy_0();
  return bem_forwardCall_2(name, args);
  //return nullptr;
}

  """
}

}

class System:Variadic {

  final forwardCall(String name, List args) any {
    if (can(name, 1)) {
      List varargs = List.new(1);
      varargs[0] = args;
      any result = invoke(name, varargs);
    }
    return(result);
   }

}

class System:WeakRef {

emit(jv,cs) {
"""
public BEC_2_6_6_SystemObject beps_ref;
"""
}

emit(cc_classHead) {
"""
//weak_ptr<BEC_2_6_6_SystemObject> beps_ref;
shared_ptr<BEC_2_6_6_SystemObject> beps_ref;
"""
}

  final forwardCall(String name, List args) any {
    return(self.ref.invoke(name, args));
   }
   
   new(ref) self {
    self.ref = ref;
   }
   
   refGet() any {
     any ref;
     emit(jv,cs) {
     """
       bevl_ref = beps_ref;
     """
     }
     emit(cc) {
       """
       //bevl_ref = beps_ref.lock();
       bevl_ref = beps_ref;
       """
     }
     return(ref);
   }
   
   refSet(ref) any {
     emit(jv,cs,cc) {
     """
     beps_ref = beva_ref;
     """
     }
   }

}

