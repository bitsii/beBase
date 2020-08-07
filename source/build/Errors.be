// Copyright 2006 The Brace Authors. All rights reserved.
// Use of this source code is governed by the BSD-3-Clause
// license that can be found in the LICENSE file.

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
