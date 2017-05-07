#include "cctry.hpp"

namespace be {
  
static unsigned char becc_clname[] = {0x53,0x79,0x73,0x74,0x65,0x6D,0x3A,0x4F,0x62,0x6A,0x65,0x63,0x74};

static shared_ptr<BEC_String> clnamestr = make_shared<BEC_String>(13, becc_clname);

BECS_Object::~BECS_Object() {
  
  cout << "destruct BECS_Object\n";
  
}

BEC_String::BEC_String(unsigned char* _bevi_bytes, int32_t _bevi_length) {
  //no copy
}

BEC_String::BEC_String(int32_t _bevi_length, unsigned char* _bevi_bytes) {
  //copy
  unsigned char* bb = (unsigned char*) malloc(_bevi_length * sizeof(unsigned char));
  memcpy(bb, _bevi_bytes, _bevi_length * sizeof(unsigned char));
  bevi_bytes = bb;
  bevi_length = _bevi_length;
}

BEC_String::~BEC_String() {
  
  cout << "destruct BEC_String\n";
  
}
  
shared_ptr<BEC_String> BEC_String::print() { 
    return static_pointer_cast<BEC_String>(shared_from_this());
}

shared_ptr<BEC_Classy> BEC_Classy::printIt(shared_ptr<BEC_String> it) { 
  return static_pointer_cast<BEC_Classy>(shared_from_this());
}

shared_ptr<BEC_Classy> BEC_StayClassy::printIt(shared_ptr<BEC_String> it) { 
  return static_pointer_cast<BEC_StayClassy>(shared_from_this());
}

void innerMain() {
  shared_ptr<BEC_String> str = make_shared<BEC_String>();
  shared_ptr<BEC_String> str2 = str->print();
}

}

int main()
{
  
cout.write("Hi\n", 3);
be::innerMain();

}
