// Copyright 2006 The Brace Authors. All rights reserved.
// Use of this source code is governed by the BSD-3-Clause
// license that can be found in the LICENSE file.

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
         //any vthing;
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
