use Math:Int;

class Test:TestElif {
   
   main() {
      return(testElif());
   }
   
   /* testElifAll() {
      //if if elif elif elif else
      if (true) {
         ("IF").print();
      }
      if (true) {
         ("IF").print();
      } elif (true) {
         ("ELIF").print();
      } elif (true) {
         ("ELIF").print();
      } elif (true) {
         ("ELIF").print();
      } else {
         ("ELSE").print();
      }
   } */
   
   testElif() {
      if (false) {
         ("IF").print();
      } elif (false) {
         ("ELIF1").print();
      } elif (false) {
         ("ELIF2").print();
      } else {
         ("ELSE").print();
      }
   }
}

