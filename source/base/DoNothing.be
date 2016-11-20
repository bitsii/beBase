// Copyright 2006 Craig Welch
//
// Licensed under the MIT license. See LICENSE.txt file in the project root 
// for full license information.

//check inline logic for including only current lang
emit(doofus) {
    """
    doofus doofus
    """
}
class System:DoNothing {
emit(doofus) {
    """
    doofus doofus
    """
}
   main() {
   emit(doofus) {
    """
    doofus doofus
    """
}
      //almost nothing, this should never be called
      //("In System:DoNothing").print();
   }
}
