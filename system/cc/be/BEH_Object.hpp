
class BECS_Object {
  public:
    virtual shared_ptr<BEC_2_4_6_TextString> bemc_clnames();
    virtual shared_ptr<BEC_2_4_6_TextString> bemc_clfiles();
    virtual shared_ptr<BEC_2_6_6_SystemObject> bemc_create();
    virtual void bemc_setInitial(shared_ptr<BEC_2_6_6_SystemObject> becc_inst);
    virtual shared_ptr<BEC_2_6_6_SystemObject> bemc_getInitial();
};

class BETS_Object {
  public:
    std::unordered_map<std::string, bool> bevs_methodNames;
    std::vector<std::string> bevs_fieldNames;
    virtual void bems_buildMethodNames(std::vector<std::string> names);
    virtual shared_ptr<BEC_2_6_6_SystemObject> bems_createInstance();
};

