
class Test:TAa {
   new() self { fields {
      any boo;
      any aac;
   } }
}

class Test:TAb (Test:TAa) {
   new() self { fields {
      any bat;
      any bac;
   } }
   bacSet(_bac) {
      "bacset".print();
      bac = _bac + "x";
   }
   bacGet() {
      "bacget".print();
      return(bac + "l");
   }
}

class Test:TestAccessor {
   
   main() {
      return(testAccessor());
   }
   
   testAccessor() {
      any a = Test:TAa.new();
      a.booSet("Hi");
      any x = a.boo;
      x.print();
      a.boo = "Goo";
      a.boo.print();
      any b = Test:TAb.new();
      b.bac = "Hi";
      b.bac.print();
      //b.bacSet("HiAcc");
      //b.bacGet().print();
      /* 
      if (uux.get(0) == "Hi") {
      (" PASSED put, get ").print();
      } else {
      "!FAILED put, get".print();
      return(false);
      }
      */
      return(true);
   }
   
}

