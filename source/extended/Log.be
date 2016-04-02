// Copyright 2006 Craig Welch
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

use IO:Log as L;

use Math:Int;
use Text:String;

class L {

  default() self {
    properties {
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
      if (def(msg)) {
        msg.print();
      } else {
        "null".print();
      }
    }
  }

}
