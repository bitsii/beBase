    
std::unordered_map<std::string, int32_t> BECS_Ids::callIds;
std::unordered_map<int32_t, std::string> BECS_Ids::idCalls;

#ifdef BEDCC_PT
thread_local BECS_FrameStack BECS_Runtime::bevs_currentStack;
#endif

#ifndef BEDCC_PT
BECS_FrameStack BECS_Runtime::bevs_currentStack;
#endif

uint_fast16_t BECS_Runtime::bevg_currentGcMark = 1;

#ifdef BEDCC_PT
std::atomic<uint_fast16_t> BECS_Runtime::bevg_gcState{0};
std::atomic<uint_fast32_t> BECS_Runtime::bevg_sharedAllocsSinceGc{0};
#endif

#ifdef BEDCC_PT
std::map<std::thread::id, BECS_FrameStack*> BECS_Runtime::bevg_frameStacks;
#endif

BECS_FrameStack BECS_Runtime::bevg_oldInstsStack;

#ifdef BEDCC_PT
std::recursive_mutex BECS_Runtime::bevs_initLock;
std::mutex BECS_Runtime::bevg_gcLock;
std::condition_variable BECS_Runtime::bevg_gcWaiter;
#endif

uint_fast64_t BECS_Runtime::bevg_countGcs = 0;
uint_fast64_t BECS_Runtime::bevg_countSweeps = 0;
uint_fast64_t BECS_Runtime::bevg_countDeletes = 0;
uint_fast64_t BECS_Runtime::bevg_countRecycles = 0;
uint_fast64_t BECS_Runtime::bevg_countAllocs = 0;

void BECS_Lib::putCallId(std::string name, int32_t iid) {
    BECS_Ids::callIds[name] = iid;
    BECS_Ids::idCalls[iid] = name;
}
    
int32_t BECS_Lib::getCallId(std::string name) {
    return BECS_Ids::callIds[name];
}
    
void BECS_Lib::putNlcSourceMap(std::string clname, std::vector<int32_t>& vals) {
  BECS_Runtime::smnlcs[clname] = vals;
}
    
void BECS_Lib::putNlecSourceMap(std::string clname, std::vector<int32_t>& vals) {
  BECS_Runtime::smnlecs[clname] = vals;  
}

BEC_2_4_6_TextString* BECS_Object::bemc_clnames() {
  return nullptr;  
}

BEC_2_4_6_TextString* BECS_Object::bemc_clfiles() {
  return nullptr; 
}

BEC_2_6_6_SystemObject* BECS_Object::bemc_create() {
  return nullptr;
}

void BECS_Object::bemc_setInitial(BEC_2_6_6_SystemObject* becc_inst) { }

BEC_2_6_6_SystemObject* BECS_Object::bemc_getInitial() {
 return nullptr; 
}

void BECS_Object::bemg_doMark() {
 
}

size_t BECS_Object::bemg_getSize() {
   return sizeof(*this);
}

#ifdef BEDCC_SGC
    BEC_2_6_6_SystemObject* BECS_Object::bems_methodNotDefined(int32_t callId, std::vector<BEC_2_6_6_SystemObject*> args) {
#endif  

  BEC_2_6_6_SystemObject* so = static_cast<BEC_2_6_6_SystemObject*>(this);
  
  BEC_2_9_4_ContainerList* beArgs = nullptr;
  BEC_2_4_6_TextString* beCallId = nullptr;

#ifdef BEDCC_SGC
  BEC_2_6_6_SystemObject** bevls_stackRefs[2] = { (BEC_2_6_6_SystemObject**) &beArgs, (BEC_2_6_6_SystemObject**) &beCallId };
  BECS_StackFrame bevs_stackFrame(bevls_stackRefs, 2, so);
#endif

  beArgs = new BEC_2_9_4_ContainerList(args);
  beCallId = new BEC_2_4_6_TextString(BECS_Ids::idCalls[callId]);
  return so->bem_methodNotDefined_2(beCallId, beArgs);
}

//bemds
BEC_2_6_6_SystemObject* BECS_Object::bemd_0(int32_t callId) {
#ifdef BEDCC_SGC
  std::vector<BEC_2_6_6_SystemObject*> args = { };
#endif 
  return bems_methodNotDefined(callId, args);
}

BEC_2_6_6_SystemObject* BECS_Object::bemd_1(int32_t callId, BEC_2_6_6_SystemObject* bevd_0) {
#ifdef BEDCC_SGC
  std::vector<BEC_2_6_6_SystemObject*> args = { bevd_0 };
#endif
  return bems_methodNotDefined(callId, args);
}

BEC_2_6_6_SystemObject* BECS_Object::bemd_2(int32_t callId, BEC_2_6_6_SystemObject* bevd_0, BEC_2_6_6_SystemObject* bevd_1) {
#ifdef BEDCC_SGC
  std::vector<BEC_2_6_6_SystemObject*> args = { bevd_0, bevd_1 };
#endif
  return bems_methodNotDefined(callId, args);
}

BEC_2_6_6_SystemObject* BECS_Object::bemd_3(int32_t callId, BEC_2_6_6_SystemObject* bevd_0, BEC_2_6_6_SystemObject* bevd_1, BEC_2_6_6_SystemObject* bevd_2) {
#ifdef BEDCC_SGC
  std::vector<BEC_2_6_6_SystemObject*> args = { bevd_0, bevd_1, bevd_2 };
#endif
  return bems_methodNotDefined(callId, args);
}

BEC_2_6_6_SystemObject* BECS_Object::bemd_4(int32_t callId, BEC_2_6_6_SystemObject* bevd_0, BEC_2_6_6_SystemObject* bevd_1, BEC_2_6_6_SystemObject* bevd_2, BEC_2_6_6_SystemObject* bevd_3) {
#ifdef BEDCC_SGC
  std::vector<BEC_2_6_6_SystemObject*> args = { bevd_0, bevd_1, bevd_2, bevd_3 };
#endif  
  return bems_methodNotDefined(callId, args);
}

BEC_2_6_6_SystemObject* BECS_Object::bemd_5(int32_t callId, BEC_2_6_6_SystemObject* bevd_0, BEC_2_6_6_SystemObject* bevd_1, BEC_2_6_6_SystemObject* bevd_2, BEC_2_6_6_SystemObject* bevd_3, BEC_2_6_6_SystemObject* bevd_4) {
#ifdef BEDCC_SGC
  std::vector<BEC_2_6_6_SystemObject*> args = { bevd_0, bevd_1, bevd_2, bevd_3, bevd_4 };
#endif  
  return bems_methodNotDefined(callId, args);
}

BEC_2_6_6_SystemObject* BECS_Object::bemd_6(int32_t callId, BEC_2_6_6_SystemObject* bevd_0, BEC_2_6_6_SystemObject* bevd_1, BEC_2_6_6_SystemObject* bevd_2, BEC_2_6_6_SystemObject* bevd_3, BEC_2_6_6_SystemObject* bevd_4, BEC_2_6_6_SystemObject* bevd_5) {

#ifdef BEDCC_SGC
  std::vector<BEC_2_6_6_SystemObject*> args = { bevd_0, bevd_1, bevd_2, bevd_3, bevd_4, bevd_5 };
#endif  
  return bems_methodNotDefined(callId, args);
}

BEC_2_6_6_SystemObject* BECS_Object::bemd_7(int32_t callId, BEC_2_6_6_SystemObject* bevd_0, BEC_2_6_6_SystemObject* bevd_1, BEC_2_6_6_SystemObject* bevd_2, BEC_2_6_6_SystemObject* bevd_3, BEC_2_6_6_SystemObject* bevd_4, BEC_2_6_6_SystemObject* bevd_5, BEC_2_6_6_SystemObject* bevd_6) {
#ifdef BEDCC_SGC
  std::vector<BEC_2_6_6_SystemObject*> args = { bevd_0, bevd_1, bevd_2, bevd_3, bevd_4, bevd_5, bevd_6 };
#endif 
  return bems_methodNotDefined(callId, args);
}

#ifdef BEDCC_SGC
    BEC_2_6_6_SystemObject* BECS_Object::bemd_x(int32_t callId, BEC_2_6_6_SystemObject* bevd_0, BEC_2_6_6_SystemObject* bevd_1, BEC_2_6_6_SystemObject* bevd_2, BEC_2_6_6_SystemObject* bevd_3, BEC_2_6_6_SystemObject* bevd_4, BEC_2_6_6_SystemObject* bevd_5, BEC_2_6_6_SystemObject* bevd_6, std::vector<BEC_2_6_6_SystemObject*> bevd_x) {
#endif 

#ifdef BEDCC_SGC
  std::vector<BEC_2_6_6_SystemObject*> args = { bevd_0, bevd_1, bevd_2, bevd_3, bevd_4, bevd_5, bevd_6 };
#endif
  args.insert(args.end(), bevd_x.begin(), bevd_x.end());
  return bems_methodNotDefined(callId, args);
}

#ifdef BEDCC_SGC
  BEC_2_6_6_SystemObject* BECS_Object::bems_forwardCall(std::string mname, std::vector<BEC_2_6_6_SystemObject*> bevd_x, int32_t numargs) {
#endif
  return nullptr;
}

bool BECS_Runtime::isInitted = false;

BEC_2_5_4_LogicBool* BECS_Runtime::boolTrue;
BEC_2_5_4_LogicBool* BECS_Runtime::boolFalse;

std::unordered_map<std::string, BETS_Object*> BECS_Runtime::typeRefs;

//for setting up initial instances
BEC_2_6_11_SystemInitializer* BECS_Runtime::initializer;

BEC_2_6_6_SystemObject * BECS_Runtime::maino;

std::string BECS_Runtime::platformName;

int BECS_Runtime::argc;
char** BECS_Runtime::argv;

std::unordered_map<std::string, std::vector<int32_t>> BECS_Runtime::smnlcs;
std::unordered_map<std::string, std::vector<int32_t>> BECS_Runtime::smnlecs;

void BECS_Runtime::init() { 
    if (isInitted) { return; }
    isInitted = true;
    BECS_FrameStack* bevs_myStack = &BECS_Runtime::bevs_currentStack;
    bevs_myStack->bevs_ohs = (BECS_Object**) malloc(5000 * sizeof(BECS_Object*));
    bevs_myStack->bevs_hs = bevs_myStack->bevs_ohs;
    BECS_Runtime::boolTrue = new BEC_2_5_4_LogicBool(true);
    BECS_Runtime::boolFalse = new BEC_2_5_4_LogicBool(false);
    BECS_Runtime::initializer = new BEC_2_6_11_SystemInitializer();
}

void BECS_Runtime::doGc() {

#ifdef BEDCC_SGC
#ifdef BED_GCSTATS
std::cout << "GCDEBUG starting gc " << std::endl;
#endif

  ////cout << "GCDEBUG starting gc " << endl;
  ////cout << "GCDEBUG thread " << std::this_thread::get_id() << endl;

  BECS_FrameStack* bevs_myStack = &BECS_Runtime::bevs_currentStack;
  
  bevs_myStack->bevs_allocsSinceGc = 0;
  
#ifdef BEDCC_PT
  BECS_Runtime::bevg_sharedAllocsSinceGc.store(0, std::memory_order_release);
#endif
  
  BECS_Runtime::bevg_countGcs++;
  //increment gcmark
  BECS_Runtime::bevg_currentGcMark++;
  if (BECS_Runtime::bevg_currentGcMark > BEDCC_GCRWM) {
    BECS_Runtime::bevg_currentGcMark = 1;
    BECS_Runtime::bemg_zero();
  }
  //do all marking
  BECS_Runtime::bemg_markAll();
  if (BECS_Runtime::bevg_currentGcMark % BEDCC_GCMPERS == 0) {
    //do all sweeping
    BECS_Runtime::bevg_countSweeps++;
    BECS_Runtime::bemg_sweep();
  }

#ifdef BEDCC_PT
  BECS_Runtime::bevg_gcState.store(0, std::memory_order_release);
#endif

#ifdef BED_GCSTATS
std::cout << "GCDEBUG ending gc " << std::endl;
//std::cout << "GCDEBUG recycles " << BECS_Runtime::bevg_countRecycles  << std::endl;
//std::cout << "GCDEBUG allocs " << BECS_Runtime::bevg_countAllocs  << std::endl;
#endif

#endif

}

int32_t BECS_Runtime::getNlcForNlec(std::string clname, int32_t val) {
  
  if (smnlcs.count(clname) > 0 && smnlecs.count(clname) > 0) {
    std::vector<int32_t> sls = smnlcs[clname];
    std::vector<int32_t> esls = smnlecs[clname];
    //Console.WriteLine("esls is not null " + clname + " val " + val);
    int eslslen = esls.size();
    for (int i = 0;i < eslslen;i++) {
      //Console.WriteLine("esls i " + esls[i]);
      if (esls[i] == val) {
        return sls[i];
      }
    }
  } else {
    //Console.WriteLine("esls is null " + clname);
  }
  return -1;
}

void BECS_Runtime::bemg_markAll() {
  
#ifdef BEDCC_SGC

  //static std::unordered_map<std::string, BETS_Object*> typeRefs;
  
  //cout << "starting markAll" << endl;
  
  //runtime true, false, initter
  //static BEC_2_5_4_LogicBool* boolTrue;
  //static BEC_2_5_4_LogicBool* boolFalse;
  //static BEC_2_6_11_SystemInitializer* initializer;
  if (boolTrue != nullptr && boolTrue->bevg_gcMark != bevg_currentGcMark) {
    boolTrue->bemg_doMark();
  }
  if (boolFalse != nullptr && boolFalse->bevg_gcMark != bevg_currentGcMark) {
    boolFalse->bemg_doMark();
  }
  if (initializer != nullptr && initializer->bevg_gcMark != bevg_currentGcMark) {
    initializer->bemg_doMark();
  }
  if (maino != nullptr && maino->bevg_gcMark != bevg_currentGcMark) {
    maino->bemg_doMark();
  }
  
  //cout << "starting markAll typerefs" << endl;
  
  for (auto nt : typeRefs) {
    nt.second->bemgt_doMark();
  }
  
  //cout << "starting markAll stack" << endl;
  
  //BECS_FrameStack* bevs_myStack = &BECS_Runtime::bevs_currentStack;
  //BECS_Runtime::bemg_markStack(bevs_myStack);
#ifdef BEDCC_PT  
  for(auto const &idStack : bevg_frameStacks) {
    bemg_markStack(idStack.second);
  }
#endif
#ifndef BEDCC_PT 
  BECS_FrameStack* bevs_myStack = &BECS_Runtime::bevs_currentStack;
  bemg_markStack(bevs_myStack);
#endif
  bemg_markStack(&bevg_oldInstsStack);
  //cout << "ending markAll" << endl;

#endif
  
}

void BECS_Runtime::bemg_markStack(BECS_FrameStack* bevs_myStack) {
  
#ifdef BEDCC_SGC

  //decls
  BECS_StackFrame* bevs_currFrame;
  BEC_2_6_6_SystemObject* bevg_le;
  BECS_Object* bevg_leo;

  //diag pass
  bevs_currFrame = bevs_myStack->bevs_lastFrame;
  bevg_le = nullptr;
  int fct = 0;
  while (bevs_currFrame != nullptr) {
    for (size_t i = 0; i < bevs_currFrame->bevs_numVars; i++) {
      bevg_le = bevs_currFrame->bevs_checkVars[i];
      if (bevg_le != nullptr && bevg_le->bevg_gcMark != bevg_currentGcMark) {
        //add it
        fct++;
      }
    }
    bevg_le = bevs_currFrame->bevs_thiso;
    if (bevg_le != nullptr && bevg_le->bevg_gcMark != bevg_currentGcMark) {
      //later add it
    }
    bevs_currFrame = bevs_currFrame->bevs_priorFrame;
  }
  std::cout << "STCHK fct " << fct << std::endl;

  int sct = 0;
  BECS_Object** bevs_ohs = bevs_myStack->bevs_ohs;
  BECS_Object** bevs_hs = bevs_myStack->bevs_hs;
  bevg_leo = nullptr;
  while (bevs_ohs < bevs_hs) {
    bevg_leo = *(bevs_ohs);
    if (bevg_leo != nullptr && bevg_leo->bevg_gcMark != bevg_currentGcMark) {
      //add it
      sct++;
    }
    bevs_ohs++;
  }
  std::cout << "STCHK sct " << sct << std::endl;

  //real pass
  bevs_currFrame = bevs_myStack->bevs_lastFrame;
  bevg_le = nullptr;
  while (bevs_currFrame != nullptr) {
    for (size_t i = 0; i < bevs_currFrame->bevs_numVars; i++) {
      bevg_le = *(bevs_currFrame->bevs_localVars[i]);
      if (bevg_le != nullptr && bevg_le->bevg_gcMark != bevg_currentGcMark) {
        bevg_le->bemg_doMark();
      }
    }
    bevg_le = bevs_currFrame->bevs_thiso;
    if (bevg_le != nullptr && bevg_le->bevg_gcMark != bevg_currentGcMark) {
      bevg_le->bemg_doMark();
    }
    bevs_currFrame = bevs_currFrame->bevs_priorFrame;
  }
  bevs_myStack->bevs_nextReuse = bevs_myStack->bevs_lastInst;
  
#endif

}

void BECS_Runtime::bemg_sweep() {

#ifdef BEDCC_SGC

#ifdef BED_GCSTATS
std::cout << "GCDEBUG starting sweep " << std::endl;
#endif

  //BECS_FrameStack* bevs_myStack = &BECS_Runtime::bevs_currentStack;
  //BECS_Runtime::bemg_sweepStack(bevs_myStack);
#ifdef BEDCC_PT  
  for(auto const &idStack : bevg_frameStacks) {
    bemg_sweepStack(idStack.second);
  }
#endif
#ifndef BEDCC_PT 
  BECS_FrameStack* bevs_myStack = &BECS_Runtime::bevs_currentStack;
  bemg_sweepStack(bevs_myStack);
#endif
  bemg_sweepStack(&bevg_oldInstsStack);

#ifdef BED_GCSTATS
std::cout << "GCDEBUG ending sweep " << std::endl;
#endif
  
#endif

}

void BECS_Runtime::bemg_sweepStack(BECS_FrameStack* bevs_myStack) {

#ifdef BEDCC_SGC

  uint_fast16_t bevg_currentGcMark = BECS_Runtime::bevg_currentGcMark;
  
  BECS_Object* bevs_lastInst = bevs_myStack->bevs_lastInst;
  
  if (bevs_lastInst != nullptr) {
    BECS_Object* bevs_currInst = bevs_lastInst->bevg_priorInst;
    while (bevs_currInst != nullptr && bevs_currInst->bevg_priorInst != nullptr) {
      if (bevs_currInst->bevg_gcMark != bevg_currentGcMark) {
        bevs_lastInst->bevg_priorInst = bevs_currInst->bevg_priorInst;
        delete bevs_currInst;
        bevs_currInst = bevs_lastInst->bevg_priorInst;
      } else {
        bevs_lastInst = bevs_currInst;
        bevs_currInst = bevs_currInst->bevg_priorInst;
      }
    }
  }

#endif

}

void BECS_Runtime::bemg_zero() {

#ifdef BEDCC_SGC

#ifdef BED_GCSTATS
std::cout << "GCDEBUG starting zero " << std::endl;
#endif

#ifdef BEDCC_PT  
  for(auto const &idStack : bevg_frameStacks) {
    bemg_zeroStack(idStack.second);
  }
#endif
#ifndef BEDCC_PT 
  BECS_FrameStack* bevs_myStack = &BECS_Runtime::bevs_currentStack;
  bemg_zeroStack(bevs_myStack);
#endif
  bemg_zeroStack(&bevg_oldInstsStack);

#ifdef BED_GCSTATS
std::cout << "GCDEBUG ending zero " << std::endl;
#endif
  
#endif

}

void BECS_Runtime::bemg_zeroStack(BECS_FrameStack* bevs_myStack) {

#ifdef BEDCC_SGC
  
  BECS_Object* bevs_currInst = bevs_myStack->bevs_lastInst;
  
  while (bevs_currInst != nullptr) {
    bevs_currInst->bevg_gcMark = 0;
    bevs_currInst = bevs_currInst->bevg_priorInst;
  }

#endif

}

void BECS_Runtime::bemg_addMyFrameStack() {

#ifdef BEDCC_SGC
#ifdef BEDCC_PT 
  std::thread::id tid = std::this_thread::get_id();
  BECS_FrameStack* bevs_myStack = &BECS_Runtime::bevs_currentStack;
  bevg_frameStacks[tid] = bevs_myStack;
#endif
#endif

}

void BECS_Runtime::bemg_deleteMyFrameStack() {

#ifdef BEDCC_SGC
#ifdef BEDCC_PT  
  //cout << "GCDEBUG dmfs b " << bevg_frameStacks.size() << endl;
  std::thread::id tid = std::this_thread::get_id();
  auto it = bevg_frameStacks.find(tid);
  bevg_frameStacks.erase(it);
  //cout << "GCDEBUG dmfs e " << bevg_frameStacks.size() << endl;
#endif
#endif

}

void BECS_Runtime::bemg_beginThread() {

#ifdef BEDCC_SGC
#ifdef BEDCC_PT 
  //cout << "GCDEBUG start begin thread" << endl;
  bevg_gcLock.lock();
  bemg_addMyFrameStack();
  bevg_gcLock.unlock();
  //cout << "GCDEBUG st do gc" << endl;
  bemg_checkDoGc();
#endif
#endif

}

void BECS_Runtime::bemg_endThread() {

#ifdef BEDCC_SGC
#ifdef BEDCC_PT
  //cout << "GCDEBUG start end thread" << endl;
  bevg_gcLock.lock();
  BECS_FrameStack* bevs_myStack = &BECS_Runtime::bevs_currentStack;
  BECS_Object* bevs_lastInst = bevs_myStack->bevs_lastInst;
  
  if (bevs_lastInst != nullptr) {
    BECS_Object* bevs_currInst = bevs_lastInst;
    while (bevs_currInst != nullptr) {
      bevs_lastInst = bevs_currInst;
      bevs_currInst = bevs_currInst->bevg_priorInst;
    }
  }
  bevs_lastInst->bevg_priorInst = BECS_Runtime::bevg_oldInstsStack.bevs_lastInst;
  BECS_Runtime::bevg_oldInstsStack.bevs_lastInst = bevs_myStack->bevs_lastInst;
  
  bemg_deleteMyFrameStack();
  bevg_gcLock.unlock();
  //cout << "GCDEBUG et do gc" << endl;
  bemg_checkDoGc();
#endif
#endif

}

void BECS_Runtime::bemg_enterBlocking() {

#ifdef BEDCC_SGC
#ifdef BEDCC_PT
  BECS_FrameStack* bevs_myStack = &BECS_Runtime::bevs_currentStack;
  bevg_gcLock.lock();
  bevs_myStack->bevg_stackGcState = 1;
  bevg_gcLock.unlock();
  bemg_checkDoGc();
#endif
#endif

}

void BECS_Runtime::bemg_exitBlocking() {

#ifdef BEDCC_SGC
#ifdef BEDCC_PT
  BECS_FrameStack* bevs_myStack = &BECS_Runtime::bevs_currentStack;
  bevg_gcLock.lock();
  bevs_myStack->bevg_stackGcState = 0;
  bevg_gcLock.unlock();
  bemg_checkDoGc();
#endif
#endif

}

//RT
//static std::mutex bevg_gcLock;
//static std::condition_variable bevg_gcWaiter;
//static std::atomic<uint_fast16_t> bevg_gcState;
//FS
//uint_fast16_t bevg_stackGcState = 0;

void BECS_Runtime::bemg_checkDoGc() {
  
#ifdef BEDCC_SGC
  BECS_FrameStack* bevs_myStack = &BECS_Runtime::bevs_currentStack;
#ifndef BEDCC_PT
  doGc();
#endif 
#ifdef BEDCC_PT 
  //lock
  std::unique_lock<std::mutex> ulock(bevg_gcLock);

  //if time for gc
  if (bevg_gcState.load(std::memory_order_acquire) == 1) {
    uint_fast16_t bevg_stackGcState = bevs_myStack->bevg_stackGcState;
    if (bevg_stackGcState != 1) {
      bevs_myStack->bevg_stackGcState = 1;
    }
    bool readyForGc = bemg_readyForGc();
    if (readyForGc) {
      //do gc
      doGc();
      if (bevg_stackGcState != 1) {
        bevs_myStack->bevg_stackGcState = bevg_stackGcState;
      }
      //notify all
      //cout << "GCDEBUG gc na" << endl;
      bevg_gcWaiter.notify_all();
    } else {
      //wait until gc is done (condvar, recheck)
      while (bevg_gcState.load(std::memory_order_acquire) == 1) {
        bevg_gcWaiter.wait(ulock);//is going to unlock then relock
      }
      if (bevg_stackGcState != 1) {
        bevs_myStack->bevg_stackGcState = bevg_stackGcState;
      }
    }
  }
#endif
#endif

}

bool BECS_Runtime::bemg_readyForGc() {
  //cout << "GCDEBUG ready for gc " << endl;
  bool readyForGc = true;
#ifdef BEDCC_SGC
#ifdef BEDCC_PT
  for(auto const &idStack : bevg_frameStacks) {
    //cout << "GCDEBUG rgc sgc " << idStack.second->bevg_stackGcState << endl;
    if (idStack.second->bevg_stackGcState == 0) {
      readyForGc = false;
    }
  }
#endif
#endif
  return readyForGc;
}

void BETS_Object::bems_buildMethodNames(std::vector<std::string> names) {
  for (unsigned i=0; i < names.size(); i++) {
      bevs_methodNames[names[i]] = true;
  }
}

BEC_2_6_6_SystemObject* BETS_Object::bems_createInstance() {
  return nullptr;
}

void BETS_Object::bemgt_doMark() {
}

BECS_ThrowBack::BECS_ThrowBack() { }

BECS_ThrowBack::BECS_ThrowBack(BEC_2_6_6_SystemObject* thrown) {
  wasThrown = thrown;
}

BEC_2_6_6_SystemObject* BECS_ThrowBack::handleThrow(BECS_ThrowBack thrown) {
  return thrown.wasThrown;
}
