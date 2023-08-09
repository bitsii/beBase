// Copyright 2015 The Bennt Authors. All rights reserved.
// Use of this source code is governed by the BSD-3-Clause
// license that can be found in the LICENSE file.

namespace be {

using System;
using System.Collections.Generic;
using be;

public class BETS_Object {
    
  public Dictionary<string, bool> bevs_methodNames;
  public string[] bevs_fieldNames;
  
  public void bems_buildMethodNames(string[] names) {
    bevs_methodNames = new Dictionary<string, bool>();
    for (int i = 0;i < names.Length;i++) {
       bevs_methodNames[names[i]] = true;
    }
  }
  
  public virtual BEC_2_6_6_SystemObject bems_createInstance() {
    return null;
  }

}

}

