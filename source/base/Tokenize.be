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

use Math:Int;
use Container:Array;
use Container:Map;
use Container:LinkedList;
use Text:String;
use Text:String;
use Logic:Bool;

final class Text:Tokenizer {
   
   new(String delims) self {
      properties {
         Map tmap; //String key, eq String value
         Bool includeTokens;
      }
      includeTokens = false;
      tokensStringSet(delims);
   }
   
   new(String delims, Bool _includeTokens) self {
      includeTokens = _includeTokens;
      tokensStringSet(delims);
   }
   
   tokensStringSet(String delims) {
      tmap = Map.new();
      foreach (String chi in delims) {
         tmap.put(chi, chi.toString());
      }
   }
   
   addToken(String _delim) {
      String delim = String.new();
      delim += _delim;
      tmap.put(delim, _delim);
   }
   
   tokenize(str) {
      return(tokenizeIterator(Text:MultiByteIterator.new(str)));
   }
   
   tokenize(str, tokenAcceptor) {
      return(tokenizeIterator(Text:MultiByteIterator.new(str), tokenAcceptor));
   }
   
   tokenizeIterator(i, acceptor) {
      String accum = String.new();
      String chi = String.new();
      while (i.hasNext) {
         i.next(chi);
         var cc = tmap.get(chi);
         if (def(cc)) {
            if (accum.size > 0) {
               acceptor.acceptToken(accum.extractString());
            }
            if (includeTokens) {
               acceptor.acceptToken(cc);
            }
         } else {
            accum += chi;
         }
      }
      if (accum.size > 0) {
         acceptor.acceptToken(accum.extractString());
      }
   }
   
   tokenizeIterator(i) {
      LinkedList splits = LinkedList.new();
      String accum = String.new();
      String chi = String.new();
      while (i.hasNext) {
         i.next(chi);
         var cc = tmap.get(chi);
         if (def(cc)) {
            if (accum.size > 0) {
               splits.addValue(accum.extractString());
            }
            if (includeTokens) {
               splits.addValue(cc);
            }
         } else {
            accum += chi;
         }
      }
      if (accum.size > 0) {
         splits.addValue(accum.extractString());
      }
      return(splits);
   }
   
}

use Container:LinkedList;
use Container:LinkedList:Node;
use Container:Stack;
use Container:Single;

use Text:Glob;

class Glob {
   
   new(String _glob) self {
      self.glob = _glob;
   }
   
   globSet(String _glob) {
      Text:Tokenizer tok = Text:Tokenizer.new("*?", true);
      LinkedList _splits = tok.tokenize(_glob);
      properties {
         String glob = _glob;
         LinkedList splits = _splits;
      }
   }
   
   //* - iterate while false, continue with each
   //? - end > pos, continue with next
   //str - begins with str, continue after
   //end - true
   
   match(String input) Bool {
      Node node = splits.iterator.nextNode;
      return(caseMatch(node, input, 0, null));
   }
   
   caseMatch(Node node, String input, Int pos, Single lpos) Bool {
      if (undef(node)) {
         if (pos == input.size) {
            return(true);
         } else {
            return(false);
         }
      }
      String val = node.held;
      if (val == "*") {
         return(starMatch(node, input, pos));
      }
      if (val == "?") {
         pos = pos++;
         if (pos <= input.size) { return(caseMatch(node.next, input, pos, null)); } else { return(false); }
      }
      Int found = input.find(val, pos);
      if (def(found)) {
         if (found == pos) {
            return(caseMatch(node.next, input, pos + val.size, null));
         } else {
            if (def(lpos)) {
               lpos.first = found;
            }
         }
      }
      return(false);
   }
   
   starMatch(Node node, String input, Int pos) Bool {
      Node nx = node.next;
      Single lpos = Single.new();
      //Special optimize for literal case with lpos
      while (pos <= input.size) {
         Bool ok = caseMatch(nx, input, pos, lpos);
         if (ok) { return(true); }
         if (def(lpos.first)) {
            pos = lpos.first;
            lpos.first = null;
         } else {
            pos = pos++;
         }
      }
      return(false);
   }

}
