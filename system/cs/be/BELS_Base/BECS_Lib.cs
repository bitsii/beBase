// Copyright 2015 Craig Welch
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

namespace be.BELS_Base {

public class BECS_Lib {
    
    public static int getCallId(string name) {
        if (BECS_Ids.callIds.ContainsKey(name)) {
            return BECS_Ids.callIds[name];
        } else {
            int iid = BECS_Ids.callIdCounter;
            BECS_Ids.callIdCounter++;
            BECS_Ids.callIds[name] = iid;
            BECS_Ids.idCalls[iid] = name;
            return iid;
        }
    }
    
    public static void putNlcSourceMap(string clname, int[] vals) {
      BECS_Runtime.smnlcs.Add(clname, vals);
    }
    
    public static void putNlecSourceMap(string clname, int[] vals) {
      BECS_Runtime.smnlecs.Add(clname, vals);  
    }
    
}

}

