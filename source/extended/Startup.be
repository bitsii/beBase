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
 
use System:Startup;
use System:StartupIfArguments;
use System:StartupWithArguments;
use System:StartupWithParameters;
use System:Parameters;
use Text:String;
use Math:Int;
use Logic:Bool;
use Container:Array;
use Container:LinkedList;
use Container:Set;
use Container:Map;
use IO:File;

class Startup {
   create() { }
   
   default() self {
      
      properties {
        Array args;
      }
   }
   
   main() {
      args = System:Process.new().args;
      if (args.size < 1) {
         throw(System:Exception.new("Insufficient number of arguments, at least one argument required for Startup, the name of the class whose main() method should be called"));
      }
      var x = getInstance(args[0]).new();
      return(x.main());
   }
}

class StartupIfArguments {
   create() { }
   
   default() self {
      
      properties {
        Array args;
      }
   }
   
   main() {
      args = System:Process.new().args;
      if (args.size > 0) {
         var x = getInstance(args[0]).new();
         return(x.main());
      }
      return(self);
   }
}

class StartupWithArguments {
   create() { }
   default() self {
      
      properties {
         Array args;
      }
      
   }
   
   main() {
      args = System:Process.new().args;
      if (args.size < 1) {
         throw(System:Exception.new("Insufficient number of arguments, at least one argument required for Startup, the name of the class whose main(Array args) method should be called"));
      }
      var x = getInstance(args[0]).new();
      return(x.main(args));
   }
}

class StartupWithParameters {
   create() { }
   default() self {
      
      properties {
         Array args;
         Parameters params;
      }
      
   }
   
   main() {
      args = System:Process.new().args;
      if (args.size < 1) {
         throw(System:Exception.new("Insufficient number of arguments, at least one argument required for Startup, the name of the class whose main(Array args, Parameters params) method should be called"));
      }
      params = Parameters.new(args);
      var x = getInstance(args[0]).new();
      return(x.main(args, params));
   }
}

local class Parameters {
   /*Boolean, Parameterized, Ordered (not including Boolean, or Parameterized), Args (as it was)*/
   
   new() self {
   
      properties {
         Array args;
         Map bParams;
         Map params;
         Array ordered;
         Text:Tokenizer fileTok = Text:Tokenizer.new("\r\n");
         var preProcessor;
      }
      
   }
   
   new(Array _args) self {
      self.new();
      addArgs(_args);
   }
   
   addArgs(_args) {
      if (def(preProcessor)) {
         for (Int ii = 0;ii < _args.length;ii = ii++) {
            _args[ii] = preProcessor.process(_args[ii]);
         }
      }
      if (undef(args)) {
         args = _args;
         bParams = Map.new();
         params = Map.new();
         ordered = Array.new();
      } else {
         args = args + _args;
      }
      String pname = null;
      Bool pnameComment = false;
      foreach (String i in _args) {
         String fa = null;
         String fb = null;
         String fc = null;
         if (i.size > 0) {
            fa = i.substring(0, 1);
            if (i.size > 1) {
               fb = i.substring(0, 2);
               if (i.size > 2) {
                  fc = i.substring(0, 3);
               }
            }
         }
         if (def(pname)) {
            if (pnameComment!) {
               addParameter(pname, i);
            }
            pname = null;
            pnameComment = false;
         } elif (def(fb) && fb == "--") {
            pname = i.substring(2, i.size);
         } elif (def(fa) && fa == "-") {
            String par = i.substring(1, i.size);
            Int pos = par.find("=");
            if (def(pos)) {
               String key = par.substring(0, pos);
               String value = par.substring(pos + 1);
               if (def(value) && (value == "true" || value == "false")) {
                  bParams.put(key, Bool.new(value));
               }
               addParameter(key, value);
            } else {
               bParams.put(par, true);
            }
         } elif (def(fc) && fc == "#--") {
            pname = i.substring(3, i.size);
            pnameComment = true;
         } elif ((def(fa) && fa == "#")!) {
            ordered += i;
         }
      }
   }
   
   preProcessorSet(var _preProcessor) {
      preProcessor = _preProcessor;
      if (def(args)) {
         for (Int i = 0;i < args.length;i = i++) {
            args[i] = preProcessor.process(args[i]);
         }
      }
      if (def(ordered)) {
         for (i = 0;i < ordered.length;i = i++) {
            ordered[i] = preProcessor.process(ordered[i]);
         }
      }
      if (def(params)) {
         Map _params = Map.new();
         for (var it = params.keyIterator;it.hasNext;) {
            String key = it.next;
            LinkedList vals = params[key];
            LinkedList _vals = LinkedList.new();
            foreach (String istr in vals) {
               _vals += preProcessor.process(istr);
            }
            key = preProcessor.process(key);
            _params[key] = _vals;
         }
         params = _params;
      }
   }
   
   isTrue(String name, Bool default) Bool {
      Bool res = bParams[name];
      if (def(res)) { return(res); }
      return(default);
   }
   
   isTrue(String name) Bool {
      return(isTrue(name, false));
   }
   
   has(String name) Bool {
      return(params.has(name));
   }
   
   get(String name) LinkedList {
      return(params.get(name));
   }
   
   get(String name, String default) LinkedList {
      LinkedList pl = params.get(name);
      if (undef(pl)) {
         pl = LinkedList.new();
         pl += default;
      }
      return(pl);
   }
   
   getFirst(String name) String {
      return(getFirst(name, null));
   }
   
   getFirst(String name, String default) String {
      LinkedList pl = params.get(name);
      if (undef(pl)) {
         return(default);
      }
      return(pl.first);
   }
   
   addParameter(String name, String value) {
      LinkedList vals = params[name];
      if (undef(vals)) {
         vals = LinkedList.new();
         params.put(name, vals);
      }
      vals += value;
   }
   
   addFile(File file) {
      var fcontents = file.reader.open().readString();
      file.reader.close();
      Array fargs = fileTok.tokenize(fcontents).toArray();
      addArgs(fargs);
   }

}

//Have a more standard params where single - leads to each character being added to map
//with null in value list, -- leads to whole word added with empty string in value list, --this=that
//leads to whole word added with post = in value list?  called Config?

use class System:Startup:MainWithParameters {
   
   main() {
      return(main(Parameters.new(System:Process.args)));
   }
   
   main(Parameters params) {
      //Inherit from this class and override this method to have a main which starts off with params and
      //set that to be main class for the build, or use without override and
      //pass a class name as the first ordered argument on the command line to invoke it with the params
      var x = getInstance(params.ordered[0]).new();
      return(x.main(params));
   }
   
}
