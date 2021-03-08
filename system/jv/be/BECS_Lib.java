// Copyright 2015 The Abelii Authors. All rights reserved.
// Use of this source code is governed by the BSD-3-Clause
// license that can be found in the LICENSE file.

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

