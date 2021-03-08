// Copyright 2006 The Abelii Authors. All rights reserved.
// Use of this source code is governed by the BSD-3-Clause
// license that can be found in the LICENSE file.

use Container:Map;
use Build:Visit;
use Build:NamePath;
use Build:VisitError;

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

