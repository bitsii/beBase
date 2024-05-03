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
use System:Object;

use Test:BaseTest;
use Test:Assertions;
use Test:Failure;

local use Test:LocalUse;

class BaseTest(Assertions) {
   

}

class Test:BaseTest:CallTests {

    noArg() {
        return("noArg");
    }
    
    oneArg(Int a) {
        return("oneArg " + a.toString());
    }
    
    twoArg(Int a, Int b) {
        return("twoArg " + a.toString() + " " + b.toString());
    }
    
    threeArg(Int a, Int b, Int c) {
        return("threeArg " + a.toString() + " " + b.toString() + " " + c.toString());
    }
    
}

use class Test:BaseTest:Init {
    default() self {
      
   }
}

/*use notNull class Test:BaseTest:IsNotNullNoDef {

}

use notNull class Test:BaseTest:IsNotNullHasDef {
    default() self {
        fields {
            String hooka = "hooka";
        }
    }
}*/

use class Test:Pic {
    new() self {
        fields {
            Math:Int one = 1;
            Text:String a = "a";
        }
    }
}

class Test:BaseTest:EC(BaseTest) {

    main() {
        "start main".print();
        //try {
            "start runTests".print();
            runTests();
            "end runTests".print();
        //} catch (any e) {
        //    "got an except".print();
            //e.print();
        //}
        "end main".print();
    }    
    
    testStamps() {
    
      //Time:Stamp s = Time:Stamp.now();
      Time:Stamp s = Time:Stamp.new(1576964368, 589);
      s.print();
      s.year.print();
      assertEqual(s.year, "2019");
      s.month.print();
      assertEqual(s.month, "12");
      s.day.print();
      assertEqual(s.day, "21");
      s.hour.print();
      assertEqual(s.hour, "21");
      s.minute.print();
      assertEqual(s.minute, "39");
      s.second.print();
      assertEqual(s.second, "28");
      s.millisecond.print();
      assertEqual(s.millisecond, "589");
      
      s.localZone = true;
      s.year.print();
      s.month.print();
      s.day.print();
      s.hour.print();
      s.minute.print();
      s.second.print();
      s.millisecond.print();
    
      //if (true) { throw(SE.new("throwing")); }
    
    }


    runTests() {
        
        printHi();
        
        ifEmit(jv) {
          testStamps();
        }
        
        intCompares();
        
        intAsserts();
        intMutes();
        intBits();
        intMinMax();
        
        if (Test:BaseTest:RunCount.runCount < 2) {
          str();
        }
        printInt();
        
        arr();
        
        clname();
        dynCalls();
        
        objEq();
        
        typeChecks();
        
        doTypes();
        
        testTag();
        
        testCreate();
        
        testMap();
        
        testI();
        
        testGi();
        
        testA();
        
        
        testCan();
        testInvoke();
        
        testNotNullable();
        
        testPi();
        
        //testFc();//is failing
        
        testHi();
        
        //nativeExcepts();
        //doExcepts();
        
        testTags();
      
    }
    
    testTags() {
    
      Object o1 = Object.new();
      Object o2 = Object.new();
      ("o1t " + System:Objects.tag(o1) + " o2t " + System:Objects.tag(o2)).print();
      assertNotEqual(System:Objects.tag(o1), System:Objects.tag(o2)); //could fail
      assertNotEqual(o1.hash, o2.hash); //could fail
      assertEqual(System:Objects.tag(o1), System:Objects.tag(o1));
      assertEqual(o2.hash, o2.hash);
    
    }
    
    testHi() {
      Hi.new().main();
    }
    
    forwardCall(String name, List args) any {
      name.print();
      args.length.print();
      for (any i in args) {
         ("fcall.arg " + i).print();
      }
      fields {
        String lastName = name;
        List lastArgs = args;
      }
   }
   
   quickOut(a) {
     ("Quick Out " + a).print();
   }
    
    testFc() {
       any vs = self;
       vs.quickOut("1");
       vs.quickOut("2");
       //if (true) { return(self); }
       vs.callIt("boo");
       assertEqual(lastName, "callIt");
       assertEqual(lastArgs.length, 1);
       assertEqual(lastArgs[0], "boo");
       ("testFc done").print();
    }
    
    testPi() {
        Pic p1 = Pic.new();
        assertEqual(p1.one, 1);
        assertEqual(p1.a, "a");
        
        Int i = 0;
        for (any v in p1) {
            if (i == 0) {
                assertEqual(v, 1);
            } elseIf (i == 1) {
                assertEqual(v, "a");
            }
            i++;
        }
        
        //if (true) { return(self); }
        
        i = 0;
        for (any it = p1.iterator;it.hasNext) {
            if (i == 0) {
                it.next = 2;
            } elseIf (i == 1) {
                it.next = "b";
            }
            i++;
        }
        assertEqual(p1.one, 2);
        assertEqual(p1.a, "b");
        
        ("Done testing pi").print();
        
    }
    
    testI() {
        Init i = Init.new();
        Init j = Init.new();
        assertEqual(i, j);
    }
    
    testNotNullable() {
        
        //normally commented because it will not compile
        
        Logic:Bool lb;
        //if (def(lb)) { }
        //if (undef(lb)) { }
        
        /*any inn = IsNotNullNoDef.new();
        any inh = IsNotNullHasDef.new();
        
        any inn2 = IsNotNullNoDef.new();
        any inh2 = IsNotNullHasDef.new();
        
        assertNotNull(inn);
        assertNotNull(inh);
        assertNotEqual(inn, inn2);
        assertEqual(inh, inh2);
        
        assertEqual(inh2.hooka, "hooka");
        
        ("NotNullable done").print();*/
        
    }
    
    nativeExcepts() {
    
        Int i = null;
        
        (i + 1).print();
    
    }
    
    testMap() {
    
        Map m = Map.new();
        m.put("hi","there");
        assertEqual(m.get("hi"), "there");
        
        m.remove("hi");
        
        m = Map.new();
        m.put(2, "two");
        m.put(3, "three");
        assertTrue(m.has(2));
        assertEqual(m.get(3), "three");
        
        
        
    }
    
    testA() {
        
        List a = List.new(1);
        a.put(0, "a");
        a.get(0).print();
        assertEqual(a[0], "a");
        
        a.addValue("b");
        a.addValue("c");
        
        assertEqual(a[0], "a");
        assertEqual(a[1], "b");
        assertEqual(a[2], "c");
        
        a.remove(1);
        //assertNull(a[0]);
        assertEqual(a[0], "a");
        
        
    }
    
    testGi() {
        any i = System:Objects.createInstance("Math:Int").new();
        assertTrue(System:Classes.sameClass(i, Math:Int.new()));
    }
    
    testCan() {
        assertTrue(can("testCan", 0));
        assertFalse(can("testCant", 32));
    
    }
    
    testInvokeExA() { return("Yo"); }
    
    testInvokeExB(aval) {
        return(aval + "!");
    }
    
    testInvokeEx7(v1, v2, v3, v4, v5, v6, v7) {
        return(v1 + v2 + v3 + v4 + v5 + v6 + v7);
    }
    
    testInvokeEx8(v1, v2, v3, v4, v5, v6, v7, v8) {
        return(v1 + v2 + v3 + v4 + v5 + v6 + v7 + v8);
    }
    
    testInvoke() {
        
        List a0 = List.new(0);
        invoke("testInvokeExA", a0).print();
        assertEqual(invoke("testInvokeExA", a0), "Yo");
        
        List a1 = List.new(0, 1);
        a1.addValue("Hai");
        invoke("testInvokeExB", a1).print();
        assertEqual(invoke("testInvokeExB", a1), "Hai!");
        
        //7, 8
        
        List am = List.new(0, 7);
        am += "a";
        am += "b";
        am += "c";
        am += "d";
        am += "e";
        am += "f";
        am += "g";
        invoke("testInvokeEx7", am).print();
        assertEqual(invoke("testInvokeEx7", am), "abcdefg");
        
        am = List.new(0, 8);
        am += "a";
        am += "b";
        am += "c";
        am += "d";
        am += "e";
        am += "f";
        am += "g";
        am += "h";
        invoke("testInvokeEx8", am).print();
        assertEqual(invoke("testInvokeEx8", am), "abcdefgh");
        
    }
    
    checkVart() {
      var x = 1;
      //x.foo();
      var y = String.new().copy();
      //y.booboo();
      
      fields {
        var m = Int.new();
        var o = self;
      }
      //m.yukka();
      o.yolo(); //works with forwardcall
    }
    
    testTag() {
    
        Object o = Object.new();
        assertEqual(o.hash, o.hash);
        assertEqual(System:Objects.tag(o), System:Objects.tag(o));
        
        //not guaranteed always, just usually
        assertNotEqual(o.hash, Object.new().hash);
    
    }
    
    testCreate() {
        assertNotNull(create());
        assertTrue(System:Classes.sameClass(self, create()));
    }
    
    typeChecks() {
        
        Math:Int i = Math:Int.new();
        System:Object o = System:Object.new();
        System:Object o2 = System:Object.new();
        
        assertFalse(System:Classes.sameClass(o, i));
        assertFalse(System:Classes.sameClass(i, o));
        assertTrue(System:Classes.sameClass(o, o));
        assertTrue(System:Classes.sameClass(o, o2));
        
        assertTrue(System:Classes.otherClass(o, i));
        assertTrue(System:Classes.otherClass(i, o));
        assertFalse(System:Classes.otherClass(o, o));
        assertFalse(System:Classes.otherClass(o, o2));
        
    }
    
    objEq() {
        Math:Int a = 1;
        Math:Int b = 2;
        assertFalse(System:Objects.sameObject(a, b));
        assertTrue(System:Objects.sameObject(a, a));
        
        System:Object c = System:Object.new();
        System:Object d = System:Object.new();
        assertEqual(c, c);
        assertNotEqual(c, d);
    }
    
    dynCalls() {
        Test:BaseTest:CallTests ctt = Test:BaseTest:CallTests.new();
        ctt.noArg().print();
        assertEqual(ctt.noArg(), "noArg");
        ctt.oneArg(1).print();
        assertEqual(ctt.oneArg(1), "oneArg 1");
        ctt.twoArg(1, 2).print();
        assertEqual(ctt.twoArg(1, 2), "twoArg 1 2");
        ctt.threeArg(1, 2, 3).print();
        assertEqual(ctt.threeArg(1, 2, 3), "threeArg 1 2 3");
    
        any ct = Test:BaseTest:CallTests.new();
        ct.noArg().print();
        assertEqual(ctt.noArg(), "noArg");
        ct.oneArg(1).print();
        assertEqual(ctt.oneArg(1), "oneArg 1");
        ct.twoArg(1, 2).print();
        assertEqual(ctt.twoArg(1, 2), "twoArg 1 2");
        ct.threeArg(1, 2, 3).print();
        assertEqual(ctt.threeArg(1, 2, 3), "threeArg 1 2 3");
    }
    
    clname() {
    
    ("!!!!!!!!!!!!!!!testing clname").print();
    
        any o = Math:Int.new();
        String cli = System:Classes.className(o);
        cli.print();
        assertEqual(cli, "Math:Int");
    
    }
    
    arr() {
        List a = List.new(3);
        a.put(0,"hi");
        a.get(0).print();
        assertEqual(a.get(0), "hi");
        
        a.put(10, "boo");
        a.get(10).print();
        assertEqual(a.get(10), "boo");
        
        a.get(0).print();
        assertEqual(a.get(0), "hi");
    }
    
    printInt() {
        1.print();
        1234.print();
        -22.print();
    }
    
    str() {
        String b = "HI";
        b.capacity = 1;
        b.print();
        
        String s = "abc";
        //org, start, end, deststart
        s.copyValue("def", 0, 3, 3);
        s.print();
        
        assertEqual("abc", "abc");
        assertTrue("abc"!="def");
        
        String doSet = "lmnop";
        
        doSet.setInt(0, 65);
        doSet.setInt(2, 66);
        doSet.setInt(4, 67);
        
        doSet.print();
      
        assertEqual("AmBoC", doSet);
        
        assertEqual(doSet.getInt(0, Int.new()), 65);
        
        "setting".print();
        doSet.setInt(1, -64);
        "asserting".print();
        assertEqual(doSet.getInt(1, Int.new()), -64);
        "printing".print();
        doSet.print();
        ("first " + doSet.getCode(1)).print();
        assertEqual(doSet.getCode(1), 192);
        ("2nd " + doSet.getCode(4)).print();
        ("2nd " + doSet.getCode(4)).print();
        assertEqual(doSet.getCode(4), 67);
        
        doSet.setCode(2, 67);
        doSet.setCode(3, 192);
        "nxt".print();
        assertEqual(doSet.getCode(2), 67);
        "nxt".print();
        assertEqual(doSet.getInt(2, Int.new()), 67);
        assertEqual(doSet.getCode(3), 192);
        assertEqual(doSet.getInt(3, Int.new()), -64);
        
        ("lmnop" += "qrs").print();
        assertEqual("lmnop" += "qrs", "lmnopqrs");
        
        String res;
        
        
        
        
    }
    
    intMinMax() {
        Math:Ints.new();
    }

    printHi() {
        "Hi".print();
    }
    
    doTypes() {
        ("Begin assertTypes").print();
        assertTrue(System:Types.sameType(self, System:Object.new()));
        assertFalse(System:Types.sameType(System:Object.new(), self));
        assertFalse(System:Types.otherType(self, System:Object.new()));
        assertTrue(System:Types.otherType(System:Object.new(), self));
        ("End assertTypes").print();
    }
    
    doExcepts() {
        try {
            if (true) {
                throw(System:Exception.new("was thrown"));
            }
        } catch (any e) {
            ("Caught " + e.toString()).print();
        }
    }
    
    intAsserts() {
        assertTrue(3 > 1);
        assertFalse(1 > 3);
        assertFalse(3 < 1);
        assertTrue(1 < 3);
        
        assertTrue(3 >= 1);
        assertFalse(1 >= 3);
        assertFalse(3 <= 1);
        assertTrue(1 <= 3);
        
        assertTrue(3 >= 3);
        assertTrue(1 <= 1);
        
        assertFalse(1 == 3);
        assertTrue(3 == 3);
        assertTrue(1 != 3);
        assertFalse(3 != 3);
    }
    
    intCompares() {
        if (3 > 1) {
            "3 > 1".print();
        } else {
            "3 !> 1".print();
        }
        
        if (1 > 3) {
            "1 > 3".print();
        } else {
            "1 !> 3".print();
        }
        
        if (1 == 3) {
            "1 == 3".print();
        } else {
            "1 != 3".print();
        }
        
        if (3 == 3) {
            "3 == 3".print();
        } else {
            "3 != 3".print();
        }
        
        if (1 != 3) {
            "1 != 3".print();
        } else {
            "1 == 3".print();
        }
        
        if (3 != 3) {
            "3 != 3".print();
        } else {
            "3 == 3".print();
        }
    }
    
    intMutes() {
       assertEqual(1++, 2);
       assertEqual(2--, 1);
       Int i = 99;
       i++;
       assertEqual(100, i);
       i--;
       assertEqual(99, i);
       assertEqual(2 + 5, 7);
       assertEqual(8 += 2, 10);
       assertEqual(9 -= 5, 4);
       assertEqual(7 - 2, 5); 
       
       assertEqual(3 * 4, 12);
       assertEqual(3 *= 7, 21);
       assertEqual(7 / 4, 1);
       assertEqual(7 /= 4, 1);
       assertEqual(4 % 3, 1);
       assertEqual(5 %= 3, 2);
       
       assertEqual(5.copy(), 5);
       
       assertEqual(-5.abs(), 5);
       assertEqual((0 - 10).abs(), 10);
       assertEqual(12.absValue(), 12);
       assertEqual(22.absValue(), 22);
    }
    
    intBits() {
        Int i = 10;
        assertEqual(i & 2, 2);
        assertEqual(i, 10);
        
        i = 10;
        i &= 2;
        assertEqual(i, 2);
        
        i = 4;
        assertEqual(i | 1, 5);
        assertEqual(i, 4);
        
        i = 4;
        i |= 1;
        assertEqual(i, 5);
        
        i = 18;
       Int j = i.shiftLeft(2);
       assertEqual(j, 72);
       assertEqual(i.shiftLeftValue(2), j);
       
       assertEqual(23.shiftLeft(1), 46);
       
       i = -105;
       assertEqual(i.shiftRight(1), -53);
       assertEqual(i.shiftRightValue(1), -53);
    }
    
}

class Test:BaseTest:Current(BaseTest) {
    
    main() {
        
        //Test:BaseTest:All.main();
        
        //BaseTest:Class.new().main();
        //BaseTest:Calls.new().main();
        //BaseTest:Invoke.new().main();
        
        Test:BaseTest:MutInt.new().main();
        
        //Test:BaseTest:QuickCheck.new().main();
        
        //BaseTest:MutString.new().main();
      
    }
}

use Text:ByteIterator;
use Text:MultiByteIterator;

class Test:BaseTest:MutString(BaseTest) {

    main() {
        gi();
        toaln();
        //hash();
        //getSetByteInts();
        //checkIntValues();
    }
    
    gi() {
        any x = System:Objects.createInstance("Math:Int").new();
        x.setValue(10);
        (x + 1).print();
    
    }
    
    toaln() {
      assertEqual("A B c 0 1 2 9 *".toAlphaNum(), "ABc0129");
    }
    
    hash() {
        "ABC".hash.print();
        "ABC".hash.print();
        
        assertEqual("ABC".hash, "ABC".hash);
        assertEqual("lmnop".hash, "lmnop".copy().hash);
        
    }
    
    checkIntValues() {
        String s;
        Int i;
        ByteIterator b;
        MultiByteIterator mb;
        Int j;
    
        s = "abc";
        i = Int.new();
        b = ByteIterator.new(s);
        j = 0;
        while (b.hasNext) {
            assertEqual(b.nextInt(i), b.currentInt(i));
            i.print();
            if (j == 0) {
                assertEqual(i, 97);
            }
            if (j == 1) {
                assertEqual(i, 98);
            }
            if (j == 2) {
                assertEqual(i, 99);
            }
            j++;
        }
        
        s = "aÂbÆcあd𡇙e";
        i = Int.new();
        b = ByteIterator.new(s);
        j = 0;
        while (b.hasNext) {
            assertEqual(b.nextInt(i), b.currentInt(i));
            i.print();
            if (j == 0) {
                assertEqual(i, 97);
            }
            if (j == 1) {
                assertEqual(i, -61);
            }
            if (j == 2) {
                assertEqual(i, -126);
            }
            if (j == 3) {
                assertEqual(i, 98);
            }
            if (j == 4) {
                assertEqual(i, -61);
            }
            if (j == 5) {
                assertEqual(i, -122);
            }
            if (j == 6) {
                assertEqual(i, 99);
            }
            if (j == 7) {
                assertEqual(i, -29);
            }
            if (j == 8) {
                assertEqual(i, -127);
            }
            if (j == 9) {
                assertEqual(i, -126);
            }
            if (j == 10) {
                assertEqual(i, 100);
            }
            if (j == 11) {
                assertEqual(i, -16);
            }
            if (j == 12) {
                assertEqual(i, -95);
            }
            if (j == 13) {
                assertEqual(i, -121);
            }
            if (j == 14) {
                assertEqual(i, -103);
            }
            if (j == 15) {
                assertEqual(i, 101);
            }
            j++;
        }
        
        s = "aÂbÆcあd𡇙e";
        i = Int.new();
        mb = MultiByteIterator.new(s);
        while (mb.hasNext) {
            mb.next;
        }
        
        
    }
    
    getSetByteInts() {
        String s = "abc";
        Int i = Int.new();
        ByteIterator b = ByteIterator.new(s);
        while (b.hasNext) {
            assertEqual(b.nextInt(i), b.currentInt(i));
            b.currentInt(i).print();
            if (i == 98) {
                b.currentInt = 97;
            }
        }
        assertEqual(s, "aac");
        s.print();
    }
    
}

class Test:BaseTest:MutInt(BaseTest) {

    main() {
        intSetValue();
        //intAndOr();
        //intCopy();
        //intMut();
    }
    
    intSetValue() {
        intSetValueInner();
        intSetValueInner();
    }
    
    intSetValueInner() {
        Int i = 10;
        assertEqual(i, 10);
        i.setValue(20);
        assertEqual(i, 20);
        ("intSetValue " + i).print();
    }
    
    intAndOr() {
        
        Int i = 10;
        (i & 2).print();
        i.print();
        assertEqual(i & 2, 2);
        assertEqual(i, 10);
        
        i = 10;
        (i &= 2).print();
        i.print();
        assertEqual(i, 2);
        
        i = 4;
        (i | 1).print();
        i.print();
        assertEqual(i | 1, 5);
        assertEqual(i, 4);
        
        i = 4;
        (i |= 1).print();
        i.print();
        assertEqual(i, 5);
        
    }
    
    intMut() {
        Int b = 1;
        
        b += 2;
        assertEqual(b, 3);
        b.print();
        
        b++;
        assertEqual(b, 4);
        b.print();
        
        b--;
        assertEqual(b, 3);
        b.print();
        
        b -= 2;
        assertEqual(b, 1);
        b.print();
        
        b++;
        b *= 2;
        assertEqual(b, 4);
        b.print();
        
        b /= 2;
        assertEqual(b, 2);
        b.print();
        
        b += 3;
        b %= 4;
        assertEqual(b, 1);
        b.print();
        
        
    }
    
    intCopy() {
        
        Int b = 10;
        Int c = b.copy();
        
        assertEqual(b, c);
        assertFalse(System:Objects.sameObject(b, c));
        ("Int copy test done").print();
        
        
    }
    
}

class Test:BaseTest:RunCount {

  default() self {
    fields {
      Int runCount = 0;
    }
  }

}

class Test:BaseTest:All(BaseTest) {
   
   main() {
         ("Test:BaseTest:All:main").print();
         //try {
         "abcd".substring(1).print();
         assertEqual("abcd".substring(1), "bcd");
         
         Test:BaseTest:List.new().main();
         Tests:Function.new().main();
         ifNotEmit(js) {
         Test:BaseTest:Float.new().main();
         }
         Test:BaseTest:EC.new().main();
         Test:BaseTest:MutString.new().main();
         Test:BaseTest:MutInt.new().main();
         Test:BaseTest:Null.new().main();
         Test:BaseTest:Int.new().main();
         Test:BaseTest:ParseCorners.new().main();
         Test:BaseTest:Calls.new().main();
         Tests:CallArgs.new().main();
         Tests:CallArgsFinal.new().main();
         ifNotEmit(noSmap) {
         Tests:Exceptions.new().main();
         }
         Test:BaseTest:Invoke.new().main();
         //ifNotEmit(cc) {
          Test:BaseTest:Gc.new().main(); 
         //}
         Test:CREComp.new();
         //} catch (any e) {
         //   e.print();
            
         //}
         ("Test:BaseTest:All:main completed successfully").print();
         
         ifEmit(cc) {
         //System:Process.exit(0);
         }
   }
}

use Test:BaseTest:Weak;

class Weak {

  echo(o) any {
    fields {
      any last = o;
    }
    return(o);
  }

}

class TestEmit {

  new() self {
    "hi".print();
  }
}

use Hi;

class Hi {

   main() {
      "Yo".print();
   }

}


