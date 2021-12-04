
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
    
    static BEC_2_5_4_LogicBool* boolTrue;
    static BEC_2_5_4_LogicBool* boolFalse;
    
    static std::unordered_map<std::string, BETS_Object*> typeRefs;
    
    //for setting up initial instances
    static BEC_2_6_11_SystemInitializer* initializer;
    
    //the main instance
    static BEC_2_6_6_SystemObject* maino;
    
    static std::string platformName;
    
    static int argc;
    static char** argv;
    
    static std::unordered_map<std::string, std::vector<int32_t>> smnlcs;
    static std::unordered_map<std::string, std::vector<int32_t>> smnlecs;
    
    static uint_fast16_t bevg_currentGcMark;
#ifdef BEDCC_PT
    static std::atomic<uint_fast16_t> bevg_gcState;
      //0 don't do gc now, 1 do gc now
    static std::atomic<uint_fast32_t> bevg_sharedAllocsSinceGc;
#endif

#ifdef BEDCC_PT    
    static std::recursive_mutex bevs_initLock;
#endif

#ifdef BEDCC_PT   
    static std::mutex bevg_gcLock;
    static std::condition_variable bevg_gcWaiter;
#endif
    
    static uint_fast64_t bevg_countGcs;
    static uint_fast64_t bevg_countSweeps;
    static uint_fast64_t bevg_countDeletes;
    static uint_fast64_t bevg_countRecycles;
    static uint_fast64_t bevg_countAllocs;
    
    static void init();
    
    static int32_t getNlcForNlec(std::string clname, int32_t val);
    
    static void bemg_beginThread();
    static void bemg_endThread();
    
    
};

class BECS_Object {
  public:
    
    void* operator new(size_t size) {
      return malloc(size);
    }
    
    void operator delete(void* theinst, size_t size) {
      free(theinst);
    }
    BECS_Object() {
    }
    virtual ~BECS_Object() = default;
    virtual BEC_2_4_6_TextString* bemc_clnames();
    virtual BEC_2_4_6_TextString* bemc_clfiles();
    virtual BEC_2_6_6_SystemObject* bemc_create();
    virtual void bemc_setInitial(BEC_2_6_6_SystemObject* becc_inst);
    virtual BEC_2_6_6_SystemObject* bemc_getInitial();
    virtual size_t bemg_getSize();
    //bemds, to 7 then x
    virtual BEC_2_6_6_SystemObject* bemd_0(int32_t callId);
    virtual BEC_2_6_6_SystemObject* bemd_1(int32_t callId, BEC_2_6_6_SystemObject* bevd_0);
    virtual BEC_2_6_6_SystemObject* bemd_2(int32_t callId, BEC_2_6_6_SystemObject* bevd_0, BEC_2_6_6_SystemObject* bevd_1);
    virtual BEC_2_6_6_SystemObject* bemd_3(int32_t callId, BEC_2_6_6_SystemObject* bevd_0, BEC_2_6_6_SystemObject* bevd_1, BEC_2_6_6_SystemObject* bevd_2);
    virtual BEC_2_6_6_SystemObject* bemd_4(int32_t callId, BEC_2_6_6_SystemObject* bevd_0, BEC_2_6_6_SystemObject* bevd_1, BEC_2_6_6_SystemObject* bevd_2, BEC_2_6_6_SystemObject* bevd_3);
    virtual BEC_2_6_6_SystemObject* bemd_5(int32_t callId, BEC_2_6_6_SystemObject* bevd_0, BEC_2_6_6_SystemObject* bevd_1, BEC_2_6_6_SystemObject* bevd_2, BEC_2_6_6_SystemObject* bevd_3, BEC_2_6_6_SystemObject* bevd_4);
    virtual BEC_2_6_6_SystemObject* bemd_6(int32_t callId, BEC_2_6_6_SystemObject* bevd_0, BEC_2_6_6_SystemObject* bevd_1, BEC_2_6_6_SystemObject* bevd_2, BEC_2_6_6_SystemObject* bevd_3, BEC_2_6_6_SystemObject* bevd_4, BEC_2_6_6_SystemObject* bevd_5);
    virtual BEC_2_6_6_SystemObject* bemd_7(int32_t callId, BEC_2_6_6_SystemObject* bevd_0, BEC_2_6_6_SystemObject* bevd_1, BEC_2_6_6_SystemObject* bevd_2, BEC_2_6_6_SystemObject* bevd_3, BEC_2_6_6_SystemObject* bevd_4, BEC_2_6_6_SystemObject* bevd_5, BEC_2_6_6_SystemObject* bevd_6);

    virtual BEC_2_6_6_SystemObject* bemd_x(int32_t callId, BEC_2_6_6_SystemObject* bevd_0, BEC_2_6_6_SystemObject* bevd_1, BEC_2_6_6_SystemObject* bevd_2, BEC_2_6_6_SystemObject* bevd_3, BEC_2_6_6_SystemObject* bevd_4, BEC_2_6_6_SystemObject* bevd_5, BEC_2_6_6_SystemObject* bevd_6, std::vector<BEC_2_6_6_SystemObject*> bevd_x);

  virtual BEC_2_6_6_SystemObject* bems_forwardCall(std::string mname, std::vector<BEC_2_6_6_SystemObject*> bevd_x, int32_t numargs);

    virtual BEC_2_6_6_SystemObject* bems_methodNotDefined(int32_t callId, std::vector<BEC_2_6_6_SystemObject*> args);

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


