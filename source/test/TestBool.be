

class Test:TestBool {
   
   main() {
      return(testBool());
   }
   
   testBool() {
      var t = true;
      t = t!;
      if (t) {
         "!FAILED not".print();
         return(false);
      }
      " PASSED not".print();
      
      t = true;
      var f = false;
      if (t == f) {
         "!FAILED equals".print();
         return(false);
      }
      " PASSED equals".print();
      var ts = Logic:Bool.new("true");
      if (ts) {
         " PASSED str cons".print();
      } else {
         "!FAILED str cons".print();
         return(false);
      }
      return(true);
   }
   
}

