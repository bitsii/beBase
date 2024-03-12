/*
 * Copyright (c) 2006-2023, the Brace Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

import Container:Pair;
import System:NonIterator;
import System:ObjectFieldIterator;
import System:CustomFieldIterator;


final class ObjectFieldIterator {

  new() self { }

  new(_instance) ObjectFieldIterator {
    return(new(_instance, false));
  }

  new(_instance, Bool forceFirstSlot) ObjectFieldIterator {
    slots {
      Int pos = -1;
      dyn instance = _instance;
      List instFieldNames = System:Types.fieldNames(instance);
      Int lastidx = instFieldNames.length - 1;
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

  nextGet() dyn {
    advance();
    return(self.current);
  }
  
  currentGet() dyn {
    if (self.hasCurrent) {
      String currentName = self.currentName;
      String invokeName = currentName + "Get";
      dyn res = instance.invoke(invokeName, List.new());
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
      for (Int mi = 0;mi < multiNullCount;mi++) {
         self.next = null;
      }
   }

}
