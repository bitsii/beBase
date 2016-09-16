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
      var x = Clp.new();
      var y = Clc.new();
      x.sameType(y).print();
      y.sameType(x).print();
      x.sameType(x).print();
   }
   
}

