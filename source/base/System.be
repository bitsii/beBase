/*
 * Copyright (c) 2006-2023, the Brace Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

final class System:Thing {
   
   emit(c) {
   """
/*-attr- -firstSlotNative-*/
   """
   }
   
   vthingGet() { }
   
   vthingSet(vthing) { }
   
   new() self {
      
      fields {
         //dyn vthing;
      }
      
   }
}

final class System:GC {

   create() self { }
   
   default() self {
      
   }
   
   maybeGc() {
   emit(cc) {
   """
   BECS_Runtime::doGc();
   """
   }
   }

}
