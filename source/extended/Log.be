// Copyright 2006 Craig Welch
//
// Licensed under the MIT license. See LICENSE.txt file in the project root 
// for full license information.

use IO:Log as L;

use Math:Int;
use Text:String;

class L {

  default() self {
    fields {
      Int debug = 400;
      Int info = 300;
      Int warn = 200;
      Int error = 100;
      Int fatal = 0;
      Int level = fatal;
    }
  }
  
  will(Int _level) Logic:Bool {
    if (_level <= level) {
      return(true);
    }
    return(false);
  }
  
  log(Int _level, String msg) {
    if (_level <= level) {
      log(msg);
    }
  }
  
  log(String msg) {
    if (def(msg)) {
      msg.print();
    } else {
      "null".print();
    }
  }

}
