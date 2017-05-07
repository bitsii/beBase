#include "cctry.hpp"

namespace be {

BECS_Object::~BECS_Object() {
  
  cout << "destruct BECS_Object\n";
  
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
