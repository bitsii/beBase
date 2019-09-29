// Copyright 2006 Craig Welch
//
// Licensed under the MIT license. See LICENSE.txt file in the project root 
// for full license information.

use IO:Log;
use IO:Logs;

use Math:Int;
use Text:String;
use System:Thread:Lock;

use System:Exceptions as Ex;

class Logs {
  
  default() self {
    fields {
      Int debug = 400;
      Int info = 300;
      Int warn = 200;
      Int error = 100;
      Int fatal = 0;
      Set overrides = Set.new();
      Map loggers = Map.new();
      Lock lock = Lock.new();
      
      Int defaultOutputLevel = error;
      Int defaultLevel = info;
      
      any sink;
      
    }
  }
  
  setDefaultLevels(Int _defaultOutputLevel, Int _defaultLevel) {
  
    try {
      lock.lock();
      defaultOutputLevel = _defaultOutputLevel;
      defaultLevel = _defaultLevel;
      for (any kv in loggers) {
        unless (overrides.has(kv.key)) {
          kv.value.setLevels(defaultOutputLevel, defaultLevel);
        }
      }
      lock.unlock();
    } catch (any e) {
      lock.unlock();
    }
  }
  
  putKeyLevels(String key, Int level, Int outputLevel) {
    try {
      lock.lock();
      overrides.put(key);
      
      Log log = loggers.get(key);
      if (undef(log)) {
        log = Log.new(sink, level, outputLevel);
        loggers.put(key, log);
      } else {
        log.level = level;
        log.outputLevel = outputLevel;
      }
      lock.unlock();
    } catch (any e) {
      lock.unlock();
    }
  }
  
  putLevels(inst, Int level, Int outputLevel) {
    putKeyLevels(inst.className, level, outputLevel);
  }
  
  getKey(String key) Log {
    try {
      lock.lock();
      Log log = loggers.get(key);
      if (undef(log)) {
        log = Log.new(sink, defaultOutputLevel, defaultLevel);
        loggers.put(key, log);
      }
      lock.unlock();
    } catch (any e) {
      lock.unlock();
    }
    return(log);
  }
  
  get(inst) Log {
    return(getKey(inst.className));
  }
  
  turnOn(inst) {
    try {
      lock.lock();
      IO:Log log = get(inst);
      putLevels(inst, log.level, log.level);
      lock.unlock();
    } catch (any e) {
      lock.unlock();
    }
  }
  
  turnOnAll() {
    try {
      lock.lock();
      defaultOutputLevel = defaultLevel;
      for (any kv in loggers) {
        kv.value.outputLevel = defaultOutputLevel;
        kv.value.level = defaultLevel;
      }
      lock.unlock();
    } catch (any e) {
      lock.unlock();
    }
  }
  
  setAllSinks(any _sink) {
    try {
      lock.lock();
      sink = _sink;
      for (any kv in loggers) {
        kv.value.sink = _sink;
      }
      lock.unlock();
    } catch (any e) {
      lock.unlock();
    }
  }
  
}

class Log {

  new(_sink, _outputLevel, _level) self {
    fields {
      Int outputLevel = _outputLevel;
      Int level = _level;
      any sink = _sink;
    }
  }
  
  will() Logic:Bool {
    if (level <= outputLevel) {
      return(true);
    }
    return(false);
  }
  
  will(Int _level) Logic:Bool {
    if (_level <= outputLevel) {
      return(true);
    }
    return(false);
  }
  
  out(String msg) {
    if (undef(msg)) {
      msg = "null";
    }
    if (def(sink)) {
      sink.out(msg);
    } else {
      msg.print();
    }
  }
  
  elog(e) {
    elog("Error logged ", e);
  }
  
  elog(String msg, e) {
    log(msg + " " + Ex.tS(e));
  }
  
  log(String msg) {
    if (level <= outputLevel) {
      out(msg);
    }
  }
  
  elog(Int level, String msg, e) {
    log(level, msg + " " + Ex.tS(e));
  }
  
  log(Int _level, String msg) {
    if (_level <= outputLevel) {
      out(msg);
    }
  }
  
  debug(String msg) {
    Int lev =@ 400;
    log(lev, msg);
  }
  
  info(String msg) {
    Int lev =@ 300;
    log(lev, msg);
  }
  
  warn(String msg) {
    Int lev =@ 200;
    log(lev, msg);
  }
  
  error(String msg) {
    Int lev =@ 100;
    log(lev, msg);
  }
  
  fatal(String msg) {
    Int lev =@ 0;
    log(lev, msg);
  }
  
  output(String msg) {
    out(msg);
  }

}
