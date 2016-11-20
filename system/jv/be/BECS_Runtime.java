// Copyright 2015 Craig Welch
//
// Licensed under the MIT license. See LICENSE.txt file in the project root 
// for full license information.

package be;

import java.util.*;

import be.BEC_2_6_6_SystemObject;
import be.BEC_2_5_4_LogicBool;
import be.BEC_2_6_11_SystemInitializer;

//This should be the var type to avoid unnecessary casting
//if we want to optimize "object" level calls we can put the signatures
//in this class and call directly...

//members array and mod for dynamic calls

public class BECS_Runtime {
    
    public static boolean isInitted = false;
   
    public static BEC_2_5_4_LogicBool boolTrue = new BEC_2_5_4_LogicBool(true);
    public static BEC_2_5_4_LogicBool boolFalse = new BEC_2_5_4_LogicBool(false);
    
    public static Map<String, Class> typeInstances;
    
    //for setting up initial instances
    public static BEC_2_6_11_SystemInitializer initializer;
    
    public static String platformName;
    
    public static String[] args;
    
    public static Map<String, int[]> smnlcs;
    public static Map<String, int[]> smnlecs;
    
    public static void init() { 
        if (isInitted) { return; }
        isInitted = true;
        BECS_Ids.callIds = new HashMap<String, Integer>();
        BECS_Ids.idCalls = new HashMap<Integer, String>();
        BECS_Ids.callIdCounter = 0;
        typeInstances = new HashMap<String, Class>();
        smnlcs = new HashMap<String, int[]>();
        smnlecs = new HashMap<String, int[]>();
        initializer = new BEC_2_6_11_SystemInitializer();
    }
    
    public static int getNlcForNlec(String clname, int val) {
      int[] sls = smnlcs.get(clname);
      int[] esls = smnlecs.get(clname);
      if (esls != null) {
        int eslslen = esls.length;
        for (int i = 0;i < eslslen;i++) {
          if (esls[i] == val) {
            return sls[i];
          }
        }
      } else {
        return -2; 
      }
      return -1;
    }
    
}

