// Copyright 2006 Craig Welch
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

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
      ("In System:DoNothing").print();
   }
}
