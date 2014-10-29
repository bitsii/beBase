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
use Container:LinkedList;
use Container:Map;
use Text:String;
use Text:String;
use Logic:Bool;
use Template:Replace;

class Replace:CallStep {
   
   new(LinkedList payloads) self {
      
      properties {
        String callName = payloads[0];
        Array callArgs = Array.new(payloads.length - 1);
      }
   
      for (Int pi = 1;pi < payloads.length;pi = pi++) {
         callArgs[pi - 1] = payloads[pi];
      }
      
   }
   
   handle(r) String {
      return(r.invoke(callName, callArgs));
   }
   
}

class Replace:StringStep {
   
   new(String _str) self {
      
      properties {
         String str = _str;
      }
      
   }
   
   handle(r) String {
      return(str);
   }
   
}

class Replace {
   
   new() self {
      
      properties {
         LinkedList steps;
         Int size;
         Bool append = true;
         Runner runner;
      }
      
   }
   
   load(String template) Replace {
      load(template, null);
   }
   
   load(String template, Runner _runner) Replace {
      runner = _runner;
      size = template.size;
      
      String blStart = "<?tt";
      String blEnd = "?>";
      Bool onStart = true;
      Bool nextIsCall = false;
      
      String delim = blStart;
      Container:LinkedList splits = Container:LinkedList.new();
      Int last = 0;
      Int i = template.find(delim, last);
      Int ds = delim.size;
      while (def(i)) {
            if (i > last) {
               if (nextIsCall) {
                  String payload = template.substring(last, i).strip();
                  LinkedList payloads = payload.split(" ");
                  if (undef(runner)) {
                     // Call based
                    Replace:CallStep rcs = Replace:CallStep.new(payloads);
                    splits.addValue(rcs);
                    nextIsCall = false;
                  } else {
                     // Build the runner
                     foreach (String paypart in payloads) {
                        Replace:RunStep rs = Replace:RunStep.new(self, paypart);
                        splits.addValue(rs);
                     }
                     nextIsCall = false;
                  }
               } else {
                  splits.addValue(Replace:StringStep.new(template.substring(last, i)));
               }
            }
            last = i + ds;
            if (onStart) {
               onStart = false;
               delim = blEnd;
               ds = delim.size;
               nextIsCall = true;
            } else {
               onStart = true;
               delim = blStart;
               ds = delim.size;
            }
            i = template.find(delim, last);
      }
      if (last < size) {
         splits.addValue(Replace:StringStep.new(template.substring(last, size)));
      }
      steps = splits;
   }
   
   accept(var inst, var out) {
      var iter = steps.iterator;
      while (iter.hasNext) {
         var s = iter.next;
         if (append) {
            out.write(s.handle(inst));
         }
      }
      return(out);
   }

}

/*
Tokens inside blStart/blEnd are labels
setup a map label->replacement which happens while going through (replacing) (swap)
run to label/skip to label
get node / go (back) to node
*/

class Replace:RunStep {
   
   new(Replace _replace, String _str) self {
      
      properties {
         Replace replace = _replace;
         String str = _str;
      }
      
   }
   
   handle(r) String {
      String toSwap = r.swap.get(str);
      if (def(toSwap)) {
         return(toSwap);
      }
      return(str);
   }
   
}

use Template:Runner;

class Runner {

   new() self {
      properties {
         Replace replace;
         var output;
         var stepIter;
         Map swap;
         Map handOff;
         Runner baton;
         Replace:RunStep runStep = Replace:RunStep.new();
      }
   }
   
   swapGet() Map {
      if (undef(swap)) { swap = Map.new(); }
      return(swap);
   }
   
   handOffGet() Map {
      if (undef(handOff)) { handOff = Map.new(); }
      return(handOff);
   }
   
   new(String template, var _output) self {
      new(template);
      output = _output;
   }
   
   new(String template) self {
      new();
      load(template);
   }
   
   load(String template) Runner {
      replace = Replace.new();
      replace.load(template, self);
   }
   
   restart() Runner {
      if (def(baton)) {
         baton.restart();
         baton = null;
      }
      stepIter = null;
   }
   
   stepIterGet() {
      if (undef(stepIter)) {
         stepIter = replace.steps.iterator;
      }
      return(stepIter);
   }
   
   currentRunnerGet() Runner {
      if (def(baton)) {
         return(baton.currentRunner);
      }
      return(self);
   }
   
   currentNodeGet() {
      return(self.currentRunner.stepIter.currentNode);
   }
   
   currentNodeSet(node) Runner {
      //check for is my list?
      var iter = self.stepIter;
      iter.currentNode = node;
   }
   
   runToLabel(String label) Bool {
      if (def(baton)) {
         if (baton.runToLabel(label)) {
            return(true);
         } else {
            //ran to end, not found
            baton.restart();
            baton = null;
         }
      }
      var iter = self.stepIter;
      while (iter.hasNext) {
         var s = iter.next;
         if (def(handOff) && s.sameType(runStep) && handOff.has(s.str)) {
            baton = handOff.get(s.str);
            baton.output = output;
            baton.swap = swap;
            if (baton.runToLabel(label)) {
               return(true);
            } else {
               //ran to end, not found
               baton.restart();
               baton = null;
            }
         } elif (s.sameType(runStep) && s.str == label) {
            return(true);
         } else {
            output.write(s.handle(self));
         }
      }
      return(false);
   }
   
   skipToLabel(String label) Bool {
      if (def(baton)) {
         if (baton.skipToLabel(label)) {
            return(true);
         } else {
            //ran to end, not found
            baton.restart();
            baton = null;
         }
      }
      var iter = self.stepIter;
      while (iter.hasNext) {
         var s = iter.next;
         if (def(handOff) && s.sameType(runStep) && handOff.has(s.str)) {
            baton = handOff.get(s.str);
            baton.output = output;
            baton.swap = swap;
            if (baton.skipToLabel(label)) {
               return(true);
            } else {
               //ran to end, not found
               baton.restart();
               baton = null;
            }
         } elif (s.sameType(runStep) && s.str == label) {
            return(true);
         }
      }
      return(false);
   }
   
   run() Runner {
      if (def(baton)) {
         baton.run();
         baton.restart();
         baton = null;
      }
      var iter = self.stepIter;
      while (iter.hasNext) {
         var s = iter.next;
         if (def(handOff) && s.sameType(runStep) && handOff.has(s.str)) {
            baton = handOff.get(s.str);
            baton.output = output;
            baton.swap = swap;
            baton.run();
            baton.restart();
            baton = null;
         } else {
            output.write(s.handle(self));
         }
      }
   }
}


