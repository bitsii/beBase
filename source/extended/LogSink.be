/*
 * Copyright (c) 2006-2023, the Brace Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

import IO:File:Path;

import Math:Int;
import Text:String;
import System:Thread:Lock;

import class IO:Log:Sink {

  new() {
    fields {
      String prefix = "Out";
      String suffix = ".log";
      IO:Writer output;
      Int currentLog = 0;
      Int maxLogs = 3;
      Int logSize = 0;
      //Int rotateSize = 1 * 10000;
      Int rotateSize = 128 * 1000000; //typical
      //Int rotateSize = 1; //test
      Lock wl = Lock.new();
      String nl = System:CurrentPlatform.newline;
      Path dir;
    }
  }
  
  openLog() {
    if (undef(dir)) {
      if (System:CurrentPlatform.name == "mswin") {
        String tmp = System:Environment.getVariable("TMP");
        if (TS.isEmpty(tmp)) {
          tmp = System:Environment.getVariable("TEMP");
        }
        dir = Path.apNew(tmp);
      } else {
        dir = Path.apNew("/tmp");
      }
    }
    ("opening log " + prefix + currentLog + suffix).print();
    output = dir.copy().addStep(prefix + currentLog + suffix).file.writer.open();
  }
  
  closeLog() {
    try {
      if (def(output)) {
        output.close();
      }
    } catch (dyn e) {
    
    }
    output = null;
  }
  
  out(msg) {
    try {
      wl.lock();
      if (undef(output)) {
        openLog();
      }
      output.write(msg);
      output.write(nl);
      logSize += msg.size;
      logSize += nl.size;
      if (logSize > rotateSize) {
        closeLog();
        logSize.setValue(0);
        currentLog++=;
        if (currentLog >= maxLogs) {
          currentLog.setValue(0);
        }
        openLog();
      }
      wl.unlock();
    } catch (dyn e) {
      wl.unlock();
    }
  }

}
