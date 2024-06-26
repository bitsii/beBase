/*
 * Copyright (c) 2006-2023, the Beysant Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
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
   
      fields {
         Int level = 200;
         LinkedList appenders = LinkedList.new();
         LinkedList fappenders = LinkedList.new();
         String nl = Text:Strings.newline;
         any formatter;
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
      for (any it = appenders.iterator;it.hasNext;) {
         any i = it.next;
         i.write(message);
         i.write(nl);
      }
      for (it = fappenders.iterator;it.hasNext;) {
         i = it.next;
         any w = getWriter(i);
         w.write(message);
         w.write(nl);
      }
   }
   
   getWriter(fappender) {
      any w = fappender.writer;
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
   create() self { }
   default() self {
      
      fields {
         any defaultAppender = IO:File:Writer:Stderr.new();
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
   create() self { }
   default() self {
      
      fields {
         Int debug = 400;
         Int info  = 300;
         Int warn  = 200;
         Int error = 100;
      }
   }
}

