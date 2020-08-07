// Copyright 2016 The Brace Authors. All rights reserved.
// Use of this source code is governed by the BSD-3-Clause
// license that can be found in the LICENSE file.

use Container:List;
use Math:Int;
use Text:String;
use Text:String;
use System:Serializer;
use Container:Map;
use Container:List;

class Test:ToSerialize {

   new() self {
      fields {
         any i = 10;
         any s = "Hi";
         any a = List.new(4);
         any n = "Not so null";
         any m = Map.new();
         any v = List.new(3);
         any t = true;
         any f = false;
      }
      a[1] = "a2";
      a[3] = "a4";
      m["Hi there"] = " Bob";
      v += "In a vector";
   }
   toString() String {
      String r = String.new();
      String nl = "\n";
      r += i.toString() += " " += s += " is n null? " += undef(n).toString() += nl;
      iteradd("a", a, r);
      iteradd("m", m, r);
      iteradd("v", v, r);
      r += "t is " += t.toString() += nl;
      r += "f is " += f.toString() += nl;
      return(r.toString());
   }
   iteradd(String p, any a, String r) {
      String nl = "\n";
      for (any j in a) {
         if (undef(j)) {
            r += "next " += p += " is null " += nl;
         } else {
            r += "next " += p += " is " += j.toString() += nl;
         }
      }
   }
}

class Test:TestSerialize {

   main() {
      testSerialize();
   }
   
   testSerialize() {
      //serializeNew(String, "Hi there").print();
      Serializer s = Serializer.new();
      
      any x = Test:ToSerialize.new();
      x.n = null;
      //any x = "Hi";
      
      /*
      x.serializeContents().print();
      1.serializeContents().print();
      */
      
      any sbuf = String.new();
      "1".print();
      s.serialize(x, sbuf);
      "2".print();
      sbuf.print();
      "3".print();
      
      any y = s.deserialize(sbuf);
      "4".print();
      y.print();
      "5".print();
      sbuf.clear();
      any z = null;
      "6".print();
      s.serialize(z, sbuf);
      "7".print();
      any zz = s.deserialize(sbuf);
      "8".print();
      sbuf.print();
      "9".print();
      if (undef(zz)) {
         "zz is null".print();
      }
   }
   
}

