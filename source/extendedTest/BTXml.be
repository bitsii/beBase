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

