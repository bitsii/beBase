/*
 * Copyright (c) 2006-2023, the Brace Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

import System:Startup;
import System:StartupIfArguments;
import System:StartupWithArguments;
import System:StartupWithParameters;
import System:Parameters;
import Text:String;
import Math:Int;
import Logic:Bool;
import Container:List;
import Container:LinkedList;
import Container:Set;
import Container:Map;
import IO:File;

class Startup {
   create() self { }
   
   default() self {
      
      fields {
        List args;
      }
   }
   
   main() {
      args = System:Process.new().args;
      if (args.size < 1) {
         throw(System:Exception.new("Insufficient number of arguments, at least one argument required for Startup, the name of the class whose main() method should be called"));
      }
      dyn x = System:Objects.createInstance(args[0]).new();
      return(x.main());
   }
}

class StartupIfArguments {
   create() self { }
   
   default() self {
      
      fields {
        List args;
      }
   }
   
   main() {
      args = System:Process.new().args;
      if (args.size > 0) {
         dyn x = System:Objects.createInstance(args[0]).new();
         return(x.main());
      }
      return(self);
   }
}

class StartupWithArguments {
   create() self { }
   default() self {
      
      fields {
         List args;
      }
      
   }
   
   main() {
      args = System:Process.new().args;
      if (args.size < 1) {
         throw(System:Exception.new("Insufficient number of arguments, at least one argument required for Startup, the name of the class whose main(List args) method should be called"));
      }
      dyn x = System:Objects.createInstance(args[0]).new();
      return(x.main(args));
   }
}

class StartupWithParameters {
   create() self { }
   default() self {
      
      fields {
         List args;
         Parameters params;
      }
      
   }
   
   main() {
      args = System:Process.new().args;
      if (args.size < 1) {
         throw(System:Exception.new("Insufficient number of arguments, at least one argument required for Startup, the name of the class whose main(List args, Parameters params) method should be called"));
      }
      params = Parameters.new(args);
      dyn x = System:Objects.createInstance(args[0]).new();
      return(x.main(args, params));
   }
}

local class Parameters {
   /*Boolean, Parameterized, Ordered (not including Boolean, or Parameterized), Args (as it was)*/
   
   new() self {
   
      fields {
         List initialArgs = List.new();
         List args = List.new();
         Map params = Map.new();
         List ordered = List.new();
         Text:Tokenizer fileTok = Text:Tokenizer.new("\r\n");
         dyn preProcessor;
      }
      
   }
   
   toJson() String {
     Map jsm = Maps.from("args", args, "params", params, "ordered", ordered);
     return(Json:Marshaller.marshall(jsm));
   }
   
   fromJson(String jsms) self {
     Map jsm = Json:Unmarshaller.unmarshall(jsms);
     args = jsm["args"];
     params = jsm["params"];
     ordered = jsm["ordered"];
   }
   
   fromJsonFile(File jsf) self {
     fromJson(jsf.reader.open().readStringClose());
   }
   
   toJsonFile(File jsf) self {
     jsf.writer.open().writeStringClose(toJson());
   }
   
   addValue(Parameters p) self {
     args += p.args;
     ordered += p.ordered;
     for (var kv in p.params) {
       LinkedList cp = params.get(kv.key);
       if (def(cp)) {
        cp += kv.value;
       } else {
        params.put(kv.key, kv.value);
       }
     }
   }
   
   new(List _args) self {
      self.new();
      initialArgs = _args;
      addArgs(_args);
   }
   
   addArgs(_args) {
      if (def(preProcessor)) {
         for (Int ii = 0;ii < _args.length;ii = ii++) {
            _args[ii] = preProcessor.process(_args[ii]);
         }
      }
      args = args + _args;
      String pname = null;
      Bool pnameComment = false;
      for (String i in _args) {
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
         } elseIf (def(fb) && fb == "--") {
            pname = i.substring(2, i.size);
         } elseIf (def(fa) && fa == "-") {
            String par = i.substring(1, i.size);
            Int pos = par.find("=");
            if (def(pos)) {
               String key = par.substring(0, pos);
               String value = par.substring(pos + 1);
               addParameter(key, value);
            }
         } elseIf (def(fc) && fc == "#--") {
            pname = i.substring(3, i.size);
            pnameComment = true;
         } elseIf ((def(fa) && fa == "#")!) {
            ordered += i;
         }
      }
   }
   
   preProcessorSet(dyn _preProcessor) {
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
         for (dyn it = params.keyIterator;it.hasNext;) {
            String key = it.next;
            LinkedList vals = params[key];
            LinkedList _vals = LinkedList.new();
            for (String istr in vals) {
               _vals += preProcessor.process(istr);
            }
            key = preProcessor.process(key);
            _params[key] = _vals;
         }
         params = _params;
      }
   }
   
   isTrue(String name, Bool isit) Bool {
      String res = getFirst(name);
      if (def(res)) {
        //("!!!! IS TRUE GOT " + res).print();
        isit = Bool.new(res);
      }
      //("!!!IS TRUE ISIT " + isit).print();
      return(isit);
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
     addParam(name, value);
   }
   
   addParam(String name, String value) {
      //("ADDING " + name + " " + value).print();
      LinkedList vals = params[name];
      if (undef(vals)) {
         vals = LinkedList.new();
         params.put(name, vals);
      }
      vals += value;
      //("add done").print();
   }
   
   addFile(File file) {
      dyn fcontents = file.reader.open().readString();
      file.reader.close();
      List fargs = fileTok.tokenize(fcontents).toList();
      addArgs(fargs);
   }
   
   iteratorGet() {
     return(params.iterator);
   }

}

//Have a more standard params where single - leads to each character being added to map
//with null in value list, -- leads to whole word added with empty string in value list, --this=that
//leads to whole word added with post = in value list?  called Config?

import class System:Startup:MainWithParameters {
   
   main() {
      return(main(Parameters.new(System:Process.args)));
   }
   
   main(Parameters params) {
      //Inherit from this class and override this method to have a main which starts off with params and
      //set that to be main class for the build, or import without override and
      //pass a class name as the first ordered argument on the command line to invoke it with the params
      dyn x = System:Objects.createInstance(params.ordered[0]).new();
      return(x.main(params));
   }
   
}
