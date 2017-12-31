    
unordered_map<string, int32_t> BECS_Ids::callIds;
unordered_map<int32_t, string> BECS_Ids::idCalls;

__thread BECS_FrameStack BECS_Runtime::bevs_currentStack;

uint_fast16_t BECS_Runtime::bevg_currentGcMark = 0;

//std::atomic<bool> BECS_Runtime::bevg_startGc{false};

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

string BECS_Runtime::platformName;

int BECS_Runtime::argc;
char** BECS_Runtime::argv;

unordered_map<string, vector<int32_t>> BECS_Runtime::smnlcs;
unordered_map<string, vector<int32_t>> BECS_Runtime::smnlecs;

void BECS_Runtime::init() { 
    if (isInitted) { return; }
    isInitted = true;
    BECS_Runtime::boolTrue = new BEC_2_5_4_LogicBool(true);
    BECS_Runtime::boolFalse = new BEC_2_5_4_LogicBool(false);
    BECS_Runtime::initializer = new BEC_2_6_11_SystemInitializer();
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
  
  cout << "starting markAll" << endl;
  
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
  
  cout << "starting markAll typerefs" << endl;
  
  for (auto nt : typeRefs) {
    nt.second->bemgt_doMark();
  }
  
  cout << "starting markAll stack" << endl;
  
  BECS_FrameStack* bevs_myStack = &BECS_Runtime::bevs_currentStack;
  BECS_StackFrame* bevs_currFrame = bevs_myStack->bevs_lastFrame;
  while (bevs_currFrame != nullptr) {
    for (size_t i = 0; i < bevs_currFrame->bevs_numVars; i++) {
      BEC_2_6_6_SystemObject* bevg_le = *(bevs_currFrame->bevs_localVars[i]);
      if (bevg_le != nullptr && bevg_le->bevg_gcMark != bevg_currentGcMark) {
        bevg_le->bemg_doMark();
      }
    }
    bevs_currFrame = bevs_currFrame->bevs_priorFrame;
  }
  
  cout << "ending markAll" << endl;
  
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


