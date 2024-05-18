/*
 * Copyright (c) 2006-2023, the Beysant Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

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
