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


final class ObjectFieldIterator {

emit(cs) {
"""
public System.Reflection.FieldInfo[] fields;
"""
}

emit(jv) {
"""
public java.lang.reflect.Field[] fields;
"""
}

  new() self { }

  new(_instance) ObjectFieldIterator {
    return(new(_instance, false));
  }

  new(_instance, Bool forceFirstSlot) ObjectFieldIterator {
    fields {
      Int pos = -1;
      any instance = _instance;
      Bool advanced = false;
      Bool done = false;
      Bool tval = true;
    }
    emit(cs) {
    """
    fields = bevp_instance.GetType().GetFields();
    """
    }
    emit(jv) {
    """
    fields = bevp_instance.getClass().getFields();
    """
    }
  }
  
  advance() this {
   emit(cs) {
    """
    string prefix = "bevp_";
    int i = bevp_pos.bevi_int;
    i++;
    while (i < fields.Length) {
      if (fields[i].Name.StartsWith(prefix)) {
        bevp_advanced = bevp_tval;
        bevp_pos.bevi_int = i;
        return this;
      }
      i++;
    }
    bevp_done = bevp_tval;
    """
    }
    emit(jv) {
    """
    String prefix = "bevp_";
    int i = bevp_pos.bevi_int;
    i++;
    while (i < fields.length) {
      if (fields[i].getName().startsWith(prefix)) {
        bevp_advanced = bevp_tval;
        bevp_pos.bevi_int = i;
        return this;
      }
      i++;
    }
    bevp_done = bevp_tval;
    """
    }
    emit(js) {
    """
    var i = this.bevp_pos.bevi_int;
    i = i + 1;
    if (i < this.bevp_instance.bepn_pnames.length) {
        this.bevp_advanced = this.bevp_tval;
        this.bevp_pos.bevi_int = i;
        return this;
    }
    this.bevp_done = this.bevp_tval;
    """
    }
  }

  hasNextGet() Bool {
    unless (advanced || done) {
      advance();
    }
    unless (done) {
      return(true);
    }
    return(false);
  }
  
  nextNameGet() String {
    unless (advanced || done) {
      advance();
    }
    if (done) {
      return(null);
    }
    advanced = false;
    return(self.currentName);
  }
  
  currentNameGet() String {
    String res;
    emit(cs) {
    """
    bevl_res = new $class/Text:String$(fields[bevp_pos.bevi_int].Name);
    """
    }
    emit(jv) {
    """
    bevl_res = new $class/Text:String$(fields[bevp_pos.bevi_int].getName());
    """
    }
    emit(js) {
    """
    bevl_res = new be_$class/Text:String$().bems_new(this.bevp_instance.bepn_pnames[this.bevp_pos.bevi_int]);
    """
    }
    return(res.substring(5));
  }

  nextGet() any {
    unless (advanced || done) {
      advance();
    }
    if (done) {
      return(null);
    }
    advanced = false;
    return(self.current);
  }
  
  currentGet() any {
    any res;
    emit(cs) {
    """
    bevl_res = ($class/System:Object$) (fields[bevp_pos.bevi_int].GetValue(bevp_instance));
    """
    }
    emit(jv) {
    """
    bevl_res = ($class/System:Object$) (fields[bevp_pos.bevi_int].get(bevp_instance));
    """
    }
    emit(js) {
    """
    bevl_res = this.bevp_instance[this.bevp_instance.bepn_pnames[this.bevp_pos.bevi_int]];
    """
    }
    return(res);
  }

  nextSet(value) this {
    unless (advanced || done) {
      advance();
    }
    if (done!) {
      self.current = value;
    }
    advanced = false;
  }
  
  currentSet(value) this {
    emit(cs) {
    """
    fields[bevp_pos.bevi_int].SetValue(bevp_instance, beva_value);
    """
    }
    emit(jv) {
    """
    fields[bevp_pos.bevi_int].set(bevp_instance, beva_value);
    """
    }
    emit(js) {
    """
    this.bevp_instance[this.bevp_instance.bepn_pnames[this.bevp_pos.bevi_int]] = beva_value;
    """
    }
  }

  skip(Int multiNullCount) {
      for (Int mi = 0;mi < multiNullCount;mi++=) {
         self.next = null;
      }
   }

}

final class ForwardCall {

   emit(js) {
   """
   
    be_$class/System:ForwardCall$.prototype.beml_new_forward = function(name, args) {
        
        //substring name
        name = name.substring(0, name.lastIndexOf("_"));
        //make it bytes, then our string
        name = this.bems_stringToBytes_1(name);
        name = new be_$class/Text:String$().beml_set_bevi_bytes_len_copy(name, name.length);
        
        args = new be_$class/Container:List$().beml_new_array(args);
        
        this.bem_new_2(name,  args);
        
        return(this);
        
    }
    
   """
   }
   
   emit(jv) {
   """
   
   public $class/System:ForwardCall$(String name, $class/System:Object$[] args) throws Throwable {
        name = name.substring(0, name.lastIndexOf("_"));
        bem_new_2(new $class/Text:String$(name.getBytes("UTF-8")), new $class/Container:List$(args));
   }
   
   """
   }
   
   emit(cs) {
   """
   
   public $class/System:ForwardCall$(string name, $class/System:Object$[] args) {
        name = name.Substring(0, name.LastIndexOf("_"));
        bem_new_2(new $class/Text:String$(System.Text.Encoding.UTF8.GetBytes(name)), new $class/Container:List$(args));
   }
   
   """
   }
   
   new(String _name, List _args) self {
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
      List largs;
      
      numargs = Int.new();
      
      fields {
         String name;
         List args;
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
      largs = List.new(numargs);
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


