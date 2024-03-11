/*
 * Copyright (c) 2006-2023, the Brace Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

use final class Function:Mapper {

    create() self { }
   
   default() self {
      
   }

   mapCopy(input, System:Method action) {
     return(map(input.copy(), action));
   }
   
   map(input, action) {
     mapIterator(input.iterator, action);
     return(input);
   }
   
   mapIterator(iter, System:Method action) {
      while (iter.hasNext) {
         iter.current = action.apply(iter.next);
      }
   }
   
}

//System:Method, use call forward as apply, args are passed to apply

class System:Method {

  new(_target, String nameac) self {
    Int cd = nameac.rfind("_");
    String name = nameac.substring(0, cd);
    Int _ac = Int.new(nameac.substring(cd + 1));
    return(new(_target, name, _ac));
  }
  
  new(_target, String _callName, Int _ac) {
      fields {
          dyn target = _target;
          var callName = _callName;
          var ac = _ac;
          //("new method " + _callName + " " + _ac).print();
      }
  }

  //use apply(args) to call (by convention)
  forwardCall(String name, List args) dyn {
    //"in fc".print();
    //("fc name " + callName + " fc args " + args.size).print();
    dyn result = target.invoke(callName, args);
    return(result);
  }

}

class System:Invocation {

  new(_target, String _callName, List _args) {
      fields {
          dyn target = _target;
          var callName = _callName;
          var args = _args;
      }
  }

  invoke() dyn {
    dyn result = target.invoke(callName, args);
    return(result);
  }
  
  main() dyn {
    dyn result = target.invoke(callName, args);
    return(result);
  }

}

//use final class Function:Callback
