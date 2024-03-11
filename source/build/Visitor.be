/*
 * Copyright (c) 2006-2023, the Brace Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

import Container:Map;
import Build:Visit;
import Build:NamePath;
import Build:VisitError;

local class Build:Visit:Visitor {
   
   begin (transi) {
      fields {
         Build:Transport trans = transi;
         Build:Build build = trans.build;
         Build:Constants const = build.constants;
         Build:NodeTypes ntypes = const.ntypes;
      }
   }
      
   accept(Build:Node node) Build:Node {
      return(node.nextDescend);
   }
      
   end(transi) {}
}

