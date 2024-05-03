/*
 * Copyright (c) 2016-2023, the Bennt Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

use Test:TestIdx;
use Math:Int;
use Container:List;

class TestIdx {
   
   new() self {
      fields {
         any outermem;
      }
   }
   
   main() {
      return(testIdx());
   }
   
   testIdx() {
      List m = List.new(10);
      m.put(3, 3);
      m.get(3).print();
      //m[3].print();
      m[1 + 1] = 2 + 7;
      m[9 - 7].print();
      
      any x = Container:Map.new();
      x["hi bird"] = "foo";
      x["hi bird"].print();
   }
   
}

