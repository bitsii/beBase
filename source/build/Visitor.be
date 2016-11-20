// Copyright 2006 Craig Welch
//
// Licensed under the MIT license. See LICENSE.txt file in the project root 
// for full license information.

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

