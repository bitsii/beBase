/*
 * Copyright (c) 2006-2023, the Beysant Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

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
      return(false);
   }
   
   final def(ref) Bool {
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
            for (Int i = 7;i < numargs;i++) {
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
        int32_t ci = BECS_Ids::callIds[beq->bevl_cname->bems_toCcString()];
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
        int32_t swi = beq->bevl_numargs->bevi_int;
        if (swi == 0) {
            beq->bevl_rval = bemd_0(ci);
        } else if (swi == 1) {
            beq->bevl_rval = bemd_1(ci, beq->beva_args->bevi_list[0]);
        } else if (swi == 2) {
            beq->bevl_rval = bemd_2(ci, beq->beva_args->bevi_list[0], beq->beva_args->bevi_list[1]);
        } else if (swi == 3) {
            beq->bevl_rval = bemd_3(ci, beq->beva_args->bevi_list[0], beq->beva_args->bevi_list[1], beq->beva_args->bevi_list[2]);
        } else if (swi == 4) {
            beq->bevl_rval = bemd_4(ci, beq->beva_args->bevi_list[0], beq->beva_args->bevi_list[1], beq->beva_args->bevi_list[2], beq->beva_args->bevi_list[3]);
        } else if (swi == 5) {
            beq->bevl_rval = bemd_5(ci, beq->beva_args->bevi_list[0], beq->beva_args->bevi_list[1], beq->beva_args->bevi_list[2], beq->beva_args->bevi_list[3], beq->beva_args->bevi_list[4]);
        }  else if (swi == 6) {
            beq->bevl_rval = bemd_6(ci, beq->beva_args->bevi_list[0], beq->beva_args->bevi_list[1], beq->beva_args->bevi_list[2], beq->beva_args->bevi_list[3], beq->beva_args->bevi_list[4], beq->beva_args->bevi_list[5]);
        }  else if (swi == 7) {
            beq->bevl_rval = bemd_7(ci, beq->beva_args->bevi_list[0], beq->beva_args->bevi_list[1], beq->beva_args->bevi_list[2], beq->beva_args->bevi_list[3], beq->beva_args->bevi_list[4], beq->beva_args->bevi_list[5], beq->beva_args->bevi_list[6]);
        }  else {
            beq->bevl_rval = bemd_x(ci, beq->beva_args->bevi_list[0], beq->beva_args->bevi_list[1], beq->beva_args->bevi_list[2], beq->beva_args->bevi_list[3], beq->beva_args->bevi_list[4], beq->beva_args->bevi_list[5], beq->beva_args->bevi_list[6], beq->bevl_args2->bevi_list);
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
      
      String name = "" + new String(bevl_cname.bevi_bytes, 0, bevl_cname.bevp_length.bevi_int, "UTF-8");
      
      BETS_Object bevs_cano = bemc_getType();
      
      if (bevs_cano.bevs_methodNames.containsKey(name)) {
        return be.BECS_Runtime.boolTrue;
      }
      
      """
      }
      emit(cs) {
      """
      
      string name = System.Text.Encoding.UTF8.GetString(bevl_cname.bevi_bytes, 0, bevl_cname.bevp_length.bevi_int);
      
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
      ifNotEmit(noRfl) {
      emit(cc) {
      """
      
      std::string name = beq->bevl_cname->bems_toCcString();
      
      BETS_Object* bevs_cano = bemc_getType();
      
      if (bevs_cano->bevs_methodNames.count(name) > 0) {
        return BECS_Runtime::boolTrue;
      }
      
      """
      }
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
      if (this != beq->beva_x) {
        return BECS_Runtime::boolFalse;
      }
      """
      }
      return(true);
   }

   hashGet() Math:Int {
      Math:Int toRet = Math:Int.new();
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
      beq->bevl_toRet->bevi_int = co3;
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

   print(athing) {
     athing.print();
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
      emit(jv,cs,js) {
      """
      bevl_copy = this.bemc_create();
      """
      }
      emit(cc) {
      """
      beq->bevl_copy = this->bemc_create();
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

#ifdef BEDCC_SGC
   virtual BEC_2_6_6_SystemObject* bems_forwardCall(std::string mname, std::vector<BEC_2_6_6_SystemObject*> bevd_x, int32_t numargs);
#endif 
  """
}

emit(cc) {
   """

#ifdef BEDCC_SGC
    BEC_2_6_6_SystemObject* BEC_2_6_6_SystemObject::bems_forwardCall(std::string mname, std::vector<BEC_2_6_6_SystemObject*> bevd_x, int32_t numargs) {
#endif  

#ifdef BEDCC_SGC

  struct bes {  BEC_2_4_6_TextString* name; BEC_2_9_4_ContainerList* args; BEC_2_6_6_SystemObject* bevr_this;  };
  BECS_FrameStack* bevs_myStack = &BECS_Runtime::bevs_currentStack;
  bes* beq = (bes*) bevs_myStack->bevs_hs;
  beq->name = nullptr;
  beq->args = nullptr;
  beq->bevr_this = this;
  BECS_StackFrame bevs_stackFrame(3);

#endif

  //cout << "in sfwdcall " << endl;
  beq->name = new BEC_2_4_6_TextString(mname);
  beq->args = new BEC_2_9_4_ContainerList(bevd_x, numargs);
  //args = args->bem_copy_0();
  return bem_forwardCall_2(beq->name, beq->args);
  //return nullptr;
} //}

  """
}

}
