// Copyright 2006 Craig Welch
//
// Licensed under the MIT license. See LICENSE.txt file in the project root 
// for full license information.

use Container:List;
use Math:Int;
use Container:Map;
use Text:String;
use Text:Strings;
use Text:ByteIterator;
use Text:MultiByteIterator;

use System:Parameters;
use Text:String;

use Test:BaseTest;
use Test:Failure;

emit(c){
"""
#include <stdarg.h>
#include <stdint.h>
#define isutf(c) (((c)&0xC0)!=0x80)
"""
}

class Test:BaseTest:Text(BaseTest) {
   
   main() {
      ("Test:BaseTest:Text:main").print();
      
      //sqstr();
      //return(self);
      
      sqstr();
      
      testGetSetPositive();
      
      testReverse();
      
      testHex();
      
      testSubstring();
      
      testAddValue();
      
      testCpVal();
      
      testNewFind();
      
      testUcode();
      
      testMbIter();
    
      //return(self);
      
      "Hi".copy().print();
      "10".print();
      self.className.print();
      
      "boo".print();
      //return(self);
      
      testIter();
      testIterBuf();
      //return(self);
      
      testString();
      testBuf();
      testFind();
      testStr();
      testBeginEnd();
      testSplit();
      
      testCompare();
      
      //testGlob();
      
      testRfind();
   }
   
   testRfind() {
     "test rfind".print();
     String sample = "hi:there:boo";
     sample.find(":").print();
     Int rf = sample.rfind(":");
     rf.print();
     assertEqual(rf, 8);
     ("rfind there " + sample.rfind("there")).print();
     assertEqual(sample.rfind("there"), 3);
     assertNull(sample.rfind("nyo"));
   }
   
   sqstr() {
   '''
   Hola dude\t\n
   '''.print();
   
   }
   
   testGetSetPositive() {
       String a = "a";
       Int val = Int.new();
       assertEqual(a.getCode(0, val), 97);
       val.print();
       val += 2;
       a.setCode(0, val);
       assertEqual(a, "c"); 
       a.print();
       
       a.setCode(0, 137);
       assertEqual(a.getInt(0, val), -119);
       val.print();
       assertEqual(a.getCode(0, val), 137);
       a.getCode(0, val).print();
   }
   
   testReverse() {
        "".reverseBytes().print();
        "a".reverseBytes().print();
        assertEqual("a".reverseBytes(), "a");
        "ab".reverseBytes().print();
        assertEqual("ab".reverseBytes(), "ba");
        "abc".reverseBytes().print();
        assertEqual("abc".reverseBytes(), "cba");
   }
   
   testHex() {
      ("1 asc " + "1".getCode(0)).print();
      ("A asc " + "A".getCode(0)).print();
      ("1 hex " + "1".getHex(0)).print();
      ("A hex " + "A".getHex(0)).print();
   
   }
   
   testUcode() {
      String x;
      String b;
      
      x = "a";
      x.print();
      b = MultiByteIterator.new(x).next;
      
      b.size.print();
      b.print();
      b.getHex(0).print();
      b.getCode(0).print();
      
      assertEqual(b.size, 1);
      assertEqual(b.getHex(0), "61");
      
      x = "Â";
      x.print();
      b = MultiByteIterator.new(x).next;
      
      b.size.print();
      b.print();
      b.getHex(0).print();
      b.getCode(0).print();
      
      assertEqual(b.size, 2);
      assertEqual(b.getHex(0), "C3");
      
      x = "あ";
      x.print();
      b = MultiByteIterator.new(x).next;
      
      b.size.print();
      b.print();
      b.getHex(0).print();
      b.getCode(0).print();
      
      assertEqual(b.size, 3);
      assertEqual(b.getHex(0), "E3");
      
      x = "𡇙";
      x.print();
      b = MultiByteIterator.new(x).next;
      
      b.size.print();
      b.print();
      b.getHex(0).print();
      b.getCode(0).print();
      
      assertEqual(b.size, 4);
      assertEqual(b.getHex(0), "F0");
      
   }
   
   testSubstring() {
      "abc".print();
      "abc".substring(0).print();
      assertEqual("abc".substring(0), "abc");
      "abc".substring(1).print();
      assertEqual("abc".substring(1), "bc");
      "abcdef".substring(2, 5).print();
      assertEqual("abcdef".substring(2, 5), "cde");
   }
   
   testAddValue() {
       String a = "abc";
       a.addValue("def");
       a.print();
       a.size.print();
       a.capacity.print();
       assertEqual(a, "abcdef");
       assertEqual(a.size, 6);
   }
   
   testCpVal() {
     testCpValInner();
     testCpValInner();
     testCpValInner();
   }
   
   testCpValInner() {
        String t = "abc";
        assertEqual(t, "abc");
        assertEqual(t.size, 3);
        assertEqual(t.capacity, 3);
        t.print();
        
        t.copyValue("d", 0, 1, 0).print();
        assertEqual(t, "dbc");
        assertEqual(t.size, 3);
        assertEqual(t.capacity, 3);
        
        t.copyValue("e", 0, 1, 1).print();
        assertEqual(t, "dec");
        assertEqual(t.size, 3);
        assertEqual(t.capacity, 3);
        
        t.copyValue("f", 0, 1, 2).print();
        assertEqual(t, "def");
        assertEqual(t.size, 3);
        assertEqual(t.capacity, 3);
        
        t.copyValue("g", 0, 1, 3).print();
        assertEqual(t, "defg");
        assertEqual(t.size, 4);
        assertEqual(t.capacity, 4);
        
        t.copyValue("abcd", 0, 4, 0).print();
        assertEqual(t, "abcd");
        assertEqual(t.size, 4);
        assertEqual(t.capacity, 4);
        
        t.copyValue("ef", 0, 2, 0).print();
        assertEqual(t, "efcd");
        assertEqual(t.size, 4);
        assertEqual(t.capacity, 4);
        
        t.copyValue("gh", 0, 2, 2).print();
        assertEqual(t, "efgh");
        assertEqual(t.size, 4);
        assertEqual(t.capacity, 4);
        
        t.copyValue("ijmn", 0, 2, 0).print();
        assertEqual(t, "ijgh");
        assertEqual(t.size, 4);
        assertEqual(t.capacity, 4);
        
        t.copyValue("mnkl", 2, 4, 2).print();
        assertEqual(t, "ijkl");
        assertEqual(t.size, 4);
        assertEqual(t.capacity, 4);
   }
   
   testNewFind() {
      assertEqual("abc".find("a"), 0);
      assertEqual("abc".find("b"), 1);
      assertEqual("abc".find("c"), 2);
      assertNull("abc".find("d"));
      
      assertEqual("abc".find("ab"), 0);
      assertEqual("abc".find("bc"), 1);
      assertNull("abc".find("cd"));
      assertNull("acc".find("ab"));
      assertNull("abb".find("bc"));
      
      assertEqual("abcdxdydedo".find("de"), 7);
      
      assertEqual("abcdef".find("abc"), 0);
      assertEqual("abcdef".find("bcd"), 1);
      assertEqual("abcdef".find("cde"), 2);
      assertEqual("abcdef".find("def"), 3);
      assertNull("abcdef".find("dem"));
      assertNull("abcdef".find("acc"));
      assertNull("abcdef".find("abb"));
      assertNull("abcdef".find("efg"));
      
   
   }
   
   testMbIter() {
   
       ByteIterator mb;
       String b = String.new();
       Int i;
       
       i = 0;
       mb = MultiByteIterator.new("hi");
       while (mb.hasNext) {
          mb.next(b);
          b.print();
          if (i == 0) {
            assertEqual(b.toString(), "h");
          } elseIf (i == 1) {
            assertEqual(b.toString(), "i");
          } else {
            throw(System:Exception.new("too many chars"));
          }
          i = i++;
       }
       
       i = 0;
       mb = MultiByteIterator.new("aÂbÆcあd𡇙e");
       while (mb.hasNext) {
          mb.next(b);
          "step".print();
          b.size.print();
          b.print();
          if (i == 0) {
            assertEqual(b.toString(), "a");
          } elseIf (i == 1) {
            assertEqual(b.toString(), "Â");
          } elseIf (i == 2) {
            assertEqual(b.toString(), "b");
          } elseIf (i == 3) {
            assertEqual(b.toString(), "Æ");
          } elseIf (i == 4) {
            assertEqual(b.toString(), "c");
          } elseIf (i == 5) {
            assertEqual(b.toString(), "あ");
          } elseIf (i == 6) {
            assertEqual(b.toString(), "d");
          } elseIf (i == 7) {
            assertEqual(b.toString(), "𡇙");
          } elseIf (i == 8) {
            assertEqual(b.toString(), "e");
          } else {
            throw(System:Exception.new("too many chars"));
          }
          i = i++;
       }
   
   }
   
   testGlob() {
   
      IO:File:Path path;
      IO:File:Path path2;
      Logic:Bool matched;
      
      IO:File:Path rpath = IO:File:Path.apNew("i/rehehe");
      matched = rpath.matchesGlob("i*e");
      assertTrue(matched);
      
      path = IO:File:Path.apNew("hi/there");
      
      matched = path.matchesGlob("*there");
      assertTrue(matched);
      
      matched = path.matchesGlob("hi*");
      assertTrue(matched);
      
      matched = path.matchesGlob("yo");
      assertFalse(matched);
      
      matched = path.matchesGlob("*");
      assertTrue(matched);
      
      matched = path.matchesGlob("there*");
      assertFalse(matched);
      
      matched = path.matchesGlob("*he");
      assertFalse(matched);
      
      path2 = IO:File:Path.new("hi/there"); //not apnew
      matched = path2.matchesGlob("hi/there");
      assertTrue(matched);
      
      matched = path.matchesGlob("?i?ther?");
      assertTrue(matched);
      
      matched = path.matchesGlob("hi??there");
      assertFalse(matched);
      
      matched = path2.matchesGlob("hi/there?");
      assertFalse(matched);
      
      matched = path2.matchesGlob("?hi/there");
      assertFalse(matched);
      
      matched = path.matchesGlob("hi?*here");
      assertTrue(matched);
      
      matched = path.matchesGlob("");
      assertFalse(matched);
      
      matched = path.matchesGlob("hi?ther");
      assertFalse(matched);
      
      matched = path.matchesGlob("*hi?there");
      assertTrue(matched);
      
      //catburg
      path2 = IO:File:Path.new("catburg");
      matched = path2.matchesGlob("cat*burg");
      assertTrue(matched);
      
      path2 = IO:File:Path.new("catburgburg");
      matched = path2.matchesGlob("cat*burg");
      assertTrue(matched);
      
      path2 = IO:File:Path.new("catYOYOburg");
      matched = path2.matchesGlob("cat*burg");
      assertTrue(matched);
      
      path2 = IO:File:Path.new("catVburg");
      matched = path2.matchesGlob("cat*burg");
      assertTrue(matched);
      
      path2 = IO:File:Path.new("catburgburgg");
      matched = path2.matchesGlob("cat*burg");
      assertFalse(matched);
      
      path2 = IO:File:Path.new("bob.txt");
      matched = path2.matchesGlob("*.txt");
      assertTrue(matched);
      
      path2 = IO:File:Path.new("txt");
      matched = path2.matchesGlob("*?txt");
      assertFalse(matched);
      
   }
   
   testCompare() {
      assertEquals("Hi".compare("Hi"), 0);
      assertEquals("Hix".compare("Hi"), 1);
      assertEquals("Hi".compare("Hix"), 0 - 1);
      assertEquals("a".compare("b"), 0 - 1);
      assertEquals("b".compare("a"), 1);
      
      assertTrue("a" < "b");
      assertFalse("a" < "a");
      assertFalse("b" < "a");
      
      assertTrue("a" == "a");
      
      assertTrue("b" > "a");
      assertFalse("b" > "b");
      assertFalse("a" > "b");
      
      assertTrue("bb" > "b");
      
   }
   
   testBeginEnd() {
      assertTrue("Hi".begins("Hi"));
      assertTrue("Hi There".begins("Hi"));
      assertFalse(Strings.new().empty.begins("xxx"));
      assertTrue("Hi bob".ends("bob"));
      assertFalse("Hi bo".ends("i"));
      assertFalse(Strings.new().empty.ends("goo"));
   }
   
   testSplit() {
      String x = "toXsplitX";
      printList(x.split("YY"));
      printList(x.split("X"));
      
      Strings.new().join("AA", "toHHSplitHHg".split("HH")).print();
      assertEquals("Hi/There/Bob".swap("/","\\"), "Hi\\There\\Bob");
   }
   
   printList(l) {
      for (any x in l) {
         x.print();
      }
   }
   
   testFind() {
      String h = "hi there bob there";
      Int p = h.find("there");
      assertTrue(h.has("there"));
      assertFalse(h.has(null));
      assertFalse(h.has("lala"));
      p.print();
      p = h.find("there", p);
      p.print();
      p = h.find("there", p + 1);
      p.print();
      p = h.find("venernc");
      if (undef(p)) {
         "Good, not found".print();
      } else {
         "Bad, found".print();
      }
      p = h.find("hi");
      p.print();
   }
   
   testBuf() {
      String x = String.new();
      x += "Hi" += "New" += " foo";
      x += Text:Strings.new().empty;
      x += "01234567890123456789";
      x += "9999";
      x.print();
      
      any a = String.new();
      any b = String.new();
      any c = String.new();
      any d = Map.new();
      
      a += "A";
      b += "A";
      c += "C";
      assertEqual(a, b);
      if (a == b) { "Equals SB ok".print(); } else { "Equals SB NOT ok".print(); }
      assertNotEqual(a, c);
      if (a == c) { "Equals SB NOT ok".print(); } else { "Equals SB ok".print(); }
      
      d.put(a, "Hi there");
      d.get(b).print();
      if (undef(d.get(c))) { "Got null Good".print(); } else { "Got notnull bad".print(); }
      
      String ex = String.new();
      ex += "Foo ";
      ex += "Org";
      ex.extractString().print();
      ex += "snow";
      ex.print();
      return(true);
   }
   
   testIter() {
      any x = "Hi there";
      "Test get".print();
      x.getPoint(0).print();
      assertEquals(x.getPoint(0), "H");
      x.getPoint(4).print();
      assertEquals(x.getPoint(4), "h");
      x.getPoint(7).print();
      assertEquals(x.getPoint(7), "e");
      //x.getPoint(8).print();
      "Test get done".print();
      any i = x.iterator;
      i.next.print();
      Text:String accum = Text:String.new();
      for (any y in x) { y.print(); accum += y;}
      ("accum " + accum.toString()).print();
      assertEqual(accum.toString(), x);
      accum.clear();
      Text:String sbuf = Text:String.new();
      for (i = x.biter;i.hasNext;;) {
         ("loop").print();
         i.next(sbuf);
         sbuf.print();
         accum += sbuf;
      }
      assertEqual(accum.toString(), x);
   }
   
   testIterBuf() {
      any x = Text:String.new().addValue("Hi there buffer");
      x.print();
      any i = x.biter;
      i.next.print();
      Text:String accum = Text:String.new();
      for (any y in x.biter) { y.print(); accum += y;}
      assertEqual(accum, x);
      accum.clear();
      Text:String sbuf = Text:String.new();
      for (i = x.biter;i.hasNext;;) {
         i.next(sbuf);
         sbuf.print();
         accum += sbuf;
      }
      assertEqual(accum, x);
   }
   
    testString() {
    
      any srep = "hi/there/bob";
      srep.swap("/", "\\").print();
      String x = String.codeNew(93);
      x.print();
      any s1 = "Hi";
      if (s1 == "Hi") {
      " PASSED equals".print();
      } else {
      return(false);
      }
      any s2 = s1.copy();
      if (s2 == "Hi") {
      " PASSED init with exiting".print();
      } else {
      return(false);
      }
      //return(true);
      //(s1 + s1).print();
      if (s1 + s1 == "HiHi") {
      " PASSED add".print();
      } else {
      " Failed add".print();
      (s1 + s1).print();
      return(false);
      }
      
      any s3 = "Test";
      any s4 = s3.copy();
      if (s3 != s4) {
         "!FAILED copy1".print();
         return(false);
      }
      " PASSED copy".print();
      
   }
   
   testStr() {
      any uux = " Hi ";
      any uuy = "There. ";
      
      if (uux + uuy == " Hi There. ") {
      (" PASSED add, equals" + uux + uuy).print();
      } else {
      "!FAILED add, equals".print();
      return(false);
      }
      
      if ("My X" != "My Y") {
      (" PASSED string not equals ").print();
      } else {
      "!FAILED string not equals ".print();
      return(false);
      }
      
      "IsInteger tests".print();
      "hh".isInteger().print();
      assertFalse("hh".isInteger());
      
      "778".isInteger().print();
      assertTrue("778".isInteger());
      
      "0".isInteger().print();
      assertTrue("0".isInteger());
      
      "9".isInteger().print();
      assertTrue("9".isInteger());
      
      "778s".isInteger().print();
      assertFalse("778s".isInteger());
      
      any tolc = "UPPER";
      tolc.lower().print();
      assertEqual(tolc.lower(), "upper");
      assertEqual(tolc.upper(), "UPPER");
      
      String str = "ABC";
      Int gi = Int.new();
      str.getInt(0, gi);
      ("gi for A " + gi).print();
      assertEqual(gi, 65);
      
      str.getInt(1, gi);
      ("gi for B " + gi).print();
      assertEqual(gi, 66);
      
      str.getInt(2, gi);
      ("gi for C " + gi).print();
      assertEqual(gi, 67);
      
      assertNull(str.getInt(3, gi));
      
      String doSet = "lmnop";
      
      doSet.setInt(0, 65);
      doSet.setInt(2, 66);
      doSet.setInt(4, 67);
      
      assertEqual("AmBoC", doSet);
      
      doSet.print();
      
      return(true);
   }
   
}

