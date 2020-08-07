// Copyright 2006 The Brace Authors. All rights reserved.
// Use of this source code is governed by the BSD-3-Clause
// license that can be found in the LICENSE file.

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

  new(_target, String _callName, Int _ac) {
      fields {
          any target = _target;
          auto callName = _callName;
          auto ac = _ac;
          //("new method " + _callName + " " + _ac).print();
      }
  }

  //use apply(args) to call (by convention)
  forwardCall(String name, List args) any {
    //"in fc".print();
    //("fc name " + callName + " fc args " + args.size).print();
    any result = target.invoke(callName, args);
    return(result);
  }

}

class System:Invocation {

  new(_target, String _callName, List _args) {
      fields {
          any target = _target;
          auto callName = _callName;
          auto args = _args;
      }
  }

  invoke() any {
    any result = target.invoke(callName, args);
    return(result);
  }
  
  main() any {
    any result = target.invoke(callName, args);
    return(result);
  }

}

//use final class Function:Callback
