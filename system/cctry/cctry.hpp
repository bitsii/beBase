#include <iostream>
#include <memory>
#include <cstdint>

using namespace std;

namespace be {

class BECS_Object;
class BEC_Object;
class BEC_Classy;
class BEC_StayClassy;

class BECS_Object : public enable_shared_from_this<BECS_Object> { 
  public:
    virtual ~BECS_Object();
};

class BEC_Object : public BECS_Object { };

class BEC_String : public BEC_Object {
  public:
    unsigned char* bevi_bytes;
    int32_t bevi_length;
    virtual shared_ptr<BEC_String> print();
    virtual ~BEC_String();
    
};


class BEC_Classy : public BEC_Object {
  
  public:
    virtual shared_ptr<BEC_Classy> printIt(shared_ptr<BEC_String> it);
  
};

class BEC_StayClassy : public BEC_Classy {
  
  public:
    virtual void yukka();
    virtual shared_ptr<BEC_Classy> printIt(shared_ptr<BEC_String> it);
    
};

}
