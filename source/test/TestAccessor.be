
class Test:TAa {
   new() self { properties {
      var boo;
      var aac;
   } }
}

class Test:TAb (Test:TAa) {
   new() self { properties {
      var bat;
      var bac;
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
      var a = Test:TAa.new();
      a.booSet("Hi");
      var x = a.boo;
      x.print();
      a.boo = "Goo";
      a.boo.print();
      var b = Test:TAb.new();
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

