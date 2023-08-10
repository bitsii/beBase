/*
 * Copyright (c) 2015-2023, the Bennt Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

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

