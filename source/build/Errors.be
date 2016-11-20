// Copyright 2006 Craig Welch
//
// Licensed under the MIT license. See LICENSE.txt file in the project root 
// for full license information.

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
