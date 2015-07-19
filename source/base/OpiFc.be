/*
Copyright 2006 Craig Welch
All rights reserved.

Developed by:

    Craig Welch

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal with
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

    * Redistributions of source code must retain the above copyright notice,
      this list of conditions and the following disclaimers.

    * Redistributions in binary form must reproduce the above copyright notice,
      this list of conditions and the following disclaimers in the
      documentation and/or other materials provided with the distribution.

    * Neither the name of the Software nor the names of its contributors may be used 
      to endorse or promote products derived from this Software without specific
      prior written permission.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
CONTRIBUTORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS WITH THE
SOFTWARE.
*/

use Logic:Bool;
use Text:String;
use Math:Int;
use Container:Array;
use Container:Pair;
use System:NonIterator;
use System:ObjectPropertyIterator;
use System:CustomPropertyIterator;
use System:ForwardCall;

emit(cs) {
    """
using System;
    """
}

final class ObjectPropertyIterator {

   new() self { }
   
   new(_instance) ObjectPropertyIterator {
      return(new(_instance, false));
   }
   
   new(_instance, Bool forceFirstSlot) ObjectPropertyIterator {
   emit(c) {
      """
/*-attr- -dec-*/
BERT_ClassDef* bevl_scldef;
void** bevl_sval;
      """
      }
      Int _minProperty;
      Int _maxProperty;
      _minProperty = Int.new();
      _maxProperty = Int.new();
      emit(c) {
      """
      bevl_scldef = (BERT_ClassDef*) $_instance&*[berdef];
      bevl_sval = $_minProperty&*;
      *((BEINT*) (bevl_sval + bercps)) = bevl_scldef->minProperty;
      bevl_sval = $_maxProperty&*;
      *((BEINT*) (bevl_sval + bercps)) = bevl_scldef->maxProperty;
      """
      }
      if (forceFirstSlot) {
      emit(c) {
      """
      bevl_sval = $_minProperty&*;
      *((BEINT*) (bevl_sval + bercps)) = bercps;
      """
      }
      }
      properties {
         var instance;
         Int minProperty;
         Int maxProperty;
         Int pos;
      }
      emit(jv) {
      """
      String prefix = "bevp_";
      java.lang.reflect.Field[] fields = beva__instance.getClass().getFields();
      int numprops = 0;
      for (int i = 0;i < fields.length;i++) {
        if (fields[i].getName().startsWith(prefix)) {
            //System.out.println("got field named " + fields[i].getName());
            numprops++;
        }
      }
      bevl__minProperty.bevi_int = 0;
      bevl__maxProperty.bevi_int = numprops;
      """
      }
      emit(cs) {
      """
      string prefix = "bevp_";
      System.Reflection.FieldInfo[] fields = beva__instance.GetType().GetFields();
      int numprops = 0;
      for (int i = 0;i < fields.Length;i++) {
        if (fields[i].Name.StartsWith(prefix)) {
            numprops++;
        }
      }
      bevl__minProperty.bevi_int = 0;
      bevl__maxProperty.bevi_int = numprops;
      """
      }
      emit(js) {
      """
      bevl__minProperty.bevi_int = 0;
      bevl__maxProperty.bevi_int = beva__instance.bepn_pnames.length;
      """
      }
      instance = _instance;
      minProperty = _minProperty;
      maxProperty = _maxProperty;
      pos = _minProperty;
      //("Min " + minProperty + " max " + maxProperty + " pos " + pos + " clname " + instance.className).print();
   }
   
   hasNextGet() Bool {
      if (pos < maxProperty) {
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
      if (pos < maxProperty) {
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
          int numprops = 0;
          for (int i = 0;i < fields.length;i++) {
            if (fields[i].getName().startsWith(prefix)) {
                if (numprops == bevl__pos.bevi_int) {
                    bevl_inst = (BEC_6_6_SystemObject) (fields[i].get(bevl__instance));
                    break;
                }
                numprops++;
            }
          }
         """
         }
         emit(cs) {
          """
          string prefix = "bevp_";
          System.Reflection.FieldInfo[] fields = bevl__instance.GetType().GetFields();
          int numprops = 0;
          for (int i = 0;i < fields.Length;i++) {
            if (fields[i].Name.StartsWith(prefix)) {
                if (numprops == bevl__pos.bevi_int) {
                    bevl_inst = (BEC_6_6_SystemObject) (fields[i].GetValue(bevl__instance));
                    break;
                }
                numprops++;
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
      if (pos < maxProperty) {
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
          int numprops = 0;
          for (int i = 0;i < fields.length;i++) {
            if (fields[i].getName().startsWith(prefix)) {
                if (numprops == bevl__pos.bevi_int) {
                    fields[i].set(bevl__instance, bevl__value);
                    break;
                }
                numprops++;
            }
          }
         """
         }
         emit(cs) {
          """
          string prefix = "bevp_";
          System.Reflection.FieldInfo[] fields = bevl__instance.GetType().GetFields();
          int numprops = 0;
          for (int i = 0;i < fields.Length;i++) {
            if (fields[i].Name.StartsWith(prefix)) {
                if (numprops == bevl__pos.bevi_int) {
                    fields[i].SetValue(bevl__instance, bevl__value);
                    break;
                }
                numprops++;
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
      if (pos > maxProperty) {
         pos = maxProperty;
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
      
      properties {
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


