
use Test:TestIdx;
use Math:Int;
use Container:Array;

class TestIdx {
   
   new() self {
      properties {
         var outermem;
      }
   }
   
   main() {
      return(testIdx());
   }
   
   testIdx() {
      Array m = Array.new(10);
      m.put(3, 3);
      m.get(3).print();
      //m[3].print();
      m[1 + 1] = 2 + 7;
      m[9 - 7].print();
      
      var x = Container:Map.new();
      x["hi bird"] = "foo";
      x["hi bird"].print();
   }
   
}

