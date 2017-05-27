// Copyright 2015 Craig Welch
//
// Licensed under the MIT license. See LICENSE.txt file in the project root 
// for full license information.

package be;

import be.BEC_2_6_6_SystemObject;

public class BECS_Lib {
  
    public static void putCallId(String name, int iid) {
        BECS_Ids.callIds.put(name, iid);
        BECS_Ids.idCalls.put(iid, name);
    }
    
    public static int getCallId(String name) {
        return BECS_Ids.callIds.get(name);
    }
    
    public static void putNlcSourceMap(String clname, int[] vals) {
      BECS_Runtime.smnlcs.put(clname, vals);
    }
    
    public static void putNlecSourceMap(String clname, int[] vals) {
      BECS_Runtime.smnlecs.put(clname, vals);  
    }
    
}

