/*
 * Copyright (c) 2016-2023, the Brace Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

import Container:List;

import Test:SClass;
import Test:Clp;
import Test:Clc;

class Test:Clp { }

class Test:Clc(Clp) { }

class Test:TestTypes {
   
   main() {
      return(testTypes());
   }
   
   testTypes() {
   }
   
}

