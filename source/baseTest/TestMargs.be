/*
 * Copyright (c) 2016-2023, the Brace Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

use Container:List;

class Test:TestMargs {
   
   main() {
      return(testMargs());
   }
   
   hmargs(a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12) {
      a1.print();
      a2.print();
      a3.print();
      a4.print();
      a5.print();
      a6.print();
      a7.print();
      a8.print();
      a9.print();
      a10.print();
      a11.print();
      a12.print();
   }
   
   testMargs() {
      hmargs(1,2,3,4,5,6,7,8,9,10,11,12);
      return(true);
   }
   
}

