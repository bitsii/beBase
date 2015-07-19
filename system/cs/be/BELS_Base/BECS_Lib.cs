namespace be.BELS_Base {

public class BECS_Lib {
    
    public static int getCallId(string name) {
        if (BECS_Ids.callIds.ContainsKey(name)) {
            return BECS_Ids.callIds[name];
        } else {
            int iid = BECS_Ids.callIdCounter;
            BECS_Ids.callIdCounter++;
            BECS_Ids.callIds[name] = iid;
            BECS_Ids.idCalls[iid] = name;
            return iid;
        }
    }
    
}

}

