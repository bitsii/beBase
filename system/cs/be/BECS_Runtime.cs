// Copyright 2015 Craig Welch
//
// Licensed under the MIT license. See LICENSE.txt file in the project root 
// for full license information.

namespace be {

using System;
using System.Collections.Generic;
using be;

public class BECS_Runtime {
    
    public static bool isInitted = false;
    
    public static BEC_2_5_4_LogicBool boolTrue = new BEC_2_5_4_LogicBool(true);
    public static BEC_2_5_4_LogicBool boolFalse = new BEC_2_5_4_LogicBool(false);
    
    public static Dictionary<string, Type> typeInstances;
    
    public static Dictionary<string, BETS_Object> typeRefs;
    
    //for setting up initial instances
    public static BEC_2_6_11_SystemInitializer initializer;
    
    public static string platformName;
    
    public static string[] args;
    
    public static Dictionary<string, int[]> smnlcs;
    public static Dictionary<string, int[]> smnlecs;
    
    public static void init() { 
        if (isInitted) { return; }
        isInitted = true;
        BECS_Ids.callIds = new Dictionary<string, int>();
        BECS_Ids.idCalls = new Dictionary<int, string>();
        typeInstances = new Dictionary<string, Type>();
        typeRefs = new Dictionary<string, BETS_Object>();
        smnlcs = new Dictionary<string, int[]>();
        smnlecs = new Dictionary<string, int[]>();
        initializer = new BEC_2_6_11_SystemInitializer();
    }
    
        
    public static int getNlcForNlec(string clname, int val) {
      int[] sls = smnlcs[clname];
      int[] esls = smnlecs[clname];
      if (esls != null) {
        //Console.WriteLine("esls is not null " + clname + " val " + val);
        int eslslen = esls.Length;
        for (int i = 0;i < eslslen;i++) {
          //Console.WriteLine("esls i " + esls[i]);
          if (esls[i] == val) {
            return sls[i];
          }
        }
      } else {
        //Console.WriteLine("esls is null " + clname);
      }
      return -1;
    }
    
}

}

