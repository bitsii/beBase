use Container:List;

class Test:TestUnless {
   
   main() {
      return(testUnless());
   }
   
   testUnless() {
      unless(true) {
         "First".print();
      } else {
         "Second".print();
      }
      any x = 0;
      until(x == 1) {
         "Iter".print();
         x = x++;
      }
   }
   
}

