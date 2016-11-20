// Copyright 2006 Craig Welch
//
// Licensed under the MIT license. See LICENSE.txt file in the project root 
// for full license information.

use final class Function:Mapper {

    create() self { }
   
   default() self {
      
   }

   mapCopy(input, action) {
     return(map(input.copy(), action));
   }
   
   map(input, action) {
     mapIterator(input.iterator, action);
     return(input);
   }
   
   mapIterator(iter, action) {
      while (iter.hasNext) {
         iter.current = action.map(iter.next);
      }
   }
   
}


use final class Function:MapProxy {

    new(_target, _callName) {
        fields {
            any target = _target;
            String callName = _callName;
            List args = List.new(1);
        }
    }
    
    map(val) {
        args[0] = val;
        return(target.invoke(callName, args));
    }

}

//use final class Function:Callback
