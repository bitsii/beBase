/*
 * Copyright (c) 2006-2023, the Brace Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

use Math:Int;
use Container:List;
use Container:LinkedList;
use Container:Map;
use Text:String;
use Text:String;
use Logic:Bool;
use Template:Replace;

class Replace:CallStep {
   
   new(LinkedList payloads) self {
      
      fields {
        String callName = payloads[0];
        List callArgs = List.new(payloads.length - 1);
      }
   
      for (Int pi = 1;pi < payloads.length;pi++) {
         callArgs[pi - 1] = payloads[pi];
      }
      
   }
   
   handle(r) String {
      return(r.invoke(callName, callArgs));
   }
   
}

class Replace:StringStep {
   
   new(String _str) self {
      
      fields {
         String str = _str;
      }
      
   }
   
   handle(r) String {
      return(str);
   }
   
}

class Replace {
   
   new() self {
      
      fields {
         LinkedList steps;
         Int length;
         Bool append = true;
         Runner runner;
      }
      
   }
   
   load(String template) Replace {
      load(template, null);
   }
   
   load(String template, Runner _runner) Replace {
      runner = _runner;
      length = template.length;
      
      String blStart = "<?tt";
      String blEnd = "?>";
      Bool onStart = true;
      Bool nextIsCall = false;
      
      String delim = blStart;
      Container:LinkedList splits = Container:LinkedList.new();
      Int last = 0;
      Int i = template.find(delim, last);
      Int ds = delim.length;
      while (def(i)) {
            if (i > last) {
               if (nextIsCall) {
                  String payload = template.substring(last, i).strip();
                  LinkedList payloads = Text:Tokenizer.new(" ").tokenize(payload);
                  if (undef(runner)) {
                     // Call based
                    Replace:CallStep rcs = Replace:CallStep.new(payloads);
                    splits.addValue(rcs);
                    nextIsCall = false;
                  } else {
                     // Build the runner
                     for (String paypart in payloads) {
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
               ds = delim.length;
               nextIsCall = true;
            } else {
               onStart = true;
               delim = blStart;
               ds = delim.length;
            }
            i = template.find(delim, last);
      }
      if (last < length) {
         splits.addValue(Replace:StringStep.new(template.substring(last, length)));
      }
      steps = splits;
   }
   
   accept(any inst, any out) {
      any iter = steps.iterator;
      while (iter.hasNext) {
         any s = iter.next;
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
      
      fields {
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
      fields {
         Replace replace;
         any output;
         any stepIter;
         Map swap;
         Map handOff;
         Runner baton;
         Replace:RunStep runStep = Replace:RunStep.new();
         System:Types stp = System:Types.new();
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
   
   new(String template, any _output) self {
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
      any iter = self.stepIter;
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
      any iter = self.stepIter;
      while (iter.hasNext) {
         any s = iter.next;
         if (def(handOff) && stp.sameType(s, runStep) && handOff.contains(s.str)) {
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
         } elseIf (stp.sameType(s, runStep) && s.str == label) {
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
      any iter = self.stepIter;
      while (iter.hasNext) {
         any s = iter.next;
         if (def(handOff) && stp.sameType(s, runStep) && handOff.contains(s.str)) {
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
         } elseIf (stp.sameType(s, runStep) && s.str == label) {
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
      any iter = self.stepIter;
      while (iter.hasNext) {
         any s = iter.next;
         if (def(handOff) && stp.sameType(s, runStep) && handOff.contains(s.str)) {
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


