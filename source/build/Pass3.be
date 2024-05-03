/*
 * Copyright (c) 2006-2023, the Bennt Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

use Container:LinkedList;
use Container:Map;
use Build:Visit;
use Build:NamePath;
use Build:VisitError;
use Build:Node;

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
      
      //pullout typename, nextpeer, nextpeer typename
      Int typename = node.typename;
      Node nextPeer = node.nextPeer;
      if (def(nextPeer)) {
        Int nextPeerTypename = nextPeer.typename;
      }
      
      //("!Visiting " + node.toString()).print();
       if ((typename == ntypes.DIVIDE) && (def(nextPeer)) && (nextPeerTypename == ntypes.MULTIPLY) && (inStr!)) {
         //comment begin, can nest
         nestComment++;
         toRet = node.nextPeer.nextDescend;
         node.nextPeer.delayDelete();
         node.delayDelete();
         return(toRet);
       }
       if ((typename == ntypes.MULTIPLY) && (def(nextPeer)) && (nextPeerTypename == ntypes.DIVIDE) && (inStr!)) {
         //comment end, can nest
         nestComment--;
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
       if ((inStr!) && (inLc!) && ((typename == ntypes.STRQ) || typename == ntypes.WSTRQ)) {
         xn = node.nextPeer;
         strqCnt = 1;
         quoteType = node.typename;
         while (def(xn) && xn.typename == quoteType) {
            strqCnt++;
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
            if (typename == ntypes.WSTRQ) {
               //"!!!!!!!!SETTING TO WSTRINGL".print();
               goingStr.typename = ntypes.WSTRINGL;
            } else {
               goingStr.typename = ntypes.STRINGL;
            }
         }
         return(xn);
       }
       if ((inStr) && (inLc!)) {
         if (goingStr.typename == ntypes.STRINGL && typename == ntypes.FSLASH) {
            node.delayDelete();
            xn = node.nextPeer;
            Int fsc = 1;
            while (def(xn) && xn.typename == ntypes.FSLASH) {
               fsc++;
               xn.delayDelete();
               xn = xn.nextPeer;
            }
            for (ia = 0;ia < fsc;ia++) {
               goingStr.held = goingStr.held + node.held;
            }
            if (def(xn) && (fsc % 2 == 1) && (xn.typename == quoteType)) {
               xn.delayDelete();
               goingStr.held = goingStr.held + xn.held;
               xn = xn.nextDescend;
            }
            return(xn);
         } elseIf (typename == quoteType) {
            node.delayDelete();
            xn = node.nextPeer;
            Int csc = 1;
            while (def(xn) && xn.typename == quoteType) {
               csc++;
               xn.delayDelete();
               xn = xn.nextPeer;
            }
            if (csc == strqCnt) {
               goingStr.typeDetail = strqCnt;
               strqCnt = 0;
               goingStr = null;
               inStr = false;
            } else {
               for (Int ia = 0;ia < csc;ia++) {
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
       if ((typename == ntypes.DIVIDE) && (def(nextPeer)) && (nextPeerTypename == ntypes.DIVIDE) && (inStr!)) {
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
       if (typename == ntypes.SUBTRACT && (def(nextPeer)) && (nextPeerTypename == ntypes.INTL)) {
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
       if ((typename == ntypes.ASSIGN) && (def(nextPeer)) && (nextPeerTypename == ntypes.ASSIGN)) {
         node.typename = ntypes.EQUALS;
         node.held = node.held + node.nextPeer.held;
         toRet = node.nextPeer.nextDescend;
         node.nextPeer.delayDelete();
         return(toRet);
       }
       if ((typename == ntypes.NOT) && (def(nextPeer)) && (nextPeerTypename == ntypes.ASSIGN)) {
         node.typename = ntypes.NOT_EQUALS;
         node.held = node.held + node.nextPeer.held;
         toRet = node.nextPeer.nextDescend;
         node.nextPeer.delayDelete();
         return(toRet);
       }
       if (typename == ntypes.OR) {
         if ((def(node.nextPeer)) && (node.nextPeer.typename == ntypes.OR)) {
            node.held = node.held + node.nextPeer.held;
            node.typename = ntypes.LOGICAL_OR;
            toRet = node.nextPeer.nextDescend;
            node.nextPeer.delayDelete();
            return(toRet);
         }
       }
       if (typename == ntypes.AND) {
         if ((def(node.nextPeer)) && (node.nextPeer.typename == ntypes.AND)) {
            node.held = node.held + node.nextPeer.held;
            node.typename = ntypes.LOGICAL_AND;
            toRet = node.nextPeer.nextDescend;
            node.nextPeer.delayDelete();
            return(toRet);
         }
       }
       if ((typename == ntypes.GREATER) && (def(nextPeer)) && (nextPeerTypename == ntypes.ASSIGN)) {
         node.typename = ntypes.GREATER_EQUALS;
         node.held = node.held + node.nextPeer.held;
         toRet = node.nextPeer.nextDescend;
         node.nextPeer.delayDelete();
         return(toRet);
       }
       if ((typename == ntypes.LESSER) && (def(nextPeer)) && (nextPeerTypename == ntypes.ASSIGN)) {
         node.typename = ntypes.LESSER_EQUALS;
         node.held = node.held + node.nextPeer.held;
         toRet = node.nextPeer.nextDescend;
         node.nextPeer.delayDelete();
         return(toRet);
       }
       if ((typename == ntypes.ADD) && (def(nextPeer)) && (nextPeerTypename == ntypes.ADD)) {
         node.typename = ntypes.INCREMENT_ASSIGN;
         node.held = node.held + node.nextPeer.held;
         toRet = node.nextPeer.nextDescend;
         node.nextPeer.delayDelete();
         return(toRet);
       }
       if ((typename == ntypes.SUBTRACT) && (def(nextPeer)) && (nextPeerTypename == ntypes.SUBTRACT)) {
         node.typename = ntypes.DECREMENT_ASSIGN;
         node.held = node.held + node.nextPeer.held;
         toRet = node.nextPeer.nextDescend;
         node.nextPeer.delayDelete();
         return(toRet);
       }
       if ((typename == ntypes.ADD) && (def(nextPeer)) && (nextPeerTypename == ntypes.ASSIGN)) {
         node.typename = ntypes.ADD_ASSIGN;
         node.held = node.held + node.nextPeer.held;
         toRet = node.nextPeer.nextDescend;
         node.nextPeer.delayDelete();
         return(toRet);
       }
       if ((typename == ntypes.SUBTRACT) && (def(nextPeer)) && (nextPeerTypename == ntypes.ASSIGN)) {
         node.typename = ntypes.SUBTRACT_ASSIGN;
         node.held = node.held + node.nextPeer.held;
         toRet = node.nextPeer.nextDescend;
         node.nextPeer.delayDelete();
         return(toRet);
       }
       if ((typename == ntypes.MULTIPLY) && (def(nextPeer)) && (nextPeerTypename == ntypes.ASSIGN)) {
         node.typename = ntypes.MULTIPLY_ASSIGN;
         node.held = node.held + node.nextPeer.held;
         toRet = node.nextPeer.nextDescend;
         node.nextPeer.delayDelete();
         return(toRet);
       }
       if ((typename == ntypes.DIVIDE) && (def(nextPeer)) && (nextPeerTypename == ntypes.ASSIGN)) {
         node.typename = ntypes.DIVIDE_ASSIGN;
         node.held = node.held + node.nextPeer.held;
         toRet = node.nextPeer.nextDescend;
         node.nextPeer.delayDelete();
         return(toRet);
       }
       if ((typename == ntypes.MODULUS) && (def(nextPeer)) && (nextPeerTypename == ntypes.ASSIGN)) {
         node.typename = ntypes.MODULUS_ASSIGN;
         node.held = node.held + node.nextPeer.held;
         toRet = node.nextPeer.nextDescend;
         node.nextPeer.delayDelete();
         return(toRet);
       }
       if ((typename == ntypes.AND) && (def(nextPeer)) && (nextPeerTypename == ntypes.ASSIGN)) {
         node.typename = ntypes.AND_ASSIGN;
         node.held = node.held + node.nextPeer.held;
         toRet = node.nextPeer.nextDescend;
         node.nextPeer.delayDelete();
         return(toRet);
       }
       if ((typename == ntypes.OR) && (def(nextPeer)) && (nextPeerTypename == ntypes.ASSIGN)) {
         node.typename = ntypes.OR_ASSIGN;
         node.held = node.held + node.nextPeer.held;
         toRet = node.nextPeer.nextDescend;
         node.nextPeer.delayDelete();
         return(toRet);
       }
       if (typename == ntypes.SPACE || typename == ntypes.NEWLINE) {
         toRet = node.nextDescend;
         node.delayDelete();
         return(toRet);
       }
       return(node.nextDescend);
   }
   
}




