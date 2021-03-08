// Copyright 2015 The Abelii Authors. All rights reserved.
// Use of this source code is governed by the BSD-3-Clause
// license that can be found in the LICENSE file.

namespace be {

public class BECS_Lib {
  
    public static void putCallId(string name, int iid) {
        BECS_Ids.callIds[name] = iid;
        BECS_Ids.idCalls[iid] = name;
    }
    
    public static int getCallId(string name) {
        return BECS_Ids.callIds[name];
    }
    
    public static void putNlcSourceMap(string clname, int[] vals) {
      BECS_Runtime.smnlcs.Add(clname, vals);
    }
    
    public static void putNlecSourceMap(string clname, int[] vals) {
      BECS_Runtime.smnlecs.Add(clname, vals);  
    }
    
}

}

