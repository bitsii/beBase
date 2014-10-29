
class Test:TestHeq {
   
   main() {
      testHeq();
   }
   
   testHeq() {
      var s2 = self;
      var y = s2.specialHeq1();
      var x = s2.specialHeq2();
      //s2.noCallExists();//will fail
      if (x && (y!)) {
      " PASSED testHeq self id".print();
      } else {
      "!FAILED testHeq self id".print();
      return(false);
      }
      return(true);
   }
   
   specialHeq1() {
      "Call one".print();
      return(false);
   }
   
   specialHeq2() {
      "Call two".print();
      return(true);
   }
   

}

