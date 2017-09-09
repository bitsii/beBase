
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

class BECS_Object : public enable_shared_from_this<BECS_Object> {
  public:
    virtual shared_ptr<BEC_2_4_6_TextString> bemc_clnames();
    virtual shared_ptr<BEC_2_4_6_TextString> bemc_clfiles();
    virtual shared_ptr<BEC_2_6_6_SystemObject> bemc_create();
    virtual void bemc_setInitial(shared_ptr<BEC_2_6_6_SystemObject> becc_inst);
    virtual shared_ptr<BEC_2_6_6_SystemObject> bemc_getInitial();
    //bemds, to 7 then x
    virtual shared_ptr<BEC_2_6_6_SystemObject> bemd_0(int32_t callId);
    virtual shared_ptr<BEC_2_6_6_SystemObject> bemd_1(int32_t callId, shared_ptr<BEC_2_6_6_SystemObject> bevd_0);
    virtual shared_ptr<BEC_2_6_6_SystemObject> bemd_2(int32_t callId, shared_ptr<BEC_2_6_6_SystemObject> bevd_0, shared_ptr<BEC_2_6_6_SystemObject> bevd_1);
    virtual shared_ptr<BEC_2_6_6_SystemObject> bemd_3(int32_t callId, shared_ptr<BEC_2_6_6_SystemObject> bevd_0, shared_ptr<BEC_2_6_6_SystemObject> bevd_1, shared_ptr<BEC_2_6_6_SystemObject> bevd_2);
    virtual shared_ptr<BEC_2_6_6_SystemObject> bemd_4(int32_t callId, shared_ptr<BEC_2_6_6_SystemObject> bevd_0, shared_ptr<BEC_2_6_6_SystemObject> bevd_1, shared_ptr<BEC_2_6_6_SystemObject> bevd_2, shared_ptr<BEC_2_6_6_SystemObject> bevd_3);
    virtual shared_ptr<BEC_2_6_6_SystemObject> bemd_5(int32_t callId, shared_ptr<BEC_2_6_6_SystemObject> bevd_0, shared_ptr<BEC_2_6_6_SystemObject> bevd_1, shared_ptr<BEC_2_6_6_SystemObject> bevd_2, shared_ptr<BEC_2_6_6_SystemObject> bevd_3, shared_ptr<BEC_2_6_6_SystemObject> bevd_4);
    virtual shared_ptr<BEC_2_6_6_SystemObject> bemd_6(int32_t callId, shared_ptr<BEC_2_6_6_SystemObject> bevd_0, shared_ptr<BEC_2_6_6_SystemObject> bevd_1, shared_ptr<BEC_2_6_6_SystemObject> bevd_2, shared_ptr<BEC_2_6_6_SystemObject> bevd_3, shared_ptr<BEC_2_6_6_SystemObject> bevd_4, shared_ptr<BEC_2_6_6_SystemObject> bevd_5);
    virtual shared_ptr<BEC_2_6_6_SystemObject> bemd_7(int32_t callId, shared_ptr<BEC_2_6_6_SystemObject> bevd_0, shared_ptr<BEC_2_6_6_SystemObject> bevd_1, shared_ptr<BEC_2_6_6_SystemObject> bevd_2, shared_ptr<BEC_2_6_6_SystemObject> bevd_3, shared_ptr<BEC_2_6_6_SystemObject> bevd_4, shared_ptr<BEC_2_6_6_SystemObject> bevd_5, shared_ptr<BEC_2_6_6_SystemObject> bevd_6);
    virtual shared_ptr<BEC_2_6_6_SystemObject> bemd_x(int32_t callId, shared_ptr<BEC_2_6_6_SystemObject> bevd_0, shared_ptr<BEC_2_6_6_SystemObject> bevd_1, shared_ptr<BEC_2_6_6_SystemObject> bevd_2, shared_ptr<BEC_2_6_6_SystemObject> bevd_3, shared_ptr<BEC_2_6_6_SystemObject> bevd_4, shared_ptr<BEC_2_6_6_SystemObject> bevd_5, shared_ptr<BEC_2_6_6_SystemObject> bevd_6, vector<shared_ptr<BEC_2_6_6_SystemObject>> bevd_x);
    virtual ~BECS_Object() = default;
    virtual shared_ptr<BEC_2_6_6_SystemObject> bems_forwardCall(string mname, vector<shared_ptr<BEC_2_6_6_SystemObject>> bevd_x, int32_t numargs);
    virtual shared_ptr<BEC_2_6_6_SystemObject> bems_methodNotDefined(int32_t callId, vector<shared_ptr<BEC_2_6_6_SystemObject>> args);

};

class BECS_Runtime {
    public:
    static bool isInitted;
    
    static shared_ptr<BEC_2_5_4_LogicBool> boolTrue;
    static shared_ptr<BEC_2_5_4_LogicBool> boolFalse;
    
    static unordered_map<string, BETS_Object*> typeRefs;
    
    //for setting up initial instances
    static shared_ptr<BEC_2_6_11_SystemInitializer> initializer;
    
    static string platformName;
    
    static vector<string> args;
    
    static unordered_map<string, vector<int32_t>> smnlcs;
    static unordered_map<string, vector<int32_t>> smnlecs;
    
    static void init();
    
    static int32_t getNlcForNlec(string clname, int32_t val);
};

class BECS_ThrowBack {
public:
    shared_ptr<BEC_2_6_6_SystemObject> wasThrown;
    BECS_ThrowBack();
    BECS_ThrowBack(shared_ptr<BEC_2_6_6_SystemObject> thrown);
    static shared_ptr<BEC_2_6_6_SystemObject> handleThrow(BECS_ThrowBack thrown);
};

class BETS_Object {
  public:
    BETS_Object* bevs_parentType;
    std::unordered_map<std::string, bool> bevs_methodNames;
    std::vector<std::string> bevs_fieldNames;
    virtual void bems_buildMethodNames(std::vector<std::string> names);
    virtual shared_ptr<BEC_2_6_6_SystemObject> bems_createInstance();
};

