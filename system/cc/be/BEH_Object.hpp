/*
 * Copyright (c) 2015-2023, the Bennt Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

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

class BECS_FrameStack {
  public:
#ifdef BECC_SS
  BECS_StackFrame* bevs_lastFrame = nullptr;
#endif
  uint_fast32_t bevs_allocsSinceGc = 0;
  BECS_Object* bevs_lastInst = nullptr;//last inst, for appending new allocs
  BECS_Object* bevs_nextReuse = nullptr;
  uint_fast16_t bevg_stackGcState = 0;
#ifdef BECC_HS
  //new for heap stack
  BECS_Object** bevs_ohs;
  BECS_Object** bevs_hs;
#endif
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

#ifdef BEDCC_PT
    static thread_local BECS_FrameStack bevs_currentStack;
#endif

#ifndef BEDCC_PT
    static BECS_FrameStack bevs_currentStack;
#endif

    static uint_fast16_t bevg_currentGcMark;
#ifdef BEDCC_PT
    static std::atomic<uint_fast16_t> bevg_gcState;
      //0 don't do gc now, 1 do gc now
    static std::atomic<uint_fast32_t> bevg_sharedAllocsSinceGc;
#endif
    
#ifdef BEDCC_PT    
    static std::map<std::thread::id, BECS_FrameStack*> bevg_frameStacks;
#endif
    
    static BECS_FrameStack bevg_oldInstsStack;

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
    static uint_fast64_t bevg_maxHs;
    
    static void init();
    
    static void doGc();
    
    static int32_t getNlcForNlec(std::string clname, int32_t val);
    
    static void bemg_markAll();
    static void bemg_markStack(BECS_FrameStack* bevs_myStack);
    static void bemg_sweep();
    static void bemg_sweepStack(BECS_FrameStack* bevs_myStack);
    static void bemg_zero();
    static void bemg_zeroStack(BECS_FrameStack* bevs_myStack);
    
    static void bemg_addMyFrameStack();
    static void bemg_deleteMyFrameStack();
    
    static void bemg_beginThread();
    static void bemg_endThread();
    
    static void bemg_enterBlocking();
    static void bemg_exitBlocking();
    
    static void bemg_checkDoGc();
    static bool bemg_readyForGc();
    
};

#ifdef BECC_SS
class BECS_StackFrame {
  public:
  BECS_StackFrame* bevs_priorFrame;
  BEC_2_6_6_SystemObject*** bevs_localVars;
  size_t bevs_numVars;
  BECS_FrameStack* bevs_myStack;
  BEC_2_6_6_SystemObject* bevs_thiso;

  inline BECS_StackFrame(BEC_2_6_6_SystemObject*** beva_localVars, size_t beva_numVars, BEC_2_6_6_SystemObject* beva_thiso) {
    bevs_localVars = beva_localVars;
    bevs_numVars = beva_numVars;
    bevs_thiso = beva_thiso;
    bevs_myStack = &BECS_Runtime::bevs_currentStack;
    bevs_priorFrame = bevs_myStack->bevs_lastFrame;
    bevs_myStack->bevs_lastFrame = this;
  }

  inline ~BECS_StackFrame() {
    bevs_myStack->bevs_lastFrame = bevs_priorFrame;
  }

};
#endif
#ifdef BECC_HS
class BECS_StackFrame {
  public:
  size_t bevs_numVars;
  
  inline BECS_StackFrame(size_t beva_numVars) {
    bevs_numVars = beva_numVars;
    BECS_FrameStack* bevs_myStack = &BECS_Runtime::bevs_currentStack;
    bevs_myStack->bevs_hs += bevs_numVars;
  }
  
  inline ~BECS_StackFrame() {
    BECS_FrameStack* bevs_myStack = &BECS_Runtime::bevs_currentStack;
    bevs_myStack->bevs_hs -= bevs_numVars;
  }
  
};
#endif

class BECS_Object {
  public:
    uint_fast16_t bevg_gcMark = 0;
    BECS_Object* bevg_priorInst = nullptr;
    
    void* operator new(size_t size) {

#ifdef BEDCC_SGC  

      BECS_FrameStack* bevs_myStack = &BECS_Runtime::bevs_currentStack;   
      bevs_myStack->bevs_allocsSinceGc++;

      //should I do gc
      bool doGc = false;

#ifdef BEDCC_PT
      //sync count sometimes
      if (bevs_myStack->bevs_allocsSinceGc % BEDCC_GCSHASYNC == 0) {
        bevs_myStack->bevs_allocsSinceGc = BECS_Runtime::bevg_sharedAllocsSinceGc += BEDCC_GCSHASYNC;
      }
#endif

      //allocsPerGc 0-4,294,967,295 :: 10000000 >>6000000<< OKish bld, 1000000 extec, diff is 1 0
      if (bevs_myStack->bevs_allocsSinceGc > BEDCC_GCAPERGC) {
#ifdef BEDCC_PT
        BECS_Runtime::bevg_gcState.store(1, std::memory_order_release);
#endif
        doGc = true;
      }

#ifdef BEDCC_PT      
      //sync do gc moretimes 2 4 8 16 32 64 128
      if (bevs_myStack->bevs_allocsSinceGc % BEDCC_GCSSCHECK == 0 && BECS_Runtime::bevg_gcState.load(std::memory_order_acquire) == 1) {
        doGc = true;
      }
#endif

      //https://www.arangodb.com/2015/02/comparing-atomic-mutex-rwlocks/
      //#include <atomic>
      //std::atomic<uint64_t> atomic_uint;
      //atomic_uint.store(i, std::memory_order_release);
      //current = atomic_uint.load(std::memory_order_acquire);

      if (doGc) {
        BECS_Runtime::bemg_checkDoGc();
      }
      
      uint_fast16_t bevg_currentGcMark = BECS_Runtime::bevg_currentGcMark;
      
      BECS_Object* bevs_lastInst = bevs_myStack->bevs_nextReuse;

#ifndef BED_GCNOREUSE      
      if (bevs_lastInst != nullptr) {
        BECS_Object* bevs_currInst = bevs_lastInst->bevg_priorInst;
        int tries = 0;
        while (tries < 2 && bevs_currInst != nullptr && bevs_currInst->bevg_priorInst != nullptr) {
          tries++;
          if (bevs_currInst->bevg_gcMark != bevg_currentGcMark) {
            bevs_lastInst->bevg_priorInst = bevs_currInst->bevg_priorInst;
            if (bevs_currInst->bemg_getSize() == size) {
#ifdef BED_GCSTATS
              BECS_Runtime::bevg_countRecycles++;
#endif
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
#endif
#ifdef BED_GCSTATS
      BECS_Runtime::bevg_countAllocs++;
#endif
      return malloc(size);
#endif
    }
    
    void operator delete(void* theinst, size_t size) {
#ifdef BED_GCSTATS
      BECS_Runtime::bevg_countDeletes++;
#endif
      free(theinst);
    }
    BECS_Object() {
      
#ifdef BEDCC_SGC
#ifdef BECC_SS
      BEC_2_6_6_SystemObject* thiso = (BEC_2_6_6_SystemObject*) this;
      BEC_2_6_6_SystemObject** bevls_stackRefs[0] = { };
      BECS_StackFrame bevs_stackFrame(bevls_stackRefs, 0, thiso);
#endif
#ifdef BECC_HS
      BEC_2_6_6_SystemObject* thisoo = (BEC_2_6_6_SystemObject*) this;

      struct bes {  BEC_2_6_6_SystemObject* bevr_this;  };
      BECS_FrameStack* bevs_myStack = &BECS_Runtime::bevs_currentStack;
      bes* beq = (bes*) bevs_myStack->bevs_hs;
      BEQP(bevr_this) = thisoo;
      BECS_StackFrame bevs_stackFrame(1);
#endif
#endif

#ifdef BEDCC_SGC
      bevg_gcMark = 0;
#ifdef BECC_SS
      BECS_FrameStack* bevs_myStack = &BECS_Runtime::bevs_currentStack;
#endif
      this->bevg_priorInst = bevs_myStack->bevs_lastInst;
      bevs_myStack->bevs_lastInst = this;
#endif
      
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

#ifdef BEDCC_SGC
    virtual BEC_2_6_6_SystemObject* bemd_x(int32_t callId, BEC_2_6_6_SystemObject* bevd_0, BEC_2_6_6_SystemObject* bevd_1, BEC_2_6_6_SystemObject* bevd_2, BEC_2_6_6_SystemObject* bevd_3, BEC_2_6_6_SystemObject* bevd_4, BEC_2_6_6_SystemObject* bevd_5, BEC_2_6_6_SystemObject* bevd_6, std::vector<BEC_2_6_6_SystemObject*> bevd_x);
#endif 

#ifdef BEDCC_SGC
  virtual BEC_2_6_6_SystemObject* bems_forwardCall(std::string mname, std::vector<BEC_2_6_6_SystemObject*> bevd_x, int32_t numargs);
#endif

#ifdef BEDCC_SGC
    virtual BEC_2_6_6_SystemObject* bems_methodNotDefined(int32_t callId, std::vector<BEC_2_6_6_SystemObject*> args);
#endif      

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


