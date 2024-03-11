/*
 * Copyright (c) 2016-2023, the Brace Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

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
         dyn i = 10;
         dyn s = "Hi";
         dyn a = List.new(4);
         dyn n = "Not so null";
         dyn m = Map.new();
         dyn v = List.new(3);
         dyn t = true;
         dyn f = false;
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
   iteradd(String p, dyn a, String r) {
      String nl = "\n";
      for (dyn j in a) {
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
      
      dyn x = Test:ToSerialize.new();
      x.n = null;
      //dyn x = "Hi";
      
      /*
      x.serializeContents().print();
      1.serializeContents().print();
      */
      
      dyn sbuf = String.new();
      "1".print();
      s.serialize(x, sbuf);
      "2".print();
      sbuf.print();
      "3".print();
      
      dyn y = s.deserialize(sbuf);
      "4".print();
      y.print();
      "5".print();
      sbuf.clear();
      dyn z = null;
      "6".print();
      s.serialize(z, sbuf);
      "7".print();
      dyn zz = s.deserialize(sbuf);
      "8".print();
      sbuf.print();
      "9".print();
      if (undef(zz)) {
         "zz is null".print();
      }
   }
   
}

