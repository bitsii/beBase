
class BECS_Ids {
    public:
    static unordered_map<string, int32_t> callIds;
    static unordered_map<int32_t, string> idCalls;
    
};

class BECS_Lib {
    public:
    static void putCallId(string name, int32_t iid);
    
    static int32_t getCallId(string name);
    
    static void putNlcSourceMap(string clname, vector<int32_t>& vals);
    
    static void putNlecSourceMap(string clname, vector<int32_t>& vals);
};

class BECS_Object {
  public:
    virtual BEC_2_4_6_TextString* bemc_clnames();
    virtual BEC_2_4_6_TextString* bemc_clfiles();
    virtual BEC_2_6_6_SystemObject* bemc_create();
    virtual void bemc_setInitial(BEC_2_6_6_SystemObject* becc_inst);
    virtual BEC_2_6_6_SystemObject* bemc_getInitial();
    //bemds, to 7 then x
    virtual BEC_2_6_6_SystemObject* bemd_0(int32_t callId);
    virtual BEC_2_6_6_SystemObject* bemd_1(int32_t callId, BEC_2_6_6_SystemObject* bevd_0);
    virtual BEC_2_6_6_SystemObject* bemd_2(int32_t callId, BEC_2_6_6_SystemObject* bevd_0, BEC_2_6_6_SystemObject* bevd_1);
    virtual BEC_2_6_6_SystemObject* bemd_3(int32_t callId, BEC_2_6_6_SystemObject* bevd_0, BEC_2_6_6_SystemObject* bevd_1, BEC_2_6_6_SystemObject* bevd_2);
    virtual BEC_2_6_6_SystemObject* bemd_4(int32_t callId, BEC_2_6_6_SystemObject* bevd_0, BEC_2_6_6_SystemObject* bevd_1, BEC_2_6_6_SystemObject* bevd_2, BEC_2_6_6_SystemObject* bevd_3);
    virtual BEC_2_6_6_SystemObject* bemd_5(int32_t callId, BEC_2_6_6_SystemObject* bevd_0, BEC_2_6_6_SystemObject* bevd_1, BEC_2_6_6_SystemObject* bevd_2, BEC_2_6_6_SystemObject* bevd_3, BEC_2_6_6_SystemObject* bevd_4);
    virtual BEC_2_6_6_SystemObject* bemd_6(int32_t callId, BEC_2_6_6_SystemObject* bevd_0, BEC_2_6_6_SystemObject* bevd_1, BEC_2_6_6_SystemObject* bevd_2, BEC_2_6_6_SystemObject* bevd_3, BEC_2_6_6_SystemObject* bevd_4, BEC_2_6_6_SystemObject* bevd_5);
    virtual BEC_2_6_6_SystemObject* bemd_7(int32_t callId, BEC_2_6_6_SystemObject* bevd_0, BEC_2_6_6_SystemObject* bevd_1, BEC_2_6_6_SystemObject* bevd_2, BEC_2_6_6_SystemObject* bevd_3, BEC_2_6_6_SystemObject* bevd_4, BEC_2_6_6_SystemObject* bevd_5, BEC_2_6_6_SystemObject* bevd_6);
    virtual BEC_2_6_6_SystemObject* bemd_x(int32_t callId, BEC_2_6_6_SystemObject* bevd_0, BEC_2_6_6_SystemObject* bevd_1, BEC_2_6_6_SystemObject* bevd_2, BEC_2_6_6_SystemObject* bevd_3, BEC_2_6_6_SystemObject* bevd_4, BEC_2_6_6_SystemObject* bevd_5, BEC_2_6_6_SystemObject* bevd_6, vector<BEC_2_6_6_SystemObject*> bevd_x);
    virtual ~BECS_Object() = default;
    virtual BEC_2_6_6_SystemObject* bems_forwardCall(string mname, vector<BEC_2_6_6_SystemObject*> bevd_x, int32_t numargs);
    virtual BEC_2_6_6_SystemObject* bems_methodNotDefined(int32_t callId, vector<BEC_2_6_6_SystemObject*> args);

};

class BECS_Runtime {
    public:
    static bool isInitted;
    
    static BEC_2_5_4_LogicBool* boolTrue;
    static BEC_2_5_4_LogicBool* boolFalse;
    
    static unordered_map<string, BETS_Object*> typeRefs;
    
    //for setting up initial instances
    static BEC_2_6_11_SystemInitializer* initializer;
    
    static string platformName;
    
    static int argc;
    static char** argv;
    
    static unordered_map<string, vector<int32_t>> smnlcs;
    static unordered_map<string, vector<int32_t>> smnlecs;
    
    static void init();
    
    static int32_t getNlcForNlec(string clname, int32_t val);
};

class BECS_ThrowBack {
public:
    BEC_2_6_6_SystemObject* wasThrown;
    BECS_ThrowBack();
    BECS_ThrowBack(BEC_2_6_6_SystemObject* thrown);
    static BEC_2_6_6_SystemObject* handleThrow(BECS_ThrowBack thrown);
};

class BETS_Object {
  public:
    BETS_Object* bevs_parentType;
    std::unordered_map<std::string, bool> bevs_methodNames;
    std::vector<std::string> bevs_fieldNames;
    virtual void bems_buildMethodNames(std::vector<std::string> names);
    virtual BEC_2_6_6_SystemObject* bems_createInstance();
};

class BECS_StackFramePile {
  
};

class BECS_StackFrame {
  
};
