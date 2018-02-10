// Copyright 2016 Craig Welch
//
// Licensed under the MIT license. See LICENSE.txt file in the project root 
// for full license information.

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

