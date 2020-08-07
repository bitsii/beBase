// Copyright 2016 The Brace Authors. All rights reserved.
// Use of this source code is governed by the BSD-3-Clause
// license that can be found in the LICENSE file.

use Container:List;

use Test:SClass;
use Test:Clp;
use Test:Clc;

class Test:Clp { }

class Test:Clc(Clp) { }

class Test:TestTypes {
   
   main() {
      return(testTypes());
   }
   
   testTypes() {
      any x = Clp.new();
      any y = Clc.new();
      x.sameType(y).print();
      y.sameType(x).print();
      x.sameType(x).print();
   }
   
}

