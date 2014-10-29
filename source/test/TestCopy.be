
class Test:TestCopy:Vars {
   
   prepare() {
      properties {
         var a = System:Object.new();
         var b = System:Object.new();
      }
   }
   
}

class Test:TestCopy {
   
   main() {
      return(testCopy());
   }
   
   testCopy() {
      if (self != copy()) {
      " PASSED testCopy self".print();
      } else {
      "!FAILED testCopy self".print();
      return(false);
      }
      
      var other = Test:TestCopy:Vars.new();
      other.prepare();
      var othercp = other.copy();
      if ((other.a == othercp.a) && (other != othercp)) {
      " PASSED testCopy other var".print();
      } else {
      "!FAILED testCopy other var".print();
      return(false);
      }
      return(true);
   }
   
}

