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
use Container:Map;
use System:Parameters;
use Text:String;

use Test:Assertions;
use Test:Failure;

use class Tests:TestJson(Assertions) {
    
    main() {
        
        //testJustStr();
        //return(self);
        
        testJustStr();
        testUcEscape();
        testUnEscape();
        testMarshall();
        testUnmarshall();
    }
    
    testJustStr() {
    
        "Here's a string with a quot \" in it".print();
    
        String sl = "\\";
        String str = "[" + Text:Strings.quote + "Hi " + sl + "n bob yoo" + sl + "byo" + sl + "tyar | " + sl + "u00c6 | **" + sl + Text:Strings.quote + " ya " + Text:Strings.quote + "]";
        var s2 = Json:Unmarshaller.new().unmarshall(str);
        s2.first.print();
        var s3 = Json:Marshaller.new().marshall(s2.first);
        s3.print();
        str.print();
    }
    
    testUnEscape() {
    
                        // \"bfnrt/ u
        String ex;
        var m;
        String ex2;
        
        ex = '{"k":"str \\ q\"q \/ "}';
        ex.print();
        Json:Parser.new().parse(ex, Json:ParseLog.new());
        m = Json:Unmarshaller.new().unmarshall(ex);
        m["k"].print();
        assertEqual(m["k"], 'str \ q"q / '); 
        ex2 = Json:Marshaller.new().marshall(m);
        ex2.print();
        assertEqual(ex, ex2);
        
        
        ex = '''{"k":"\u00c6"}''';
        ex.print();
        Json:Parser.new().parse(ex, Json:ParseLog.new());
        "Æ".print();
        m = Json:Unmarshaller.new().unmarshall(ex);
        m["k"].print();
        assertEqual(m["k"], "Æ");
        ex2 = Json:Marshaller.new().marshall(m);
        ex2.print();
        assertEqual(ex, ex2);
        
        ex = '''{"k":"\u3042"}''';
        ex.print();
        Json:Parser.new().parse(ex, Json:ParseLog.new());
        "あ".print();
        m = Json:Unmarshaller.new().unmarshall(ex);
        m["k"].print();
        assertEqual(m["k"], "あ");
        ex2 = Json:Marshaller.new().marshall(m);
        ex2.print();
        assertEqual(ex, ex2);
        
        ex = '''{"k":"\ud844\uddd9"}''';
        ex.print();
        Json:Parser.new().parse(ex, Json:ParseLog.new());
        "𡇙".print();
        m = Json:Unmarshaller.new().unmarshall(ex);
        m["k"].print();
        assertEqual(m["k"], "𡇙");
        ex2 = Json:Marshaller.new().marshall(m);
        ex2.print();
        assertEqual(ex, ex2);
        
        ex = '''{"k":"a\u00c6 b\u3042 c\ud844\uddd9 "}''';
        ex.print();
        Json:Parser.new().parse(ex, Json:ParseLog.new());
        "𡇙".print();
        m = Json:Unmarshaller.new().unmarshall(ex);
        m["k"].print();
        assertEqual(m["k"], "aÆ bあ c𡇙 ");
        ex2 = Json:Marshaller.new().marshall(m);
        ex2.print();
        assertEqual(ex, ex2);
        
        // \\ud840\\ude13 - supposed to be surrogate pair
        ex = '''{"k":"\ud840\ude13"}''';
        ex.print();
        Json:Parser.new().parse(ex, Json:ParseLog.new());
        "𠈓".print();
        m = Json:Unmarshaller.new().unmarshall(ex);
        m["k"].print();
        assertEqual(m["k"], "𠈓");
        ex2 = Json:Marshaller.new().marshall(m);
        ex2.print();
        assertEqual(ex, ex2);
    
    }
    
    testUcEscape() {
        Json:Marshaller mar = Json:Marshaller.new();
        assertEqual(mar.jsonEscape("b").toString(), "b");
        assertEqual(mar.jsonEscape("Æ").toString().substring(1), "u00c6");
        assertEqual(mar.jsonEscape("あ").toString().substring(1), "u3042");
        assertEqual(mar.jsonEscape("𡇙").toString().substring(1, 6), "ud844");
        assertEqual(mar.jsonEscape("𡇙").toString().substring(7, 12), "uddd9");
        assertEqual(mar.jsonEscape("Æ"), mar.jsonEscape("Æ"));
        ("printing things").print();
        //TODO reactivate and make these work
        //mar.jsonEscape("""|hi \\ \b \f \n \r \t / "|""").toString().print();
        //("PRINTING THE 3Q").print();
        //"""|hi \\\\ \\b \\f \\n \\r \\t \\/ \\"|""".print();
        //"""|hi \\\\ \\b \\f \\n \\r \\t \\/ \\"|""".size.print();
        //("DONE PRINTING THE 3Q").print();
        //assertEqual(mar.jsonEscape("""|hi \\ \b \f \n \r \t / "|""").toString(),
        //"""|hi \\\\ \\b \\f \\n \\r \\t \\/ \\"|""");
        
    }
    
    testMarshall() {
        Json:Marshaller mar = Json:Marshaller.new();
        Json:Unmarshaller unmar = Json:Unmarshaller.new();
        
        Map m = Map.new();
        String ms;
        
        m.put("hi", "there");
        
        ms = mar.marshall(m);
        ms.print();
        m = unmar.unmarshall(ms);
        
        assertEqual(m["hi"], "there");
        
        
        ms = mar.marshall(m);
        ms.print();
        m = unmar.unmarshall(ms);
        
        ms = getExample();
        m = unmar.unmarshall(ms);
        ms = mar.marshall(m);
        ms.print();
        
        m = Json:Unmarshaller.new().unmarshall(ms);
        assertEqual(m["age"], 25);
        assertNull(m["car"])
        assertTrue(m["lame"]);
        assertFalse(m["cool"]);
        assertEqual(m["address"]["postalCode"],10021);
        assertEqual(m["phoneNumbers"][0]["type"], "home");
        
    }
    
    getExample() String {
        
        String ex1 = '''
{
    "firstName": "John",
    "lastName": "Smith",
    "age": 25,
    "car": null,
    "cool": false,
    "lame": true,
    "address": {
        "streetAddress": "21 2nd Street",
        "city": "New York",
        "state": "NY",
        "postalCode": 10021
    },
    "phoneNumbers": [
        {
            "type": "home",
            "number": "212 555-1234"
        },
        {
            "type": "fax",
            "number": "646 555-4567"
        }
    ]
}
        ''';
        return(ex1);
    }
    
    testUnmarshall() {
    
        String ex1 = getExample();
        
        //Json:Parser.new().parse(ex1, Json:ParseLog.new());
        
        var m;
        String val;
        
        val = '   {"hi":"\"1q"}   ';
        m = Json:Unmarshaller.new().unmarshall(val);
        val.print();
        m.get("hi").print();
        assertEqual(m.get("hi"), Text:Strings.quote + "1q");
        
        val = '   {"hi":"\\2"}   ';
        m = Json:Unmarshaller.new().unmarshall(val);
        val.print();
        m.get("hi").print();
        assertEqual(m.get("hi"), "\\" + "2");
        
        val = '''   {"hi":"\\\"3q"}   ''';
        m = Json:Unmarshaller.new().unmarshall(val);
        val.print();
        m.get("hi").print();
        assertEqual(m.get("hi"), "\\" + Text:Strings.quote + "3q");
        
        //return(self);
        
        m = Json:Unmarshaller.new().unmarshall('''   {"hi":"there"}   ''');
        assertEqual(m.get("hi"), "there");
        
        m = Json:Unmarshaller.new().unmarshall('''   {"hey":{"yo","bobo"}   ''');
        assertEqual(m.get("hey").get("yo"), "bobo");
        
        m = Json:Unmarshaller.new().unmarshall(ex1);
        assertEqual(m["age"], 25);
        assertNull(m["car"])
        assertTrue(m["lame"]);
        assertFalse(m["cool"]);
        assertEqual(m["address"]["postalCode"],10021);
        assertEqual(m["phoneNumbers"][0]["type"], "home");
        
        
    }
    
}

