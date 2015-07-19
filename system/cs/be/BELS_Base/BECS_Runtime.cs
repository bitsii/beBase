// Copyright 2015 Craig Welch
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

namespace be.BELS_Base {

using System;
using System.Collections.Generic;
using be.BEL_4_Base;

public class BECS_Runtime {
    
    public static bool isInitted = false;
    
    public static BEC_5_4_LogicBool boolTrue = new BEC_5_4_LogicBool(true);
    public static BEC_5_4_LogicBool boolFalse = new BEC_5_4_LogicBool(false);
    
    public static Dictionary<string, Type> typeInstances;
    
    //for setting up initial instances
    public static BEC_6_11_SystemInitializer initializer;
    
    public static string platformName;
    
    public static string[] args;
    
    public static void init() { 
        if (isInitted) { return; }
        isInitted = true;
        BECS_Ids.callIds = new Dictionary<string, int>();
        BECS_Ids.idCalls = new Dictionary<int, string>();
        BECS_Ids.callIdCounter = 0;
        typeInstances = new Dictionary<string, Type>();
        initializer = new BEC_6_11_SystemInitializer();
    }
    
}

}

