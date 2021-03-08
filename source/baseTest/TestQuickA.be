// Copyright 2016 The Abelii Authors. All rights reserved.
// Use of this source code is governed by the BSD-3-Clause
// license that can be found in the LICENSE file.

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

