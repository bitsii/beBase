package abe.BELS_Base;

import java.util.*;

import abe.BEL_4_Base.BEC_6_6_SystemObject;
import abe.BEL_4_Base.BEC_5_4_LogicBool;
import abe.BEL_4_Base.BEC_6_11_SystemInitializer;

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

