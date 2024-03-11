/*
 * Copyright (c) 2006-2023, the Brace Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

use Container:LinkedList:Iterator as LIter;

use class System:ExceptionTranslator {
  
  default() self { }
  
  translateEmittedException(Exception tt) {
    try {
      translateEmittedExceptionInner(tt);
    } catch(dyn e) {
      ("Exception translation failed").print();
      if (def(e) && e.can("getDescription", 0)) {
        e.description.print();
        //try { e.print(); } catch (dyn ee) { }
      }
    }
  }

  translateEmittedExceptionInner(Exception tt) {
    if (def(tt.translated) && tt.translated) {
      return(self);
    }
    if (undef(tt.vv)) {
      tt.vv = false;
    }
    tt.translated = true;
    if (def(tt.framesText) && def(tt.lang) && (tt.lang == "cs" || tt.lang == "js")) {
       TT ltok = TT.new("\r\n");
       LinkedList lines = ltok.tokenize(tt.framesText);
       if (tt.lang == "cs") {
           Bool isCs = true;
       } else {
           isCs = false;
       }
       for (String line in lines) {
         if (tt.vv) {
           ("Frame line is " + line).print();
         }
           Int start = line.find("at ");
           String efile = null;
           Int eline = null;
           if (def(start) && start >= 0) {
             if (tt.vv) {
               ("start is " + start).print();
             }
               Int end = line.find(" ", start + 3);
               if (def(end) && end > start) {
                 if (tt.vv) {
                   ("end is " + end).print();
                 }
                   String callPart = line.substring(start + 3, end);
                   //for cs, this is the one which has emit file and line
                   if (isCs) {
                       start = line.find("in", end);
                       if (def(start)) {
                         //("in start def").print();
                         String inPart = line.substring(start + 3);
                         if (inPart.ends(" ")) {
                           inPart.size = inPart.size - 1;
                         }
                         //("in part |" + inPart + "|").print();
                         Int pdelim = inPart.rfind(":");
                         if (def(pdelim)) {
                           efile = inPart.substring(0, pdelim);
                           //("efile " + efile).print();
                           String iv = inPart.substring(pdelim + 1);
                           if (iv.begins("line ")) {
                               iv = iv.substring(5);
                           }
                           //("iv is |" + iv + "|").print();
                           if (iv.isInteger) {
                             eline = Int.new(iv);
                           }
                         }
                       }
                   }  else {
                       start = line.find("(", end);//)
                       if (def(start)) {
                         if (tt.vv) {
                         ("in js start def").print();
                         }
                         //(
                         end = line.find(")", start + 1);
                         if (def(end)) {
                           if (tt.vv) {
                           ("in js end def").print();
                           }
                           inPart = line.substring(start + 1, end);
                           //("js in part |" + inPart + "|").print();
                           pdelim = inPart.rfind(":"); //drop pos in line
                           if (def(pdelim)) {
                             inPart = inPart.substring(0, pdelim);
                             //("efile " + efile).print();
                             pdelim = inPart.rfind(":");
                             if (def(pdelim)) {
                               efile = inPart.substring(0, pdelim);
                             }
                             iv = inPart.substring(pdelim + 1);
                             //("iv is |" + iv + "|").print();
                             if (iv.isInteger) {
                               eline = Int.new(iv);
                             }
                           }
                         }
                       }
                   }
               } else {
                   end = line.find("(", start + 3);
                   if (def(end) && end > start) {
                       callPart = line.substring(start + 3, end);
                   } else {
                       callPart = line.substring(start + 3);
                   }
               }
               if (def(callPart)) {
                 if (isCs) {
                   //("callPart |" + callPart + "|").print();
                   List parts = callPart.split(".");
                   //3rd is class, 4th is method
                   String klass = parts.get(1);
                   String mtd = parts.get(2);
                   //("klass |" + klass + "| mtd |" + mtd + "|").print();
                   klass = extractKlass(klass);
                   //("extracted klass |" + klass + "|").print();
                   mtd = extractMethod(mtd);
                   //("extracted mtd |" + mtd + "|").print();
                   fr = Exception:Frame.new(klass, mtd, efile, eline);
                   fr.fileName = getSourceFileName(fr.klassName);
                   tt.addFrame(fr);
                 } else {
                   //is js
                   if (tt.vv) {
                   ("callPart |" + callPart + "|").print();
                   }
                   parts = callPart.split(".");
                   if (parts.size > 1) {
                     if (parts.size > 2) {
                       mtd = parts.get(2);
                       klass = parts.get(1);
                     } else {
                       mtd = parts.get(1);
                       klass = parts.get(0);
                     }
                       mtd = extractMethod(mtd);
                       if (tt.vv) {
                       ("extracted mtd |" + mtd + "|").print();
                       }
                       start = klass.find("BEC_");
                       if (def(start) && start > 0) {
                           end = klass.find("_", start + 4);
                           if (def(end) && end > 0) {
                               //String libLens = klass.substring(start, end);
                               //("libLens |" + libLens + "|").print();
                               //Int libLen = Int.new(libLens);
                               klass = klass.substring(start);
                               if (tt.vv) {
                               ("pre extracted klass |" + klass + "|").print();
                               }
                               klass = extractKlass(klass);
                               if (tt.vv) {
                               ("extracted klass |" + klass + "|").print();
                               }
                               fr = Exception:Frame.new(klass, mtd, efile, eline);
                               fr.fileName = getSourceFileName(fr.klassName);
                               if (tt.vv) {
                               "adding frame".print();
                               }
                               tt.addFrame(fr);
                           } else {
                             if (tt.vv) {
                               "no end".print();
                             }
                           }
                       }
                   }
                 }
               }
           }
       }
       tt.emitLang = tt.lang;
       tt.lang = "be";
       tt.framesText = null;
    } elseIf (def(tt.frames) && def(tt.lang) && tt.lang == "jv") {
       for (Exception:Frame fr in tt.frames) {
           fr.klassName = extractKlassLib(fr.klassName);
           fr.methodName = extractMethod(fr.methodName);
           fr.fileName = getSourceFileName(fr.klassName);
           ifEmit(jv) {
             fr.extractLine();
           }
       }
       tt.emitLang = tt.lang;
       tt.lang = "be";
    } else {
      //("TRANSLATION FAILED").print();
    }
    if (tt.vv) {
     ("translation done").print();
    }
  }
  
   getSourceFileName(String klassName) String {
     //("getting source file name for " + klassName).print();
     dyn i = System:Objects.createInstance(klassName, false);
     if (def(i)) {
       //("is def").print();
       return(System:Objects.sourceFileName(i));
     }
     //("not def").print();
     return(null);
   }
  
  extractKlassLib(String callPart) String {
    //("in extractKlassLib " + callPart).print();
    List parts = callPart.split(".");
    //3rd is class, 4th is method
    return(extractKlass(parts.get(1)));
  }
  
  extractKlass(String klass) String {
    try {
      return(extractKlassInner(klass));
    } catch (dyn e) {
      
    }
    return(klass);
  }
  
  extractKlassInner(String klass) String {
   if (undef(klass) || klass.begins("BEC_")!) {
       return(klass);
   }
   List kparts = klass.substring(6).split("_");
   Int kps = kparts.size - 1; //last is the string, rest is the sizes
   String rawkl = kparts.get(kps);
   String bec = String.new();
   Int sofar = 0;
   for (Int i = 0;i < kps;i++=) {
       Int len = Int.new(kparts.get(i));
       //("got len " + len).print();
       bec += rawkl.substring(sofar, sofar + len);
       if (i + 1 < kps) { bec += ":"; }
       sofar += len;
   }
   //("bec " + bec).print();
   return(bec);
  }
  
  extractMethod(String mtd) String {
   if (undef(mtd) || mtd.begins("bem_")!) {
       return(mtd);
   }
   List mparts = mtd.substring(4).split("_");
   Int mps = mparts.size - 1; //last is the argnum, rest is the name
   String bem = String.new();
   for (Int i = 0;i < mps;i++=) {
       bem += mparts.get(i);
       if (i + 1 < mps) { bem += "_"; }
   }
   //("bem " + bem).print();
   return(bem);
  }

}

use Text:Tokenizer as TT;
use Container:Single;
use Container:LinkedList:Node;
