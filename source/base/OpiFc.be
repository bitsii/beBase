// Copyright 2006 Craig Welch
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

use Logic:Bool;
use Text:String;
use Math:Int;
use Container:Array;
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

final class ObjectFieldIterator {

   new() self { }
   
   new(_instance) ObjectFieldIterator {
      return(new(_instance, false));
   }
   
   new(_instance, Bool forceFirstSlot) ObjectFieldIterator {
   emit(c) {
      """
/*-attr- -dec-*/
BERT_ClassDef* bevl_scldef;
void** bevl_sval;
      """
      }
      Int _minField;
      Int _maxField;
      _minField = Int.new();
      _maxField = Int.new();
      emit(c) {
      """
      bevl_scldef = (BERT_ClassDef*) $_instance&*[berdef];
      bevl_sval = $_minField&*;
      *((BEINT*) (bevl_sval + bercps)) = bevl_scldef->minField;
      bevl_sval = $_maxField&*;
      *((BEINT*) (bevl_sval + bercps)) = bevl_scldef->maxField;
      """
      }
      if (forceFirstSlot) {
      emit(c) {
      """
      bevl_sval = $_minField&*;
      *((BEINT*) (bevl_sval + bercps)) = bercps;
      """
      }
      }
      fields {
         var instance;
         Int minField;
         Int maxField;
         Int pos;
      }
      emit(jv) {
      """
      String prefix = "bevp_";
      java.lang.reflect.Field[] fields = beva__instance.getClass().getFields();
      int numfields = 0;
      for (int i = 0;i < fields.length;i++) {
        if (fields[i].getName().startsWith(prefix)) {
            //System.out.println("got field named " + fields[i].getName());
            numfields++;
        }
      }
      bevl__minField.bevi_int = 0;
      bevl__maxField.bevi_int = numfields;
      """
      }
      emit(cs) {
      """
      string prefix = "bevp_";
      System.Reflection.FieldInfo[] fields = beva__instance.GetType().GetFields();
      int numfields = 0;
      for (int i = 0;i < fields.Length;i++) {
        if (fields[i].Name.StartsWith(prefix)) {
            numfields++;
        }
      }
      bevl__minField.bevi_int = 0;
      bevl__maxField.bevi_int = numfields;
      """
      }
      emit(js) {
      """
      bevl__minField.bevi_int = 0;
      bevl__maxField.bevi_int = beva__instance.bepn_pnames.length;
      """
      }
      instance = _instance;
      minField = _minField;
      maxField = _maxField;
      pos = _minField;
      //("Min " + minField + " max " + maxField + " pos " + pos + " clname " + instance.className).print();
   }
   
   hasNextGet() Bool {
      if (pos < maxField) {
         return(true);
      }
      return(false);
   }
      
   nextGet() {
      emit(c) {
      """
/*-attr- -dec-*/
void** bevl_sval;
void** bevl_ind;
      """
      }
      var _instance;
      Int _pos;
      var inst;
      _instance = instance;
      _pos = pos;
      if (pos < maxField) {
         emit(c) {
         """
         bevl_sval = $_instance&*;
         bevl_ind = $_pos&*;
         $inst=* bevl_sval[*((BEINT*) (bevl_ind + bercps))];
         """
         }
         emit(jv) {
         """
          String prefix = "bevp_";
          java.lang.reflect.Field[] fields = bevl__instance.getClass().getFields();
          int numfields = 0;
          for (int i = 0;i < fields.length;i++) {
            if (fields[i].getName().startsWith(prefix)) {
                if (numfields == bevl__pos.bevi_int) {
                    bevl_inst = (BEC_6_6_SystemObject) (fields[i].get(bevl__instance));
                    break;
                }
                numfields++;
            }
          }
         """
         }
         emit(cs) {
          """
          string prefix = "bevp_";
          System.Reflection.FieldInfo[] fields = bevl__instance.GetType().GetFields();
          int numfields = 0;
          for (int i = 0;i < fields.Length;i++) {
            if (fields[i].Name.StartsWith(prefix)) {
                if (numfields == bevl__pos.bevi_int) {
                    bevl_inst = (BEC_6_6_SystemObject) (fields[i].GetValue(bevl__instance));
                    break;
                }
                numfields++;
            }
          }
          """
          }
          emit(js) {
          """
          //console.log("pos " + bevl__pos.bevi_int);
          //console.log("pname " + bevl__instance.bepn_pnames[bevl__pos.bevi_int]);
          bevl_inst = bevl__instance[bevl__instance.bepn_pnames[bevl__pos.bevi_int]];
          """
          }
         pos = pos++;
      }
      return(inst);
   }
   
   nextSet(value) {
      emit(c) {
      """
/*-attr- -dec-*/
void** bevl_sval;
void** bevl_ind;
      """
      }
      var _instance;
      Int _pos;
      var _value;
      _instance = instance;
      _pos = pos;
      _value = value;
      if (pos < maxField) {
         emit(c) {
         """
         bevl_sval = $_instance&*;
         bevl_ind = $_pos&*;
         bevl_sval[*((BEINT*) (bevl_ind + bercps))] = $_value*;
         """
         }
         emit(jv) {
         """
          String prefix = "bevp_";
          java.lang.reflect.Field[] fields = bevl__instance.getClass().getFields();
          int numfields = 0;
          for (int i = 0;i < fields.length;i++) {
            if (fields[i].getName().startsWith(prefix)) {
                if (numfields == bevl__pos.bevi_int) {
                    fields[i].set(bevl__instance, bevl__value);
                    break;
                }
                numfields++;
            }
          }
         """
         }
         emit(cs) {
          """
          string prefix = "bevp_";
          System.Reflection.FieldInfo[] fields = bevl__instance.GetType().GetFields();
          int numfields = 0;
          for (int i = 0;i < fields.Length;i++) {
            if (fields[i].Name.StartsWith(prefix)) {
                if (numfields == bevl__pos.bevi_int) {
                    fields[i].SetValue(bevl__instance, bevl__value);
                    break;
                }
                numfields++;
            }
          }
          """
          }
          emit(js) {
          """
          bevl__instance[bevl__instance.bepn_pnames[bevl__pos.bevi_int]] = bevl__value;
          """
          }
         pos = pos++;
      }
   }
   
   skip(Int multiNullCount) {
      pos = pos + multiNullCount;
      if (pos > maxField) {
         pos = maxField;
      }
   }
   
}

final class ForwardCall {

   emit(js) {
   """
   
    be_BEL_4_Base_BEC_6_11_SystemForwardCall.prototype.beml_new_forward = function(name, args) {
        
        //substring name
        name = name.substring(0, name.lastIndexOf("_"));
        //make it bytes, then our string
        name = this.bems_stringToBytes_1(name);
        name = new be_BEL_4_Base_BEC_4_6_TextString().beml_set_bevi_bytes_len_copy(name, name.length);
        
        args = new be_BEL_4_Base_BEC_9_5_ContainerArray().beml_new_array(args);
        
        this.bem_new_2(name,  args);
        
        return(this);
        
    }
    
   """
   }
   
   emit(jv) {
   """
   
   public BEC_6_11_SystemForwardCall(String name, BEC_6_6_SystemObject[] args) throws Throwable {
        name = name.substring(0, name.lastIndexOf("_"));
        bem_new_2(new BEC_4_6_TextString(name.getBytes("UTF-8")), new BEC_9_5_ContainerArray(args));
   }
   
   """
   }
   
   emit(cs) {
   """
   
   public BEC_6_11_SystemForwardCall(string name, BEC_6_6_SystemObject[] args) {
        name = name.Substring(0, name.LastIndexOf("_"));
        bem_new_2(new BEC_4_6_TextString(System.Text.Encoding.UTF8.GetBytes(name)), new BEC_9_5_ContainerArray(args));
   }
   
   """
   }
   
   new(String _name, Array _args) self {
        name = _name;
        args = _args;
        notReady = false;
   }
   
   new() self {
   emit(c) {
"""
/*-attr- -dec-*/
void** bevl_aargs;
BEINT i;
void** bevl_na;
"""
}
      Int numargs;
      String lname;
      Array largs;
      
      numargs = Int.new();
      
      fields {
         String name;
         Array args;
         Bool notReady = true;
      }
      
      emit(c) {
      """
      if (berv_sts->forwardArgs != NULL) {
         bevl_na = $numargs&*;
         *((BEINT*) bevl_na + bercps) = berv_sts->forwardNumargs;
         $lname=* BERF_String_For_Chars(berv_sts, berv_sts->forwardName);
      """
      }
      largs = Array.new(numargs);
      args = largs;
      name = lname;
      notReady = false;
      emit(c) {
      """
      bevl_aargs = (void**) $largs&*[bercps];
      for (i = 0;i < berv_sts->forwardNumargs;i++) {
         bevl_aargs[i] = berv_sts->forwardArgs[i];
      }
      if (berv_sts->forwardNumargs > beramax) {
        BENoFree(berv_sts->forwardArgs);
      }
      berv_sts->forwardArgs = NULL;
      berv_sts->forwardName = NULL;
      berv_sts->forwardNumargs = 0;
      }
      """
      }
   }
   
}


