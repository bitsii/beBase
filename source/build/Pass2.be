/*
Copyright 2006 Craig Welch
All rights reserved.

Developed by:

    Craig Welch

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal with
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

    * Redistributions of source code must retain the above copyright notice,
      this list of conditions and the following disclaimers.

    * Redistributions in binary form must reproduce the above copyright notice,
      this list of conditions and the following disclaimers in the
      documentation and/or other materials provided with the distribution.

    * Neither the name of the Software nor the names of its contributors may be used 
      to endorse or promote products derived from this Software without specific
      prior written permission.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
CONTRIBUTORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS WITH THE
SOFTWARE.
*/

use Container:LinkedList;
use Container:Map;
use Text:String;
use Math:Int;
use Build:Visit;
use Build:NamePath;
use Build:VisitError;
use Build:Node;

final class Visit:Pass2(Visit:Visitor) {
   
   begin (transi) {
      super.begin(transi);
      
      properties {
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
      var held = node.held;
      if (def(held)) {
         var type = matchMap.get(held);
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
