// Copyright 2006 Craig Welch
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

use Container:List;
use System:Parameters;
use Math:Int;
use Text:String;
use Text:String;
use System:Serializer;
use Container:Set;
use Container:Map;
use Container:List;
use Container:LinkedList as LL;

use Test:BaseTest;
use Test:Failure;
use Db:DirStore;

class Test:NotMuch {
}

class Test:Structy {

   new() self {
      fields {
         Int i;
         String s;
         any x;
         any y;
         String s2 = "StringS2";
      }
   }

}

class Test:ToSerialize {

   new() self {
      any ai = 4;
      any vi = 3;
      fields {
         any i = 10;
         any s = "Hi";
         any a = List.new(ai);
         any n = null;
         any j = Set.new();
         any m = Map.new();
         any v = List.new(vi);
         any l = LL.new();
         any t = true;
         any f = false;
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

use Test:HasProps;

class HasProps {

   new() self {
      fields {
         String alpha = "a";
         String beta = "b";
         String gamma = "c";
      }
   }

   serializationNamesGet() List {
     //to make threadsafe, init before return to once assign
      List names = List.new(3);
       names[0] = "alpha";
       names[1] = "beta";
       names[2] = "gamma";
      return(names);
   }

   serializationIteratorGet() {
      List names =@ self.serializationNames;
      return(System:NamedPropertiesIterator.new(self, names));
   }

}

use Test:SerProps;

class SerProps {

   new() self {
      fields {
         String alpha = "a";
         String beta = "b";
      }
   }

   serializationNamesGet() List {
     //to make threadsafe, init before return to once assign
      List names = List.new(5);
         names[0] = "alpha";
         names[1] = "beta";
         names[2] = "gamma";
         names[3] = "delta";
         names[4] = "epsilon";
         return(names);
   }

   serializationIteratorGet() {
      List names =@ self.serializationNames;
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
      any sbuf = String.new();

      SerProps x = SerProps.new();
      x.beta = "uanyics";
      x.beta.print();
      //throw(System:Exception.new("same instance " + x.sameObject(x)));
      ("clear").print();
      sbuf.clear();
      ("serialize").print();
      s.serialize(x, sbuf);
      ("buf print").print();
      sbuf.print();
      ("deserialize").print();
      any y = s.deserialize(sbuf);
      ("asserts").print();
      assertEquals(x.beta, "uanyics");
      ("xa " + x.alpha + " ya " + y.alpha).print();
      assertEquals(x.alpha, y.alpha);
      assertEquals(x.beta, y.beta);
      
      any xi = x.fieldIterator;
      xi.next;
      assertEqual(xi.currentName, "alpha");
      assertEqual(xi.current, "a");

   }

   main() {
      ("Test:BaseTest:Serialize:main").print();

      ifEmit(cs, jv) {
        //dirStoreTest();//can't be run concurrently due to fs changes, run from extended test
        //directly instead
      }

      ("testSerProps").print();
      testSerProps();

      ifEmit(js) {
        if (true) { return(self); }
      }
      
      ("NAME IS").print();
      Test:Structy.new().iterator.nextName.print();

      ("testNamedProperties").print();
      testNamedProperties();

      ("testSet").print();
      testSet();

      ("testMap").print();
      testMap();

      ("testList").print();
      testList();

      ("testSaveIdentity").print();
      testSaveIdentity();
      
      ("testFieldMNull").print();
      testFieldMNull();

      ("testSimpleCase").print();
      testSimpleCase();

      ("testPropertyIterator").print();
      //testPropertyIterator();

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

      any iter;

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

   testList() {
      Serializer s = Serializer.new();
      any sbuf = String.new();
      sbuf.clear();

      List x = List.new();
      x += 2;

      s.serialize(x, sbuf);
      sbuf.print();
      any y = s.deserialize(sbuf);
      y.print();
      assertTrue(x[0] == y[0]);
      assertTrue(x.className == y.className);
      assertTrue(x.size == y.size);
   }

   testSet() {
      Serializer s = Serializer.new();
      any sbuf = String.new();
      sbuf.clear();

      Set x = Set.new(13);
      x.put("Hi");

      s.serialize(x, sbuf);
      sbuf.print();
      any y = s.deserialize(sbuf);
      //y.print();
      assertTrue(y.has("Hi"));
   }

   testMap() {
      Serializer s = Serializer.new();
      any sbuf = String.new();
      sbuf.clear();

      Map x = Map.new();
      x.put("Hi","There");

      s.serialize(x, sbuf);
      sbuf.print();
      any y = s.deserialize(sbuf);
      //y.print();
      assertTrue(x["Hi"] == y["Hi"]);
   }

   testSimpleCase() {
      Serializer s = Serializer.new();
      any sbuf = String.new();
      sbuf.clear();

      Test:Structy x = Test:Structy.new();
      x.x = List.new(3);
      x.x[1] = "Hi";
      
      x.y = -1;

      s.serialize(x, sbuf);
      sbuf.print();
      any y = s.deserialize(sbuf);
      y.print();
      
      "doing to from map!".print();
      Map rm = Maps.fieldsIntoMap(x, Map.new());
      assertEquals(rm["x"], x.x);
      assertEquals(rm["y"], x.y);
      y = Test:Structy.new();
      Maps.mapIntoFields(rm, y);
      assertEquals(y.x[1], x.x[1]);
      assertEquals(y.y, -1);
      
      ("NEG ONE " + y.y).print();
   }
   
   testFieldMNull() {
      Serializer s = Serializer.new();
      any sbuf = String.new();
      sbuf.clear();

      Test:Structy x = Test:Structy.new();
      
      x.y = -1;

      s.serialize(x, sbuf);
      sbuf.print();
      any y = s.deserialize(sbuf);
      y.print();
      assertEquals(y.y, -1);
      assertEquals(y.s2, "StringS2");
   }

   testSaveIdentity() {
      ("testSaveIdentity start").print();
      Serializer s = Serializer.new();
      any sbuf = String.new();
      sbuf.clear();

      Test:Structy x = Test:Structy.new();
      x.x = "Two";
      x.y = x.x;

      s.serialize(x, sbuf);
      sbuf.print();
      any y = s.deserialize(sbuf);
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
      any sbuf = String.new();

      any y;
      any inst;
      any sinst;
      any iter;

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
      ("NOTMUCH").print();
      Test:NotMuch tn = Test:NotMuch.new();
      s.serialize(tn, sbuf);
      sbuf.print();
      y = s.deserialize(sbuf);
      ("NOTMUCH DONE").print();
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
      inst = List.new(6);
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
      inst = List.new();
      inst[1] = true;
      inst[3] = "Spoke";
      s.serialize(inst, sbuf);
      sbuf.print();
      y = s.deserialize(sbuf);
      assertTrue(y[1]);
      assertEquals(y[3], "Spoke");

      sbuf.clear();
      inst = LL.new();
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
      any sbuf = String.new();

      sbuf.clear();
      String str = "";
      s.serialize(str, sbuf);
      sbuf.print();
      any y = s.deserialize(sbuf);
      y.print();
      assertEquals(y, "");

   }

   testSerializePieces2() {
      ("Test:BaseTest:Serialize:testSerializePieces2").print();
      Serializer s = Serializer.new();
      any sbuf = String.new();

      any y;
      any inst;
      any sinst;
      any iter;

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

      inst = List.new(4);
      inst[1] = true;
      inst[3] = "Spoke";
      s.serialize(inst, sbuf);
      //sbuf.print();

      y = s.deserialize(sbuf);
      assertTrue(y[1]);
      assertEquals(y[3], "Spoke");

      sbuf.clear();

      inst = List.new();
      inst[1] = true;
      inst[3] = "Spoke";
      s.serialize(inst, sbuf);
      //sbuf.print();

      y = s.deserialize(sbuf);
      assertTrue(y[1]);
      assertEquals(y[3], "Spoke");

      sbuf.clear();

      inst = LL.new();
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
      any t = Test:ToSerialize.new();
      any i = t.serializationIterator;
      List v = List.new();
      ("Starting iterate").print();
      while (i.hasNext) {
         any j = i.next;
         if (undef(j)) {
            ("Got null ").print();
         } else {
            ("Got of type " + j.className).print();
         }
         v += j;
      }
      ("End iterate").print();
      ("Starting insert iterate").print();
      any tt = Test:ToSerialize.new();
      v[0] = 25;
      v[8] = false;
      ("T" + t).print();
      i = tt.serializationIterator;
      any vi = v.iterator;
      while (vi.hasNext && i.hasNext) {
         i.next = vi.next;
      }
      ("TT" + tt).print();
      ("Done insert iterate").print();
   }

   testSerialize() {
      ("Test:BaseTest:Serialize:testSerialize").print();
      Serializer s = Serializer.new();
      any sbuf = String.new();
      ("Serialize").print();
      sbuf.clear();
      any x = Test:ToSerialize.new();
      s.serialize(x, sbuf);
      ("Deserialize").print();
      any y = s.deserialize(sbuf);
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
      any sbuf = String.new();

      sbuf.clear();
      any x = Test:ToSerialize.new();
      s.serialize(x, sbuf);
      any y = s.deserialize(sbuf);

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
