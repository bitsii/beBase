/*
 * Copyright (c) 2006-2023, the Brace Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

import Container:LinkedList:Iterator as LIter;

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

import final class System:Main {

    create() self { }
   
   default() self {
      
   }
   
    main() {
    
    }
    
}

class System:BasePath {
   
   new() self {
   
      fields {
         String separator;
         String path;
      }
      
      self.new(Text:String.new());
   }
   
   new(String spath) self {
      separator = " ";
      fromString(spath);
   }
   
   fromString(String spath) {
      path = spath;
   }
   
   toString() Text:String {
      return(path);
   }
   
   toString(String newsep) Text:String {
	  return(toStringWithSeparator(newsep));
   }
   
   toStringWithSeparator(String newsep) Text:String {
      LinkedList fpath = self.stepList;
      String npath = Text:Strings.new().join(newsep, fpath);
      return(npath);
   }
   
   stepListGet() LinkedList {
      return(TT.new(separator).tokenize(path));
   }
   
   firstStepGet() String {
      return(self.stepList.first);
   }
   
   lastStepGet() String {
      return(self.stepList.last);
   }
   
   add(other) self {
      if (other.path == Text:Strings.new().empty) {
         return(copy());
      }
      if (other.isAbsolute) {
         return(other.copy());
      }
      LinkedList fpath = self.stepList;
      LinkedList spath = other.stepList;
      for (LIter i = spath.linkedListIterator;i.hasNext;;) {
         dyn l = i.next;
         fpath.addValue(l);
      }
      String rstr = Text:Strings.new().join(separator, fpath);
      System:BasePath rpath = copy();
      rpath = rpath.fromString(rstr);
      //("Added " + path + " to " + other.path + " and got " + rstr).print();
      return(rpath);
   }
   
   parentGet() System:BasePath  {
      LinkedList fpath = self.stepList;
      System:BasePath rpath = copy();
      rpath.path = String.new();
      Int rpl = fpath.length;
      rpl = rpl--;
      Int c = 0;
      for (LIter i = fpath.linkedListIterator;i.hasNext;;) {
         if (c < rpl) {
            rpath.addStep(i.next);
         } else {
            i.next;
         }
         c = c++;
      }
      if (self.isAbsolute) {
         rpath.makeAbsolute();
      }
      return(rpath);
   }
   
   isAbsoluteGet() Bool {
      if (undef(path) || path.toString().length < 1) { return(false); }
      if (path.getPoint(0) == separator) {
         return(true);
      }
      return(false);
   }
   
   makeNonAbsolute() self {
      if (self.isAbsolute) {
         path = path.substring(1, path.length);
      }
   }
   
   makeAbsolute() self {
      if (self.isAbsolute!) {
         path = separator + path;
      }
   }
   
   trimParents(Int howMany) self {
      if (howMany > 0) {
         makeNonAbsolute();
         LinkedList fpath = self.stepList;
         Node current;
         Node next = fpath.firstNode;
         for (Int i = 0;i < howMany;i = i++) {
            if (undef(next)) { break; }
            current = next;
            next = current.next;
            current.delete();
         }
         path = path.join(separator, fpath);
      }
   }
   
   addStep(step) self {
      LinkedList fpath = self.stepList;
      fpath.addValue(step);
      path = path.join(separator, fpath);
   }
   
   deleteFirstStep() self {
      Int fp = path.find(separator);
      if (undef(fp)) {
         path = Text:Strings.new().empty;
      } else {
         path = path.substring(fp + 1, path.length);
      }
   }
   
   addStepList(LinkedList sl) {
      LinkedList fpath = self.stepList;
      for (LIter i = sl.linkedListIterator;i.hasNext;;) {
         fpath.addValue(i.next);
      }
      path = path.join(separator, fpath);
   }
   
   addSteps(step) {
      return(addStep(step));
   }
   
   addSteps(s1, s2) {
      LinkedList fpath = self.stepList;
      fpath.addValue(s1);
      fpath.addValue(s2);
      path = path.join(separator, fpath);
   }
   
   copy() self {
      System:BasePath other = create();
      copyTo(other);
      other.path = path.copy();
      return(other);
   }
   
   stepsGet() LinkedList {
      return(self.stepList);
   }
   
   hashGet() Math:Int {
      return(path.hash);
   }
   
   notEquals(x) Bool {
      return(equals(x)!);
   }
   
   equals(x) Bool {
      if (undef(x) || System:Types.otherType(x, self) || path != x.path) {
         return(false);
      } 
      return(true);
   }
   
   subPath(Int start) {
      return(subPath(start, null));
   }
   
   subPath(Int start, Int end) {
      LinkedList st = self.steps;
      if (undef(end)) {
         dyn ll = st.subList(start);
      } else {
         ll = st.subList(start, end);
      }
      dyn res = create();
      res.separator = separator;
      res.path = Text:Strings.join(separator, ll);
      return(res);
   }

}


final class System:CurrentPlatform (System:Platform) {

    create() self { }
   
   default() self {
       ifEmit(jv,cs,js,cc) {
           if (undef(name)) {
                String platformName;
                emit(jv) {
                """
                    bevl_platformName = new $class/Text:String$(be.BECS_Runtime.platformName.getBytes("UTF-8"));
                """
                }
                emit(cs) {
                """
                    bevl_platformName = new $class/Text:String$(System.Text.Encoding.UTF8.GetBytes(be.BECS_Runtime.platformName));
                """
                }
                ifEmit(embPlat) {
                  platformName = "linux";
                }
                ifNotEmit(embPlat) {
                  emit(js) {
                  """
                      bevls_name = this.bems_stringToBytes_1(be_BECS_Runtime.prototype.platformName);
                      bevl_platformName = new be_$class/Text:String$().beml_set_bevi_bytes_len_copy(bevls_name, bevls_name.length);
                  """
                  }
                }
                ifNotEmit(embPlat) {
                emit(cc) {
                """
                    beq->bevl_platformName = new BEC_2_4_6_TextString(BECS_Runtime::platformName);
                """
                }
                }
                setName(platformName);
           }
       }
   }
   
   setName(Text:String _name) System:CurrentPlatform {
      name = _name;
      buildProfile();
   }
   
   buildProfile() {
      super.buildProfile();
      dyn strings = Text:Strings.new();
      strings.newline = newline;
   }
   
}

//change System:CurrentPlatform to System:Platforms.current
//init current at start with process
//have .current, .get(string name) which gets from / makes and puts in map
//should probably make things immutable...

class System:Platform {
   
   new() self {
   
      fields {
         Text:String name;
         Text:String properName;
         Logic:Bool isNix;
         Logic:Bool isWin;
         Text:String separator;
         Text:String newline;
         Text:String otherSeparator;
         Text:String nullFile;
         Text:String scriptExt;
      }
   
   }
   
   new(Text:String _name) System:Platform {
      name = _name;
      buildProfile();
   }
   
   buildProfile() {
      //("!!!!!!!!!!!!! platform " + name).print();
      if ((name == "macos") || (name == "linux") || (name == "freebsd")) {
         isNix = true;
         isWin = false;
         separator = "/";
         otherSeparator = "\\";
         nullFile = "/dev/null";
         scriptExt = ".sh";
         if (name == "macos") {
           properName = "MacOS";
         } elseIf (name == "linux") {
           properName = "Linux";
         } elseIf (name == "freebsd") {
           properName = "FreeBSD";
         }
      } elseIf (name == "mswin") {
         isNix = false;
         isWin = true;
         separator = "\\";
         otherSeparator = "/";
         nullFile = "nul";
         scriptExt = ".bat";
         properName = "MSWin";
      } else {
         throw(System:Exception.new("Platform " + name + " is not defined, platform must be defined in System:Platform"));
      }
      dyn strings = Text:Strings.new();
      if (name == "mswin") {
         //newline = strings.dosNewline;
         newline = strings.unixNewline;
      } else {
         newline = strings.unixNewline;
      }
   }
   
}

//future, pass inst, mtd name, (optional) args
//getresult (optional time to wait) (save result in lock, lock will be needed for this)
//also queue/task/worker (queue in, out, things go in, things come out, # workers)

import local class System:ThinThread {
  
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
       dyn toRun = _toRun;
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
     dyn e;
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

import final class System:Thread(ThinThread) {

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
     dyn e;
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

import final class System:Thread:Lock {

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

import System:Thread:ContainerLocker as CLocker;
class System:Thread:ContainerLocker {
  
  new(_container) self {
    fields {
      Lock lock = Lock.new();
      dyn container;
    }
    lock.lock();
    try {
      container = _container;
      lock.unlock();
    } catch (dyn e) {
      lock.unlock();
      throw(e);
    }
  }
  
  contains(key) Bool {
    lock.lock();
    try {
      Bool r = container.contains(key);
      lock.unlock();
    } catch (dyn e) {
      lock.unlock();
      throw(e);
    }
    return(r);
  }

  contains(key, key2) Bool {
    lock.lock();
    try {
      Bool r = container.contains(key, key2);
      lock.unlock();
    } catch (dyn e) {
      lock.unlock();
      throw(e);
    }
    return(r);
  }
  
  get() {
    lock.lock();
    try {
      dyn r = container.get();
      lock.unlock();
    } catch (dyn e) {
      lock.unlock();
      throw(e);
    }
    return(r);
  }
  
  get(key) {
    lock.lock();
    try {
      dyn r = container.get(key);
      lock.unlock();
    } catch (dyn e) {
      lock.unlock();
      throw(e);
    }
    return(r);
  }
  
  getAndClear(key) {
    lock.lock();
    try {
      dyn r = container.get(key);
      container.delete(key);
      lock.unlock();
    } catch (dyn e) {
      lock.unlock();
      throw(e);
    }
    return(r);
  }
  
  get(p, k) {
    lock.lock();
    try {
      dyn r = container.get(p, k);
      lock.unlock();
    } catch (dyn e) {
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
    } catch (dyn e) {
      lock.unlock();
      throw(e);
    }
  }
  
  putReturn(key) {
    lock.lock();
    try {
      dyn r = container.put(key);
      lock.unlock();
    } catch (dyn e) {
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
    } catch (dyn e) {
      lock.unlock();
      throw(e);
    }
  }
  
  putReturn(key, value) {
    lock.lock();
    try {
      dyn r = container.put(key, value);
      lock.unlock();
    } catch (dyn e) {
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
    } catch (dyn e) {
      lock.unlock();
      throw(e);
    }
  }
  
  testAndPut(key, oldValue, value) {
    lock.lock();
    try {
      dyn rc = container.testAndPut(key, oldValue, value);
      lock.unlock();
    } catch (dyn e) {
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
    } catch (dyn e) {
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
    } catch (dyn e) {
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
    } catch (dyn e) {
      lock.unlock();
      throw(e);
    }
    return(rc);
  }
  
  putIfAbsent(key, value) Bool {
    lock.lock();
    try {
      if (container.contains(key)) {
        Bool didPut = false;
      } else {
        container.put(key, value);
        didPut = true;
      }
      lock.unlock();
    } catch (dyn e) {
      lock.unlock();
      throw(e);
    }
    return(didPut);
  }
  
  getOrPut(key, value) {
    lock.lock();
    try {
      if (container.contains(key)) {
        dyn result = container.get(key);
      } else {
        container.put(key, value);
        result = value;
      }
      lock.unlock();
    } catch (dyn e) {
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
    } catch (dyn e) {
      lock.unlock();
      throw(e);
    }
  }
  
  delete(key) {
    lock.lock();
    try {
      dyn r = container.delete(key);
      lock.unlock();
    } catch (dyn e) {
      lock.unlock();
      throw(e);
    }
    return(r);
  }
  
  delete(p, k) {
    lock.lock();
    try {
      dyn r = container.delete(p, k);
      lock.unlock();
    } catch (dyn e) {
      lock.unlock();
      throw(e);
    }
    return(r);
  }

  lengthGet() Int {
    lock.lock();
    try {
      Int r = container.length;
      lock.unlock();
    } catch (dyn e) {
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
    } catch (dyn e) {
      lock.unlock();
      throw(e);
    }
    return(r);
  }
  
  copyContainer() {
    lock.lock();
    try {
      dyn r = container.copy();
      lock.unlock();
    } catch (dyn e) {
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
    } catch (dyn e) {
      lock.unlock();
      throw(e);
    }
  }
  
  close() self {
    lock.lock();
    try {
      container.close();
      lock.unlock();
    } catch (dyn e) {
      lock.unlock();
      throw(e);
    }
  }
  
}

import System:Thread:ObjectLocker as OLocker;
class OLocker {
  
  new() self {
    fields {
      Lock lock = Lock.new();
    }
  }
  
  new(_obj) self {
    new();
    fields {
      dyn obj;
    }
    lock.lock();
    try {
      obj = _obj;
      lock.unlock();
    } catch (dyn e) {
      lock.unlock();
      throw(e);
    }
  }
  
  oGet() {
    lock.lock();
    try {
      dyn r = obj;
      lock.unlock();
    } catch (dyn e) {
      lock.unlock();
      throw(e);
    }
    return(r);
  }
  
  getAndClear() {
    lock.lock();
    try {
      dyn r = obj;
      obj = null;
      lock.unlock();
    } catch (dyn e) {
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
    } catch (dyn e) {
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
    } catch (dyn e) {
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

import Text:Tokenizer as TT;
import Text:Glob;

class Glob {
   
   new(String _glob) self {
      self.glob = _glob;
   }
   
   globSet(String _glob) {
      TT tok = TT.new("*?", true);
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
         if (pos == input.length) {
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
         if (pos <= input.length) { return(caseMatch(node.next, input, pos, null)); } else { return(false); }
      }
      Int found = input.find(val, pos);
      if (def(found)) {
         if (found == pos) {
            return(caseMatch(node.next, input, pos + val.length, null));
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
      while (pos <= input.length) {
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

import Container:Single;
import Container:LinkedList:Node;
