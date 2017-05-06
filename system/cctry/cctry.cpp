#include "cctry.hpp"

namespace bet {
  
void BECT_String::doIt(shared_ptr<BECT_String> aptr) { 
    
}

shared_ptr<BECT_String> BECT_String::retIt(shared_ptr<BECT_String> aptr) { 
    return aptr;
}

void BECT_Classy::yukka() { }

void BECT_StayClassy::yukka() { 
   bevm_a = make_shared<BECT_Classy>();
}

}

int main()
{
//std::cout << "Hello, World.";
std::cout.write("Hi\n", 3);
}
