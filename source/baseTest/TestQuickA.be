/*
 * Copyright (c) 2016-2023, the Beysant Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

use Logic:Bool;

class Test:A {
   hubba3() { "dohubba".print(); }
}

class Test:TestQuick{
   
   main() {
      ("tqmain").print();
      Test:B.hubba3();
   }
   
}

