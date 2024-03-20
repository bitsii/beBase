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
use System:Parameters;
use Text:String;
use Text:String;

use Test:BaseTest;
use Test:Failure;
use Math:Int;
use Xml:TagIterator;

class Test:BaseTest:Xml(BaseTest) {
   
   main() {
      ("Test:BaseTest:Xml:main").print();
      
      String q = Text:Strings.new().quote;
      
      TagIterator tp = TagIterator.new();
      any e;
      
      tp.xmlString = "<xml></xml>";
      for (e in tp) {
         e.print();
      }
      
      tp.xmlString = "<xml></xml>  ";
      tp.restart();
      for (e in tp) {
         e.print();
      }
      
      tp.xmlString = " <xml></xml>";
      tp.restart();
      for (e in tp) {
         e.print();
      }
      
      tp.xmlString = "  <xml><foop>knu</foop></xml><goo> new </goo>  ";
      tp.restart();
      for (e in tp) {
         e.print();
      }
      
      tp.xmlString = "  <snow/><glow> boof  lala km </glow> ";
      tp.restart();
      for (e in tp) {
         e.print();
      }
      
      tp.xmlString = '''<snow cat="dog" slick="SSmo" ><sneeze ahh = "choo"></sneeze></snow>''';
      tp.restart();
      for (e in tp) {
         e.print();
      }
      
      tp.xmlString = '''<clueluck goofy="slick"><snow  gigo="somken"   foola="snooko"  >BoraBora</snow></clueluck>''';
      tp.restart();
      for (e in tp) {
         e.print();
      }
      
      tp.xmlString = '''<snow foola="snooko"  >BoraBora</snow>''';
      tp.restart();
      for (e in tp) {
         e.print();
      }
      
      tp.xmlString = '''<? proc inst ?>''';
      tp.restart();
      for (e in tp) {
         e.print();
      }
      
      
      tp.xmlString = '''<!-- my > comment  -->   <claus hi="ho ho ho"/>''';
      tp.restart();
      for (e in tp) {
         e.print();
      }
      
   }
   
}

