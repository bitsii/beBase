#include <iostream>
#include <memory>

using namespace std;

class BECT_Classy;
class BECT_StayClassy;

class BECT_String {
  public:
    unsigned char* bevi_bytes;
    int bevi_length;
    void doIt(shared_ptr<BECT_String> aptr);
};


class BECT_Classy {
  
  public:
    virtual void yukka();
    
  private:
    shared_ptr<BECT_Classy> bevt_a;
  
};

class BECT_StayClassy : public BECT_Classy {
  
  public:
    virtual void yukka();
  
  private:
    shared_ptr<BECT_StayClassy> bevt_a;
    
};
