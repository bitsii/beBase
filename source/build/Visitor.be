// Copyright 2006 Craig Welch
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

use Container:LinkedList;
use Container:Map;
use Text:String;
use Logic:Bool;
use Math:Int;
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

