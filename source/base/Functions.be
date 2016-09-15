// Copyright 2006 Craig Welch
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

use Container:Array;
use Container:Map;

use System:Exception;

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
            var target = _target;
            String callName = _callName;
            Array args = Array.new(1);
        }
    }
    
    map(val) {
        args[0] = val;
        return(target.invoke(callName, args));
    }

}

//use final class Function:Callback
