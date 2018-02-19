
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
  BECS_Object* bevs_lastInst = nullptr;//last inst, for appending new allocs
  BECS_Object* bevs_nextReuse = nullptr;
  uint_fast16_t bevg_stackGcState = 0;
};

class BECS_Runtime {
    public:
    static bool isInitted;
    
    static BEC_2_5_4_LogicBool* boolTrue;
    static BEC_2_5_4_LogicBool* boolFalse;
    
    static unordered_map<string, BETS_Object*> typeRefs;
    
    //for setting up initial instances
    static BEC_2_6_11_SystemInitializer* initializer;
    
    //the main instance
    static BEC_2_6_6_SystemObject* maino;
    
    static string platformName;
    
    static int argc;
    static char** argv;
    
    static unordered_map<string, vector<int32_t>> smnlcs;
    static unordered_map<string, vector<int32_t>> smnlecs;
    
    static thread_local BECS_FrameStack bevs_currentStack;
    
    static uint_fast16_t bevg_currentGcMark;
    static atomic<uint_fast16_t> bevg_gcState;
      //0 don't do gc now, 1 do gc now
    static atomic<uint_fast32_t> bevg_sharedAllocsSinceGc;
    
    static map<std::thread::id, BECS_FrameStack*> bevg_frameStacks;
    
    static BECS_FrameStack bevg_oldInstsStack;
    
    static std::recursive_mutex bevs_initLock;
    
    static std::mutex bevg_gcLock;
    static std::condition_variable bevg_gcWaiter;
    
    static uint_fast64_t bevg_countGcs;
    static uint_fast64_t bevg_countSweeps;
    static uint_fast64_t bevg_countNews;
    static uint_fast64_t bevg_countConstructs;
    static uint_fast64_t bevg_countDeletes;
    static uint_fast64_t bevg_countRecycles;
    
    static void init();
    
    static void doGc();
    
    static int32_t getNlcForNlec(string clname, int32_t val);
    
    static void bemg_markAll();
    static void bemg_markStack(BECS_FrameStack* bevs_myStack);
    static void bemg_sweep();
    static void bemg_sweepStack(BECS_FrameStack* bevs_myStack);
    
    static void bemg_addMyFrameStack();
    
    static void bemg_checkDoGc();
    
    static void bevg_setStackGcState(uint_fast16_t bevg_stackGcState);
      
    static bool bemg_readyForGc();
    
};

class BECS_StackFrame {
  public:
  BECS_StackFrame* bevs_priorFrame;
  BEC_2_6_6_SystemObject*** bevs_localVars;
  size_t bevs_numVars;
  BECS_FrameStack* bevs_myStack;
  BEC_2_6_6_SystemObject* bevs_lastConstruct;
  
  BECS_StackFrame(BEC_2_6_6_SystemObject*** beva_localVars, size_t beva_numVars) {
    bevs_localVars = beva_localVars;
    bevs_numVars = beva_numVars;
    bevs_myStack = &BECS_Runtime::bevs_currentStack;
    bevs_priorFrame = bevs_myStack->bevs_lastFrame;
    bevs_myStack->bevs_lastFrame = this;
    bevs_lastConstruct = nullptr;
  }
  
  ~BECS_StackFrame() {
    bevs_myStack->bevs_lastFrame = bevs_priorFrame;
  }
  
};

class BECS_Object {
  public:
    uint_fast16_t bevg_gcMark = 0;
    BECS_Object* bevg_priorInst = nullptr;
    
    void* operator new(size_t size) {
      
      BECS_FrameStack* bevs_myStack = &BECS_Runtime::bevs_currentStack;
      
      bevs_myStack->bevs_allocsSinceGc++;
      
      uint_fast16_t bevg_currentGcMark = BECS_Runtime::bevg_currentGcMark;
      
      BECS_Object* bevs_lastInst = bevs_myStack->bevs_nextReuse;
      
      if (bevs_lastInst != nullptr) {
        BECS_Object* bevs_currInst = bevs_lastInst->bevg_priorInst;
        int tries = 0;
        while (tries < 3 && bevs_currInst != nullptr && bevs_currInst->bevg_priorInst != nullptr) {
          tries++;
          if (bevs_currInst->bevg_gcMark != bevg_currentGcMark) {
            bevs_lastInst->bevg_priorInst = bevs_currInst->bevg_priorInst;
            if (bevs_currInst->bemg_getSize() == size) {
              BECS_Runtime::bevg_countRecycles++;
              bevs_currInst->~BECS_Object();
              bevs_myStack->bevs_nextReuse = bevs_lastInst;
              return bevs_currInst;
            } else {
              delete bevs_currInst;
              bevs_currInst = bevs_lastInst->bevg_priorInst; 
            }
          } else {
            bevs_lastInst = bevs_currInst;
            bevs_currInst = bevs_currInst->bevg_priorInst;
          }
        }
        bevs_myStack->bevs_nextReuse = bevs_lastInst;
      }
      BECS_Runtime::bevg_countNews++;
      return malloc(size);
    }
    
    void operator delete(void* theinst, size_t size) {
      BECS_Runtime::bevg_countDeletes++;
      free(theinst);
    }
    BECS_Object() {
      BECS_Runtime::bevg_countConstructs++;
      BECS_FrameStack* bevs_myStack = &BECS_Runtime::bevs_currentStack;
      this->bevg_priorInst = bevs_myStack->bevs_lastInst;
      bevs_myStack->bevs_lastInst = this;
      
      //should I do gc
      bool doGc = false;
      
      //sync count sometimes
      if (bevs_myStack->bevs_allocsSinceGc % 8192 == 0) {
        bevs_myStack->bevs_allocsSinceGc = BECS_Runtime::bevg_sharedAllocsSinceGc += 8192;
      }
      
      //allocsPerGc 0-4,294,967,295 :: 10000000 OKish bld, 1000000 extec, diff is 1 0
      if (bevs_myStack->bevs_allocsSinceGc > 6000000) {
        BECS_Runtime::bevg_gcState.store(1, std::memory_order_release);
        doGc = true;
      }
      
      //sync do gc moretimes 16 32 64 128
      if (bevs_myStack->bevs_allocsSinceGc % 32 == 0 && BECS_Runtime::bevg_gcState.load(std::memory_order_acquire) == 1) {
        doGc = true;
      }
      
      //https://www.arangodb.com/2015/02/comparing-atomic-mutex-rwlocks/
      //#include <atomic>
      //std::atomic<uint64_t> atomic_uint;
      //atomic_uint.store(i, std::memory_order_release);
      //current = atomic_uint.load(std::memory_order_acquire);
      
      if (doGc) {
        //put in a stack stackframe
        BEC_2_6_6_SystemObject* bevsl_thiso = (BEC_2_6_6_SystemObject*) this;
        BEC_2_6_6_SystemObject** bevls_stackRefs[1] = { &bevsl_thiso };
        BECS_StackFrame bevs_stackFrame(bevls_stackRefs, 1);
        
        BECS_Runtime::bemg_checkDoGc();
      }
      
      bevg_gcMark = BECS_Runtime::bevg_currentGcMark;
      
    }
    virtual ~BECS_Object() = default;
    virtual BEC_2_4_6_TextString* bemc_clnames();
    virtual BEC_2_4_6_TextString* bemc_clfiles();
    virtual BEC_2_6_6_SystemObject* bemc_create();
    virtual void bemc_setInitial(BEC_2_6_6_SystemObject* becc_inst);
    virtual BEC_2_6_6_SystemObject* bemc_getInitial();
    virtual void bemg_doMark();
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


