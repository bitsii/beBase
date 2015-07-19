// Copyright 2015 Craig Welch
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

package be.BELS_Base;

import java.util.*;

import be.BEL_4_Base.BEC_6_6_SystemObject;
import be.BEL_4_Base.BEC_5_4_LogicBool;
import be.BEL_4_Base.BEC_6_11_SystemInitializer;

//This should be the var type to avoid unnecessary casting
//if we want to optimize "object" level calls we can put the signatures
//in this class and call directly...

//members array and mod for dynamic calls

public class BECS_Runtime {
    
    public static boolean isInitted = false;
   
    public static BEC_5_4_LogicBool boolTrue = new BEC_5_4_LogicBool(true);
    public static BEC_5_4_LogicBool boolFalse = new BEC_5_4_LogicBool(false);
    
    public static Map<String, Class> typeInstances;
    
    //for setting up initial instances
    public static BEC_6_11_SystemInitializer initializer;
    
    public static String platformName;
    
    public static String[] args;
    
    public static void init() { 
        if (isInitted) { return; }
        isInitted = true;
        BECS_Ids.callIds = new HashMap<String, Integer>();
        BECS_Ids.idCalls = new HashMap<Integer, String>();
        BECS_Ids.callIdCounter = 0;
        typeInstances = new HashMap<String, Class>();
        initializer = new BEC_6_11_SystemInitializer();
    }
    
}

