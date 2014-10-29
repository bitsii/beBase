/*
Copyright 2006 Craig Welch
All rights reserved.

Developed by:

    Craig Welch

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal with
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

    * Redistributions of source code must retain the above copyright notice,
      this list of conditions and the following disclaimers.

    * Redistributions in binary form must reproduce the above copyright notice,
      this list of conditions and the following disclaimers in the
      documentation and/or other materials provided with the distribution.

    * Neither the name of the Software nor the names of its contributors may be used 
      to endorse or promote products derived from this Software without specific
      prior written permission.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
CONTRIBUTORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS WITH THE
SOFTWARE.
*/

use Container:Array;
use System:Parameters;
use Math:Int;
use Text:String;
use Text:String;
use System:Serializer;
use Container:Set;
use Container:Map;
use Container:Array;
use Container:LinkedList;

use Test:BaseTest;
use Test:Failure;
use Db:DirStore;

class Test:NotMuch {
}

class Test:Structy {
   
   new() self {
      properties {
         Int i;
         String s;
         var x;
         var y;
         String s2 = "StringS2";
      }
   }

}

class Test:ToSerialize {

   new() self {
      var ai = 4;
      var vi = 3;
      properties {
         var i = 10;
         var s = "Hi";
         var a = Array.new(ai);
         var n = null;
         var j = Set.new();
         var m = Map.new();
         var v = Array.new(vi);
         var l = LinkedList.new();
         var t = true;
         var f = false;
      }
      a[1] = "a2";
      a[3] = "a4";
      j.put("Goo");
      j.put("Ga");
      m["Hi there"] = " Bob";
      m["two"] = 2;
      v[0] = "In a vector";
      l += "In a linked list";
      l += "b";
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
      r += "i is " += i.toString() += nl;
      return(r.toString());
   }
   iteradd(String p, var a, String r) {
      String nl = "\n";
      foreach (var j in a) {
         if (undef(j)) {
            r += "next " += p += " is null " += nl;
         } else {
            r += "next " += p += " is " += j.toString() += nl;
         }
      }
   }
}

use Test:HasProps;

class HasProps {

   new() self {
      properties {
         String alpha = "a";
         String beta = "b";
         String gamma = "c";
      }
   }
   
   serializationNamesGet() Array {
     //to make threadsafe, init before return to once assign
      Array names = Array.new(3);
       names[0] = "alpha";
       names[1] = "beta";
       names[2] = "gamma";
      return(names);
   }
   
   serializationIteratorGet() {
      Array names =@ self.serializationNames;
      return(System:NamedPropertiesIterator.new(self, names));
   }
   
}

use Test:SerProps;

class SerProps {

   new() self {
      properties {
         String alpha = "a";
         String beta = "b";
      }
   }
   
   serializationNamesGet() Array {
     //to make threadsafe, init before return to once assign
      Array names = Array.new(5);
         names[0] = "alpha";
         names[1] = "beta";
         names[2] = "gamma";
         names[3] = "delta";
         names[4] = "epsilon";
         return(names);
   }
   
   serializationIteratorGet() {
      Array names =@ self.serializationNames;
      return(System:NamedPropertiesIterator.new(self, names));
   }
   
   gammaGet() {
      
   }
   
   deltaSet(x) {
   
   }
   
}

class Test:BaseTest:Serialize(BaseTest) {

   testSerProps() {
      ("setup").print();
      Serializer s = Serializer.new();
      var sbuf = String.new();
      
      SerProps x = SerProps.new();
      x.beta = "u";
      x.beta.print();
      //throw(System:Exception.new("same instance " + x.sameObject(x)));
      ("clear").print();
      sbuf.clear();
      ("serialize").print();
      s.serialize(x, sbuf);
      ("buf print").print();
      sbuf.print();
      ("deserialize").print();
      var y = s.deserialize(sbuf);
      ("asserts").print();
      assertEquals(x.beta, "u");
      ("xa " + x.alpha + " ya " + y.alpha).print();
      assertEquals(x.alpha, y.alpha);
      assertEquals(x.beta, y.beta);
      
   }
   
   main() {
      ("Test:BaseTest:Serialize:main").print();
      
      ifEmit(cs, jv) {
        //dirStoreTest();//can't be run concurrently due to fs changes, run from extended test
        //directly instead
      }
      
      ("testSerProps").print();
      testSerProps();
      
      if (true) { return(self); }
      
      ("testNamedProperties").print();
      testNamedProperties();
      
      ("testSet").print();
      testSet();
      
      ("testMap").print();
      testMap();
      
      ("testArray").print();
      testArray();
      
      ("testSaveIdentity").print();
      testSaveIdentity();
      
      ("testSimpleCase").print();
      testSimpleCase();
      
      ("testPropertyIterator").print();
      testPropertyIterator();
      
      ("testSerializePieces").print();
      testSerializePieces();
      
      ("testEmptyString").print();
      testEmptyString();
      
      ("testSerialize").print();
      testSerialize();
      
      ("testSerializePieces2").print();
      testSerializePieces2();
      
      ("testSerialize2").print();
      testSerialize2();
   }
   
   dirStoreTest() {
        DirStore ds = DirStore.new("test/tmp/ds");
        ds.delete("hi");
        assertFalse(ds.has("hi"));
        ds.put("hi","there");
        assertTrue(ds.has("hi"));
        assertEqual(ds.get("hi"), "there");
        ds.delete("hi");
    }
   
   testNamedProperties() {
      
      HasProps hp = HasProps.new();
      
      var iter;
      
      for (iter = hp.serializationIterator;iter.hasNext;) {
         iter.next.print();
      }
      
      Int i = 0;
      for (iter = hp.serializationIterator;iter.hasNext;) {
         iter.next = i.toString();
         i = i++;
      }
      
      for (iter = hp.serializationIterator;iter.hasNext;) {
         iter.next.print();
      }
      
   }
   
   testArray() {
      Serializer s = Serializer.new();
      var sbuf = String.new();
      sbuf.clear();
      
      Array x = Array.new();
      x += 2;
      
      s.serialize(x, sbuf);
      sbuf.print();
      var y = s.deserialize(sbuf);
      y.print();
      assertTrue(x[0] == y[0]);
      assertTrue(x.className == y.className);
      assertTrue(x.size == y.size);
   }
   
   testSet() {
      Serializer s = Serializer.new();
      var sbuf = String.new();
      sbuf.clear();
      
      Set x = Set.new(13);
      x.put("Hi");
      
      s.serialize(x, sbuf);
      sbuf.print();
      var y = s.deserialize(sbuf);
      //y.print();
      assertTrue(y.has("Hi"));
   }
   
   testMap() {
      Serializer s = Serializer.new();
      var sbuf = String.new();
      sbuf.clear();
      
      Map x = Map.new();
      x.put("Hi","There");
      
      s.serialize(x, sbuf);
      sbuf.print();
      var y = s.deserialize(sbuf);
      //y.print();
      assertTrue(x["Hi"] == y["Hi"]);
   }
   
   testSimpleCase() {
      Serializer s = Serializer.new();
      var sbuf = String.new();
      sbuf.clear();
      
      Test:Structy x = Test:Structy.new();
      x.x = Array.new(3);
      x.x[1] = "Hi";
      
      s.serialize(x, sbuf);
      sbuf.print();
      var y = s.deserialize(sbuf);
      y.print();
      assertEquals(y.x[1], x.x[1]);
   }
   
   testSaveIdentity() {
      ("testSaveIdentity start").print();
      Serializer s = Serializer.new();
      var sbuf = String.new();
      sbuf.clear();
      
      Test:Structy x = Test:Structy.new();
      x.x = "Two";
      x.y = x.x;
      
      s.serialize(x, sbuf);
      sbuf.print();
      var y = s.deserialize(sbuf);
      y.print();
      assertTrue(y.x.sameObject(y.y));
      
      sbuf.clear();
      s.saveIdentity = false;
      s.serialize(x, sbuf);
      sbuf.print();
      y = s.deserialize(sbuf);
      y.print();
      assertFalse(y.x.sameObject(y.y));
   }
   
   testSerializePieces() {
      ("Test:BaseTest:Serialize:testSerializePieces").print();
      Serializer s = Serializer.new();
      var sbuf = String.new();
      
      var y;
      var inst;
      var sinst;
      var iter;
      
      sbuf.clear();
      s.serialize(null, sbuf);
      assertIsNull(s.deserialize(sbuf));
      sbuf.print();
      
      sbuf.clear();
      String str = "..|#&@?;..";
      s.serialize(str, sbuf);
      sbuf.print();
      y = s.deserialize(sbuf);
      y.print();
      assertEquals(y, str);
      
      sbuf.clear();
      Int i = 10;
      s.serialize(i, sbuf);
      sbuf.print();
      y = s.deserialize(sbuf);
      y.print();
      assertEquals(y, 10);
      
      sbuf.clear();
      Test:NotMuch tn = Test:NotMuch.new();
      s.serialize(tn, sbuf);
      sbuf.print();
      y = s.deserialize(sbuf);
      y.print();
      
      sbuf.clear();
      Test:Structy structy = Test:Structy.new();
      structy.i = 5;
      structy.s = "Yo";
      structy.x = Test:Structy.new();
      structy.y = structy.x;
      s.serialize(structy, sbuf);
      sbuf.print();
      y = s.deserialize(sbuf);
      y.print();
      ("i " + y.i + " s " + y.s).print();
      if (undef(y.x)) {"y.x is null".print();}
      if (undef(y.y)) {"y.y is null".print();}
      assertTrue(y.x.sameObject(y.y))
      //return(self);
      sbuf.clear();
      inst = true;
      s.serialize(inst, sbuf);
      sbuf.print();
      y = s.deserialize(sbuf);
      //y.print();
      assertEquals(y, true);
      
      sbuf.clear();
      inst = Text:String.new();
      inst += "FooBah";
      s.serialize(inst, sbuf);
      sbuf.print();
      y = s.deserialize(sbuf);
      //y.print();
      assertEquals(y.toString(), "FooBah");
      
      sbuf.clear();
      inst = Text:String.new();
      s.serialize(inst, sbuf);
      sbuf.print();
      y = s.deserialize(sbuf);
      y.print();
      assertEquals(y, Text:String.new());
      
      sbuf.clear();
      inst = Array.new(6);
      inst[1] = true;
      inst[3] = "Spoke";
      inst[4] = inst[1];
      inst[5] = inst[3];
      s.serialize(inst, sbuf);
      sbuf.print();
      y = s.deserialize(sbuf);
      assertTrue(y[1]);
      assertEquals(y[3], "Spoke");
      
      sbuf.clear();
      inst = Array.new();
      inst[1] = true;
      inst[3] = "Spoke";
      s.serialize(inst, sbuf);
      sbuf.print();
      y = s.deserialize(sbuf);
      assertTrue(y[1]);
      assertEquals(y[3], "Spoke");
      
      sbuf.clear();
      inst = LinkedList.new();
      inst += "Hi";
      inst += "Spoke";
      s.serialize(inst, sbuf);
      sbuf.print();
      y = s.deserialize(sbuf);
      iter = y.iterator;
      assertEquals(iter.next, "Hi");
      assertEquals(iter.next, "Spoke");
      
      sbuf.clear();
      inst = Map.new();
      inst["smoke"] = "fire";
      inst["honky"] = "tonk";
      s.serialize(inst, sbuf);
      sbuf.print();
      y = s.deserialize(sbuf);
      assertEquals(inst["smoke"], "fire");
      assertEquals(inst["honky"], "tonk");
      
   }
   
   testEmptyString() {
   
      Serializer s = Serializer.new();
      var sbuf = String.new();
      
      sbuf.clear();
      String str = "";
      s.serialize(str, sbuf);
      sbuf.print();
      var y = s.deserialize(sbuf);
      y.print();
      assertEquals(y, "");
      
   }
   
   testSerializePieces2() {
      ("Test:BaseTest:Serialize:testSerializePieces2").print();
      Serializer s = Serializer.new();
      var sbuf = String.new();
      
      var y;
      var inst;
      var sinst;
      var iter;
      
      sbuf.clear();
      
      s.serialize(null, sbuf);
      assertIsNull(s.deserialize(sbuf));
      
      sbuf.clear();
      
      String str = "Hi there";
      s.serialize(str, sbuf);
      //sbuf.print();
      
      y = s.deserialize(sbuf);
      //y.print();
      assertEquals(y, "Hi there");
      
      sbuf.clear();
      
      Int i = 10;
      s.serialize(i, sbuf);
      //sbuf.print();
      
      y = s.deserialize(sbuf);
      //y.print();
      assertEquals(y, 10);
      
      sbuf.clear();
      
      inst = true;
      s.serialize(inst, sbuf);
      //sbuf.print();
      
      y = s.deserialize(sbuf);
      //y.print();
      assertEquals(y, true);
      
      sbuf.clear();
      
      inst = Text:String.new();
      inst += "FooBah";
      s.serialize(inst, sbuf);
      //sbuf.print();
      
      y = s.deserialize(sbuf);
      //y.print();
      assertEquals(y.toString(), "FooBah");
      
      sbuf.clear();
      
      inst = Array.new(4);
      inst[1] = true;
      inst[3] = "Spoke";
      s.serialize(inst, sbuf);
      //sbuf.print();
      
      y = s.deserialize(sbuf);
      assertTrue(y[1]);
      assertEquals(y[3], "Spoke");
      
      sbuf.clear();
      
      inst = Array.new();
      inst[1] = true;
      inst[3] = "Spoke";
      s.serialize(inst, sbuf);
      //sbuf.print();
      
      y = s.deserialize(sbuf);
      assertTrue(y[1]);
      assertEquals(y[3], "Spoke");
      
      sbuf.clear();
      
      inst = LinkedList.new();
      inst += "Hi";
      inst += "Spoke";
      s.serialize(inst, sbuf);
      //sbuf.print();
      
      y = s.deserialize(sbuf);
      iter = y.iterator;
      assertEquals(iter.next, "Hi");
      assertEquals(iter.next, "Spoke");
      
      sbuf.clear();
      
      inst = Map.new();
      inst["smoke"] = "fire";
      inst["honky"] = "tonk";
      s.serialize(inst, sbuf);
      //sbuf.print();
      
      y = s.deserialize(sbuf);
      assertEquals(inst["smoke"], "fire");
      assertEquals(inst["honky"], "tonk");
   }
   
   testPropertyIterator() {
      var t = Test:ToSerialize.new();
      var i = t.serializationIterator;
      Array v = Array.new();
      ("Starting iterate").print();
      while (i.hasNext) {
         var j = i.next;
         if (undef(j)) {
            ("Got null ").print();
         } else {
            ("Got of type " + j.className).print();
         }
         v += j;
      }
      ("End iterate").print();
      ("Starting insert iterate").print();
      var tt = Test:ToSerialize.new();
      v[0] = 25;
      v[8] = false;
      ("T" + t).print();
      i = tt.serializationIterator;
      var vi = v.iterator;
      while (vi.hasNext && i.hasNext) {
         i.next = vi.next;
      }
      ("TT" + tt).print();
      ("Done insert iterate").print();
   }
   
   testSerialize() {
      ("Test:BaseTest:Serialize:testSerialize").print();
      Serializer s = Serializer.new();
      var sbuf = String.new();
      ("Serialize").print();
      sbuf.clear();
      var x = Test:ToSerialize.new();
      s.serialize(x, sbuf);
      ("Deserialize").print();
      var y = s.deserialize(sbuf);
      ("Deserialize Done").print();
      assertEquals(y.i, 10);
      assertEquals(y.s, "Hi");
      assertIsNull(y.n);
      assertTrue(y.t);
      assertFalse(y.f);
      assertEquals(y.a[1], "a2");
      assertEquals(y.j.get("Goo"), "Goo");
      assertEquals(y.j.get("Ga"), "Ga");
      assertEquals(y.m["Hi there"], " Bob");
      assertEquals(y.m["two"], 2);
      assertEquals(y.v[0], "In a vector");
      assertEquals(y.l.first, "In a linked list");
      
   }
   
   testSerialize2() {
      ("Test:BaseTest:Serialize:testSerialize2").print();
      Serializer s = Serializer.new();
      var sbuf = String.new();
      
      sbuf.clear();
      var x = Test:ToSerialize.new();
      s.serialize(x, sbuf);
      var y = s.deserialize(sbuf);
      
      assertEquals(y.i, 10);
      assertEquals(y.s, "Hi");
      assertIsNull(y.n);
      assertTrue(y.t);
      assertFalse(y.f);
      assertEquals(y.a[1], "a2");
      assertEquals(y.j.get("Goo"), "Goo");
      assertEquals(y.j.get("Ga"), "Ga");
      assertEquals(y.m["Hi there"], " Bob");
      assertEquals(y.m["two"], 2);
      assertEquals(y.v[0], "In a vector");
      assertEquals(y.l.first, "In a linked list");
      
   }
   
}

