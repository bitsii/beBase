// Copyright 2006 The Brace Authors. All rights reserved.
// Use of this source code is governed by the BSD-3-Clause
// license that can be found in the LICENSE file.

class System:Exceptions {
  ts(any e) {
    String esm = "Failure occurred";
    if (def(e)) {
      String es = e.toString();
      if (undef(es)) {
        es = "...failure toString null..."
      }
    } else {
      es = "...failure is null...";
    }
    esm += es;
    return(esm);
  }
  
  tS(any e) {
    return(ts(e));
  }
  
  toString(any e) {
    return(ts(e));
  }
  
}

use System:Exception;

class System:Exception {
   
   new(descr) self {
      
      fields {
         any methodName;
         any klassName;
         any description;
         any fileName;
         any lineNumber;
         String lang;
         String emitLang;
         List frames;
         String framesText;
         Bool translated;
         Bool vv = false;
      }
      
      description = descr;
   }
   
   toString() String {
      ifNotEmit(noSmap) {
        createInstance("System:ExceptionTranslator").new().translateEmittedException(self);
      }
      //"in tostring exception".print();
      //self.sourceFileName.print();
      any toRet = "Exception> ";
      if (def(description)) {
         toRet = toRet + " Description: " + description;
      }
      if (def(fileName)) {
         toRet = toRet + " IO:File: " + fileName;
      }
      if (def(lineNumber)) {
         toRet = toRet + " Line: " + lineNumber.toString();
      }
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
      if (def(framesText)) {
        toRet = toRet + " Frames Text: " + framesText;
      }
      if (def(frames)) {
        toRet = toRet + getFrameText();
      }
      return(toRet);
   }
    
   framesGet() List {
    //translate frames from emit lang to be if needed
    //will get from existing frames or from frame text depending on lang
    ifNotEmit(noSmap) {
      createInstance("System:ExceptionTranslator").new().translateEmittedException(self);
    }
    if(vv) {
    ("translation done").print();
    }
    
    return(frames);
   }
   
   getFrameText() String {
      ifNotEmit(noSmap) {
        createInstance("System:ExceptionTranslator").new().translateEmittedException(self);
      }
      String toRet = String.new();
      List myFrames = self.frames;
      if (def(myFrames)) {
         toRet = toRet + "\n";
         for (any ft in myFrames) {
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
        frames = List.new();
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

   create() self { }
   
   default() self {
      
      fields {
         any except = Exception.new();
         any thing = System:Thing.new();
         any int = Math:Int.new();
         any lastStr;
      }
      
   }
   
   getLineForEmitLine(String klass, Int eline) Int {
   
     if (undef(klass) || undef(eline)) {
       //("got no class or line ").print();
       return(-1);
     }
     
     Int line = Int.new();
     //("calling the get nlc").print();
     emit(cs) {
     """
       bevl_line.bevi_int = 
         be.BECS_Runtime.getNlcForNlec(beva_klass.bems_toCsString(),
           beva_eline.bevi_int);
     """
     }
     
     emit(js) {
     """
       bevl_line.bevi_int = 
         be_BECS_Runtime.prototype.getNlcForNlec(this.bems_stringToJsString_1(beva_klass),
           beva_eline.bevi_int);
     """
     }
     
     emit(jv) {
     """
       bevl_line.bevi_int = 
         be.BECS_Runtime.getNlcForNlec(beva_klass.bems_toJvString(),
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
         } catch (any e) {
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
         } catch (any e) {
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
