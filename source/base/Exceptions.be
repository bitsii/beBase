// Copyright 2006 Craig Welch
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

use System:Exception;
use Text:String;
use Math:Int;
use Container:LinkedList;
use Container:Array;
use Logic:Bool;

class System:Exception {
   
   new(descr) self {
      
      fields {
         var methodName;
         var klassName;
         var description;
         var fileName;
         var lineNumber;
         String lang;
         String emitLang;
         LinkedList frames;
         String framesText;
         Bool translated;
      }
      
      description = descr;
   }
   
   toString() String {
      translateEmittedException();
      //"in tostring exception".print();
      //self.sourceFileName.print();
      var toRet = "Exception> ";
      if (def(lang)) {
         toRet = toRet + " Lang: " + lang;
      }
      if (def(emitLang)) {
         toRet = toRet + " EmitLang: " + emitLang;
      }
      if (def(methodName)) {
         toRet = toRet + " Method: " + methodName;
      }
      if (def(klassName)) {
         toRet = toRet + " Class: " + klassName;
      }
      if (def(description)) {
         toRet = toRet + " Description: " + description;
      }
      if (def(fileName)) {
         toRet = toRet + " IO:File: " + fileName;
      }
      if (def(lineNumber)) {
         toRet = toRet + " Line: " + lineNumber.toString();
      }
      if (def(framesText)) {
        toRet = toRet + " Frames Text: " + framesText;
      }
      if (def(frames)) {
        toRet = toRet + getFrameText();
      }
      return(toRet);
   }
   
   translateEmittedException() {
     try {
       translateEmittedExceptionInner();
     } catch(var e) {
       ("Exception translation failed").print();
       if (def(e)) {
         try { e.print(); } catch (var ee) { }
       }
     }
   }
   
   translateEmittedExceptionInner() {
     if (def(translated) && translated) {
       return(self);
     }
     translated = true;
     if (def(framesText) && def(lang) && (lang == "cs" || lang == "js")) {
        Text:Tokenizer ltok = Text:Tokenizer.new("\r\n");
        LinkedList lines = ltok.tokenize(framesText);
        if (lang == "cs") {
            Bool isCs = true;
        } else {
            isCs = false;
        }
        foreach (String line in lines) {
            //("Frame line is " + line).print();
            Int start = line.find("at ");
            String efile = null;
            Int eline = null;
            if (def(start) && start >= 0) {
                //("start is " + start).print();
                Int end = line.find(" ", start + 3);
                if (def(end) && end > start) {
                    //("end is " + end).print();
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
                            if (iv.isInteger()) {
                              eline = Int.new(iv);
                            }
                          }
                        }
                    }  else {
                        start = line.find("(", end);//)
                        if (def(start)) {
                          //("in js start def").print();
                          //(
                          end = line.find(")", start + 1);
                          if (def(end)) {
                            //("in js end def").print();
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
                              if (iv.isInteger()) {
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
                    LinkedList parts = callPart.split(".");
                    //3rd is class, 4th is method
                    String klass = parts.get(2);
                    String mtd = parts.get(3);
                    //("klass |" + klass + "| mtd |" + mtd + "|").print();
                    klass = extractKlass(klass);
                    //("extracted klass |" + klass + "|").print();
                    mtd = extractMethod(mtd);
                    //("extracted mtd |" + mtd + "|").print();
                    fr = Exception:Frame.new(klass, mtd, efile, eline);
                    fr.fileName = getSourceFileName(fr.klassName);
                    addFrame(fr);
                  } else {
                    //is js
                    //("callPart |" + callPart + "|").print();
                    parts = callPart.split(".");
                    if (parts.size > 1) {
                        mtd = parts.get(1);
                        mtd = extractMethod(mtd);
                        //("extracted mtd |" + mtd + "|").print();
                        klass = parts.get(0);
                        start = klass.find("BEL_");
                        if (def(start) && start > 0) {
                            end = klass.find("_", start + 4);
                            if (def(end) && end > 0) {
                                String libLens = klass.substring(start + 4, end);
                                //("libLens |" + libLens + "|").print();
                                Int libLen = Int.new(libLens);
                                klass = klass.substring(start + 7 + libLen);
                                //("pre extracted klass |" + klass + "|").print();
                                klass = extractKlass(klass);
                                //("extracted klass |" + klass + "|").print();
                                fr = Exception:Frame.new(klass, mtd, efile, eline);
                                fr.fileName = getSourceFileName(fr.klassName);
                                addFrame(fr);
                            }
                        }
                    }
                  }
                }
            }
        }
        emitLang = lang;
        lang = "be";
        framesText = null;
     } elif (def(frames) && def(lang) && lang == "jv") {
        foreach (Exception:Frame fr in frames) {
            fr.klassName = extractKlassLib(fr.klassName);
            fr.methodName = extractMethod(fr.methodName);
            fr.fileName = getSourceFileName(fr.klassName);
            ifEmit(jv) {
              fr.extractLine();
            }
        }
        emitLang = lang;
        lang = "be";
     } else {
       //("TRANSLATION FAILED").print();
     }
   }
   
   getSourceFileName(String klassName) String {
     //("getting source file name for " + klassName).print();
     var i = createInstance(klassName, false);
     if (def(i)) {
       //("is def").print();
       return(i.sourceFileName);
     }
     //("not def").print();
     return(null);
   }
   
   extractKlassLib(String callPart) String {
     //("in extractKlassLib " + callPart).print();
     LinkedList parts = callPart.split(".");
     //3rd is class, 4th is method
     return(extractKlass(parts.get(2)));
   }
   
   extractKlass(String klass) String {
     try {
       return(extractKlassInner(klass));
     } catch (var e) {
       
     }
     return(klass);
   }
   
   extractKlassInner(String klass) String {
    if (undef(klass) || klass.begins("BEC_")!) {
        return(klass);
    }
    LinkedList kparts = klass.substring(4).split("_");
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
    LinkedList mparts = mtd.substring(4).split("_");
    Int mps = mparts.size - 1; //last is the argnum, rest is the name
    String bem = String.new();
    for (Int i = 0;i < mps;i++=) {
        bem += mparts.get(i);
        if (i + 1 < mps) { bem += "_"; }
    }
    //("bem " + bem).print();
    return(bem);
   }
   
   framesGet() LinkedList {
    //translate frames from emit lang to be if needed
    //will get from existing frames or from frame text depending on lang
    return(frames);
   }
   
   getFrameText() String {
      translateEmittedException();
      String toRet = String.new();
      LinkedList myFrames = self.frames;
      if (def(myFrames)) {
         toRet = toRet + "\n";
         foreach (var ft in myFrames) {
            toRet = toRet + ft;
         }
      }
      return(toRet);
   }
   
   klassNameGet() Text:String {
      return(klassName);
   }
   
   addFrame(Exception:Frame frame) {
     if (undef(frames)) {
        frames = LinkedList.new();
     }
     frames += frame;
   }
   
   addFrame(String _klassName, String _methodName, String _fileName, Int _line) {
     addFrame(Exception:Frame.new(_klassName, _methodName, _fileName, _line));
   }
}

final class System:MethodNotDefined(System:Exception) {

}

final class System:CallOnNull(System:Exception) {
   new(descr) self {
      description = descr;
   }
}

final class System:IncorrectType(System:Exception) {
   new(descr) self {
      description = descr;
   }
}

final class System:InvocationException(System:Exception) {
}

final class System:ExceptionBuilder {

   create() { }
   
   default() self {
      
      fields {
         var except = Exception.new();
         var thing = System:Thing.new();
         var int = Math:Int.new();
         var lastStr;
      }
      
   }
   
   getLineForEmitLine(String klass, Int eline) Int {
   
     if (undef(klass) || undef(eline)) {
       return(-1);
     }
     
     Int line = Int.new();
     
     emit(cs) {
     """
       bevl_line.bevi_int = 
         be.BELS_Base.BECS_Runtime.getNlcForNlec(beva_klass.bems_toCsString(),
           beva_eline.bevi_int);
     """
     }
     
     emit(js) {
     """
       bevl_line.bevi_int = 
         be_BELS_Base_BECS_Runtime.prototype.getNlcForNlec(this.bems_stringToJsString_1(beva_klass),
           beva_eline.bevi_int);
     """
     }
     
     emit(jv) {
     """
       bevl_line.bevi_int = 
         be.BELS_Base.BECS_Runtime.getNlcForNlec(beva_klass.bems_toJvString(),
           beva_eline.bevi_int);
     """
     }
     
     return(line);
   
   }
   
   printException(ex) {
      if (undef(ex)) {
         "Unable to print exception, passed exception is null".print();
      } else {
         try {
            ex.print();
         } catch (var e) {
            "Unable to print exception".print();
         }
      }
   }
   
   sendToConsole(ex) {
      lastStr = null;
      if (undef(ex)) {
         "Unable to print exception, passed exception is null".print();
      } else {
         try {
            //IO:File:NamedWriters.new().exceptionConsole.write(ex.toString());
         } catch (var e) {
            "Unable to print exception".print();
         }
      }
   }

   buildException(passBack, smsg, sinClass, sinMtd, sfname, ilinep) {
      if (def(passBack) && (passBack.sameType(except))) {
         passBack.klassName = sinClass;
         passBack.methodName = sinMtd;
         passBack.fileName = sfname;
         passBack.lineNumber = ilinep;
      }
   }

}

class Exception:Frame {

    new(String _klassName, String _methodName, String _emitFileName, Int _emitLine) self {
        fields {
            String klassName = _klassName;
            String methodName = _methodName;
            String emitFileName = _emitFileName;
            Int emitLine = _emitLine;
            String fileName;
            Int line;
        }
        ifEmit(cs) {
          extractLine();
        }
        ifEmit(js) {
          extractLine();
        }
    }
    
    extractLine() {
      line = System:ExceptionBuilder.getLineForEmitLine(klassName, emitLine);
    }
    
    toString() String {
        String res = "Exception Frame> ";
        res += " Class: ";
        if (def(klassName)) { res += klassName; }
        res += " Method: ";
        if (def(methodName)) { res += methodName; }
        res += " IO:File: ";
        if (def(fileName)) { res += fileName; }
        res += " Line: ";
        if (def(line)) { res += line.toString(); }
        res += " EmitFile: ";
        if (def(emitFileName)) { res += emitFileName; }
        res += " EmitLine: ";
        if (def(emitLine)) { res += emitLine.toString(); }
        res += "\n";
        return(res);
    }

}
