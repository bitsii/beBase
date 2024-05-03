/*
 * Copyright (c) 2016-2023, the Bennt Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

use System:Parameters;

use Test:BaseTest;
use Test:Failure;
use Math:Float;
use System:Method;


use Logic:Bool;

use Test:FrontCons;

class LocalUse {
  
  rtrue() Bool {
    return(true);
  }
  
}

emit(c) {
"""
#ifdef BENM_ISNIX
#include <sys/time.h>
#endif
"""
}

   emit(c) {
      """
static const unsigned char global_s[] = {0x41,0x42,0x43, 0}; 
      """
      }

use Container:LinkedList;
use IO:File;



use Test:BaseTest:Misc(BaseTest) {
   
   main() {
      ("Test:BaseTest:Misc:main").print();
      //testNPE();
      
      //return(self);
      
      
      //testNullIf();
      //testNullLoop();
      //testSelfReturn();
      
      //only works for c due to emit stuff
      //testErProp();
      //testIfEmit();
      //testByteStrLit();
      //testEmit();
      
      //Normally on
      testOnceAssign();
      testSingleton();
      testNotter();
      testLiterals();
      testIntAssembly();
      testFloatAssembly();
      testSelfType();
      testReturnIsReturning();
      testTypeChecks();
      
      testMyUsedClass();
      testSameObject();
      testReverse();
      
      //needs cmd working
      //testCwd();
      
      //needs io stuff
      //testSubThing();
      
      ("Misc Done").print();
      
   }
   
   testErProp() {
      emit(c) {
"""
/*-attr- -dec-*/
void** bevl_posi;
"""
}

    fields {
        Int propa = 20;
    }
    
    emit(c) {
    """
    *($propa&* + bercps) = 10;
    """
    }
    
    assertEqual(propa, 10);
   
   }
   
   testIfEmit() {
      fields {
        Bool did = false;
        Bool didAfter = false;
        Bool didnt = true;
        Bool didntAfter = false;
        Bool didSolo = false;
        Bool didntSolo = true;
      }
   
      ieDoes();
      assertTrue(did);
      assertTrue(didAfter);
      
      ieDont();
      assertTrue(didnt);
      assertTrue(didntAfter);
      
      ieDoesSolo();
      assertTrue(didSolo);
      
      ieDontSolo();
      assertTrue(didntSolo);
   }
   
   ieDoes() {
       ifEmit(c) {
          did = true;
       }
       didAfter = true;
   }
   
   ieDont() {
       ifEmit(doofus) {
          didnt = false;
       }
       didntAfter = true;
   }
   
   ieDoesSolo() {
       ifEmit(c) {
          didSolo = true;
       }
   }
   
   ieDontSolo() {
       ifEmit(doofus) {
          didntSolo = false;
       }
   }
   
   testByteStrLit() {
   emit(c) {
      """
/*-attr- -dec-*/
static const unsigned char s[] = {0x41,0x42,0x43, 0}; 
      """
      }
      
      emit(c) {
        """
        printf("printing s\n");
        printf("s %s\n", (char*) &s);
        printf("global_s %s\n", (char*) &global_s);
        """
      }
   
   }
   
   testOnceAssign() {
      testOnceAssignInner("wheredef");
      testOnceAssignInner("yo");
   }
   
   testOnceAssignInner(String expected) {
      InheritFrom ih = InheritFrom.new();
      assertEqual(ih.hi, expected);
      ih.hi = "yo";
   }
   
   testSingleton() {
   
         MyUsedClass2 a = MyUsedClass2.new();
         MyUsedClass2 b = MyUsedClass2.new();
         assertFalse(a.flag);
         a.flag = true;
         assertTrue(b.flag);
   
   }
   
   testNotter() {
      
      any t = true;
      any f = false;
      assertFalse(t!);
      assertTrue(f!);
      
      Bool tt = true;
      Bool ff = false;
      assertFalse(tt!);
      assertTrue(ff!);
   
   }
   
   testLiterals() {
      //TODO THESE ARE VALID WHY ARE THEY NULLPOINTERING - once eval issue?
      //1;
      //1.0;
      //"Hi";
      
      Int x = 2;
      Float y = 2.2;
      String z = "There";
      
      assertEqual(x, Int.new("2"));
      assertEqual(y, Float.new("2.2"));
      
      String me = '''MMM
MMM'''; //needs to stay unindented
      String mu = "MMM" + Text:Strings.unixNewline + "MMM";
      String md = "MMM" + Text:Strings.dosNewline + "MMM";
      Bool ok = false;
      if (me == mu) { ok = true; }
      if (me == md) { ok = true; }
      assertTrue(ok);
      
   }
   
   testIntAssembly() {
   
      Int i = 1;
      i++;
      assertEqual(2, i);
      
      Int j = 1;
      Int k = j + 1;
      assertEqual(2, k);
      assertEqual(1, j);
      
      Int l = 2;
      Int m = l + 6;
      assertEqual(8, m);
      assertEqual(l, 2);
      
      any n = 1;
      any o = n + 3;
      assertEqual(4, o);
      assertEqual(n, 1);
      
      any p = 4;
      Int q = p - 2;
      assertEqual(q, 2);
      assertEqual(4, p);
   }
   
   testFloatAssembly() {
   
      Float i = 1.0;
      i = i + 1.0;
      assertEqual(2.0, i);
      
      Float j = 1.0;
      Float k = j + 1.0;
      assertEqual(2.0, k);
      assertEqual(1.0, j);
      
      Float l = 2.0;
      Float m = l + 6.0;
      assertEqual(8.0, m);
      assertEqual(l, 2.0);
      
      any n = 1.0;
      any o = n + 3.0;
      assertEqual(4.0, o);
      assertEqual(n, 1.0);
      
      any p = 4.0;
      Float q = p - 2.0;
      assertEqual(q, 2.0);
      assertEqual(4.0, p);
   }
   
   testReturnIsReturning() {
   
      if (true) {
         return(self);
      }
      if (true) {
      throw(System:Exception.new("Return did not return, or true was not true"));
      }
   }
   
   testTypeChecks() {
      Misc m = Misc.new();
      any x = m;
      Misc y = x;
      
      x = 10;
      Bool caught = false;
      try {
         y = x;
      } catch (any e) {
         caught = true;
      }
      assertTrue(caught);
      assertNotNull(y);
      
      caught = false;
      y = m;
      try {
         y = returnDifferentType();
      } catch (e) {
         caught = true;
      }
      assertTrue(caught);
      //assertIsNull(y); //why would this be the case?
   }
   
   returnDifferentType() {
      return("hi");
   }
   
   testNullLoop() {
      ("Start null loops").print();
      
      any x = null;
      while (x) {
         if (true) {
         throw(System:Exception.new("Entered null while loop"));
         }
      }
      
      for (any i = 0;x;i++) {
         if (true) {
         throw(System:Exception.new("Entered null for loop"));
         }
      }
      
      //for (any j in x) {
      //   throw(System:Exception.new("Entered null for loop"));
      //}
      
      ("End null loops").print();
      
   }
   
   testNullIf() {
   
      any val = null;
      if (val) {
         throw(System:Exception.new("IF FOR NULL FAILED"));
      } else {
         ("if for null was false as it should be").print();
      }
      
      unless (val) {
         ("unless for null was true as it should be").print();
      } else {
         throw(System:Exception.new("UNLESS FOR NULL FAILED"));
      }
      
      Logic:Bool bval = null;
      if (bval) {
         throw(System:Exception.new("IF FOR NULL FAILED"));
      } else {
         ("if for null was false as it should be").print();
      }
      
      unless (bval) {
         ("unless for null was true as it should be").print();
      } else {
         throw(System:Exception.new("UNLESS FOR NULL FAILED"));
      }
   }
   
   testMyUsedClass() {
   
      ("FMUC " + MyUsedClass.new().fromMyUsedClass("In")).print();
      assertEquals(MyUsedClass.new().fromMyUsedClass("In"), "Out: In");
      assertEquals(MyUsedClass2.fromMyUsedClass("In"), "Out: In");
      assertEquals(MyUsedClass3.new().fromMyUsedClass("In"), "Out: In");
      assertEquals(MyUsedClass4.fromMyUsedClass("In"), "Out: In");
      assertEquals(MyUsedClass5.fromMyUsedClass("In"), "Out: In");
      
   }
   
   testCwd() {
      String cwd = System:Env.cwd;
      ("cwd " + cwd).print();
      ("workingDirectory " + System:Env.workingDirectory).print();
   }
   
   testReverse() {
   
      String begin;
      String end;
      
      LinkedList.new().reverse();
      
      begin = "a b c d e";
      end = Text:Strings.join(" ", LinkedList.addAll(begin.split(" ")).reverse());
      ("Reverse " + end).print();
      assertEquals(end, "e d c b a");
      
      begin = "a";
      end = Text:Strings.join(" ", LinkedList.addAll(begin.split(" ")).reverse());
      ("Reverse " + end).print();
      assertEquals(end, "a");
      
      begin = "a b";
      end = Text:Strings.join(" ", LinkedList.addAll(begin.split(" ")).reverse());
      ("Reverse " + end).print();
      assertEquals(end, "b a");
      
      begin = "a b c";
      end = Text:Strings.join(" ", LinkedList.addAll(begin.split(" ")).reverse());
      ("Reverse " + end).print();
      assertEquals(end, "c b a");
   }
   
   testSubThing() {
   
      String x = "12345";
      ("SubString " + x.substring(1,3).print()).print();
      
      LinkedList ll = LinkedList.new();
      ll += "a" += "b" += "c" += "d" += "e";
      
      ("Sublist " + Text:Strings.join(" ", ll.subList(1, 3))).print();
      assertEquals(Text:Strings.join(" ", ll.subList(1, 3)), "b c");
      
      ("Sublist " + Text:Strings.join(" ", ll.subList(3,4))).print();
      assertEquals(Text:Strings.join(" ", ll.subList(3, 4)), "d");
      
      ("Sublist Onearg " + Text:Strings.join(" ", ll.subList(2))).print();
      assertEquals(Text:Strings.join(" ", ll.subList(2)), "c d e");
      
      System:BasePath bp = System:BasePath.new("a b c d e f");
      
      bp.subPath(2,4).print();
      assertEquals(bp.subPath(2,4).toString(), "c d");
      
      IO:File:Path fp = IO:File:Path.apNew("/hi/there");
      fp.toStringWithSeparator(":").print();
      
      fp.subPath(1).toStringWithSeparator(":").print();
      assertEquals(fp.subPath(1).toStringWithSeparator(":"), "hi:there");
      
      fp.subPath(2).print();
      assertEquals(fp.subPath(2).toString(), "there");
   }
   
   testNPE() {
      any x = null;
      x.blowup();
   }
   
   testEmit() {
   emit(c) {
      """
#ifdef BENM_ISNIX
      struct timeval tv;
      printf("SIZEOF timeval %u %u %u\n", sizeof(struct timeval), sizeof(tv.tv_sec), sizeof(tv.tv_usec));
#endif
#ifdef BENM_ISWIN
      printf("SIZEOF LARGEINT %u\n", sizeof(LARGE_INTEGER));
#endif
      printf("SIZEOF VOID* %u\n", sizeof(void*));
      printf("SIZEOF char %u\n", sizeof(char));
      
      printf("SIZEOF BEINT %u of size_t %u\n", sizeof(BEINT), sizeof(size_t));
      """
      }
   }
   
   testSameObject() {
      Int x = Int.new();
      Int y = Int.new();
      assertTrue(System:Objects.sameObject(x, x));
      assertFalse(System:Objects.sameObject(x, y));
   }
   
   testSelfType() {
      SelfReturn.myNew();
      SelfReturn.my3New();
      SelfReturn2.myNew();
      SelfReturn2.my2New();
      SelfReturn2.my3New();
      
      SelfReturn2.cascadeNew().re1().re2();
      //SelfReturn2.cascadeNew().nope(); //fails no nope
      
      //Should be runtime check fail
      //SelfReturn3 cn = SelfReturn2.cascadeNew();
      //SelfReturn3 cn = SelfReturn3.my4New();
      
   }
   
}


// use class

use class MyUsedClass {

   fromMyUsedClass(String input) {
      return("Out: " + input);
   }
}

use final class MyUsedClass2 {

   create() self { }
   
   
   default() self {
      
   }

   fromMyUsedClass(String input) {
      fields {
         Bool flag = false;
      }
      return("Out: " + input);
   }
}

use class MyPackage:MyUsedClass3 {

   fromMyUsedClass(String input) {
      return("Out: " + input);
   }
}

use class MyPackage:MyUsedClass4 {

   create() self { }
   
   default() self {
      
   }

   fromMyUsedClass(String input) {
      return("Out: " + input);
   }
}

use class MyPackage:MyUsedClass5(MyUsedClass) {

   create() self { }
   
   default() self {
      
   }
   
}

use class SelfReturn {

   myNew() self {
      any x = Int.new();
      //return(x);
      //return(Int.new());
   }
   
   my3New() self {
      return(SelfReturn2.new());
   }
   
   my4New() self {
      return(SelfReturn2.new());
   }
   
   cascadeNew() self {   }
   
   caller() {
      //SelfReturn.my3New().doobie();
   }
   
   re1() self {  }

}

use class SelfReturn3(SelfReturn2) {  }

use class SelfReturn2(SelfReturn) {

   myNew() self {
      return(SelfReturn2.new());
   }
   
   my2New() self {
   
   }
   
   my3New() self {
      return(self);
   }
   
   re2() self { ("Hi from re2").print(); }
}

use class Test:RunTryThings {

   main() {
      TryThings.new().tryThings();
   }
}

use class Test:TryThings {

   tryThings() self {
      any x = 1;
      x.print();
   }

}

use class Test:InheritFrom {
   
   new() self { fields {
   any hi = "wheredef";
   } }
   
}

final class Test:CloseCall {

   callMeClose() {
      ("fromCloseCall").print();
   }
}

