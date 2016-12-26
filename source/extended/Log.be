// Copyright 2006 Craig Welch
//
// Licensed under the MIT license. See LICENSE.txt file in the project root 
// for full license information.

use IO:Log;
use IO:Logs;

use Math:Int;
use Text:String;
use System:Thread:Lock;

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
      
      //("putting kl for " + key).print();
      //("levels " + level + " " + outputLevel).print();
      
      Log log = loggers.get(key);
      if (undef(log)) {
        log = Log.new(level, outputLevel);
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
    //("in putlevels").print();
    putKeyLevels(inst.className, level, outputLevel);
    //("after putkey").print();
  }
  
  getKey(String key) Log {
    try {
      lock.lock();
      Log log = loggers.get(key);
      if (undef(log)) {
        log = Log.new(defaultOutputLevel, defaultLevel);
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
      //"in turnon".print();
      IO:Log log = get(inst);
      putLevels(inst, log.level, log.level);
      //"after pl".print();
      lock.unlock();
    } catch (any e) {
      lock.unlock();
    }
  }
  
  turnOnAll() {
    try {
      lock.lock();
      //"in turnon".print();
      defaultOutputLevel = defaultLevel;
      for (any kv in loggers) {
        kv.value.outputLevel = defaultOutputLevel;
        kv.value.level = defaultLevel;
      }
      //"after pl".print();
      lock.unlock();
    } catch (any e) {
      lock.unlock();
    }
  }
  
}

class Log {

  new(_outputLevel, _level) self {
    fields {
      Int outputLevel = _outputLevel;
      Int level = _level;
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
  
  log(String msg) {
    if (level <= outputLevel) {
      if (def(msg)) {
        msg.print();
      } else {
        "null".print();
      }
    }
  }
  
  log(Int _level, String msg) {
    if (_level <= outputLevel) {
      if (def(msg)) {
        msg.print();
      } else {
        "null".print();
      }
    }
  }
  
  output(String msg) {
    if (def(msg)) {
      msg.print();
    } else {
      "null".print();
    }
  }

}
