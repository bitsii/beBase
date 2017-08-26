    
unordered_map<string, int32_t> BECS_Ids::callIds;
unordered_map<int32_t, string> BECS_Ids::idCalls;


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

shared_ptr<BEC_2_4_6_TextString> BECS_Object::bemc_clnames() {
  return nullptr;  
}

shared_ptr<BEC_2_4_6_TextString> BECS_Object::bemc_clfiles() {
  return nullptr; 
}

shared_ptr<BEC_2_6_6_SystemObject> BECS_Object::bemc_create() {
  return nullptr;
}

void BECS_Object::bemc_setInitial(shared_ptr<BEC_2_6_6_SystemObject> becc_inst) { }

shared_ptr<BEC_2_6_6_SystemObject> BECS_Object::bemc_getInitial() {
 return nullptr; 
}

//bemds
shared_ptr<BEC_2_6_6_SystemObject> BECS_Object::bemd_0(int32_t callId) {
  //TODO impl bems_methodNotDefined, don't cast have a BECS_Object method
  cout << "in bemd0 becs" << endl;
  return nullptr;
}

shared_ptr<BEC_2_6_6_SystemObject> BECS_Object::bemd_1(int32_t callId, shared_ptr<BEC_2_6_6_SystemObject> bevd_0) {
  return nullptr;
}

shared_ptr<BEC_2_6_6_SystemObject> BECS_Object::bemd_2(int32_t callId, shared_ptr<BEC_2_6_6_SystemObject> bevd_0, shared_ptr<BEC_2_6_6_SystemObject> bevd_1) {
  return nullptr;
}

shared_ptr<BEC_2_6_6_SystemObject> BECS_Object::bemd_3(int32_t callId, shared_ptr<BEC_2_6_6_SystemObject> bevd_0, shared_ptr<BEC_2_6_6_SystemObject> bevd_1, shared_ptr<BEC_2_6_6_SystemObject> bevd_2) {
  return nullptr;
}

shared_ptr<BEC_2_6_6_SystemObject> BECS_Object::bemd_4(int32_t callId, shared_ptr<BEC_2_6_6_SystemObject> bevd_0, shared_ptr<BEC_2_6_6_SystemObject> bevd_1, shared_ptr<BEC_2_6_6_SystemObject> bevd_2, shared_ptr<BEC_2_6_6_SystemObject> bevd_3) {
  return nullptr;
}

shared_ptr<BEC_2_6_6_SystemObject> BECS_Object::bemd_5(int32_t callId, shared_ptr<BEC_2_6_6_SystemObject> bevd_0, shared_ptr<BEC_2_6_6_SystemObject> bevd_1, shared_ptr<BEC_2_6_6_SystemObject> bevd_2, shared_ptr<BEC_2_6_6_SystemObject> bevd_3, shared_ptr<BEC_2_6_6_SystemObject> bevd_4) {
  return nullptr;
}

shared_ptr<BEC_2_6_6_SystemObject> BECS_Object::bemd_6(int32_t callId, shared_ptr<BEC_2_6_6_SystemObject> bevd_0, shared_ptr<BEC_2_6_6_SystemObject> bevd_1, shared_ptr<BEC_2_6_6_SystemObject> bevd_2, shared_ptr<BEC_2_6_6_SystemObject> bevd_3, shared_ptr<BEC_2_6_6_SystemObject> bevd_4, shared_ptr<BEC_2_6_6_SystemObject> bevd_5) {
  return nullptr;
}

shared_ptr<BEC_2_6_6_SystemObject> BECS_Object::bemd_7(int32_t callId, shared_ptr<BEC_2_6_6_SystemObject> bevd_0, shared_ptr<BEC_2_6_6_SystemObject> bevd_1, shared_ptr<BEC_2_6_6_SystemObject> bevd_2, shared_ptr<BEC_2_6_6_SystemObject> bevd_3, shared_ptr<BEC_2_6_6_SystemObject> bevd_4, shared_ptr<BEC_2_6_6_SystemObject> bevd_5, shared_ptr<BEC_2_6_6_SystemObject> bevd_6) {
  return nullptr;
}

shared_ptr<BEC_2_6_6_SystemObject> BECS_Object::bemd_x(int32_t callId, shared_ptr<BEC_2_6_6_SystemObject> bevd_0, shared_ptr<BEC_2_6_6_SystemObject> bevd_1, shared_ptr<BEC_2_6_6_SystemObject> bevd_2, shared_ptr<BEC_2_6_6_SystemObject> bevd_3, shared_ptr<BEC_2_6_6_SystemObject> bevd_4, shared_ptr<BEC_2_6_6_SystemObject> bevd_5, shared_ptr<BEC_2_6_6_SystemObject> bevd_6, vector<shared_ptr<BEC_2_6_6_SystemObject>> bevd_x) {
  return nullptr;
}

shared_ptr<BEC_2_6_6_SystemObject> BECS_Object::bems_forwardCall(string mname, vector<shared_ptr<BEC_2_6_6_SystemObject>> bevd_x, int32_t numargs) {
  return nullptr;
}

bool BECS_Runtime::isInitted = false;

shared_ptr<BEC_2_5_4_LogicBool> BECS_Runtime::boolTrue;
shared_ptr<BEC_2_5_4_LogicBool> BECS_Runtime::boolFalse;

unordered_map<string, BETS_Object*> BECS_Runtime::typeRefs;

//for setting up initial instances
shared_ptr<BEC_2_6_11_SystemInitializer> BECS_Runtime::initializer;

string BECS_Runtime::platformName;

vector<string> BECS_Runtime::args;

unordered_map<string, vector<int32_t>> BECS_Runtime::smnlcs;
unordered_map<string, vector<int32_t>> BECS_Runtime::smnlecs;

void BECS_Runtime::init() { 
    if (isInitted) { return; }
    isInitted = true;
    BECS_Runtime::boolTrue = make_shared<BEC_2_5_4_LogicBool>(true);
    BECS_Runtime::boolFalse = make_shared<BEC_2_5_4_LogicBool>(false);
    BECS_Runtime::initializer = make_shared<BEC_2_6_11_SystemInitializer>();
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

void BETS_Object::bems_buildMethodNames(std::vector<std::string> names) {
  for (unsigned i=0; i < names.size(); i++) {
      bevs_methodNames[names[i]] = true;
  }
}

shared_ptr<BEC_2_6_6_SystemObject> BETS_Object::bems_createInstance() {
  return nullptr;
}

BECS_ThrowBack::BECS_ThrowBack() { }

BECS_ThrowBack::BECS_ThrowBack(shared_ptr<BEC_2_6_6_SystemObject> thrown) {
  wasThrown = thrown;
}

shared_ptr<BEC_2_6_6_SystemObject> BECS_ThrowBack::handleThrow(BECS_ThrowBack thrown) {
  return thrown.wasThrown;
}


