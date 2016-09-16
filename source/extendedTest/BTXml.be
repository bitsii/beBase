// Copyright 2006 Craig Welch
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

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
      var e;
      
      tp.xmlString = "<xml></xml>";
      foreach (e in tp) {
         e.print();
      }
      
      tp.xmlString = "<xml></xml>  ";
      tp.restart();
      foreach (e in tp) {
         e.print();
      }
      
      tp.xmlString = " <xml></xml>";
      tp.restart();
      foreach (e in tp) {
         e.print();
      }
      
      tp.xmlString = "  <xml><foop>knu</foop></xml><goo> new </goo>  ";
      tp.restart();
      foreach (e in tp) {
         e.print();
      }
      
      tp.xmlString = "  <snow/><glow> boof  lala km </glow> ";
      tp.restart();
      foreach (e in tp) {
         e.print();
      }
      
      tp.xmlString = '''<snow cat="dog" slick="SSmo" ><sneeze ahh = "choo"></sneeze></snow>''';
      tp.restart();
      foreach (e in tp) {
         e.print();
      }
      
      tp.xmlString = '''<clueluck goofy="slick"><snow  gigo="somken"   foola="snooko"  >BoraBora</snow></clueluck>''';
      tp.restart();
      foreach (e in tp) {
         e.print();
      }
      
      tp.xmlString = '''<snow foola="snooko"  >BoraBora</snow>''';
      tp.restart();
      foreach (e in tp) {
         e.print();
      }
      
      tp.xmlString = '''<? proc inst ?>''';
      tp.restart();
      foreach (e in tp) {
         e.print();
      }
      
      
      tp.xmlString = '''<!-- my > comment  -->   <claus hi="ho ho ho"/>''';
      tp.restart();
      foreach (e in tp) {
         e.print();
      }
      
   }
   
}

