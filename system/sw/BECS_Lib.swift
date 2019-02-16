// Copyright 2015 Craig Welch
//
// Licensed under the MIT license. See LICENSE.txt file in the project root 
// for full license information.

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
