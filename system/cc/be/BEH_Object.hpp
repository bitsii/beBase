
class BECS_Ids {
    public:
    static std::unordered_map<std::string, int32_t> callIds;
    static std::unordered_map<int32_t, std::string> idCalls;
    
};

class BECS_Lib {
    public:
    static void putCallId(std::string name, int32_t iid);
    
    static int32_t getCallId(std::string name);
    
    static void putNlcSourceMap(std::string clname, std::vector<int32_t>& vals);
    
    static void putNlecSourceMap(std::string clname, std::vector<int32_t>& vals);
};

class BECS_Runtime {
    public:
    static bool isInitted;
    
    static std::shared_ptr<BEC_2_5_4_LogicBool> boolTrue;
    static std::shared_ptr<BEC_2_5_4_LogicBool> boolFalse;
    
    static std::unordered_map<std::string, BETS_Object*> typeRefs;
    
    //for setting up initial instances
    static std::shared_ptr<BEC_2_6_11_SystemInitializer> initializer;
    
    //the main instance
    static BEC_2_6_6_SystemObject* maino;
    
    static std::string platformName;
    
    static int argc;
    static char** argv;
    
    static std::unordered_map<std::string, std::vector<int32_t>> smnlcs;
    static std::unordered_map<std::string, std::vector<int32_t>> smnlecs;

#ifdef BEDCC_PT    
    static std::recursive_mutex bevs_initLock;
#endif
    
    static void init();
    
    static int32_t getNlcForNlec(std::string clname, int32_t val);
    
    static void bemg_beginThread();
    static void bemg_endThread();
    
    
};

class BECS_Object : public std::enable_shared_from_this<BECS_Object> {
  public:
    
    /*void* operator new(size_t size) {
      return malloc(size);
    }
    void operator delete(void* theinst, size_t size) {
      free(theinst);
    }*/
    
    BECS_Object() {
    }
    virtual ~BECS_Object() = default;
    
    virtual std::shared_ptr<BEC_2_4_6_TextString> bemc_clnames();
    virtual std::shared_ptr<BEC_2_4_6_TextString> bemc_clfiles();
    virtual std::shared_ptr<BEC_2_6_6_SystemObject> bemc_create();
    virtual void bemc_setInitial(std::shared_ptr<BEC_2_6_6_SystemObject> becc_inst);
    virtual std::shared_ptr<BEC_2_6_6_SystemObject> bemc_getInitial();
    //bemds, to 7 then x
    virtual std::shared_ptr<BEC_2_6_6_SystemObject> bemd_0(int32_t callId);
    virtual std::shared_ptr<BEC_2_6_6_SystemObject> bemd_1(int32_t callId, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_0);
    virtual std::shared_ptr<BEC_2_6_6_SystemObject> bemd_2(int32_t callId, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_0, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_1);
    virtual std::shared_ptr<BEC_2_6_6_SystemObject> bemd_3(int32_t callId, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_0, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_1, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_2);
    virtual std::shared_ptr<BEC_2_6_6_SystemObject> bemd_4(int32_t callId, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_0, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_1, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_2, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_3);
    virtual std::shared_ptr<BEC_2_6_6_SystemObject> bemd_5(int32_t callId, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_0, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_1, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_2, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_3, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_4);
    virtual std::shared_ptr<BEC_2_6_6_SystemObject> bemd_6(int32_t callId, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_0, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_1, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_2, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_3, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_4, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_5);
    virtual std::shared_ptr<BEC_2_6_6_SystemObject> bemd_7(int32_t callId, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_0, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_1, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_2, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_3, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_4, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_5, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_6);
    
    virtual std::shared_ptr<BEC_2_6_6_SystemObject> bemd_x(int32_t callId, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_0, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_1, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_2, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_3, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_4, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_5, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_6, std::vector<std::shared_ptr<BEC_2_6_6_SystemObject>> bevd_x);
    
    virtual std::shared_ptr<BEC_2_6_6_SystemObject> bems_forwardCall(std::string mname, std::vector<std::shared_ptr<BEC_2_6_6_SystemObject>> bevd_x, int32_t numargs);
    
    virtual std::shared_ptr<BEC_2_6_6_SystemObject> bems_methodNotDefined(int32_t callId, std::vector<std::shared_ptr<BEC_2_6_6_SystemObject>> args);

};

class BECS_ThrowBack {
public:
    std::shared_ptr<BEC_2_6_6_SystemObject> wasThrown;
    BECS_ThrowBack();
    BECS_ThrowBack(std::shared_ptr<BEC_2_6_6_SystemObject> thrown);
    static std::shared_ptr<BEC_2_6_6_SystemObject> handleThrow(BECS_ThrowBack thrown);
};
        
class BETS_Object {
  public:
    BETS_Object* bevs_parentType;
    std::unordered_map<std::string, bool> bevs_methodNames;
    std::vector<std::string> bevs_fieldNames;
    virtual void bems_buildMethodNames(std::vector<std::string> names);
    virtual std::shared_ptr<BEC_2_6_6_SystemObject> bems_createInstance();
};


