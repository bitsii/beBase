// Copyright 2006 The Brace Authors. All rights reserved.
// Use of this source code is governed by the BSD-3-Clause
// license that can be found in the LICENSE file.

use Container:Pair;
use System:NonIterator;
use System:ObjectFieldIterator;
use System:CustomFieldIterator;


final class ObjectFieldIterator {

  new() self { }

  new(_instance) ObjectFieldIterator {
    return(new(_instance, false));
  }

  new(_instance, Bool forceFirstSlot) ObjectFieldIterator {
    fields {
      Int pos = -1;
      any instance = _instance;
      List instFieldNames = instance.fieldNames;
      Int lastidx = instFieldNames.size - 1;
    }
  }
  
  advance() {
    if (self.hasNext) {
      pos = pos++;
    }
  }

  hasNextGet() Bool {
    if (pos < lastidx) {
      return(true);
    }
    return(false);
  }
  
  hasCurrentGet() Bool {
    if (pos <= lastidx) {
      return(true);
    }
    return(false);
  }
  
  nextNameGet() String {
    advance();
    return(self.currentName);
  }
  
  currentNameGet() String {
    if (self.hasCurrent) {
      return(instFieldNames[pos]);
    }
    return(null);
  }

  nextGet() any {
    advance();
    return(self.current);
  }
  
  currentGet() any {
    if (self.hasCurrent) {
      String currentName = self.currentName;
      String invokeName = currentName + "Get";
      any res = instance.invoke(invokeName, List.new());
      return(res);
    }
    return(null);
  }

  nextSet(value) this {
    advance();
    self.current = value;
  }
  
  currentSet(value) this {
    if (self.hasCurrent) {
      String currentName = self.currentName;
      String invokeName = currentName + "Set";
      List args = List.new(1);
      args[0] = value;
      instance.invoke(invokeName, args);
    }
  }

  skip(Int multiNullCount) {
      for (Int mi = 0;mi < multiNullCount;mi++=) {
         self.next = null;
      }
   }

}
