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

use Encode:Url;

class Test:BaseTest:Encode(BaseTest) {
   
   main() {
      ("Test:BaseTest:Encode:main").print();
      
      
      //return(self);
      
      tinyTest();
      smallTest();
      fullTest();
      
      testB16();
   }
   
   testB16() {
   
      Encode:Hex eh = Encode:Hex.new();
      String res;
      
      res = eh.encode("abcxyz");
      assertEqual(res, "61626378797A");
      res.print();
      
      res = eh.decode(res);
      assertEqual(res, "abcxyz");
      res.print();
      
   }
   
   tinyTest() {
       "#".getHex(0).print(); 
       String.hexNew("23").print();
       assertEqual("#", String.hexNew("#".getHex(0)));
   }
   
   smallTest() {
   
       Encode:Url.encode("#").print();
       Encode:Url.decode("%23").print();
       "#".getCode(0).print(); //35 35/16=2, 35%16=3
       
       Encode:Url.encode("Â").print();
       Encode:Url.decode("%C3%82").print();
       "Â".getCode(0).print(); //first - -61 + 256 = 195 %16=3, /16=12
       
       //assertEqual(Encode:Url.decode("%C3%82"), "Â");
       
   }
   
   fullTest() {
      Url url = Url.new();
      //String mytest = "This is a, string \nto deal with = *-/():";
      String mytest = "|#&@;?^"; // Standard serialization tokens $-_.+!*'(),
      String str = url.encode(mytest);
      assertNotEquals(mytest, str);
      
      ("Precoded String \n" + mytest + "\n encoded String \n" + str).print();
      
      str = url.decode(str);
      ("Decoded String \n" + str + "\n").print();
      assertEquals(mytest, str);
      
      
      assertEqual("\\", '\');
      assertEqual(" \"\" ", ''' "" ''');
      "Â Ã Ä Å Æ Ç".print();
      'Â Ã Ä Å Æ Ç'.print();
      assertEqual("Â Ã Ä Å Æ Ç",'Â Ã Ä Å Æ Ç');
      
      if (false) {
      
      IO:File.new("test/tmp").makeDirs();
      
      var fout; var w;
      fout = IO:File.apNew("test/tmp/u8.html");
      w = fout.writer.open();
      writeHtmlPre(w);
      //2byte
      w.write("Â Ã Ä Å Æ Ç");
      w.write("\n");
      //3byte
      w.write("あ诶");
      w.write("\n");
      //4byte
      w.write("𡇙𢱕");
      w.write("\n");
      writeHtmlPost(w);
      w.close();
      
      fout = IO:File.apNew("test/tmp/u8-2.html");
      w = fout.writer.open();
      writeHtmlPre(w);
      //2byte
      w.write('Â Ã Ä Å Æ Ç');
      w.write("\n");
      //3byte
      w.write('あ诶');
      w.write("\n");
      //4byte
      w.write('𡇙𢱕');
      w.write("\n");
      writeHtmlPost(w);
      w.close();
      
      }
      
      Encode:Url.encode("Â").print();
      Encode:Url.encode("あ").print();
      Encode:Url.encode("𡇙").print();
      
      Text:String.new().addValue("Â").getHex(0).print();
      Text:String.new().addValue(" ").getHex(0).print();
      
      Encode:Url.decode("%C3%82").print();
      Encode:Url.decode("%E3%81%82").print();
    
      assertEqual(Encode:Url.decode("%C3%82"), "Â");
      assertEqual(Encode:Url.decode("%E3%81%82%E8%AF%B6"), "あ诶");
      
      assertEqual(Encode:Url.decode("%F0%A1%87%99"), "𡇙");
      
      str = url.encode("user@name");
      str.print();
      url.decode(str).print();
      assertEquals(url.decode(str), "user@name");
      
      url.decode("User+Specified").print();
   }
   
   writeHtmlPre(w) {
   
w.write('''
<!DOCTYPE html>
<html lang="en">
<head>

    <title>Slashdot: News for nerds, stuff that matters</title>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
</head>
<body>
''');
   
   }
   
   writeHtmlPost(w) {
w.write('''
</body>
</html>
''');
   }
   
   
}

