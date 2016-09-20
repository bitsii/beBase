use Math:Int;

class Test:TestElif {
   
   main() {
      return(testElif());
   }
   
   /* testElifAll() {
      //if if elseIf elseIf elseIf else
      if (true) {
         ("IF").print();
      }
      if (true) {
         ("IF").print();
      } elseIf (true) {
         ("ELIF").print();
      } elseIf (true) {
         ("ELIF").print();
      } elseIf (true) {
         ("ELIF").print();
      } else {
         ("ELSE").print();
      }
   } */
   
   testElif() {
      if (false) {
         ("IF").print();
      } elseIf (false) {
         ("ELIF1").print();
      } elseIf (false) {
         ("ELIF2").print();
      } else {
         ("ELSE").print();
      }
   }
}

