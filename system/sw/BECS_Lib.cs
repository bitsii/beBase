// Copyright 2015 Craig Welch
//
// Licensed under the MIT license. See LICENSE.txt file in the project root 
// for full license information.

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

