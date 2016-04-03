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
use Math:Int;
use Build:Visit;
use Build:NamePath;
use Build:VisitError;
use Build:Node;
use Logic:Bool;

final class Build:Visit:Pass3(Build:Visit:Visitor) {

   //COMBINE
   
   begin (transi) {
      super.begin(transi);
      
      fields {
         //current holder
         Node container; 
         //int nexted comment depth
         Int nestComment = 0;
         //int strq repeats
         Int strqCnt = 0;
         
         //buffers for multiple space, newline, and string
         Node goingStr;
         
         //What kind of quote started me off if I am in a string
         Int quoteType;
         
         //boolean states
         Bool inLc = false; //in line comment
         Bool inSpace = false; //in space set
         Bool inNl = false; //in new line
         Bool inStr = false; //in string set
      }
   }

   accept(Build:Node node) Build:Node {
      Node toRet;
      Node xn;
      //("!Visiting " + node.toString()).print();
       if ((node.typename == ntypes.DIVIDE) && (def(node.nextPeer)) && (node.nextPeer.typename == ntypes.MULTIPLY) && (inStr!)) {
         //comment begin, can nest
         nestComment = nestComment++;
         toRet = node.nextPeer.nextDescend;
         node.nextPeer.delayDelete();
         node.delayDelete();
         return(toRet);
       }
       if ((node.typename == ntypes.MULTIPLY) && (def(node.nextPeer)) && (node.nextPeer.typename == ntypes.DIVIDE) && (inStr!)) {
         //comment end, can nest
         nestComment = nestComment--;
         toRet = node.nextPeer.nextDescend;
         node.nextPeer.delayDelete();
         node.delayDelete();
         return(toRet);
       }
       if (nestComment > 0) {
         toRet = node.nextDescend;
         node.delayDelete();
         return(toRet);
       }
       if ((inStr!) && (inLc!) && ((node.typename == ntypes.STRQ) || node.typename == ntypes.WSTRQ)) {
         xn = node.nextPeer;
         strqCnt = 1;
         quoteType = node.typename;
         while (def(xn) && xn.typename == quoteType) {
            strqCnt = strqCnt++;
            xn.delayDelete();
            xn = xn.nextPeer;
         }
         if (strqCnt == 2) {
            strqCnt = 0;
            node.held = Text:String.new();
            node.typename = ntypes.STRINGL;
            node.typeDetail = 1;
         } else {
            inStr = true;
            goingStr = node;
            node.held = Text:String.new();
            if (node.typename == ntypes.WSTRQ) {
               //"!!!!!!!!SETTING TO WSTRINGL".print();
               goingStr.typename = ntypes.WSTRINGL;
            } else {
               goingStr.typename = ntypes.STRINGL;
            }
         }
         return(xn);
       }
       if ((inStr) && (inLc!)) {
         if (goingStr.typename == ntypes.STRINGL && node.typename == ntypes.FSLASH) {
            node.delayDelete();
            xn = node.nextPeer;
            Int fsc = 1;
            while (def(xn) && xn.typename == ntypes.FSLASH) {
               fsc = fsc++;
               xn.delayDelete();
               xn = xn.nextPeer;
            }
            for (ia = 0;ia < fsc;ia = ia++) {
               goingStr.held = goingStr.held + node.held;
            }
            if (def(xn) && (fsc % 2 == 1) && (xn.typename == quoteType)) {
               xn.delayDelete();
               goingStr.held = goingStr.held + xn.held;
               xn = xn.nextDescend;
            }
            return(xn);
         } elif (node.typename == quoteType) {
            node.delayDelete();
            xn = node.nextPeer;
            var csc = 1;
            while (def(xn) && xn.typename == quoteType) {
               csc = csc++;
               xn.delayDelete();
               xn = xn.nextPeer;
            }
            if (csc == strqCnt) {
               goingStr.typeDetail = strqCnt;
               strqCnt = 0;
               goingStr = null;
               inStr = false;
            } else {
               for (var ia = 0;ia < csc;ia = ia++) {
                  goingStr.held = goingStr.held + node.held;
               }
            }
            return(xn);
          } else {
            goingStr.held = goingStr.held + node.held;
            toRet = node.nextDescend;
            node.delayDelete();
            return(toRet);
          }
       }
       if ((node.typename == ntypes.DIVIDE) && (def(node.nextPeer)) && (node.nextPeer.typename == ntypes.DIVIDE) && (inStr!)) {
         toRet = node.nextPeer.nextDescend;
         inLc = true;
         node.nextPeer.delayDelete();
         node.delayDelete();
         return(toRet);
       }
       if (inLc) {
         toRet = node.nextDescend;
         node.delayDelete();
         if (toRet.typename == ntypes.NEWLINE) {
            inLc = false;
            toRet.delayDelete();
            toRet = toRet.nextDescend;
         }
         return(toRet);
       }
       if (node.typename == ntypes.SUBTRACT && (def(node.nextPeer)) && (node.nextPeer.typename == ntypes.INTL)) {
         if (def(node.priorPeer)) {
            Node vback = node.priorPeer;
            while (def(vback) && vback.typename == ntypes.SPACE) {
                vback = vback.priorPeer;
            }
            Node pre = vback;
          }
          //if (def(pre)) { pre.typename.print(); }
          if (undef(pre) || pre.typename == ntypes.COMMA || pre.typename == ntypes.PARENS || const.oper.has(pre.typename)) {
            //("FoundNeg -" + node.nextPeer.held).print();
            //throw(VisitError.new("Found Neg -" + node.nextPeer.held));
            node.nextPeer.held = "-" + node.nextPeer.held;
            toRet = node.nextDescend;
            node.delayDelete();
            return(toRet);
          }
       }
       if ((node.typename == ntypes.ASSIGN) && (def(node.nextPeer)) && (node.nextPeer.typename == ntypes.ASSIGN)) {
         node.typename = ntypes.EQUALS;
         node.held = node.held + node.nextPeer.held;
         toRet = node.nextPeer.nextDescend;
         node.nextPeer.delayDelete();
         return(toRet);
       }
       if ((node.typename == ntypes.ASSIGN) && (def(node.nextPeer)) && (node.nextPeer.typename == ntypes.ONCE || node.nextPeer.typename == ntypes.MANY)) {
         //concatenates the text of node.held into =@ (or =#), which is later used to see that it was a "once" (or a many :-)
         node.held = node.held + node.nextPeer.held;
         toRet = node.nextPeer.nextDescend;
         node.nextPeer.delayDelete();
         return(toRet);
       }
       if ((node.typename == ntypes.NOT) && (def(node.nextPeer)) && (node.nextPeer.typename == ntypes.ASSIGN)) {
         node.typename = ntypes.NOT_EQUALS;
         node.held = node.held + node.nextPeer.held;
         toRet = node.nextPeer.nextDescend;
         node.nextPeer.delayDelete();
         return(toRet);
       }
       if (node.typename == ntypes.OR) {
         if ((def(node.nextPeer)) && (node.nextPeer.typename == ntypes.OR)) {
            node.held = node.held + node.nextPeer.held;
            node.typename = ntypes.LOGICAL_OR;
            toRet = node.nextPeer.nextDescend;
            node.nextPeer.delayDelete();
            return(toRet);
         }
       }
       if (node.typename == ntypes.AND) {
         if ((def(node.nextPeer)) && (node.nextPeer.typename == ntypes.AND)) {
            node.held = node.held + node.nextPeer.held;
            node.typename = ntypes.LOGICAL_AND;
            toRet = node.nextPeer.nextDescend;
            node.nextPeer.delayDelete();
            return(toRet);
         }
       }
       if ((node.typename == ntypes.GREATER) && (def(node.nextPeer)) && (node.nextPeer.typename == ntypes.ASSIGN)) {
         node.typename = ntypes.GREATER_EQUALS;
         node.held = node.held + node.nextPeer.held;
         toRet = node.nextPeer.nextDescend;
         node.nextPeer.delayDelete();
         return(toRet);
       }
       if ((node.typename == ntypes.LESSER) && (def(node.nextPeer)) && (node.nextPeer.typename == ntypes.ASSIGN)) {
         node.typename = ntypes.LESSER_EQUALS;
         node.held = node.held + node.nextPeer.held;
         toRet = node.nextPeer.nextDescend;
         node.nextPeer.delayDelete();
         return(toRet);
       }
       if ((node.typename == ntypes.ADD) && (def(node.nextPeer)) && (node.nextPeer.typename == ntypes.ADD)) {
         if ((def(node.nextPeer.nextPeer)) && (node.nextPeer.nextPeer.typename == ntypes.ASSIGN)) {
            node.typename = ntypes.INCREMENT_ASSIGN;
            node.held = node.held + node.nextPeer.held + node.nextPeer.nextPeer.held;
            toRet = node.nextPeer.nextPeer.nextDescend;
            node.nextPeer.delayDelete();
            node.nextPeer.nextPeer.delayDelete();
            return(toRet);
         }
         node.typename = ntypes.INCREMENT;
         node.held = node.held + node.nextPeer.held;
         toRet = node.nextPeer.nextDescend;
         node.nextPeer.delayDelete();
         return(toRet);
       }
       if ((node.typename == ntypes.SUBTRACT) && (def(node.nextPeer)) && (node.nextPeer.typename == ntypes.SUBTRACT)) {
         if ((def(node.nextPeer.nextPeer)) && (node.nextPeer.nextPeer.typename == ntypes.ASSIGN)) {
            node.typename = ntypes.DECREMENT_ASSIGN;
            node.held = node.held + node.nextPeer.held + node.nextPeer.nextPeer.held;
            toRet = node.nextPeer.nextPeer.nextDescend;
            node.nextPeer.delayDelete();
            node.nextPeer.nextPeer.delayDelete();
            return(toRet);
         }
         node.typename = ntypes.DECREMENT;
         node.held = node.held + node.nextPeer.held;
         toRet = node.nextPeer.nextDescend;
         node.nextPeer.delayDelete();
         return(toRet);
       }
       if ((node.typename == ntypes.ADD) && (def(node.nextPeer)) && (node.nextPeer.typename == ntypes.ASSIGN)) {
         node.typename = ntypes.ADD_ASSIGN;
         node.held = node.held + node.nextPeer.held;
         toRet = node.nextPeer.nextDescend;
         node.nextPeer.delayDelete();
         return(toRet);
       }
       if ((node.typename == ntypes.SUBTRACT) && (def(node.nextPeer)) && (node.nextPeer.typename == ntypes.ASSIGN)) {
         node.typename = ntypes.SUBTRACT_ASSIGN;
         node.held = node.held + node.nextPeer.held;
         toRet = node.nextPeer.nextDescend;
         node.nextPeer.delayDelete();
         return(toRet);
       }
       if ((node.typename == ntypes.MULTIPLY) && (def(node.nextPeer)) && (node.nextPeer.typename == ntypes.ASSIGN)) {
         node.typename = ntypes.MULTIPLY_ASSIGN;
         node.held = node.held + node.nextPeer.held;
         toRet = node.nextPeer.nextDescend;
         node.nextPeer.delayDelete();
         return(toRet);
       }
       if ((node.typename == ntypes.DIVIDE) && (def(node.nextPeer)) && (node.nextPeer.typename == ntypes.ASSIGN)) {
         node.typename = ntypes.DIVIDE_ASSIGN;
         node.held = node.held + node.nextPeer.held;
         toRet = node.nextPeer.nextDescend;
         node.nextPeer.delayDelete();
         return(toRet);
       }
       if ((node.typename == ntypes.MODULUS) && (def(node.nextPeer)) && (node.nextPeer.typename == ntypes.ASSIGN)) {
         node.typename = ntypes.MODULUS_ASSIGN;
         node.held = node.held + node.nextPeer.held;
         toRet = node.nextPeer.nextDescend;
         node.nextPeer.delayDelete();
         return(toRet);
       }
       if ((node.typename == ntypes.AND) && (def(node.nextPeer)) && (node.nextPeer.typename == ntypes.ASSIGN)) {
         node.typename = ntypes.AND_ASSIGN;
         node.held = node.held + node.nextPeer.held;
         toRet = node.nextPeer.nextDescend;
         node.nextPeer.delayDelete();
         return(toRet);
       }
       if ((node.typename == ntypes.OR) && (def(node.nextPeer)) && (node.nextPeer.typename == ntypes.ASSIGN)) {
         node.typename = ntypes.OR_ASSIGN;
         node.held = node.held + node.nextPeer.held;
         toRet = node.nextPeer.nextDescend;
         node.nextPeer.delayDelete();
         return(toRet);
       }
       if (node.typename == ntypes.SPACE || node.typename == ntypes.NEWLINE) {
         toRet = node.nextDescend;
         node.delayDelete();
         return(toRet);
       }
       return(node.nextDescend);
   }
   
}




