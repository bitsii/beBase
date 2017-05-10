
class BECS_Object {
  public:
    virtual shared_ptr<BEC_2_4_6_TextString> bemc_clnames();
    virtual shared_ptr<BEC_2_4_6_TextString> bemc_clfiles();
    virtual shared_ptr<BEC_2_6_6_SystemObject> bemc_create();
};

