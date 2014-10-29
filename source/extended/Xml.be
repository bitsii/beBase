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

use Xml:TagIterator;
use Xml:TagIteratorException;
use Xml:XTokenizer;
use Xml:Tag;
use Xml:StartElement;
use Xml:EndElement;
use Xml:TextNode;
use Xml:ProcessingInstruction;
use Xml:Comment;
use Text:String;
use Text:Tokenizer;
use Text:String;
use Math:Int;
use Logic:Bool;
use Container:LinkedList;
use Container:Map;

class Tag {
}

class StartElement(Tag) {
   
   new() self {
      properties {
         String name;
         Bool isClosed;
         String attName;
         Map attributes;
      }
   }
   
   addAttributeName(String pname) {
      //("Added attribute name " + pname).print();
      attName = pname;
   }
   
   addAttributeValue(String pval) {
      //("Added attribute value " + pval).print();
      if (undef(attributes)) {
         attributes = Map.new();
      }
      attributes.put(attName, pval);
      attName = null;
   }
   
   toString() String {
      String accum = String.new();
      accum += "<" += name;
      if (def(attributes)) {
         String q = Text:Strings.new().quote;
         foreach (var entry in attributes) {
            accum += " " += entry.key += "=" += q += entry.value += q;
         }
      }
      if (isClosed) {
         accum += "/>";
      } else {
         accum += ">";
      }
      return(accum.extractString());
   }
}

class EndElement(Tag) {
   
   new() self {
      properties {
         String name;
      }
   }
   
   toString() String {
      return("</" + name + ">");
   }
}

class TextNode(Tag) {
   
   new(String _contents) self {
      properties {
         String contents = _contents;
      }
   }
   toString() String {
      return(contents);
   }
}

class Comment(Tag) {

   new(String _contents) self {
      properties {
         String contents = _contents;
      }
   }
   
   toString() String {
      return(contents);
   }
}

class ProcessingInstruction(Tag) {

   new(String _contents) self {
      properties {
         String contents = _contents;
      }
   }
   
   toString() String {
      return(contents);
   }
}

class TagIteratorException(System:Exception) {}

class XTokenizer {
   create() { }
   default() self {
      
      String tokString = "<>=/?! \"";
      properties {
         Tokenizer tok = Tokenizer.new(tokString, true);
         IO:Log log;
      }
      //log = IO:Log.new(IO:LogLevels.debug, IO:File.new("xml.log").writer.open());
      log = IO:Log.new().clearAppenders();
   }
}

class TagIterator {
   
   new() self {
      properties {
         String xmlString;
         Bool started = false;
         XTokenizer xt = XTokenizer.new();
         LinkedList res = null;
         var iter = null;
         Bool textNode = false;
         Int line = 1;
         Bool skip = false;
         Bool debug = true;
       }
   }
   
   stringNew(String _xmlString) self {
      self.new();
      xmlString = _xmlString;
   }
   
   restart() {
      self.new();
   }
   
   iteratorGet() {
      return(self);
   }
   
   start() {
      res = xt.tok.tokenize(xmlString);
      iter = res.iterator;
      started = true;
      String nxt;
      nxt = iter.next;
      while (def(nxt) && (nxt != "<")) {
         nxt = iter.next;
      }
      if (def(nxt) && (nxt == "<")) {
         skip = true;
      }
   }
   
   nextGet() Tag {
      if (started!) {
         start();
      }
      String nxt;
      String q = Text:Strings.new().quote;
      String nl = Text:Strings.new().newline;
      if (skip) {
         nxt = iter.current;
         skip = false;
      } else {
         nxt = iter.next;
      }
      if (debug) {
         if (undef(nxt)) {
            xt.log.debug("1 nxt null");
         } else {
            xt.log.debug("1 " + nxt);
         }
      }
      String accum = String.new();
      if (def(nxt) && textNode) {
         while (nxt != "<") {
            accum += nxt;
            nxt = iter.next;
            if (debug) { xt.log.debug("2 " + nxt); }
         }
         textNode = false;
         if (debug) { xt.log.debug(" t:" + accum.toString() + ":"); }
         skip = true;
         return(TextNode.new(accum.extractString()));
      } elif (def(nxt)) {
         if (nxt == "<") {
            Bool tagName = true;
            Bool attributeName = false;
            Bool attributeValue = false;
            Bool pinstruct = false;
            Bool comment = false;
            Bool isStart = true;
            while (nxt != ">") {
               if (pinstruct) {
                  Bool instr = false;
                  while (instr || nxt != ">") {
                     accum += nxt;
                     if (nxt == q) {
                        instr = instr!;
                     }
                     nxt = iter.next;
                  }
                  accum += ">";
                  pinstruct = false;
                  while (def(nxt) && nxt != "<") {
                     nxt = iter.next;
                  }
                  skip = true;
                  return(ProcessingInstruction.new(accum.toString()));
               }
               if (comment) {
                  while (nxt != ">") {
                     accum += nxt;
                     nxt = iter.next;
                     if (nxt == ">" && accum.toString().ends("--")!) {
                        accum += nxt;
                        nxt = iter.next;
                     }
                  }
                  comment = false;
                  while (def(nxt) && nxt != "<") {
                     nxt = iter.next;
                  }
                  accum += ">";
                  skip = true;
                  return(Comment.new(accum.extractString()));
               }
               if (tagName) {
                  nxt = iter.next;
                  if (debug) { xt.log.debug("3 " + nxt); }
                  while (nxt == " " || nxt == nl) {
                     if (nxt == nl) { line = line++; }
                     nxt = iter.next;
                     if (debug) { xt.log.debug("4 " + nxt); }
                  }
                  if (nxt == "?") {
                     isStart = false;
                     pinstruct = true;
                     nxt = iter.next;
                     accum.extractString();
                     accum += "<?";
                     if (debug) { xt.log.debug("15 " + nxt); }
                  } elif (nxt == "!") {
                     isStart = false;
                     comment = true;
                     nxt = iter.next;
                     accum.extractString();
                     accum += "<!";
                     if (debug) { xt.log.debug("15 " + nxt); }
                  } else {
                     if (nxt == "/") {
                        isStart = false;
                        nxt = iter.next;
                        if (debug) { xt.log.debug("5 " + nxt); }
                     }
                     while (nxt != " " && nxt != nl && nxt != ">" && nxt != "/") {
                        accum += nxt;
                        nxt = iter.next;
                        if (debug) { xt.log.debug("6 " + nxt); }
                     }
                     if (nxt == nl) { line = line++; }
                     tagName = false;
                     if (isStart) {
                        StartElement myElement = StartElement.new();
                        Tag myTag = myElement;
                        myElement.name = accum.extractString();
                        if (debug) { xt.log.debug(" StartElement " + myElement.name); }
                     } else {
                        EndElement myEndElement = EndElement.new();
                        myEndElement.name = accum.extractString();
                        myTag = myEndElement;
                        if (debug) { xt.log.debug(" EndElement " + myEndElement.name); }
                     }
                     if (nxt == ">") {
                        attributeName = false;
                        if (isStart) {
                           textNode = true;
                        }
                     } elif (nxt == "/" && isStart) {
                        attributeName = false;
                        myElement.isClosed = true;
                        nxt = iter.next;
                     } elif (isStart) {
                        attributeName = true;
                     } else {
                        attributeName = false;
                     }
                  }
               }
               if (attributeName) {
                  nxt = iter.next;
                  if (debug) { xt.log.debug("7 " + nxt); }
                  while (nxt == " " || nxt == nl) {
                     if (nxt == nl) { line = line++; }
                     nxt = iter.next;
                     if (debug) { xt.log.debug("8 " + nxt); }
                  }
                  while (nxt != " " && nxt != nl && nxt != ">" && nxt != "/" && nxt != "=") {
                     accum += nxt;
                     nxt = iter.next;
                     if (debug) { xt.log.debug("9 " + nxt); }
                  }
                  attributeName = false;
                  if (nxt == nl) { line = line++; }
                  if (nxt == ">") {
                     attributeValue = false;
                     textNode = true;
                  } elif (nxt == "/") {
                     attributeValue = false;
                     myElement.isClosed = true;
                     nxt = iter.next;
                     if (debug) { xt.log.debug("14 " + nxt); }
                  } else {
                     if (debug) { xt.log.debug(" an:" + accum.toString() + ":"); }
                     myElement.addAttributeName(accum.extractString());
                     attributeValue = true;
                  }
               }
               if (attributeValue) {
                  nxt = iter.next;
                  if (debug) { xt.log.debug("10 " + nxt); }
                  while (nxt == " " || nxt == nl || nxt == "=") {
                     //Check for = ?
                     if (nxt == nl) { line = line++; }
                     nxt = iter.next;
                     if (debug) { xt.log.debug("11 " + nxt); }
                  }
                  if (nxt != q) {
                     throw(Xml:TagIteratorException.new("Malformed Xml, incorrect attributeeter def at line " + line.toString()));
                  }
                  nxt = iter.next;
                  if (debug) { xt.log.debug("11.5 " + nxt); }
                  while (nxt != q) {
                     if (nxt == nl) { line = line++; }
                     accum += nxt;
                     nxt = iter.next;
                     if (debug) { xt.log.debug("12 " + nxt); }
                  }
                  if (nxt != q) {
                     throw(Xml:TagIteratorException.new("Malformed Xml, incorrect attributeeter def at line " + line.toString()));
                  }
                  attributeValue = false;
                  if (debug) { xt.log.debug(" av:" + accum.toString() + ":"); }
                  myElement.addAttributeValue(accum.extractString());
                  attributeName = true;
               }
            }
            if (def(myEndElement) || (def(myElement) && myElement.isClosed)) {
               nxt = iter.next;
               while (def(nxt) && (nxt == " " || nxt == nl)) { nxt = iter.next; };
               if (def(nxt) && nxt == "<") { skip = true; }
            }
         } else {
            if (undef(nxt)) { nxt = "null"; }
            throw(TagIteratorException.new("Malformed Xml, tag does not start :" + nxt + ":"));
         }
      }
      return(myTag);
   }
   
   hasNextGet() Bool {
      if (started!) { return(true); }
      return(iter.hasNext);
   }
   
}

