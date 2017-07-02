#include "cctry.hpp"

namespace be {
  
static unsigned char becc_BEC_2_6_6_SystemObject_clname[] = {0x53,0x79,0x73,0x74,0x65,0x6D,0x3A,0x4F,0x62,0x6A,0x65,0x63,0x74};

int32_t BEX_E::bevn_an = 22;
unordered_map<string, int32_t> BEX_E::callIds;

static shared_ptr<BEC_String> clnamestr = dynamic_pointer_cast<BEC_String>((make_shared<BEC_String>(13, becc_BEC_2_6_6_SystemObject_clname)));

static shared_ptr<BEC_StayClassy> bece_BEC_2_6_6_BEC_StayClassy_bevs_inst;

void BEC_StayClassy::bemc_setInitial(shared_ptr<BEC_Classy> becc_inst) {
bece_BEC_2_6_6_BEC_StayClassy_bevs_inst = static_pointer_cast<BEC_StayClassy>(becc_inst);
}
shared_ptr<BEC_Classy> BEC_StayClassy::bemc_getInitial() {
return bece_BEC_2_6_6_BEC_StayClassy_bevs_inst;
}

shared_ptr<BEC_StayClassy> BEC_StayClassy::bemc_retNull() {
  return nullptr;
}


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
    cout.write((char*)bevi_bytes, bevi_length);
    cout.write("\n", 1);
    return static_pointer_cast<BEC_String>(shared_from_this());
}

shared_ptr<BEC_Classy> BEC_Classy::printIt(shared_ptr<BEC_String> it) { 
  return static_pointer_cast<BEC_Classy>(shared_from_this());
}

shared_ptr<BEC_Classy> BEC_StayClassy::printIt(shared_ptr<BEC_String> it) { 
  return static_pointer_cast<BEC_StayClassy>(shared_from_this());
}

void innerMain() {
  int32_t len = clnamestr->bevi_length;
  shared_ptr<BEC_String> str2 = clnamestr->print();
  str2->print();
  
  if (str2 == nullptr) {
    cout << "str2 null should not be\n";
  }
  
  if (str2 != nullptr) {
    cout << "str2 not null should be not null\n";
  }
  
  str2 = nullptr;
  
  if (str2 == nullptr) {
    cout << "str2 null should be null\n";
  }
  
  if (str2 != nullptr) {
    cout << "str2 not null should not be not null\n";
  }
  
  str2 = clnamestr->print();
  
  if (str2 != nullptr) {
    cout << "str2 not null should be not null 2\n";
  }
  
  shared_ptr<BEC_String> str3 = dynamic_pointer_cast<BEC_String>(str2);
  
  cout << BEX_E::bevn_an;
  cout << "\n";
  
  shared_ptr<BEC_StayClassy> sc1 = make_shared<BEC_StayClassy>();
  
  sc1 = sc1->bemc_retNull();
  
  if (sc1 == nullptr) {
    cout << "sc1 null should be null\n";
  }
  
}

}

int main()
{
  
cout << "Start main()\n";
be::innerMain();
cout << "End main()\n";

}
