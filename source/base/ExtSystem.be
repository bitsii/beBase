// Copyright 2006 The Brace Authors. All rights reserved.
// Use of this source code is governed by the BSD-3-Clause
// license that can be found in the LICENSE file.

emit(cs) {
    """
using System;
// for threading
using System.Threading;
    """
}

emit(jv) {
"""
import java.util.concurrent.locks.ReentrantLock;
"""
}

//future, pass inst, mtd name, (optional) args
//getresult (optional time to wait) (save result in lock, lock will be needed for this)
//also queue/task/worker (queue in, out, things go in, things come out, # workers)

use local class System:ThinThread {
  
   //start (calls passed obj's main())
   //wait, wait(int millis) (bool true if worked, false if timed out) (see what happens when joining
   //thread already joined)
   //alive?
   //id? (use for compare, equals)
   //current?
   emit(cs) {
   """
   volatile public Thread bevi_thread;
   public static void bems_run(object sysThreadInst) {
     $class/System:ThinThread$ st = ($class/System:ThinThread$) sysThreadInst;
     st.bem_main_0();
   }
   """
   }
   emit(jv) {
   """
   volatile public Thread bevi_thread;
   static class BECS_Runnable implements Runnable {
    volatile $class/System:ThinThread$ bevi_sysThread = null;
    BECS_Runnable($class/System:ThinThread$ bevi_sysThread) {
      this.bevi_sysThread = bevi_sysThread;
    }
    public void run() {
      try {
        bevi_sysThread.bem_main_0();
      } catch (Throwable t) {
        throw new RuntimeException(t.getMessage(), t);
      }
    }
   }
   """
   }
   emit(cc_classHead) {
   """
#ifdef BEDCC_PT
   std::shared_ptr<std::thread> bevi_thread;
#endif
   void bems_runMain() {
       BECS_Runtime::bemg_beginThread();
       bem_main_0();
       BECS_Runtime::bemg_endThread();
   }
   """
   }
   
   new(_toRun) self {
     fields {
       any toRun = _toRun;
     }
   }
   
   start() this {
     emit(cs) {
     """
     bevi_thread = new Thread($class/System:ThinThread$.bems_run);
     bevi_thread.Start(this);
     """
     }
     emit(jv) {
     """
     BECS_Runnable bevi_runnable = new BECS_Runnable(this);
     bevi_thread = new Thread(bevi_runnable);
     bevi_thread.start();
     """
     }
     emit(cc) {
     """
#ifdef BEDCC_PT
     bevi_thread = std::make_shared<std::thread>(&BEC_2_6_10_SystemThinThread::bems_runMain, this);
#endif
     """
     }
   }
   
   main() {
     any e;
     try { 
      toRun.main();
     } catch (e) {
     }
   }
   
   wait() Bool {
     emit(cs) {
     """
     bevi_thread.Join();
     """
     }
     emit(jv) {
     """
     bevi_thread.join();
     """
     }
     emit(cc) {
     """
     BECS_Runtime::bemg_enterBlocking();
#ifdef BEDCC_PT
     if (bevi_thread->joinable()) {
      bevi_thread->join();
     }
#endif
     BECS_Runtime::bemg_exitBlocking();
     """
     }
     return(true);
   }
   
}

use final class System:Thread(ThinThread) {

  new(_toRun) self {
     fields {
       OLocker started = OLocker.new(false);
       OLocker finished = OLocker.new(false);
       OLocker threwException = OLocker.new();
       OLocker returned = OLocker.new();
       OLocker exception = OLocker.new();
     }
     super.new(_toRun);
   }
   
   main() {
     any e;
     try { 
      started.o = true;
      returned.o = toRun.main();
      threwException.o = false;
      finished.o = true;
     } catch (e) {
      threwException.o = true;
      exception.o = e;
      finished.o = true;
     }
   }

}

//nanny - wraps thread, starts, wait for it to start, does join
//on join see's if own start was called, if not, restarts internal
//in new thread - first calls "finished" then, if except "failed" with except
//stop on nanny sets it to stop and results in a call to it's inner

use final class System:Thread:Lock {

  emit(jv) {
  """
  volatile public ReentrantLock bevi_lock = new ReentrantLock();
  """
  }
  emit(cc_classHead) {
  """
#ifdef BEDCC_PT
  std::recursive_mutex bevi_lock;
#endif
  """
  }
  
  lock() Bool {
    emit(cs) {
    """
    Monitor.Enter(this); //yes, monitor is reentrant
    """
    }
    emit(jv) {
    """
    bevi_lock.lock();
    """
    }
    emit(cc) {
    """
    BECS_Runtime::bemg_enterBlocking();
#ifdef BEDCC_PT
    bevi_lock.lock();
#endif
    BECS_Runtime::bemg_exitBlocking();
    """
    }
    return(true);
  }
  
  unlock() Bool {
    emit(cs) {
    """
    Monitor.Exit(this);
    """
    }
    emit(jv) {
    """
    bevi_lock.unlock();
    """
    }
    emit(cc) {
    """
#ifdef BEDCC_PT
    bevi_lock.unlock();
#endif
    """
    }
    return(true);
  }

}

use System:Thread:ContainerLocker as CLocker;
class System:Thread:ContainerLocker {
  
  new(_container) self {
    fields {
      Lock lock = Lock.new();
      any container;
    }
    lock.lock();
    try {
      container = _container;
      lock.unlock();
    } catch (any e) {
      lock.unlock();
      throw(e);
    }
  }
  
  has(key) Bool {
    lock.lock();
    try {
      Bool r = container.has(key);
      lock.unlock();
    } catch (any e) {
      lock.unlock();
      throw(e);
    }
    return(r);
  }
  
  has(key, key2) Bool {
    lock.lock();
    try {
      Bool r = container.has(key, key2);
      lock.unlock();
    } catch (any e) {
      lock.unlock();
      throw(e);
    }
    return(r);
  }
  
  get() {
    lock.lock();
    try {
      any r = container.get();
      lock.unlock();
    } catch (any e) {
      lock.unlock();
      throw(e);
    }
    return(r);
  }
  
  get(key) {
    lock.lock();
    try {
      any r = container.get(key);
      lock.unlock();
    } catch (any e) {
      lock.unlock();
      throw(e);
    }
    return(r);
  }
  
  getAndClear(key) {
    lock.lock();
    try {
      any r = container.get(key);
      container.delete(key);
      lock.unlock();
    } catch (any e) {
      lock.unlock();
      throw(e);
    }
    return(r);
  }
  
  get(p, k) {
    lock.lock();
    try {
      any r = container.get(p, k);
      lock.unlock();
    } catch (any e) {
      lock.unlock();
      throw(e);
    }
    return(r);
  }
  
  addValue(key) self {
    lock.lock();
    try {
      container.addValue(key);
      lock.unlock();
    } catch (any e) {
      lock.unlock();
      throw(e);
    }
  }
  
  putReturn(key) {
    lock.lock();
    try {
      any r = container.put(key);
      lock.unlock();
    } catch (any e) {
      lock.unlock();
      throw(e);
    }
    return(r);
  }
  
  put(key) self {
    lock.lock();
    try {
      container.put(key);
      lock.unlock();
    } catch (any e) {
      lock.unlock();
      throw(e);
    }
  }
  
  putReturn(key, value) {
    lock.lock();
    try {
      any r = container.put(key, value);
      lock.unlock();
    } catch (any e) {
      lock.unlock();
      throw(e);
    }
    return(r);
  }
  
  put(key, value) self {
    lock.lock();
    try {
      container.put(key, value);
      lock.unlock();
    } catch (any e) {
      lock.unlock();
      throw(e);
    }
  }
  
  testAndPut(key, oldValue, value) {
    lock.lock();
    try {
      any rc = container.testAndPut(key, oldValue, value);
      lock.unlock();
    } catch (any e) {
      lock.unlock();
      throw(e);
    }
    return(rc);
  }
  
  getSet() {
    lock.lock();
    try {
      Map rc = container.getSet();
      lock.unlock();
    } catch (any e) {
      lock.unlock();
      throw(e);
    }
    return(rc);
  }
  
  getMap() {
    lock.lock();
    try {
      Map rc = container.getMap();
      lock.unlock();
    } catch (any e) {
      lock.unlock();
      throw(e);
    }
    return(rc);
  }
  
  getMap(String prefix) {
    lock.lock();
    try {
      Map rc = container.getMap(prefix);
      lock.unlock();
    } catch (any e) {
      lock.unlock();
      throw(e);
    }
    return(rc);
  }
  
  putIfAbsent(key, value) Bool {
    lock.lock();
    try {
      if (container.has(key)) {
        Bool didPut = false;
      } else {
        container.put(key, value);
        didPut = true;
      }
      lock.unlock();
    } catch (any e) {
      lock.unlock();
      throw(e);
    }
    return(didPut);
  }
  
  getOrPut(key, value) {
    lock.lock();
    try {
      if (container.has(key)) {
        any result = container.get(key);
      } else {
        container.put(key, value);
        result = value;
      }
      lock.unlock();
    } catch (any e) {
      lock.unlock();
      throw(e);
    }
    return(result);
  }
  
  put(p, k, v) self {
    lock.lock();
    try {
      container.put(p, k, v);
      lock.unlock();
    } catch (any e) {
      lock.unlock();
      throw(e);
    }
  }
  
  delete(key) {
    lock.lock();
    try {
      any r = container.delete(key);
      lock.unlock();
    } catch (any e) {
      lock.unlock();
      throw(e);
    }
    return(r);
  }
  
  delete(p, k) {
    lock.lock();
    try {
      any r = container.delete(p, k);
      lock.unlock();
    } catch (any e) {
      lock.unlock();
      throw(e);
    }
    return(r);
  }
  
  sizeGet() Int {
    lock.lock();
    try {
      Int r = container.size;
      lock.unlock();
    } catch (any e) {
      lock.unlock();
      throw(e);
    }
    return(r);
  }
  
  isEmptyGet() Bool {
    lock.lock();
    try {
      Bool r = container.isEmpty;
      lock.unlock();
    } catch (any e) {
      lock.unlock();
      throw(e);
    }
    return(r);
  }
  
  copyContainer() {
    lock.lock();
    try {
      any r = container.copy();
      lock.unlock();
    } catch (any e) {
      lock.unlock();
      throw(e);
    }
    return(r);
  }
  
  clear() self {
    lock.lock();
    try {
      container.clear();
      lock.unlock();
    } catch (any e) {
      lock.unlock();
      throw(e);
    }
  }
  
  close() self {
    lock.lock();
    try {
      container.close();
      lock.unlock();
    } catch (any e) {
      lock.unlock();
      throw(e);
    }
  }
  
}

use System:Thread:ObjectLocker as OLocker;
class OLocker {
  
  new() self {
    fields {
      Lock lock = Lock.new();
    }
  }
  
  new(_obj) self {
    new();
    fields {
      any obj;
    }
    lock.lock();
    try {
      obj = _obj;
      lock.unlock();
    } catch (any e) {
      lock.unlock();
      throw(e);
    }
  }
  
  oGet() {
    lock.lock();
    try {
      any r = obj;
      lock.unlock();
    } catch (any e) {
      lock.unlock();
      throw(e);
    }
    return(r);
  }
  
  getAndClear() {
    lock.lock();
    try {
      any r = obj;
      obj = null;
      lock.unlock();
    } catch (any e) {
      lock.unlock();
      throw(e);
    }
    return(r);
  }
  
  setIfClear(_obj) Bool {
    lock.lock();
    Bool res = false;
    try {
      if (undef(obj)) {
        obj = _obj;
        res = true;
      }
      lock.unlock();
    } catch (any e) {
      lock.unlock();
      throw(e);
    }
    return(res);
  }
  
  oSet(_obj) {
    lock.lock();
    try {
      obj = _obj;
      lock.unlock();
    } catch (any e) {
      lock.unlock();
      throw(e);
    }
  }
  
  objectGet() {
    return(oGet());
  }
  
  objectSet(_obj) {
    return(oSet(_obj));
  }
  
}


use Text:Glob;

class Glob {
   
   new(String _glob) self {
      self.glob = _glob;
   }
   
   globSet(String _glob) {
      Text:Tokenizer tok = Text:Tokenizer.new("*?", true);
      LinkedList _splits = tok.tokenize(_glob);
      fields {
         String glob = _glob;
         LinkedList splits = _splits;
      }
   }
   
   //* - iterate while false, continue with each
   //? - end > pos, continue with next
   //str - begins with str, continue after
   //end - true
   
   match(String input) Bool {
      Node node = splits.iterator.nextNode;
      return(caseMatch(node, input, 0, null));
   }
   
   caseMatch(Node node, String input, Int pos, Single lpos) Bool {
      if (undef(node)) {
         if (pos == input.size) {
            return(true);
         } else {
            return(false);
         }
      }
      String val = node.held;
      if (val == "*") {
         return(starMatch(node, input, pos));
      }
      if (val == "?") {
         pos = pos++;
         if (pos <= input.size) { return(caseMatch(node.next, input, pos, null)); } else { return(false); }
      }
      Int found = input.find(val, pos);
      if (def(found)) {
         if (found == pos) {
            return(caseMatch(node.next, input, pos + val.size, null));
         } else {
            if (def(lpos)) {
               lpos.first = found;
            }
         }
      }
      return(false);
   }
   
   starMatch(Node node, String input, Int pos) Bool {
      Node nx = node.next;
      Single lpos = Single.new();
      //Special optimize for literal case with lpos
      while (pos <= input.size) {
         Bool ok = caseMatch(nx, input, pos, lpos);
         if (ok) { return(true); }
         if (def(lpos.first)) {
            pos = lpos.first;
            lpos.first = null;
         } else {
            pos = pos++;
         }
      }
      return(false);
   }

}

use Container:Single;
use Container:LinkedList:Node;