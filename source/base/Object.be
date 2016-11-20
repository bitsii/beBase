// Copyright 2006 Craig Welch
//
// Licensed under the MIT license. See LICENSE.txt file in the project root 
// for full license information.

use Container:Pair;
use System:NonIterator;
use System:ObjectFieldIterator;
use System:CustomFieldIterator;
use System:ForwardCall;

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
   
   final methodNotDefined() {
      //get forwarding stuff, also clears it if present
      System:ForwardCall forwardCall = System:ForwardCall.new();
      //if forward stuff not defined, throw here
      if (forwardCall.notReady) {
         throw(System:InvocationException.new("methodNotDefined called in a context where arguments were not available from the stack"));
      }
      return(methodNotDefined(forwardCall));
   }
   
   final toAny() any {
     return(self);
   }
   
   final methodNotDefined(System:ForwardCall forwardCall) {
      if (def(forwardCall) && def(forwardCall.name)) {
        String fcn = forwardCall.name + "Args";
        if (can(fcn, 1)) {
          s = self;
          List args = List.new(1);
          args[0] = forwardCall.args;
          result = s.invoke(fcn, args);
          return(result);
        }
      }
      if (can("forwardCall", 1)) {
         //call forward with stuff
         any s = self;
         any result = s.forwardCall(forwardCall);
         return(result);
      } elseIf(true) {
         throw(System:MethodNotDefined.new("Method: " + forwardCall.name + " not defined for class " + self.className));
      }
      return(result);
   }
   
   final createInstance(String cname) {
     return(createInstance(cname, true));
   }
   
   final createInstance(String cname, Bool throwOnFail) {
   emit(c) {
      """
/*-attr- -dec-*/
BEINT bevl_chash;
void** bevl_chashv;

void* bevl_nserv;
BEINT bevl_nser;

char* bevl_cname;
void** bevl_cnamev;

      """
      }
      
      if (undef(cname)) {
         throw(System:InvocationException.new("class name is null"));
      }
      any result = null;
      
      ifEmit(c) {
      
      Int chash;   
      chash = cname.hash;
      
      String mname = "new_0";
      Int mhash = mname.hash;
      
      if (false) {
         //This is here so that dynamic call bits which we need get declared (twcv_mtdi)
         result.toString();
      }
      
      }
      
      emit(c) {
      """
bevl_chashv = $chash&*;
bevl_chash = *((BEINT*) (bevl_chashv + bercps));
bevl_cnamev = $cname&*;
bevl_cname = (char*) bevl_cnamev[bercps];

bevl_nserv = BERF_Hash_Get(BERV_proc_glob->classHash, bevl_chash, bevl_cname);
berv_sts->passedClassDef = bevl_nserv;

bevl_chashv = $mhash&*;
bevl_chash = *((BEINT*) (bevl_chashv + bercps));

bevl_cnamev = $mname&*;
bevl_cname = (char*) bevl_cnamev[bercps];

bevl_nserv = BERF_Hash_Get(BERV_proc_glob->nameHash, bevl_chash, bevl_cname);
if (bevl_nserv != NULL) {
bevl_nser = (BEINT) bevl_nserv;

twcv_mtdi = bevl_nser % berv_sts->passedClassDef->dmlistlen;
twcv_mtddef = berv_sts->passedClassDef->dmlist[twcv_mtdi];
$result=* BERF_Create_Instance(berv_sts, berv_sts->passedClassDef, 0);
/* $result=* ((becd0)twcv_mtddef->mcall)( 1, berv_sts, BERF_Create_Instance(berv_sts, berv_sts->passedClassDef, 0)); */
}

      """
      }
      emit(jv) {
        """
        String key = new String(beva_cname.bevi_bytes, 0, beva_cname.bevp_size.bevi_int, "UTF-8");
        Class ti = be.BECS_Runtime.typeInstances.get(key);
        if (ti != null) {
            //System.out.println("Getting new instance for |" + key + "|");
            bevl_result = ($class/System:Object$) ti.newInstance();
        } 
        //else {
        //    System.out.println("No typeInstance for |" + key + "|");
        //}
        """
      }
      emit(cs) {
        """
        string key = System.Text.Encoding.UTF8.GetString(beva_cname.bevi_bytes, 0, beva_cname.bevp_size.bevi_int);
        Type ti = be.BECS_Runtime.typeInstances[key];
        if (ti != null) {
            bevl_result = ($class/System:Object$) Activator.CreateInstance(ti);
        }
        """
      }
      emit(js) {
      """
      var ti = be_BECS_Runtime.prototype.typeInstances[this.bems_stringToJsString_1(beva_cname)];
      if (null != ti) {
        bevl_result = ti.bemc_create();
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
   emit(c) {
      """
/*-attr- -dec-*/
BEINT bevl_chash;
void** bevl_chashv;

BEINT bevl_nser;
void* bevl_nserv;

void** bevl_numargsv;
BEINT bevl_numargs;

char* bevl_oname;
void** bevl_onamev;

char* bevl_cname;
void** bevl_cnamev;
void** bevl_rval;

void** bevl_receiver;
void** bevl_twvm;

void** bevl_mcall;

      """
      }
      String cname;
      Int chash;
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
      chash = cname.hash;
      
      ifEmit(c,js) {
        args = args.copy(); //do we still need to do this? - yes for js, to be sure the array is exactly the length of the args
      }
      ifEmit(jv,cs) {
        if (numargs > 7) { 
            List args2 = List.new(numargs - 7); 
            for (Int i = 7;i < numargs;i++=) {
                args2[i - 7] = args[i];
            }
        }
      }
      emit(jv) {
        """
        int ci = be.BECS_Ids.callIds.get(new String(bevl_cname.bevi_bytes, 0, bevl_cname.bevp_size.bevi_int, "UTF-8"));
        """
      }
      emit(cs) {
        """
        int ci = be.BECS_Ids.callIds[System.Text.Encoding.UTF8.GetString(bevl_cname.bevi_bytes, 0, bevl_cname.bevp_size.bevi_int)];
        """
      }
      emit(jv,cs) {
        """
        if (bevl_numargs.bevi_int == 0) {
            bevl_rval = bemd_0(bevl_chash.bevi_int, ci);
        } else if (bevl_numargs.bevi_int == 1) {
            bevl_rval = bemd_1(bevl_chash.bevi_int, ci, beva_args.bevi_list[0]);
        } else if (bevl_numargs.bevi_int == 2) {
            bevl_rval = bemd_2(bevl_chash.bevi_int, ci, beva_args.bevi_list[0], beva_args.bevi_list[1]);
        } else if (bevl_numargs.bevi_int == 3) {
            bevl_rval = bemd_3(bevl_chash.bevi_int, ci, beva_args.bevi_list[0], beva_args.bevi_list[1], beva_args.bevi_list[2]);
        } else if (bevl_numargs.bevi_int == 4) {
            bevl_rval = bemd_4(bevl_chash.bevi_int, ci, beva_args.bevi_list[0], beva_args.bevi_list[1], beva_args.bevi_list[2], beva_args.bevi_list[3]);
        } else if (bevl_numargs.bevi_int == 5) {
            bevl_rval = bemd_5(bevl_chash.bevi_int, ci, beva_args.bevi_list[0], beva_args.bevi_list[1], beva_args.bevi_list[2], beva_args.bevi_list[3], beva_args.bevi_list[4]);
        } else if (bevl_numargs.bevi_int == 6) {
            bevl_rval = bemd_6(bevl_chash.bevi_int, ci, beva_args.bevi_list[0], beva_args.bevi_list[1], beva_args.bevi_list[2], beva_args.bevi_list[3], beva_args.bevi_list[4], beva_args.bevi_list[5]);
        } else if (bevl_numargs.bevi_int == 7) {
            bevl_rval = bemd_7(bevl_chash.bevi_int, ci, beva_args.bevi_list[0], beva_args.bevi_list[1], beva_args.bevi_list[2], beva_args.bevi_list[3], beva_args.bevi_list[4], beva_args.bevi_list[5], beva_args.bevi_list[6]);
        } else {
            bevl_rval = bemd_x(bevl_chash.bevi_int, ci, beva_args.bevi_list[0], beva_args.bevi_list[1], beva_args.bevi_list[2], beva_args.bevi_list[3], beva_args.bevi_list[4], beva_args.bevi_list[5], beva_args.bevi_list[6], bevl_args2.bevi_list);
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
      emit(c) {
      """

bevl_twvm = $args&*;
bevl_twvm = (void**) bevl_twvm[bercps];

bevl_chashv = $chash&*;
bevl_chash = *((BEINT*) (bevl_chashv + bercps));

bevl_numargsv = $numargs&*;
bevl_numargs = *((BEINT*) (bevl_numargsv + bercps));

bevl_onamev = $name&*;
bevl_oname = (char*) bevl_onamev[bercps];

bevl_cnamev = $cname&*;
bevl_cname = (char*) bevl_cnamev[bercps];

bevl_nserv = BERF_Hash_Get(BERV_proc_glob->nameHash, bevl_chash, bevl_cname);
if (bevl_nserv != NULL) {
bevl_nser = (BEINT) bevl_nserv;

twcv_cdef = (BERT_ClassDef*) bevs[berdef];
twcv_mtdi = bevl_nser % twcv_cdef->dmlistlen;
twcv_mtddef = twcv_cdef->dmlist[twcv_mtdi];

bevl_receiver = bevs;

bevl_mcall = twcv_mtddef->mcall;

if (twcv_mtddef->twnn == bevl_nser) {

if (bevl_numargs == 0) {
$rval=* ((becd0)bevl_mcall)( 1, berv_sts, bevl_receiver );
} else if (bevl_numargs == 1) {
$rval=* ((becd1)bevl_mcall)( 1, berv_sts, bevl_receiver, (void**) bevl_twvm[0] );
} else if (bevl_numargs == 2) {
$rval=* ((becd2)bevl_mcall)( 1, berv_sts, bevl_receiver, (void**) bevl_twvm[0], (void**) bevl_twvm[1] );
} else if (bevl_numargs == 3) {
$rval=* ((becd3)bevl_mcall)( 1, berv_sts, bevl_receiver, (void**) bevl_twvm[0], (void**) bevl_twvm[1], (void**) bevl_twvm[2] );
} else if (bevl_numargs == 4) {
$rval=* ((becd4)bevl_mcall)( 1, berv_sts, bevl_receiver, (void**) bevl_twvm[0], (void**) bevl_twvm[1], (void**) bevl_twvm[2], (void**) bevl_twvm[3] );
} else if (bevl_numargs == 5) {
$rval=* ((becd5)bevl_mcall)( 1, berv_sts, bevl_receiver, (void**) bevl_twvm[0], (void**) bevl_twvm[1], (void**) bevl_twvm[2], (void**) bevl_twvm[3], (void**) bevl_twvm[4] );
} else if (bevl_numargs == 6) {
$rval=* ((becd6)bevl_mcall)( 1, berv_sts, bevl_receiver, (void**) bevl_twvm[0], (void**) bevl_twvm[1], (void**) bevl_twvm[2], (void**) bevl_twvm[3], (void**) bevl_twvm[4], (void**) bevl_twvm[5] );
} else if (bevl_numargs == 7) {
$rval=* ((becd7)bevl_mcall)( 1, berv_sts, bevl_receiver, (void**) bevl_twvm[0], (void**) bevl_twvm[1], (void**) bevl_twvm[2], (void**) bevl_twvm[3], (void**) bevl_twvm[4], (void**) bevl_twvm[5], (void**) bevl_twvm[6] );
} else if (bevl_numargs == 8) {
$rval=* ((becd8)bevl_mcall)( 1, berv_sts, bevl_receiver, (void**) bevl_twvm[0], (void**) bevl_twvm[1], (void**) bevl_twvm[2], (void**) bevl_twvm[3], (void**) bevl_twvm[4], (void**) bevl_twvm[5], (void**) bevl_twvm[6], (void**) bevl_twvm[7] );
} else if (bevl_numargs == 9) {
$rval=* ((becd9)bevl_mcall)( 1, berv_sts, bevl_receiver, (void**) bevl_twvm[0], (void**) bevl_twvm[1], (void**) bevl_twvm[2], (void**) bevl_twvm[3], (void**) bevl_twvm[4], (void**) bevl_twvm[5], (void**) bevl_twvm[6], (void**) bevl_twvm[7], (void**) bevl_twvm[8] );
} else if (bevl_numargs == 10) {
$rval=* ((becd10)bevl_mcall)( 1, berv_sts, bevl_receiver, (void**) bevl_twvm[0], (void**) bevl_twvm[1], (void**) bevl_twvm[2], (void**) bevl_twvm[3], (void**) bevl_twvm[4], (void**) bevl_twvm[5], (void**) bevl_twvm[6], (void**) bevl_twvm[7], (void**) bevl_twvm[8], (void**) bevl_twvm[9] );
} else if (bevl_numargs == 11) {
$rval=* ((becd11)bevl_mcall)( 1, berv_sts, bevl_receiver, (void**) bevl_twvm[0], (void**) bevl_twvm[1], (void**) bevl_twvm[2], (void**) bevl_twvm[3], (void**) bevl_twvm[4], (void**) bevl_twvm[5], (void**) bevl_twvm[6], (void**) bevl_twvm[7], (void**) bevl_twvm[8], (void**) bevl_twvm[9], (void**) bevl_twvm[10] );
} else if (bevl_numargs == 12) {
$rval=* ((becd12)bevl_mcall)( 1, berv_sts, bevl_receiver, (void**) bevl_twvm[0], (void**) bevl_twvm[1], (void**) bevl_twvm[2], (void**) bevl_twvm[3], (void**) bevl_twvm[4], (void**) bevl_twvm[5], (void**) bevl_twvm[6], (void**) bevl_twvm[7], (void**) bevl_twvm[8], (void**) bevl_twvm[9], (void**) bevl_twvm[10], (void**) bevl_twvm[11] );
} else if (bevl_numargs == 13) {
$rval=* ((becd13)bevl_mcall)( 1, berv_sts, bevl_receiver, (void**) bevl_twvm[0], (void**) bevl_twvm[1], (void**) bevl_twvm[2], (void**) bevl_twvm[3], (void**) bevl_twvm[4], (void**) bevl_twvm[5], (void**) bevl_twvm[6], (void**) bevl_twvm[7], (void**) bevl_twvm[8], (void**) bevl_twvm[9], (void**) bevl_twvm[10], (void**) bevl_twvm[11], (void**) bevl_twvm[12] );
} else if (bevl_numargs == 14) {
$rval=* ((becd14)bevl_mcall)( 1, berv_sts, bevl_receiver, (void**) bevl_twvm[0], (void**) bevl_twvm[1], (void**) bevl_twvm[2], (void**) bevl_twvm[3], (void**) bevl_twvm[4], (void**) bevl_twvm[5], (void**) bevl_twvm[6], (void**) bevl_twvm[7], (void**) bevl_twvm[8], (void**) bevl_twvm[9], (void**) bevl_twvm[10], (void**) bevl_twvm[11], (void**) bevl_twvm[12], (void**) bevl_twvm[13] );
} else if (bevl_numargs == 15) {
$rval=* ((becd15)bevl_mcall)( 1, berv_sts, bevl_receiver, (void**) bevl_twvm[0], (void**) bevl_twvm[1], (void**) bevl_twvm[2], (void**) bevl_twvm[3], (void**) bevl_twvm[4], (void**) bevl_twvm[5], (void**) bevl_twvm[6], (void**) bevl_twvm[7], (void**) bevl_twvm[8], (void**) bevl_twvm[9], (void**) bevl_twvm[10], (void**) bevl_twvm[11], (void**) bevl_twvm[12], (void**) bevl_twvm[13], (void**) bevl_twvm[14] );
} else if (bevl_numargs == 16) {
$rval=* ((becd16)bevl_mcall)( 1, berv_sts, bevl_receiver, (void**) bevl_twvm[0], (void**) bevl_twvm[1], (void**) bevl_twvm[2], (void**) bevl_twvm[3], (void**) bevl_twvm[4], (void**) bevl_twvm[5], (void**) bevl_twvm[6], (void**) bevl_twvm[7], (void**) bevl_twvm[8], (void**) bevl_twvm[9], (void**) bevl_twvm[10], (void**) bevl_twvm[11], (void**) bevl_twvm[12], (void**) bevl_twvm[13], (void**) bevl_twvm[14], (void**) bevl_twvm[15] );
} else {
$rval=* ((becdx16)bevl_mcall)( 1, berv_sts, bevl_receiver, (void**) bevl_twvm[0], (void**) bevl_twvm[1], (void**) bevl_twvm[2], (void**) bevl_twvm[3], (void**) bevl_twvm[4], (void**) bevl_twvm[5], (void**) bevl_twvm[6], (void**) bevl_twvm[7], (void**) bevl_twvm[8], (void**) bevl_twvm[9], (void**) bevl_twvm[10], (void**) bevl_twvm[11], (void**) bevl_twvm[12], (void**) bevl_twvm[13], (void**) bevl_twvm[14], (void**) bevl_twvm[15], (void**) bevl_twvm[16] );
}

}
}

"""
}
      
      if (false) {
         //This is here so that dynamic call bits which we need get declared (twcv_mtdi)
         rval.toString();
      }
      return(rval);
   }
   
   can(String name, Int numargs) Bool {
   emit(c) {
      """
/*-attr- -dec-*/
BEINT bevl_chash;
void** bevl_chashv;

BEINT bevl_nser;
void* bevl_nserv;

char* bevl_cname;
void** bevl_cnamev;

BEINT twcv_mnpos;
BEINT twcv_mserial;

      """
      }
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
      chash = cname.hash;
      
      emit(c) {
      """
      
bevl_chashv = $chash&*;
bevl_chash = *((BEINT*) (bevl_chashv + bercps));
bevl_cnamev = $cname&*;
bevl_cname = (char*) bevl_cnamev[bercps];

bevl_nserv = BERF_Hash_Get(BERV_proc_glob->nameHash, bevl_chash, bevl_cname);
if (bevl_nserv != NULL) {
bevl_nser = (BEINT) bevl_nserv;

twcv_cdef = (BERT_ClassDef*) bevs[berdef];
twcv_mtdi = bevl_nser % twcv_cdef->dmlistlen;
twcv_mtddef = twcv_cdef->dmlist[twcv_mtdi];

if (twcv_mtddef->twnn == bevl_nser) {
$rval=* $cname*;
}
}
      """
      }
      emit(jv) {
      """
      String name = "bem_" + new String(bevl_cname.bevi_bytes, 0, bevl_cname.bevp_size.bevi_int, "UTF-8");
      java.lang.reflect.Method[] methods = this.getClass().getMethods();
      for (int i = 0;i < methods.length;i++) {
        if (methods[i].getName().equals(name)) {
            return be.BECS_Runtime.boolTrue;
        }
      }
      """
      }
      emit(cs) {
      """
      string name = "bem_" + System.Text.Encoding.UTF8.GetString(bevl_cname.bevi_bytes, 0, bevl_cname.bevp_size.bevi_int);
      System.Reflection.MethodInfo[] methods = this.GetType().GetMethods();
      for (int i = 0;i < methods.Length;i++) {
        if (methods[i].Name.Equals(name)) {
            return be.BECS_Runtime.boolTrue;
        }
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
      byte[] bevls_clname = bemc_clname();
      bevl_xi = new $class/Text:String$(bevls_clname.length, bevls_clname);
      """
      }
      emit(cs) {
      """
      byte[] bevls_clname = bemc_clname();
      bevl_xi = new $class/Text:String$(bevls_clname.Length, bevls_clname);
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
      byte[] bevls_clname = bemc_clfile();
      bevl_xi = new $class/Text:String$(bevls_clname.length, bevls_clname);
      """
      }
      emit(cs) {
      """
      byte[] bevls_clname = bemc_clfile();
      bevl_xi = new $class/Text:String$(bevls_clname.Length, bevls_clname);
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
   emit(c) {
      """
/*-attr- -dec-*/
void** bevl_toRet;
void** bevl_other;
BERT_ClassDef* twst_selfcd;
size_t twst_icomp;
      """
      }
      emit(c) {
      """
bevl_toRet = berv_sts->bool_False;
bevl_other = $other&*;
if (bevl_other == NULL) { BEVReturn(bevl_toRet); } 
twst_selfcd = (BERT_ClassDef*) bevs[berdef];
twst_icomp = (size_t) bevl_other[berdef];
while (twst_selfcd != NULL) {
if ((size_t) twst_selfcd == twst_icomp) {
BEVReturn(berv_sts->bool_True);
} twst_selfcd = twst_selfcd->twst_supercd; }
BEVReturn(bevl_toRet);
      """
      }
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
      return(false);
   }
   
   otherType(other) Bool {
      return(sameType(other).not());
   }

    //below two methods for handling x@ x#
    final once() self { }

    final many() self { }
   
}

