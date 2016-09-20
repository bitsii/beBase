
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

