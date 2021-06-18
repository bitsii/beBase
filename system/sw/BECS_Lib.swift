// Copyright 2015 The Brace Authors. All rights reserved.
// Use of this source code is governed by the BSD-3-Clause
// license that can be found in the LICENSE file.

class BECS_Lib {
  
    static func putCallId(name:String?, iid:Int?) {
        //BECS_Ids.callIds[name] = iid;
        //BECS_Ids.idCalls[iid] = name;
    }
    
    static func getCallId(name:String?) -> Int? {
        //return BECS_Ids.callIds[name];
        return nil;
    }
    
    static func putNlcSourceMap(clname:String?, vals:[Int]?) {
      //BECS_Runtime.smnlcs.Add(clname, vals);
    }
    
    static func putNlecSourceMap(clname:String?, vals:[Int]?) {
      //BECS_Runtime.smnlecs.Add(clname, vals);  
    }
    
}
