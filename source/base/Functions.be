// Copyright 2006 Craig Welch
//
// Licensed under the MIT license. See LICENSE.txt file in the project root 
// for full license information.

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

  new(_target, String _callName) {
      fields {
          any target = _target;
          auto callName = _callName;
      }
  }

  //use apply(args) to call (by convention)
  final forwardCall(String name, List args) any {
    any result = target.invoke(callName, args);
    return(result);
  }

}

//use final class Function:Callback
