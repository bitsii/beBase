use Container:List;

class Test:TestInvoke {
   
   main() {
      return(testInvoke());
   }
   
   callMe(aname) {
      ("From callMe " + aname).print();
   }
   
   testInvoke() {
      List args1 = List.new(1);
      List args0 = List.new(0);
      
      var x;
      var i;
      
      i = 5;
      "First".print();
      args1.put(0, 10);
      x = i.invoke("add", args1);
      x.print();

      x = "There";
      x.print();
      
      i = "Hi";
      i.invoke("print", args0);
      
      i.can("boofa", 2).print();
      i.can("lower", 0).print();
      
   }
   
}

