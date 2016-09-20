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

final class Build:Visit:Pass2(Build:Visit:Visitor) {
   
   begin (transi) {
      super.begin(transi);
      
      fields {
         Int idType = ntypes.ID;
         Int intType = ntypes.INTL;
         Map matchMap = build.constants.matchMap;
         Map rwords = build.constants.rwords;
      }
      
   }

   accept(Build:Node node) Build:Node {
      //"Node is".print();
      //node.className.print();
      if (node.typename == ntypes.TRANSUNIT) {
         return(node.nextDescend);
      }
      any held = node.held;
      if (def(held)) {
         any type = matchMap.get(held);
         if (def(type)) {
            //("Found type " + type.toString()).print();
            node.typename = type;
         } else {
            //"Not found type".print();
            if (held.isInteger()) {
               Node nxp = node.nextPeer;
               if (def(nxp) && def(nxp.held)) {
                  if (nxp.held == ".") {
                     Node nxp2 = nxp.nextPeer;
                     if (def(nxp2) && def(nxp2.held)) {
                        Node nxp3 = nxp2.nextDescend;
                        if (nxp2.held.isInteger()) {
                           node.held = node.held + nxp.held + nxp2.held;
                           node.typename = ntypes.FLOATL;
                           nxp2.delete();
                           nxp.delete();
                           return(nxp3);
                        }
                     }
                  }
               }
               node.typename = intType;
            } else {
               type = rwords.get(held);
               if (def(type)) {
                  node.typename = type;
               } else {
                  node.typename = idType;
               }
            }
         }
      }
      return(node.nextDescend);
   }
   
}
