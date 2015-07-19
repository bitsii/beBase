package be.BELS_Base;

import be.BEL_4_Base.BEC_6_6_SystemObject;

public class BECS_Lib {
    
    public static int getCallId(String name) {
        Integer id = BECS_Ids.callIds.get(name);
        if (id == null) {
            int iid = BECS_Ids.callIdCounter;
            BECS_Ids.callIdCounter++;
            BECS_Ids.callIds.put(name, iid);
            BECS_Ids.idCalls.put(iid, name);
            return iid;
        }
        return id;
    }
    
}

