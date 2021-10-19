#include <iostream>
#include <memory>
#include <cstdint>
#include <cstring>
#include <unordered_map>

using namespace std;

namespace be {

class BECS_Object;
class BEC_Object;
class BEC_Classy;
class BEC_StayClassy;
class BEX_E;

class BEX_E {
  public:
    static int32_t bevn_an;
    static std::unordered_map<std::string, int32_t> callIds;
};

class BECS_Object : public enable_shared_from_this<BECS_Object> { 
  public:
    virtual ~BECS_Object();
};

class BEC_Object : public BECS_Object { };

class BEC_String : public BEC_Object {
  public:
    unsigned char* bevi_bytes;
    int32_t bevi_length;
    BEC_String() { }
    BEC_String(unsigned char* _bevi_bytes, int32_t _bevi_length);//no copy
    BEC_String(int32_t _bevi_length, unsigned char* _bevi_bytes);//copy
    virtual ~BEC_String();
    virtual shared_ptr<BEC_String> print();

};


class BEC_Classy : public BEC_Object {
  
  public:
    virtual shared_ptr<BEC_Classy> printIt(shared_ptr<BEC_String> it);
  
};

class BEC_StayClassy : public BEC_Classy {
  
  public:
    virtual shared_ptr<BEC_Classy> printIt(shared_ptr<BEC_String> it);
    virtual void bemc_setInitial(shared_ptr<BEC_Classy> becc_inst);
    virtual shared_ptr<BEC_Classy> bemc_getInitial();
    virtual shared_ptr<BEC_StayClassy> bemc_retNull();
    
};

}
