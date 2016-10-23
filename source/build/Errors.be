// Copyright 2006 Craig Welch
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

use Text:String;

class Build:VisitError(System:Exception) {
   
   new(msgi) self {
      msg = msgi;
   }
   
   new(msgi, nodei) self {
      fields {
         any msg = msgi;
         any node = nodei;
      }
   }
   
   toString() Text:String {
      //any toRet = self.className + " ";//something wrong with self.className
      
      any toRet = "";
      if (def(msg)) {
         toRet = toRet + msg + Text:Strings.new().newline;
      }
      if (def(node)) {
        any nc = node;
        while (def(nc)) {
          toRet += nc;
          toRet += Text:Strings.new().newline;
          nc = nc.container;
        }
      }
      toRet = toRet + getFrameText();
      return(toRet);
   }
}
