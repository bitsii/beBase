// Copyright 2015 Craig Welch
//
// Licensed under the MIT license. See LICENSE.txt file in the project root 
// for full license information.

package be;

import java.util.*;

//Native / generated Object, rather than this class is the untyped/var type to avoid unnecessary casting

import be.BEC_2_6_6_SystemObject;

public class BETS_Object {
  
  public Map<String, Boolean> bevs_methodNames;
  public String[] bevs_fieldNames;
  
  public void bems_buildMethodNames(String[] names) {
    bevs_methodNames = new HashMap<String, Boolean>();
    for (int i = 0;i < names.length;i++) {
       bevs_methodNames.put(names[i], true);
    }
  }
  
  public BEC_2_6_6_SystemObject bems_createInstance() {
    return null;
  }
    
}


