    
std::unordered_map<std::string, int32_t> BECS_Ids::callIds;
std::unordered_map<int32_t, std::string> BECS_Ids::idCalls;

#ifdef BEDCC_PT
std::recursive_mutex BECS_Runtime::bevs_initLock;
#endif

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

std::shared_ptr<BEC_2_4_6_TextString> BECS_Object::bemc_clnames() {
  return nullptr;  
}

std::shared_ptr<BEC_2_4_6_TextString> BECS_Object::bemc_clfiles() {
  return nullptr; 
}

std::shared_ptr<BEC_2_6_6_SystemObject> BECS_Object::bemc_create() {
  return nullptr;
}

void BECS_Object::bemc_setInitial(std::shared_ptr<BEC_2_6_6_SystemObject> becc_inst) { }

std::shared_ptr<BEC_2_6_6_SystemObject> BECS_Object::bemc_getInitial() {
 return nullptr; 
}

    std::shared_ptr<BEC_2_6_6_SystemObject> BECS_Object::bems_methodNotDefined(int32_t callId, std::vector<std::shared_ptr<BEC_2_6_6_SystemObject>> args) {

  std::shared_ptr<BEC_2_6_6_SystemObject> so = std::static_pointer_cast<BEC_2_6_6_SystemObject>(shared_from_this());
  
  std::shared_ptr<BEC_2_9_4_ContainerList> beArgs = nullptr;
  std::shared_ptr<BEC_2_4_6_TextString> beCallId = nullptr;

  beArgs = std::make_shared<BEC_2_9_4_ContainerList>(args);
  beCallId = std::make_shared<BEC_2_4_6_TextString>(BECS_Ids::idCalls[callId]);
  return so->bem_methodNotDefined_2(beCallId, beArgs);
}

//bemds
std::shared_ptr<BEC_2_6_6_SystemObject> BECS_Object::bemd_0(int32_t callId) {
  std::vector<std::shared_ptr<BEC_2_6_6_SystemObject>> args = { };
  return bems_methodNotDefined(callId, args);
}

std::shared_ptr<BEC_2_6_6_SystemObject> BECS_Object::bemd_1(int32_t callId, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_0) {

  std::vector<std::shared_ptr<BEC_2_6_6_SystemObject>> args = { bevd_0 };
  return bems_methodNotDefined(callId, args);
}

std::shared_ptr<BEC_2_6_6_SystemObject> BECS_Object::bemd_2(int32_t callId, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_0, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_1) {
  std::vector<std::shared_ptr<BEC_2_6_6_SystemObject>> args = { bevd_0, bevd_1 };
  return bems_methodNotDefined(callId, args);
}

std::shared_ptr<BEC_2_6_6_SystemObject> BECS_Object::bemd_3(int32_t callId, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_0, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_1, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_2) {
  std::vector<std::shared_ptr<BEC_2_6_6_SystemObject>> args = { bevd_0, bevd_1, bevd_2 };
  return bems_methodNotDefined(callId, args);
}

std::shared_ptr<BEC_2_6_6_SystemObject> BECS_Object::bemd_4(int32_t callId, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_0, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_1, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_2, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_3) {
  std::vector<std::shared_ptr<BEC_2_6_6_SystemObject>> args = { bevd_0, bevd_1, bevd_2, bevd_3 };
  return bems_methodNotDefined(callId, args);
}

std::shared_ptr<BEC_2_6_6_SystemObject> BECS_Object::bemd_5(int32_t callId, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_0, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_1, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_2, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_3, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_4) {
  std::vector<std::shared_ptr<BEC_2_6_6_SystemObject>> args = { bevd_0, bevd_1, bevd_2, bevd_3, bevd_4 };
  return bems_methodNotDefined(callId, args);
}

std::shared_ptr<BEC_2_6_6_SystemObject> BECS_Object::bemd_6(int32_t callId, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_0, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_1, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_2, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_3, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_4, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_5) {
  std::vector<std::shared_ptr<BEC_2_6_6_SystemObject>> args = { bevd_0, bevd_1, bevd_2, bevd_3, bevd_4, bevd_5 };
  return bems_methodNotDefined(callId, args);
}

std::shared_ptr<BEC_2_6_6_SystemObject> BECS_Object::bemd_7(int32_t callId, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_0, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_1, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_2, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_3, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_4, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_5, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_6) {
  std::vector<std::shared_ptr<BEC_2_6_6_SystemObject>> args = { bevd_0, bevd_1, bevd_2, bevd_3, bevd_4, bevd_5, bevd_6 };
  return bems_methodNotDefined(callId, args);
}

    std::shared_ptr<BEC_2_6_6_SystemObject> BECS_Object::bemd_x(int32_t callId, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_0, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_1, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_2, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_3, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_4, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_5, std::shared_ptr<BEC_2_6_6_SystemObject> bevd_6, std::vector<std::shared_ptr<BEC_2_6_6_SystemObject>> bevd_x) {

  std::vector<std::shared_ptr<BEC_2_6_6_SystemObject>> args = { bevd_0, bevd_1, bevd_2, bevd_3, bevd_4, bevd_5, bevd_6 };
  args.insert(args.end(), bevd_x.begin(), bevd_x.end());
  return bems_methodNotDefined(callId, args);
}

std::shared_ptr<BEC_2_6_6_SystemObject> BECS_Object::bems_forwardCall(std::string mname, std::vector<std::shared_ptr<BEC_2_6_6_SystemObject>> bevd_x, int32_t numargs) {
  return nullptr;
}

bool BECS_Runtime::isInitted = false;

std::shared_ptr<BEC_2_5_4_LogicBool> BECS_Runtime::boolTrue;
std::shared_ptr<BEC_2_5_4_LogicBool> BECS_Runtime::boolFalse;

std::unordered_map<std::string, BETS_Object*> BECS_Runtime::typeRefs;

//for setting up initial instances
std::shared_ptr<BEC_2_6_11_SystemInitializer> BECS_Runtime::initializer;

std::shared_ptr<BEC_2_6_6_SystemObject> BECS_Runtime::maino;

std::string BECS_Runtime::platformName;

int BECS_Runtime::argc;
char** BECS_Runtime::argv;

std::unordered_map<std::string, std::vector<int32_t>> BECS_Runtime::smnlcs;
std::unordered_map<std::string, std::vector<int32_t>> BECS_Runtime::smnlecs;

void BECS_Runtime::init() { 
    if (isInitted) { return; }
    isInitted = true;
    BECS_Runtime::boolTrue = std::make_shared<BEC_2_5_4_LogicBool>(true);
    BECS_Runtime::boolFalse = std::make_shared<BEC_2_5_4_LogicBool>(false);
    BECS_Runtime::initializer = std::make_shared<BEC_2_6_11_SystemInitializer>();
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

void BECS_Runtime::bemg_beginThread() {
}

void BECS_Runtime::bemg_endThread() {
}

void BETS_Object::bems_buildMethodNames(std::vector<std::string> names) {
  for (unsigned i=0; i < names.size(); i++) {
      bevs_methodNames[names[i]] = true;
  }
}

std::shared_ptr<BEC_2_6_6_SystemObject> BETS_Object::bems_createInstance() {
  return nullptr;
}

BECS_ThrowBack::BECS_ThrowBack() { }

BECS_ThrowBack::BECS_ThrowBack(std::shared_ptr<BEC_2_6_6_SystemObject> thrown) {
  wasThrown = thrown;
}

std::shared_ptr<BEC_2_6_6_SystemObject> BECS_ThrowBack::handleThrow(BECS_ThrowBack thrown) {
  return thrown.wasThrown;
}
