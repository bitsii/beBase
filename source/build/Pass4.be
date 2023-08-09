// Copyright 2006 The Bennt Authors. All rights reserved.
// Use of this source code is governed by the BSD-3-Clause
// license that can be found in the LICENSE file.

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

