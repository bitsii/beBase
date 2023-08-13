/*
 * Copyright (c) 2006-2023, the Brace Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

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
