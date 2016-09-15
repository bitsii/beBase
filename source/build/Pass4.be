// Copyright 2006 Craig Welch
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

use Container:LinkedList;
use Container:Map;
use Build:Visit;
use Build:NamePath;
use Build:VisitError;
use Build:Node;

final class Build:Visit:Pass4(Build:Visit:Visitor) {
   
   begin (transi) {
      super.begin(transi);
   }
   
   accept(Build:Node node) Build:Node {
      Node nnode = node.nextPeer;
      while ((node.typename == ntypes.ID) && def(nnode) && (nnode.typename == ntypes.COLON)) {
         if (undef(String nps)) {
            nps = Text:String.new();
         }
         nps = nps + node.held + nnode.held;
         Node nxn = nnode.nextPeer;
         if (undef(nxn) || (nxn.typename != ntypes.ID)) {
            throw(VisitError.new("Incomplete namepath", node));
         }
         Node nxnn = nxn.nextPeer;
         if (def(first)) {
            node.delete();
         } else {
            Node first = node;
         }
         nnode.delete();
         node = nxn;
         nnode = nxnn;
      }
      if (def(first)) {
         first.typename = ntypes.NAMEPATH;
         Build:NamePath np = Build:NamePath.new();
         if (def(node) && (node.typename == ntypes.ID)) {
            nps = nps + node.held;
            node.delete();
         }
         np.fromString(nps);
         first.held = np;
         return(first.nextDescend);
      }
      return(node.nextDescend);
   }
}

