// Copyright 2006 Craig Welch
//
// Licensed under the MIT license. See LICENSE.txt file in the project root 
// for full license information.

use Container:List;

use System:Parameters;
use Text:String;
use Text:String;

use Test:BaseTest;
use Test:Failure;
use Math:Int;

use Template:Replace;
use Template:Runner;
use Test:MyTemplate;

class MyTemplate {

   new() self {
      fields {
         String lala = "lala";
      }
   }
   
   this() String { return("this!!"); }
   
   that() String { return("that!!"); }
   
   oneArg(String oneArg) String { return("oneArg is |" + oneArg + "|"); }
   
   twoArgs(String oneArg, String twoArg) String { return("oneArg is |" + oneArg + "| twoArg is |" + twoArg + "|"); }
   
}

class Test:BaseTest:Template(BaseTest) {
   
   main() {
      ("Test:BaseTest:Template:main").print();
      testStrings();
      testTemplate();
      testTemplateMargs();
      testRunner();
   }
   
   //IO:File:Writer:Stdout.new()
   
   testRunner() {
      String buf = String.new();
      Runner runner;
      any nd;
      any nd2;
      
      buf.clear();
      runner = Runner.new("Yo <?tt yup ?>  nop  <?tt nar ?>", buf);
      runner.run();
      buf.print();
      
      assertEquals(buf.toString(), "Yo yup  nop  nar");
      
      buf.clear();
      runner = Runner.new("Yo <?tt yup ?>  nop  <?tt nar ?>", buf);
      runner.swap["yup"] = "nope";
      runner.run();
      buf.print();
      
      assertEquals(buf.toString(), "Yo nope  nop  nar");
      
      buf.clear();
      runner = Runner.new("One <?tt Two ?> Three <?tt Four ?> Five", buf);
      runner.runToLabel("Four");
      buf.print();
      
      assertEquals(buf.toString(), "One Two Three ");
      
      buf.clear();
      runner = Runner.new("A <?tt B ?> C <?tt D ?> E <?tt F ?> G", buf);
      runner.runToLabel("D");
      nd = runner.currentNode;
      runner.runToLabel("F");
      runner.currentNode = nd;
      runner.run();
      runner.restart();
      runner.run();
      buf.print();
      
      assertEquals(buf.toString(), "A B C  E  E F GA B C D E F G");
      
      buf.clear();
      runner = Runner.new("A <?tt B ?> C <?tt D ?> E <?tt F ?> G", buf);
      runner.skipToLabel("D");
      nd = runner.currentNode;
      runner.run();
      buf.print();
      
      assertEquals(buf.toString(), " E F G");
      
      buf.clear();
      runner = Runner.new("A <?tt B ?> C <?tt D ?> E <?tt F ?> G", buf);
      runner.skipToLabel("B");
      nd = runner.currentNode;
      runner.skipToLabel("F");
      runner.currentNode = nd;
      runner.runToLabel("F");
      buf.print();
      
      assertEquals(buf.toString(), " C D E ");
      
      buf.clear();
      runner = Runner.new("A <?tt B ?> C <?tt D ?> E <?tt F ?> G", buf);
      runner.skipToLabel("D");
      nd = runner.currentNode;
      runner.restart();
      runner.skipToLabel("D");
      runner.runToLabel("F");
      buf.print();
      
      assertEquals(buf.toString(), " E ");
      
      // Multi
      
      buf.clear();
      
      Runner a = Runner.new("A 2 <?tt B ?> <?tt C ?>C 3 <?tt L ?>", buf);
      
      Runner b = Runner.new("IN <?tt L ?> B");
      
      a.swap["L"] = "LMNOP";
      a.handOff["B"] = b;
      a.swap["C"] = "";
      
      a.run();
      
      assertEquals(buf.toString(), "A 2 IN LMNOP B C 3 LMNOP");
      
      buf.print();
      
      buf.clear();
      a.restart();
      
      a.runToLabel("C");
      
      buf.print();
      
      assertEquals(buf.toString(), "A 2 IN LMNOP B ");
      
      buf.clear();
      a.restart();
      a.skipToLabel("L");
      a.run();
      
      buf.print();
      
      assertEquals(buf.toString(), " B C 3 LMNOP");
      // -Multi
      
   }
   
   testTemplate() {
      ("Test:BaseTest:Template:testTemplate").print();
      
      Replace r = Replace.new();
      MyTemplate mt = MyTemplate.new();
      r.load("Blah <?tt this ?> bb <?tt that ?>");
      
      r.accept(mt, String.new()).print();
      /*
      for (any s in r.steps) {
         ("Step " + s.handle(mt)).print();
      }
      */
   }
   
   testTemplateMargs() {
      ("Test:BaseTest:Template:testTemplate").print();
      
      Replace r = Replace.new();
      MyTemplate mt = MyTemplate.new();
      r.load("Blah <?tt this ?> bb <?tt that ?> wargs 1 <?tt oneArg thisIsAnArg ?> wargs2 <?tt twoArgs firstArg secondArg ?>");
      
      r.accept(mt, String.new()).print();
      /*
      for (any s in r.steps) {
         ("Step " + s.handle(mt)).print();
      }
      */
   }
   
   testStrings() {
      ("Test:BaseTest:Template:testStrings").print();

      String x = "Hi\n".chomp();
      x = "XX" + x + "XX";
      //x.print();
      assertEquals("XXHiXX", x);
      //the below should fail on build if all is not well
      String xs = '''
      
      Hi
      
      ''';
      xs.print();
      
      String foo = " Hi there ";
      String choo = foo.strip();
      ("X" + choo + "X").print();
   }
   
}

