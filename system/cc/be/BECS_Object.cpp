    
unordered_map<string, int32_t> BECS_Ids::callIds;
unordered_map<int32_t, string> BECS_Ids::idCalls;

thread_local BECS_FrameStack BECS_Runtime::bevs_currentStack;

uint_fast16_t BECS_Runtime::bevg_currentGcMark = 0;
atomic<uint_fast16_t> BECS_Runtime::bevg_gcState{0};
atomic<uint_fast32_t> BECS_Runtime::bevg_sharedAllocsSinceGc{0};

map<std::thread::id, BECS_FrameStack*> BECS_Runtime::bevg_frameStacks;

BECS_FrameStack BECS_Runtime::bevg_oldInstsStack;

std::recursive_mutex BECS_Runtime::bevs_initLock;

std::mutex BECS_Runtime::bevg_gcLock;
std::condition_variable BECS_Runtime::bevg_gcWaiter;

uint_fast64_t BECS_Runtime::bevg_countGcs = 0;
uint_fast64_t BECS_Runtime::bevg_countSweeps = 0;
uint_fast64_t BECS_Runtime::bevg_countNews = 0;
uint_fast64_t BECS_Runtime::bevg_countConstructs = 0;
uint_fast64_t BECS_Runtime::bevg_countDeletes = 0;
uint_fast64_t BECS_Runtime::bevg_countRecycles = 0;

void BECS_Lib::putCallId(string name, int32_t iid) {
    BECS_Ids::callIds[name] = iid;
    BECS_Ids::idCalls[iid] = name;
}
    
int32_t BECS_Lib::getCallId(string name) {
    return BECS_Ids::callIds[name];
}
    
void BECS_Lib::putNlcSourceMap(string clname, vector<int32_t>& vals) {
  BECS_Runtime::smnlcs[clname] = vals;
}
    
void BECS_Lib::putNlecSourceMap(string clname, vector<int32_t>& vals) {
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

BEC_2_6_6_SystemObject* BECS_Object::bems_methodNotDefined(int32_t callId, vector<BEC_2_6_6_SystemObject*> args) {
  BEC_2_6_6_SystemObject* so = static_cast<BEC_2_6_6_SystemObject*>(this);
  BEC_2_9_4_ContainerList* beArgs = new BEC_2_9_4_ContainerList(args);
  BEC_2_4_6_TextString* beCallId = new BEC_2_4_6_TextString(BECS_Ids::idCalls[callId]);
  return so->bem_methodNotDefined_2(beCallId, beArgs);
}

//bemds
BEC_2_6_6_SystemObject* BECS_Object::bemd_0(int32_t callId) {
  vector<BEC_2_6_6_SystemObject*> args = { };
  return bems_methodNotDefined(callId, args);
}

BEC_2_6_6_SystemObject* BECS_Object::bemd_1(int32_t callId, BEC_2_6_6_SystemObject* bevd_0) {
  vector<BEC_2_6_6_SystemObject*> args = { bevd_0 };
  return bems_methodNotDefined(callId, args);
}

BEC_2_6_6_SystemObject* BECS_Object::bemd_2(int32_t callId, BEC_2_6_6_SystemObject* bevd_0, BEC_2_6_6_SystemObject* bevd_1) {
  vector<BEC_2_6_6_SystemObject*> args = { bevd_0, bevd_1 };
  return bems_methodNotDefined(callId, args);
}

BEC_2_6_6_SystemObject* BECS_Object::bemd_3(int32_t callId, BEC_2_6_6_SystemObject* bevd_0, BEC_2_6_6_SystemObject* bevd_1, BEC_2_6_6_SystemObject* bevd_2) {
  vector<BEC_2_6_6_SystemObject*> args = { bevd_0, bevd_1, bevd_2 };
  return bems_methodNotDefined(callId, args);
}

BEC_2_6_6_SystemObject* BECS_Object::bemd_4(int32_t callId, BEC_2_6_6_SystemObject* bevd_0, BEC_2_6_6_SystemObject* bevd_1, BEC_2_6_6_SystemObject* bevd_2, BEC_2_6_6_SystemObject* bevd_3) {
  vector<BEC_2_6_6_SystemObject*> args = { bevd_0, bevd_1, bevd_2, bevd_3 };
  return bems_methodNotDefined(callId, args);
}

BEC_2_6_6_SystemObject* BECS_Object::bemd_5(int32_t callId, BEC_2_6_6_SystemObject* bevd_0, BEC_2_6_6_SystemObject* bevd_1, BEC_2_6_6_SystemObject* bevd_2, BEC_2_6_6_SystemObject* bevd_3, BEC_2_6_6_SystemObject* bevd_4) {
  vector<BEC_2_6_6_SystemObject*> args = { bevd_0, bevd_1, bevd_2, bevd_3, bevd_4 };
  return bems_methodNotDefined(callId, args);
}

BEC_2_6_6_SystemObject* BECS_Object::bemd_6(int32_t callId, BEC_2_6_6_SystemObject* bevd_0, BEC_2_6_6_SystemObject* bevd_1, BEC_2_6_6_SystemObject* bevd_2, BEC_2_6_6_SystemObject* bevd_3, BEC_2_6_6_SystemObject* bevd_4, BEC_2_6_6_SystemObject* bevd_5) {
  vector<BEC_2_6_6_SystemObject*> args = { bevd_0, bevd_1, bevd_2, bevd_3, bevd_4, bevd_5 };
  return bems_methodNotDefined(callId, args);
}

BEC_2_6_6_SystemObject* BECS_Object::bemd_7(int32_t callId, BEC_2_6_6_SystemObject* bevd_0, BEC_2_6_6_SystemObject* bevd_1, BEC_2_6_6_SystemObject* bevd_2, BEC_2_6_6_SystemObject* bevd_3, BEC_2_6_6_SystemObject* bevd_4, BEC_2_6_6_SystemObject* bevd_5, BEC_2_6_6_SystemObject* bevd_6) {
  vector<BEC_2_6_6_SystemObject*> args = { bevd_0, bevd_1, bevd_2, bevd_3, bevd_4, bevd_5, bevd_6 };
  return bems_methodNotDefined(callId, args);
}

BEC_2_6_6_SystemObject* BECS_Object::bemd_x(int32_t callId, BEC_2_6_6_SystemObject* bevd_0, BEC_2_6_6_SystemObject* bevd_1, BEC_2_6_6_SystemObject* bevd_2, BEC_2_6_6_SystemObject* bevd_3, BEC_2_6_6_SystemObject* bevd_4, BEC_2_6_6_SystemObject* bevd_5, BEC_2_6_6_SystemObject* bevd_6, vector<BEC_2_6_6_SystemObject*> bevd_x) {
  vector<BEC_2_6_6_SystemObject*> args = { bevd_0, bevd_1, bevd_2, bevd_3, bevd_4, bevd_5, bevd_6 };
  args.insert(args.end(), bevd_x.begin(), bevd_x.end());
  return bems_methodNotDefined(callId, args);
}

BEC_2_6_6_SystemObject* BECS_Object::bems_forwardCall(string mname, vector<BEC_2_6_6_SystemObject*> bevd_x, int32_t numargs) {
  return nullptr;
}

bool BECS_Runtime::isInitted = false;

BEC_2_5_4_LogicBool* BECS_Runtime::boolTrue;
BEC_2_5_4_LogicBool* BECS_Runtime::boolFalse;

unordered_map<string, BETS_Object*> BECS_Runtime::typeRefs;

//for setting up initial instances
BEC_2_6_11_SystemInitializer* BECS_Runtime::initializer;

BEC_2_6_6_SystemObject * BECS_Runtime::maino;

string BECS_Runtime::platformName;

int BECS_Runtime::argc;
char** BECS_Runtime::argv;

unordered_map<string, vector<int32_t>> BECS_Runtime::smnlcs;
unordered_map<string, vector<int32_t>> BECS_Runtime::smnlecs;

void BECS_Runtime::init() { 
    if (isInitted) { return; }
    isInitted = true;
    BECS_Runtime::bemg_addMyFrameStack();
    BECS_Runtime::boolTrue = new BEC_2_5_4_LogicBool(true);
    BECS_Runtime::boolFalse = new BEC_2_5_4_LogicBool(false);
    BECS_Runtime::initializer = new BEC_2_6_11_SystemInitializer();
}

void BECS_Runtime::doGc() {
  
  BECS_FrameStack* bevs_myStack = &BECS_Runtime::bevs_currentStack;
  
  bevs_myStack->bevs_allocsSinceGc = 0;
  BECS_Runtime::bevg_sharedAllocsSinceGc.store(0, std::memory_order_release);
  
  BECS_Runtime::bevg_countGcs++;
  //increment gcmark
  BECS_Runtime::bevg_currentGcMark++;
  if (BECS_Runtime::bevg_currentGcMark > 60000) {
    BECS_Runtime::bevg_currentGcMark = 1;
  }
  //do all marking
  BECS_Runtime::bemg_markAll();
  if (BECS_Runtime::bevg_currentGcMark % 6 == 0) {
    //do all sweeping
    BECS_Runtime::bevg_countSweeps++;
    BECS_Runtime::bemg_sweep();
  }

  bevs_myStack->bevs_nextReuse = bevs_myStack->bevs_lastInst;

  BECS_Runtime::bevg_gcState.store(0, std::memory_order_release);
  
  cout << "gcs " << BECS_Runtime::bevg_countGcs << " sweeps " << BECS_Runtime::bevg_countSweeps << " gc news " << BECS_Runtime::bevg_countNews << " gc deletes " << BECS_Runtime::bevg_countDeletes << " gc constructs " << BECS_Runtime::bevg_countConstructs << " recycles " << BECS_Runtime::bevg_countRecycles << endl;

}

int32_t BECS_Runtime::getNlcForNlec(string clname, int32_t val) {
  
  if (smnlcs.count(clname) > 0 && smnlecs.count(clname) > 0) {
    vector<int32_t> sls = smnlcs[clname];
    vector<int32_t> esls = smnlecs[clname];
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
  //static unordered_map<string, BETS_Object*> typeRefs;
  
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
  
  for(auto const &idStack : bevg_frameStacks) {
    bemg_markStack(idStack.second);
  }
  bemg_markStack(&bevg_oldInstsStack);
  //cout << "ending markAll" << endl;
  
}

void BECS_Runtime::bemg_markStack(BECS_FrameStack* bevs_myStack) {
  BECS_StackFrame* bevs_currFrame = bevs_myStack->bevs_lastFrame;
  BEC_2_6_6_SystemObject* bevg_le = nullptr;
  while (bevs_currFrame != nullptr) {
    bevg_le = bevs_currFrame->bevs_lastConstruct;
    if (bevg_le != nullptr && bevg_le->bevg_gcMark != bevg_currentGcMark) {
      bevg_le->bemg_doMark();
    }
    for (size_t i = 0; i < bevs_currFrame->bevs_numVars; i++) {
      bevg_le = *(bevs_currFrame->bevs_localVars[i]);
      if (bevg_le != nullptr && bevg_le->bevg_gcMark != bevg_currentGcMark) {
        bevg_le->bemg_doMark();
      }
    }
    bevs_currFrame = bevs_currFrame->bevs_priorFrame;
  }
}

void BECS_Runtime::bemg_sweep() {
  //BECS_FrameStack* bevs_myStack = &BECS_Runtime::bevs_currentStack;
  //BECS_Runtime::bemg_sweepStack(bevs_myStack);
  for(auto const &idStack : bevg_frameStacks) {
    bemg_sweepStack(idStack.second);
  }
  bemg_sweepStack(&bevg_oldInstsStack);
}

void BECS_Runtime::bemg_sweepStack(BECS_FrameStack* bevs_myStack) {
  
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
   
}

void BECS_Runtime::bemg_addMyFrameStack() {
  std::thread::id tid = std::this_thread::get_id();
  BECS_FrameStack* bevs_myStack = &BECS_Runtime::bevs_currentStack;
  bevg_frameStacks[tid] = bevs_myStack;
}

//RT
//static std::mutex bevg_gcLock;
//static std::condition_variable bevg_gcWaiter;
//static atomic<uint_fast16_t> bevg_gcState;
//FS
//uint_fast16_t bevg_stackGcState = 0;

void BECS_Runtime::bemg_checkDoGc() {
  BECS_FrameStack* bevs_myStack = &BECS_Runtime::bevs_currentStack;
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
}

void BECS_Runtime::bevg_setStackGcState(uint_fast16_t bevg_stackGcState) {
  //need to set state in lock and do a check do gc
  BECS_FrameStack* bevs_myStack = &BECS_Runtime::bevs_currentStack;
  bevg_gcLock.lock();
  bevs_myStack->bevg_stackGcState = bevg_stackGcState;
  bevg_gcLock.unlock();
  //? could only do checkDo if old state was 0
  bemg_checkDoGc();
}

bool BECS_Runtime::bemg_readyForGc() {
  bool readyForGc = true;
  for(auto const &idStack : bevg_frameStacks) {
    if (idStack.second->bevg_stackGcState == 0) {
      readyForGc = false;
    }
  }
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


