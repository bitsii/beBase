// Copyright 2015 Craig Welch
//
// Licensed under the MIT license. See LICENSE.txt file in the project root 
// for full license information.

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

