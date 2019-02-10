// Copyright 2015 Craig Welch
//
// Licensed under the MIT license. See LICENSE.txt file in the project root 
// for full license information.

class BECS_Object {
  
    init() { }
    
    /*func bemd_0(int callId) throws -> BEC_2_6_6_SystemObject? { 
        //throw new System.Exception("Failed in bemd_0");
        //BEC_2_6_6_SystemObject[] args = new BEC_2_6_6_SystemObject[0];
        //return ((BEC_2_6_6_SystemObject) this).bems_methodNotDefined(BECS_Ids.idCalls[callId], args);
        return nil; 
    }

    func bemd_1(int callId, BEC_2_6_6_SystemObject bevd_0) throws -> BEC_2_6_6_SystemObject? { 
        //throw new System.Exception("Failed in bemd_1");  
        //BEC_2_6_6_SystemObject[] args = { bevd_0 };
        //return ((BEC_2_6_6_SystemObject) this).bems_methodNotDefined(BECS_Ids.idCalls[callId], args);
        return nil; 
    }
    
    func BEC_2_6_6_SystemObject bemd_2(int callId, BEC_2_6_6_SystemObject bevd_0, BEC_2_6_6_SystemObject bevd_1) { 
        //throw new System.Exception("Failed in bemd_2");  
        BEC_2_6_6_SystemObject[] args = { bevd_0, bevd_1 };
        return ((BEC_2_6_6_SystemObject) this).bems_methodNotDefined(BECS_Ids.idCalls[callId], args); 
    }
    
    func BEC_2_6_6_SystemObject bemd_3(int callId, BEC_2_6_6_SystemObject bevd_0, BEC_2_6_6_SystemObject bevd_1, BEC_2_6_6_SystemObject bevd_2) { 
        //throw new System.Exception("Failed in bemd_3");  
        BEC_2_6_6_SystemObject[] args = { bevd_0, bevd_1, bevd_2 };
        return ((BEC_2_6_6_SystemObject) this).bems_methodNotDefined(BECS_Ids.idCalls[callId], args); 
    }
    
    func BEC_2_6_6_SystemObject bemd_4(int callId, BEC_2_6_6_SystemObject bevd_0, BEC_2_6_6_SystemObject bevd_1, BEC_2_6_6_SystemObject bevd_2, BEC_2_6_6_SystemObject bevd_3) { 
        //throw new System.Exception("Failed in bemd_4");  
        BEC_2_6_6_SystemObject[] args = { bevd_0, bevd_1, bevd_2, bevd_3 };
        return ((BEC_2_6_6_SystemObject) this).bems_methodNotDefined(BECS_Ids.idCalls[callId], args); 
    }
    
    func BEC_2_6_6_SystemObject bemd_5(int callId, BEC_2_6_6_SystemObject bevd_0, BEC_2_6_6_SystemObject bevd_1, BEC_2_6_6_SystemObject bevd_2, BEC_2_6_6_SystemObject bevd_3, BEC_2_6_6_SystemObject bevd_4) { 
        //throw new System.Exception("Failed in bemd_5");  
        BEC_2_6_6_SystemObject[] args = { bevd_0, bevd_1, bevd_2, bevd_3, bevd_4 };
        return ((BEC_2_6_6_SystemObject) this).bems_methodNotDefined(BECS_Ids.idCalls[callId], args); 
    }
    
    func BEC_2_6_6_SystemObject bemd_6(int callId, BEC_2_6_6_SystemObject bevd_0, BEC_2_6_6_SystemObject bevd_1, BEC_2_6_6_SystemObject bevd_2, BEC_2_6_6_SystemObject bevd_3, BEC_2_6_6_SystemObject bevd_4, BEC_2_6_6_SystemObject bevd_5) { 
        //throw new System.Exception("Failed in bemd_5");
        BEC_2_6_6_SystemObject[] args = { bevd_0, bevd_1, bevd_2, bevd_3, bevd_4, bevd_5 };  
        return ((BEC_2_6_6_SystemObject) this).bems_methodNotDefined(BECS_Ids.idCalls[callId], args); 
    }
    
    func BEC_2_6_6_SystemObject bemd_7(int callId, BEC_2_6_6_SystemObject bevd_0, BEC_2_6_6_SystemObject bevd_1, BEC_2_6_6_SystemObject bevd_2, BEC_2_6_6_SystemObject bevd_3, BEC_2_6_6_SystemObject bevd_4, BEC_2_6_6_SystemObject bevd_5, BEC_2_6_6_SystemObject bevd_6) { 
        //throw new System.Exception("Failed in bemd_7");
        BEC_2_6_6_SystemObject[] args = { bevd_0, bevd_1, bevd_2, bevd_3, bevd_4, bevd_5, bevd_6 };  
        return ((BEC_2_6_6_SystemObject) this).bems_methodNotDefined(BECS_Ids.idCalls[callId], args); 
    }
    
    func BEC_2_6_6_SystemObject bemd_x(int callId, BEC_2_6_6_SystemObject bevd_0, BEC_2_6_6_SystemObject bevd_1, BEC_2_6_6_SystemObject bevd_2, BEC_2_6_6_SystemObject bevd_3, BEC_2_6_6_SystemObject bevd_4, BEC_2_6_6_SystemObject bevd_5, BEC_2_6_6_SystemObject bevd_6, BEC_2_6_6_SystemObject[] bevd_x) { 
        //throw new System.Exception("Failed in bemd_x");
        BEC_2_6_6_SystemObject[] args = new BEC_2_6_6_SystemObject[7 + bevd_x.Length];
        args[0] = bevd_0;
        args[1] = bevd_1;
        args[2] = bevd_2;
        args[3] = bevd_3;
        args[4] = bevd_4;
        args[5] = bevd_5;
        args[6] = bevd_6;
        for (int i = 0;i < bevd_x.Length;i++) {
            args[i + 7] = bevd_x[i];
        }
        return ((BEC_2_6_6_SystemObject) this).bems_methodNotDefined(BECS_Ids.idCalls[callId], args);
    }*/
    
    func bemc_clnames() throws -> BEC_2_4_6_TextString? {
        return nil;
    }
    
    func bemc_clfiles() throws -> BEC_2_4_6_TextString? {
        return nil;
    }

    func bemc_create() throws -> BEC_2_6_6_SystemObject? {
        return BEC_2_6_6_SystemObject();
    }
    
    func bemc_setInitial(becc_inst:BEC_2_6_6_SystemObject) throws {
        
    }
    
    func bemc_getInitial() throws -> BEC_2_6_6_SystemObject? {
        return BEC_2_6_6_SystemObject.bece_BEC_2_6_6_SystemObject_bevs_inst;
    }
    
    func bemc_getType() throws -> BETS_Object? {
        return BEC_2_6_6_SystemObject.bece_BEC_2_6_6_SystemObject_bevs_type;
    }



}

