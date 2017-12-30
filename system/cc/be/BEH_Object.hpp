

extern __thread BECS_FrameStack bevs_currentStack;

extern uint_fast16_t bevg_currentGcMark;

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

class BECS_FrameStack {
  public:
  BECS_StackFrame* bevs_lastFrame = nullptr;
  uint_fast32_t bevs_allocsSinceGc = 0;
  uint_fast32_t bevs_allocsPerGc = 1000000; //0-4,294,967,295 :: 10000000 OKish bld, 1000000 extec
  //uint_fast32_t bevs_ticksSinceCheck = 0;
  //uint_fast32_t bevs_ticksPerCheck = 5000;
  BECS_Object* bevs_lastInst = nullptr;//last inst, for appending new allocs
  //bool gcWaiting = false;
  //bool gcBlocked = false;
  //mutex gcWaitingLock
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
    
    //static std::atomic<bool> bevg_startGc;
    
    static void init();
    
    static int32_t getNlcForNlec(string clname, int32_t val);
    
    static void bemg_markAll();
    
};

class BECS_Object {
  public:
    uint_fast16_t bevg_gcMark = 0;
    BECS_Object* bevg_priorInst = nullptr;
    BECS_Object() {
      BECS_FrameStack* bevs_myStack = &bevs_currentStack;
      this->bevg_priorInst = bevs_myStack->bevs_lastInst;
      bevs_myStack->bevs_lastInst = this;
      bevs_myStack->bevs_allocsSinceGc++;
      if (bevs_myStack->bevs_allocsSinceGc > bevs_myStack->bevs_allocsPerGc) {
        bevs_myStack->bevs_allocsSinceGc = 0;
        //put in a stack stackframe
        //increment gcmark
        bevg_currentGcMark++;
        if (bevg_currentGcMark > 60000) {
          bevg_currentGcMark = 1;
        }
        //do all marking
        BECS_Runtime::bemg_markAll();
      }
    }
    virtual ~BECS_Object() = default;
    virtual BEC_2_4_6_TextString* bemc_clnames();
    virtual BEC_2_4_6_TextString* bemc_clfiles();
    virtual BEC_2_6_6_SystemObject* bemc_create();
    virtual void bemc_setInitial(BEC_2_6_6_SystemObject* becc_inst);
    virtual BEC_2_6_6_SystemObject* bemc_getInitial();
    virtual void bemg_doMark();
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
    virtual BEC_2_6_6_SystemObject* bems_forwardCall(string mname, vector<BEC_2_6_6_SystemObject*> bevd_x, int32_t numargs);
    virtual BEC_2_6_6_SystemObject* bems_methodNotDefined(int32_t callId, vector<BEC_2_6_6_SystemObject*> args);

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
    virtual void bemgt_doMark();
};

class BECS_StackFrame {
  public:
  BECS_StackFrame* bevs_priorFrame;
  BEC_2_6_6_SystemObject*** bevs_localVars;
  int bevs_numVars;
  BECS_FrameStack* bevs_myStack;
  BECS_StackFrame(BEC_2_6_6_SystemObject*** beva_localVars, int beva_numVars) {
    bevs_localVars = beva_localVars;
    bevs_numVars = beva_numVars;
    bevs_myStack = &bevs_currentStack;
    bevs_priorFrame = bevs_myStack->bevs_lastFrame;
    bevs_myStack->bevs_lastFrame = this;
  }
  ~BECS_StackFrame() {
    bevs_myStack->bevs_lastFrame = bevs_priorFrame;
  }
};

