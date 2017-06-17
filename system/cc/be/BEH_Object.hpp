
class BECS_Object {
  public:
    virtual shared_ptr<BEC_2_4_6_TextString> bemc_clnames();
    virtual shared_ptr<BEC_2_4_6_TextString> bemc_clfiles();
    virtual shared_ptr<BEC_2_6_6_SystemObject> bemc_create();
    virtual void bemc_setInitial(shared_ptr<BEC_2_6_6_SystemObject> becc_inst);
    virtual shared_ptr<BEC_2_6_6_SystemObject> bemc_getInitial();
    //bemds, to 7 then x
    virtual shared_ptr<BEC_2_6_6_SystemObject> bemd_0(int callId);
    virtual shared_ptr<BEC_2_6_6_SystemObject> bemd_1(int callId, shared_ptr<BEC_2_6_6_SystemObject> bevd_0);
    virtual shared_ptr<BEC_2_6_6_SystemObject> bemd_2(int callId, shared_ptr<BEC_2_6_6_SystemObject> bevd_0, shared_ptr<BEC_2_6_6_SystemObject> bevd_1);
    virtual shared_ptr<BEC_2_6_6_SystemObject> bemd_3(int callId, shared_ptr<BEC_2_6_6_SystemObject> bevd_0, shared_ptr<BEC_2_6_6_SystemObject> bevd_1, shared_ptr<BEC_2_6_6_SystemObject> bevd_2);
    virtual shared_ptr<BEC_2_6_6_SystemObject> bemd_4(int callId, shared_ptr<BEC_2_6_6_SystemObject> bevd_0, shared_ptr<BEC_2_6_6_SystemObject> bevd_1, shared_ptr<BEC_2_6_6_SystemObject> bevd_2, shared_ptr<BEC_2_6_6_SystemObject> bevd_3);
    virtual shared_ptr<BEC_2_6_6_SystemObject> bemd_5(int callId, shared_ptr<BEC_2_6_6_SystemObject> bevd_0, shared_ptr<BEC_2_6_6_SystemObject> bevd_1, shared_ptr<BEC_2_6_6_SystemObject> bevd_2, shared_ptr<BEC_2_6_6_SystemObject> bevd_3, shared_ptr<BEC_2_6_6_SystemObject> bevd_4);
    virtual shared_ptr<BEC_2_6_6_SystemObject> bemd_6(int callId, shared_ptr<BEC_2_6_6_SystemObject> bevd_0, shared_ptr<BEC_2_6_6_SystemObject> bevd_1, shared_ptr<BEC_2_6_6_SystemObject> bevd_2, shared_ptr<BEC_2_6_6_SystemObject> bevd_3, shared_ptr<BEC_2_6_6_SystemObject> bevd_4, shared_ptr<BEC_2_6_6_SystemObject> bevd_5);
    virtual shared_ptr<BEC_2_6_6_SystemObject> bemd_7(int callId, shared_ptr<BEC_2_6_6_SystemObject> bevd_0, shared_ptr<BEC_2_6_6_SystemObject> bevd_1, shared_ptr<BEC_2_6_6_SystemObject> bevd_2, shared_ptr<BEC_2_6_6_SystemObject> bevd_3, shared_ptr<BEC_2_6_6_SystemObject> bevd_4, shared_ptr<BEC_2_6_6_SystemObject> bevd_5, shared_ptr<BEC_2_6_6_SystemObject> bevd_6);
    virtual shared_ptr<BEC_2_6_6_SystemObject> bemd_x(int callId, shared_ptr<BEC_2_6_6_SystemObject> bevd_0, shared_ptr<BEC_2_6_6_SystemObject> bevd_1, shared_ptr<BEC_2_6_6_SystemObject> bevd_2, shared_ptr<BEC_2_6_6_SystemObject> bevd_3, shared_ptr<BEC_2_6_6_SystemObject> bevd_4, shared_ptr<BEC_2_6_6_SystemObject> bevd_5, shared_ptr<BEC_2_6_6_SystemObject> bevd_6, vector<shared_ptr<BEC_2_6_6_SystemObject>> bevd_x);
};

class BETS_Object {
  public:
    std::unordered_map<std::string, bool> bevs_methodNames;
    std::vector<std::string> bevs_fieldNames;
    virtual void bems_buildMethodNames(std::vector<std::string> names);
    virtual shared_ptr<BEC_2_6_6_SystemObject> bems_createInstance();
};


class BECS_ThrowBack {
public:
    shared_ptr<BEC_2_6_6_SystemObject> wasThrown;
    BECS_ThrowBack();
    BECS_ThrowBack(shared_ptr<BEC_2_6_6_SystemObject> thrown);
    static shared_ptr<BEC_2_6_6_SystemObject> handleThrow(BECS_ThrowBack thrown);
};
