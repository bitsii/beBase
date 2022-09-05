// Copyright 2006 The Brace Authors. All rights reserved.
// Use of this source code is governed by the BSD-3-Clause
// license that can be found in the LICENSE file.

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
   
   methodNotDefined(String name, List args) any {
     if(true) {
       throw(System:MethodNotDefined.new("Method: " + name + " not defined"));
     }
   }
   
   forwardCall(String name, List args) any {
     if(true) {
       throw(System:MethodNotDefined.new("Method: " + name + " not defined"));
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
        std::string key = beva_cname->bems_toCcString();
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
      
      std::string name = bevl_cname->bems_toCcString();
      
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
      if (this != beva_x) {
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
      if (this != beva_x) {
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
      BECS_Object* co = this;
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
      BECS_Object* co = this;
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
      return("Object.toString");
   }
   
   print() {
      toString().print();
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

   iteratorGet() any {
      return(System:ObjectFieldIterator.new(self));
   }
   
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
#ifdef BEDCC_BGC
   virtual BEC_2_6_6_SystemObject* bems_forwardCall(std::string mname, std::vector<BEC_2_6_6_SystemObject*, gc_allocator<BEC_2_6_6_SystemObject*>> bevd_x, int32_t numargs);
#endif

#ifdef BEDCC_SGC
   virtual BEC_2_6_6_SystemObject* bems_forwardCall(std::string mname, std::vector<BEC_2_6_6_SystemObject*> bevd_x, int32_t numargs);
#endif 
  """
}

emit(cc) {
   """

#ifdef BEDCC_BGC
    BEC_2_6_6_SystemObject* BEC_2_6_6_SystemObject::bems_forwardCall(std::string mname, std::vector<BEC_2_6_6_SystemObject*, gc_allocator<BEC_2_6_6_SystemObject*>> bevd_x, int32_t numargs) {
#endif

#ifdef BEDCC_SGC
    BEC_2_6_6_SystemObject* BEC_2_6_6_SystemObject::bems_forwardCall(std::string mname, std::vector<BEC_2_6_6_SystemObject*> bevd_x, int32_t numargs) {
#endif  
  BEC_2_4_6_TextString* name = nullptr;
  BEC_2_9_4_ContainerList* args = nullptr;

#ifdef BEDCC_SGC
  BEC_2_6_6_SystemObject** bevls_stackRefs[2] = { (BEC_2_6_6_SystemObject**) &name, (BEC_2_6_6_SystemObject**) &args };
  BECS_StackFrame bevs_stackFrame(bevls_stackRefs, 2, this);
#endif

  //cout << "in sfwdcall " << endl;
  name = new BEC_2_4_6_TextString(mname);
  args = new BEC_2_9_4_ContainerList(bevd_x, numargs);
  //args = args->bem_copy_0();
  return bem_forwardCall_2(name, args);
  //return nullptr;
} //}

  """
}

}
