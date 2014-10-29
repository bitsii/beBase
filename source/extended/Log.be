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

use IO:Log;
use IO:Logs;
use IO:LogLevels;
use IO:File;
use Text:String;
use Logic:Bool;
use Math:Int;
use Container:Map;
use Container:LinkedList;

final class Log {
   
   new() self {
   
      properties {
         Int level = 200;
         LinkedList appenders = LinkedList.new();
         LinkedList fappenders = LinkedList.new();
         String nl = Text:Strings.newline;
         var formatter;
      }
      
      appenders += IO:File:Writer:Stderr.new();
   }
   
   new(Int _level, appender) Log {
      level = _level;
      appenders = LinkedList.new();
      fappenders = LinkedList.new();
      appenders += appender;
      nl = Text:Strings.new().newline;
   }
   
   fileNew(Int _level, fappender) self {
      level = _level;
      appenders = LinkedList.new();
      fappenders = LinkedList.new();
      fappenders += fappender;
      nl = Text:Strings.new().newline;
   }
   
   addAppender(appender) {
      appenders += appender;
   }
   
   addFileAppender(fappender) {
      fappenders += fappender;
   }
   
   clearAppenders() {
      appenders = LinkedList.new();
   }
   
   output(String message) {
      if (def(formatter)) {
         message = formatter.format(message);
      }
      for (var it = appenders.iterator;it.hasNext;) {
         var i = it.next;
         i.write(message);
         i.write(nl);
      }
      for (it = fappenders.iterator;it.hasNext;) {
         i = it.next;
         var w = getWriter(i);
         w.write(message);
         w.write(nl);
      }
   }
   
   getWriter(fappender) {
      var w = fappender.writer;
      if (w.isClosed) {
         w.openAppend();
      }
      return(w);
   }
   
   log(Int _level, String message) {
      if (_level <= level) {
         output(message);
      }
   }
   
   willDebug() Bool {
      if (400 <= level) { return(true); }
      return(false);
   }
   
   debug(String message) {
      if (400 <= level) {
         output(message);
      }
   }
   
   willInfo() Bool {
      if (300 <= level) { return(true); }
      return(false);
   }
   
   info(String message) {
      if (300 <= level) {
         output(message);
      }
   }
   
   willWarn() Bool {
      if (200 <= level) { return(true); }
      return(false);
   }
   
   warn(String message) {
      if (200 <= level) {
         output(message);
      }
   }
   
   willError() Bool {
      if (100 <= level) { return(true); }
      return(false);
   }
   
   error(String message) {
      if (100 <= level) {
         output(message);
      }
   }

}

final class Logs {
   create() { }
   default() self {
      
      properties {
         var defaultAppender = IO:File:Writer:Stderr.new();
         Log default = Log.new(LogLevels.new().error, defaultAppender);
         Map logs = Map.new();
      }
      
   }
   
   get() Log {
      return(default);
   }
   
   get(key) Log {
      Log log = logs.get(key);
      if (undef(log)) {
         log = default;
      }
      return(log);
   }
   
   put(key, Log log) {
      logs.put(key, log);
   }
}

final class LogLevels {
   create() { }
   default() self {
      
      properties {
         Int debug = 400;
         Int info  = 300;
         Int warn  = 200;
         Int error = 100;
      }
   }
}

