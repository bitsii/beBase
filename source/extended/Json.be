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

use Container:Map;
use Container:Set;
use Container:LinkedList;
use Constainer:Stack;
use Math:Int;
use Logic:Bool;
use System:Env;
use Text:String;
use Text:String;
use Web:Request;
use Web:Requests;
use Web:StaticHandler;
use Web:MimeTypes;
use Web:Cookie;
use Web:Path;
use Web:TemplateHandler;
use System:Env;
use Encode:Url;
use Text:Tokenizer;
use Text:MultiByteIterator;
use Text:ByteIterator;
use IO:File;
use System:Serializer;
use Container:Array;
use Web:Request:Cgi;

use class Json:Parser {

    new() self {
        properties {
            String quote = Text:Strings.quote;
            String lbrace = "{";
            String rbrace = "}";
            String lbracket = "[";
            String rbracket = "]";
            String space = Text:Strings.space;
            String colon = Text:Strings.colon;
            String escape = "\\";
            String cr = Text:Strings.cr;
            String lf = Text:Strings.lf;
            String comma = ",";
            String tokens = quote + lbrace + rbrace + lbracket + rbracket + space + colon + escape + cr + lf + comma + "bfnrt/";
            Tokenizer toker = Tokenizer.new(tokens, true);
            Int hsub = Int.hexNew("D800");
            Int vsub = Int.hexNew("DC00");
            Int hmAdd = Int.hexNew("10000");
        }
    }

    parse(String str, handler) self {
        //("Got json string" + str).print();
        parseTokens(toker.tokenize(str), handler);
    }
    
    jsonUcIsPairStart(Int value) Bool {
      //0xD800 55296 0xDBFF 56319
      if (55296 <= value && value <= 56319) {
         Bool result = true;
      } else {
         result = false;
      }
        return(result);
    }
    
    jsonUcIsPairEnd(Int value) Bool {
    
      //0xDC00 56320 0xDFFF 57343
      if (56320 <= value && value <= 57343) {
         Bool result = true;
      } else {
         result = false;
      }
      return(result);
        
    }
    
    jsonUcGetAfterPart(String tok) String {
      if (tok.size < 6) {
        return(null);
      }
      return(tok.substring(5));
    }
    
    jsonUcUnescape(String tok) Int {
      if (tok.size < 5) {
        throw(System:Exception.new("tok too small"));
      }
      return(Int.hexNew(tok.substring(1)));
    }
    
    jsonUcAppendValue(Int heldValue, Int value, String accum) {
    
      if (accum.capacity - accum.size < 4) {
        accum.capacitySet(accum.size + 4);
      }
      Int sizeNow = accum.size;
      Int size;
      
      if (def(heldValue)) {
          //throw(System:Exception.new("Got a dupl case"));
          Int heldm = heldValue;
          heldm -= hsub;
          heldm.shiftLeftValue(10);
          heldm -= vsub;
          heldm += value;
          heldm += hmAdd;
          value = heldm;
      }
      
    //accum is buffer
    //start with sizenow
    
    if(value < 0) {
        size = -1;
    } elif(value < Int.hexNew("80")) {
        accum.setIntUnchecked(sizeNow, value);
        size = 1;
    } elif(value < Int.hexNew("800")) {
        accum.setIntUnchecked(sizeNow, Int.hexNew("C0").add(value.and(Int.hexNew("7C0")).shiftRight(6)));
        accum.setIntUnchecked(sizeNow + 1, Int.hexNew("80").add(value.and(Int.hexNew("03F"))));
        size = 2;
    } elif(value < Int.hexNew("10000")) {
        accum.setIntUnchecked(sizeNow, Int.hexNew("E0").add(value.and(Int.hexNew("F000")).shiftRight(12)));
        accum.setIntUnchecked(sizeNow + 1, Int.hexNew("80").add(value.and(Int.hexNew("0FC0")).shiftRight(6)));
        accum.setIntUnchecked(sizeNow + 2, Int.hexNew("80").add(value.and(Int.hexNew("003F"))));
        size = 3;
    } elif(value <= Int.hexNew("10FFFF")) {
        accum.setIntUnchecked(sizeNow, Int.hexNew("F0").add(value.and(Int.hexNew("1C0000")).shiftRight(18)));
        accum.setIntUnchecked(sizeNow + 1, Int.hexNew("80").add(value.and(Int.hexNew("03F000")).shiftRight(12)));
        accum.setIntUnchecked(sizeNow + 2, Int.hexNew("80").add(value.and(Int.hexNew("000FC0")).shiftRight(6)));
        accum.setIntUnchecked(sizeNow + 3, Int.hexNew("80").add(value.and(Int.hexNew("00003F"))));
        size = 4;
    } else {
        size = -1;
    }
        
        if (size < 0) {
            throw(System:Exception.new("failed during value to buffer convert"));
        }
        accum.size = accum.size + size;//TODO setValue (addValue)
    }
    
    parseTokens(LinkedList toks, handler) self {
        
        // http://en.wikipedia.org/wiki/JSON#Data_types.2C_syntax_and_example
        //lbrace, rbrace, lbracket, rbracket, number, boolean, space, colon, escape, quote
        //sp strings outside of quotes - true, false, null, numbers
        //inString, inEscape
        //string escaping 
        //- http://stackoverflow.com/questions/3020094/how-should-i-escape-strings-in-json
        //- http://code.google.com/p/json-simple/wiki/EscapingExamples
        //- https://groups.google.com/forum/?fromgroups=#!topic/Google-Web-Toolkit/X0N9ErqD__A
        //- http://awwx.ws/combinator/13
        //surrogate pair info
        //- http://www.russellcottrell.com/greek/utilities/SurrogatePairCalculator.htm
        //- http://stackoverflow.com/questions/8868432/how-the-surrogate-pairs-is-calculated
        //surrogate pair example found here (in tests)
        //- http://csharp.2000things.com/tag/unicode/
        
        
        Bool inString = false;
        Bool inEscape = false;
        String accum = String.new();
        
        Map fromEscapes = Escapes.fromEscapes;
        
        LinkedList:Iterator tokIter = toks.iterator;
        
        Int heldValue;
        
        while (tokIter.hasNext) {
            String tok = tokIter.next;
            //("Got tok " + tok).print()
            if (inString) {
                if (inEscape! && tok == quote) {
                    inString = false;
                    handler.handleString(accum.extractString());
                } else {
                    if (inEscape) {
                        String escval = fromEscapes.get(tok);
                        if (def(escval)) {
                            accum += escval;
                        } elif (tok.begins("u")) {
                            Int value = jsonUcUnescape(tok);
                            String remainder = jsonUcGetAfterPart(tok);
                            Bool isStart = false;
                            if (def(heldValue) && jsonUcIsPairEnd(value)!) {
                                throw(System:Exception.new("Invalid escape state, second part of surrogate pair is invalid"));
                            } elif (undef(heldValue)) {
                                isStart = jsonUcIsPairStart(value);
                            }
                            if (isStart && def(remainder)) {
                                throw(System:Exception.new("Invalid escape state, first part of surrogate pair not followed by second"));
                            }
                            if (isStart) {
                                heldValue = value;
                            } else {
                                jsonUcAppendValue(heldValue, value, accum);
                                heldValue = null;
                                if (def(remainder)) {
                                    accum += remainder;
                                }
                            }
                        } else {
                           accum += tok; 
                        }
                        inEscape = false;
                    } elif (tok == escape) {
                        inEscape = true;
                    } else {
                        accum += tok;
                    }
                }
            } else {
                //not instring
                if (tok == space || tok == cr || tok == lf || tok == comma) {
                } elif (tok == quote) {
                    inString = true;
                } elif (tok == lbrace) {
                    handler.beginMap();
                } elif (tok == rbrace) {
                    handler.endMap();
                } elif (tok == colon) {
                    handler.kvMid();
                } elif (tok == lbracket) {
                    handler.beginList();
                } elif (tok == rbracket) {
                    handler.endList();
                } else {
                    //bfnrt
                    //other literal string, true, false, null, numbers
                    if (tok == "t" || tok == "r" || tok == "f" || tok == "n") {
                        //just ignore these, outside of string they're causalties of
                        //the "special escape" handling.  The below shortened items will catch
                    } elif (tok == "ue") {
                        handler.handleTrue();
                    } elif (tok == "alse") {
                        handler.handleFalse();
                    } elif (tok == "ull") {
                        handler.handleNull();
                    } else {
                        //better be a number
                        handler.handleInteger(Int.new(tok));
                    }
                }
            }
        }
    }
    
}

use final class Json:Escapes {
    create() { }
    default() self {
        
        properties {
            Map toEscapes = Map.new();
            Map fromEscapes = Map.new();
        }
        toEscapes.put(String.new().addValue("\\"), "\\\\");
        toEscapes.put(String.new().addValue(Text:Strings.quote), "\\" + Text:Strings.quote);
        toEscapes.put(String.new().addValue("\b"), "\\b");
        toEscapes.put(String.new().addValue("\f"), "\\f");
        toEscapes.put(String.new().addValue("\n"), "\\n");
        toEscapes.put(String.new().addValue("\r"), "\\r");
        toEscapes.put(String.new().addValue("\t"), "\\t");
        toEscapes.put(String.new().addValue("/"), "\\/");
        
        fromEscapes.put("\\", "\\");
        fromEscapes.put(Text:Strings.quote, Text:Strings.quote);
        fromEscapes.put("b", "\b");
        fromEscapes.put("f", "\f");
        fromEscapes.put("n", "\n");
        fromEscapes.put("r", "\r");
        fromEscapes.put("t", "\t");
        fromEscapes.put("/", "/");
    }

}

use class Json:Marshaller {

    new() self {
        properties {
          //Instances for determining types when marshalling
          String str = String.new();
          //list
          LinkedList lls = LinkedList.new();
          Array arr = Array.new(1); 
          //map
          Map map = Map.new();
          //int
          Int int = Int.new();
          //bool  
          Bool boo = Bool.new();
          
          String q = Text:Strings.quote;
          
          MultiByteIterator mbi = MultiByteIterator.new();
          String txtpt = String.new();
          String escaped = String.new();
        }
    }
    
    marshall(inst) String {
        if (undef(str)) {
          new();
        }
        String bb = String.new();
        marshallWriteInst(inst, bb);
        return(bb.toString());
    }
    
    marshallWrite(inst, writer) {
        if (undef(str)) {
          new();
        }
        marshallWriteInst(inst, writer);
    }
    
    marshallWriteInst(inst, writer) {
       if (undef(inst)) {
         writer.write("null");
       } elif (inst.sameType(str)) {
         marshallWriteString(inst, writer);
       } elif (inst.sameType(lls) || inst.sameType(arr)) {
         marshallWriteList(inst, writer);
       } elif (inst.sameType(map)) {
         marshallWriteMap(inst, writer);
       } elif (inst.sameType(int)) {
         writer.write(inst.toString());
       } elif (inst.sameType(boo)) {
         writer.write(inst.toString());
       } else {
         marshallWriteString(inst.toString(), writer);
       }
    }
    
   jsonEscapePoint(String txtpt, String txt) {
      Int rcap = Int.new();
      Int txtsznow = txt.size;
      
      Int size = txtpt.size;
      Int value;

    Int u = txtpt.getInt(0, Int.new());
    if(size == 2)
    {
        value = u & Int.hexNew("1F");
    }
    elif(size == 3)
    {
        value = u & Int.hexNew("F");
    }
    elif(size == 4)
    {
        value = u & Int.hexNew("7");
    }
    if (size > 1) { //redundant?
        for(Int i = 1; i < size; i++=)
        {
            txtpt.getInt(i, u);

            value = value.shiftLeft(6) + u.and(Int.hexNew("3F"));
        }
    }
    if (size == 0) {
        rcap = 0;
    } elif (size == 1) {
        rcap = 2;
    } else {
        if(value < Int.hexNew("10000")) {
            rcap = 7;
        } else {
            rcap = 13;
        }
    }

      if (txt.capacity - txtsznow < rcap) {
        txt.capacitySet(txtsznow + rcap);
      }
      //rcap 0 nothing happens, size stays 0
      if (rcap == 2) {
        //ascii, check for special characters
        Escapes esc = Escapes.new();
        String escval = esc.toEscapes.get(txtpt);
        if (def(escval)) {
            txt += escval;
        } else {
            //else simple append
            txt += txtpt;
        }
      } elif (rcap > 3) {
      if (rcap == 7) {
        txt += "\\u" += value.toString(String.new(4@), 4@, 16@, 87@);
      } elif (rcap == 13) {
        value -= Int.hexNew("10000");
        Int first = Int.hexNew("D800").or(value.and(Int.hexNew("ffc00")).shiftRight(10));
        Int last = Int.hexNew("DC00").or(value.and(Int.hexNew("003ff")));
        txt += "\\u" += first.toString(String.new(4@), 4@, 16@, 87@);
        txt += "\\u" += last.toString(String.new(4@), 4@, 16@, 87@);
      }
      }
   }
   
   jsonEscape(toEscape) String {
       escaped.clear();
       return(jsonEscape(mbi.new(toEscape), txtpt, escaped));
   }
    
   jsonEscape(MultiByteIterator mbi, String txtpt, String escaped) String {
        while (mbi.hasNext) {
            mbi.next(txtpt);
            jsonEscapePoint(txtpt, escaped);
        }
        return(escaped);
    }
    
    marshallWriteString(String inst, writer) {
        writer.write(q);
        writer.write(jsonEscape(inst));
        writer.write(q);
    }
    
    marshallWriteList(inst, writer) {
        writer.write("[");
        Bool first = true;
        foreach (var instin in inst) {
            if (first) {
              first = false;
            } else {
              writer.write(",");
            }
            marshallWriteInst(instin, writer);
        }
        writer.write("]");
    }
    
    marshallWriteMap(inst, writer) {
        writer.write("{");
        Bool first = true;
        foreach (var kv in inst) {
            //assumes keys are strings
            if (first) {
              first = false;
            } else {
              writer.write(",");
            }
            marshallWriteString(kv.key, writer);
            writer.write(":");
            marshallWriteInst(kv.value, writer);
        }
        writer.write("}");
    }
    
}

use class Json:Unmarshaller {

    new() self {
        properties {
            Parser parser = Parser.new();
            LinkedList ll = LinkedList.new();
            
            var key;
            var top;
            Container:Stack stack;
            Bool inList = false;
        }
    }

    unmarshall(String str) {
        if (undef(parser)) {
          new();
        }
        key = null;
        top = null;
        stack = Container:Stack.new();
        inList = false;
        
        parser.parse(str, self);
        return(top);
    }
    
    beginMap() {
        //("beginMap").print();
        Map m = Map.new();
        if (def(top)) { 
            addItem(m);
            stack.push(top); 
        }
        top = m;
        inList = false;
    }
    
    endMap() {
        //("endMap").print();
        if (stack.isEmpty!) {
            top = stack.pop();
            
            if (top.sameClass(ll)) {
                inList = true;
            } else {
                inList = false;
            }
        }
    }
    
    kvMid() {
        //("kvMid").print();
    }
    
    beginList() {
        //("beginList").print();
        Array l = Array.new();
        if (def(top)) { 
            addItem(l);
            stack.push(top); 
        }
        top = l;
        inList = true;
    }
    
    endList() {
        //("endList").print();
        if (stack.isEmpty!) {
            top = stack.pop();
            
            if (top.sameClass(ll)) {
                inList = true;
            } else {
                inList = false;
            }
        }
    }
    
    addItem(var item) {
        if (def(top)) {
            //?an error if not
            if (inList) {
                top.addValue(item);
            } else {
                //assumes keys can't be null.  appears to be true.  otherwise, use the kv to know if we are in key or value land
                //this is simpler and appears to work...
                if (undef(key)) {
                    key = item;
                } else {
                    top.put(key, item);
                    key = null;
                }
            }
        }
    }
    
    handleString(String str) {
        //log.info("Got string |" + str + "|");
        //("Got String |" + str + "|").print();
        addItem(str);
    }
    
    handleTrue() {
        //("handleTrue").print();
        addItem(true);
    }
    
    handleFalse() {
        //("handleFalse").print();
        addItem(false);
    }
    
    handleNull() {
        //("handleNull").print();
        addItem(null);
    }
    
    handleInteger(Int int) {
        //("Got Integer |" + int + "|").print();
        addItem(int);
    }

}

use class Json:ParseLog {

    new() self {
        properties {
            //IO:Log log = IO:Log.new();
        }
    }

    handleString(String str) {
        //log.info("Got string |" + str + "|");
        ("Got String |" + str + "|").print();
    }
    
    beginMap() {
        ("beginMap").print();
    }
    
    endMap() {
        ("endMap").print();
    }
    
    kvMid() {
        ("kvMid").print();
    }
    
    beginList() {
        ("beginList").print();
    }
    
    endList() {
        ("endList").print();
    }
    
    handleTrue() {
        ("handleTrue").print();
    }
    
    handleFalse() {
        ("handleFalse").print();
    }
    
    handleNull() {
        ("handleNull").print();
    }
    
    handleInteger(Int int) {
        ("Got Integer |" + int + "|").print();
    }

}



