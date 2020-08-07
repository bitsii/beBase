// Copyright 2016 The Brace Authors. All rights reserved.
// Use of this source code is governed by the BSD-3-Clause
// license that can be found in the LICENSE file.

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

