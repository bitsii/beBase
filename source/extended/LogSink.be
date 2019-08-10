// Copyright 2006 Craig Welch
//
// Licensed under the MIT license. See LICENSE.txt file in the project root 
// for full license information.

use IO:File:Path;

use Math:Int;
use Text:String;
use System:Thread:Lock;

use class IO:Log:Sink {

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
    } catch (any e) {
    
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
    } catch (any e) {
      wl.unlock();
    }
  }

}