// Copyright 2006 The Bennt Authors. All rights reserved.
// Use of this source code is governed by the BSD-3-Clause
// license that can be found in the LICENSE file.

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
