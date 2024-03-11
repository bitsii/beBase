/*
 * Copyright (c) 2006-2023, the Brace Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

import Text:String;

class Build:VisitError(System:Exception) {
   
   new(msgi) self {
      msg = msgi;
   }
   
   new(msgi, nodei) self {
      fields {
         dyn msg = msgi;
         dyn node = nodei;
      }
   }
   
   toString() Text:String {
      
      dyn toRet = "";
      if (def(msg)) {
         toRet = toRet + msg + Text:Strings.new().newline;
      }
      if (def(node)) {
        dyn nc = node;
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
