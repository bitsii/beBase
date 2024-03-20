/*
 * Copyright (c) 2016-2023, the Brace Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

use Math:Int;

class Test:TestElif {
   
   main() {
      return(testElif());
   }
   
   /* testElifAll() {
      //if if elseIf elseIf elseIf else
      if (true) {
         ("IF").print();
      }
      if (true) {
         ("IF").print();
      } elseIf (true) {
         ("ELIF").print();
      } elseIf (true) {
         ("ELIF").print();
      } elseIf (true) {
         ("ELIF").print();
      } else {
         ("ELSE").print();
      }
   } */
   
   testElif() {
      if (false) {
         ("IF").print();
      } elseIf (false) {
         ("ELIF1").print();
      } elseIf (false) {
         ("ELIF2").print();
      } else {
         ("ELSE").print();
      }
   }
}

