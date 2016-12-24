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
