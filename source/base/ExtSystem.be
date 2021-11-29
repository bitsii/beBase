// Copyright 2006 The Brace Authors. All rights reserved.
// Use of this source code is governed by the BSD-3-Clause
// license that can be found in the LICENSE file.

use Container:LinkedList:Iterator as LIter;

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

use final class System:Main {

    create() self { }
   
   default() self {
      
   }
   
    main() {
    
    }
    
}

final class System:Types {

   create() self { }
   
   default() self {
      
      fields {
         Math:Int int = Math:Int.new();
         Logic:Bool bool = false;
         Math:Float float = Math:Float.new();
         System:Thing thing = System:Thing.new();
         Text:String string = Text:String.new();
         Text:String byteBuffer = Text:String.new();
//         IO:File:Writer fileWriter = IO:File:Writer.new();
//         IO:File:Reader fileReader = IO:File:Reader.new();
      }
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
      LinkedList fpath = path.split(separator);
      String npath = Text:Strings.new().join(newsep, fpath);
      return(npath);
   }
   
   stepListGet() LinkedList {
      return(path.split(separator));
   }
   
   firstStepGet() String {
      return(path.split(separator).first);
   }
   
   lastStepGet() String {
      return(path.split(separator).last);
   }
   
   add(other) self {
      if (other.path == Text:Strings.new().empty) {
         return(copy());
      }
      if (other.isAbsolute) {
         return(other.copy());
      }
      LinkedList fpath = path.split(separator);
      LinkedList spath = other.path.split(separator);
      for (LIter i = spath.linkedListIterator;i.hasNext;;) {
         any l = i.next;
         fpath.addValue(l);
      }
      String rstr = Text:Strings.new().join(separator, fpath);
      System:BasePath rpath = copy();
      rpath = rpath.fromString(rstr);
      //("Added " + path + " to " + other.path + " and got " + rstr).print();
      return(rpath);
   }
   
   parentGet() System:BasePath  {
      LinkedList fpath = path.split(separator);
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
      if (undef(path) || path.toString().size < 1) { return(false); }
      if (path.getPoint(0) == separator) {
         return(true);
      }
      return(false);
   }
   
   makeNonAbsolute() self {
      if (self.isAbsolute) {
         path = path.substring(1, path.size);
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
         LinkedList fpath = path.split(separator);
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
      LinkedList fpath = path.split(separator);
      fpath.addValue(step);
      path = path.join(separator, fpath);
   }
   
   deleteFirstStep() self {
      Int fp = path.find(separator);
      if (undef(fp)) {
         path = Text:Strings.new().empty;
      } else {
         path = path.substring(fp + 1, path.size);
      }
   }
   
   addStepList(LinkedList sl) {
      LinkedList fpath = path.split(separator);
      for (LIter i = sl.linkedListIterator;i.hasNext;;) {
         fpath.addValue(i.next);
      }
      path = path.join(separator, fpath);
   }
   
   addSteps(step) {
      return(addStep(step));
   }
   
   addSteps(s1, s2) {
      LinkedList fpath = path.split(separator);
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
      return(path.split(separator));
   }
   
   hashGet() Math:Int {
      return(path.hash);
   }
   
   notEquals(x) Bool {
      return(equals(x)!);
   }
   
   equals(x) Bool {
   //if (undef(x)) { "xnull".print(); }
   //if (x.otherType(self)) { "xots".print(); }
   //if (path != x.path) { ("xpne |" + path + "| |" + x.path + "|").print(); }
      if (undef(x) || x.otherType(self) || path != x.path) {
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
         any ll = st.subList(start);
      } else {
         ll = st.subList(start, end);
      }
      any res = create();
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
                    bevl_platformName = (new BEC_2_4_6_TextString())->bems_ccsnew(BECS_Runtime::platformName);
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
      any strings = Text:Strings.new();
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
      any strings = Text:Strings.new();
      if (name == "mswin") {
         //newline = strings.dosNewline;
         newline = strings.unixNewline;
      } else {
         newline = strings.unixNewline;
      }
   }
   
}

final class System:GarbageCollector {

    create() self { }
   
   default() self {
      
   }
   
   doFullCollection() {
   emit(c) {
   """
   BERF_Collect(berv_sts);
   """
   }
   }

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

use class System:ExceptionTranslator {
  
  default() self { }
  
  translateEmittedException(Exception tt) {
    try {
      translateEmittedExceptionInner(tt);
    } catch(any e) {
      ("Exception translation failed").print();
      if (def(e) && e.can("getDescription", 0)) {
        e.description.print();
        //try { e.print(); } catch (any ee) { }
      }
    }
  }

  translateEmittedExceptionInner(Exception tt) {
    if (def(tt.translated) && tt.translated) {
      return(self);
    }
    if (undef(tt.vv)) {
      tt.vv = false;
    }
    tt.translated = true;
    if (def(tt.framesText) && def(tt.lang) && (tt.lang == "cs" || tt.lang == "js")) {
       Text:Tokenizer ltok = Text:Tokenizer.new("\r\n");
       LinkedList lines = ltok.tokenize(tt.framesText);
       if (tt.lang == "cs") {
           Bool isCs = true;
       } else {
           isCs = false;
       }
       for (String line in lines) {
         if (tt.vv) {
           ("Frame line is " + line).print();
         }
           Int start = line.find("at ");
           String efile = null;
           Int eline = null;
           if (def(start) && start >= 0) {
             if (tt.vv) {
               ("start is " + start).print();
             }
               Int end = line.find(" ", start + 3);
               if (def(end) && end > start) {
                 if (tt.vv) {
                   ("end is " + end).print();
                 }
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
                         if (tt.vv) {
                         ("in js start def").print();
                         }
                         //(
                         end = line.find(")", start + 1);
                         if (def(end)) {
                           if (tt.vv) {
                           ("in js end def").print();
                           }
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
                   String klass = parts.get(1);
                   String mtd = parts.get(2);
                   //("klass |" + klass + "| mtd |" + mtd + "|").print();
                   klass = extractKlass(klass);
                   //("extracted klass |" + klass + "|").print();
                   mtd = extractMethod(mtd);
                   //("extracted mtd |" + mtd + "|").print();
                   fr = Exception:Frame.new(klass, mtd, efile, eline);
                   fr.fileName = getSourceFileName(fr.klassName);
                   tt.addFrame(fr);
                 } else {
                   //is js
                   if (tt.vv) {
                   ("callPart |" + callPart + "|").print();
                   }
                   parts = callPart.split(".");
                   if (parts.size > 1) {
                     if (parts.size > 2) {
                       mtd = parts.get(2);
                       klass = parts.get(1);
                     } else {
                       mtd = parts.get(1);
                       klass = parts.get(0);
                     }
                       mtd = extractMethod(mtd);
                       if (tt.vv) {
                       ("extracted mtd |" + mtd + "|").print();
                       }
                       start = klass.find("BEC_");
                       if (def(start) && start > 0) {
                           end = klass.find("_", start + 4);
                           if (def(end) && end > 0) {
                               //String libLens = klass.substring(start, end);
                               //("libLens |" + libLens + "|").print();
                               //Int libLen = Int.new(libLens);
                               klass = klass.substring(start);
                               if (tt.vv) {
                               ("pre extracted klass |" + klass + "|").print();
                               }
                               klass = extractKlass(klass);
                               if (tt.vv) {
                               ("extracted klass |" + klass + "|").print();
                               }
                               fr = Exception:Frame.new(klass, mtd, efile, eline);
                               fr.fileName = getSourceFileName(fr.klassName);
                               if (tt.vv) {
                               "adding frame".print();
                               }
                               tt.addFrame(fr);
                           } else {
                             if (tt.vv) {
                               "no end".print();
                             }
                           }
                       }
                   }
                 }
               }
           }
       }
       tt.emitLang = tt.lang;
       tt.lang = "be";
       tt.framesText = null;
    } elseIf (def(tt.frames) && def(tt.lang) && tt.lang == "jv") {
       for (Exception:Frame fr in tt.frames) {
           fr.klassName = extractKlassLib(fr.klassName);
           fr.methodName = extractMethod(fr.methodName);
           fr.fileName = getSourceFileName(fr.klassName);
           ifEmit(jv) {
             fr.extractLine();
           }
       }
       tt.emitLang = tt.lang;
       tt.lang = "be";
    } else {
      //("TRANSLATION FAILED").print();
    }
    if (tt.vv) {
     ("translation done").print();
    }
  }
  
   getSourceFileName(String klassName) String {
     //("getting source file name for " + klassName).print();
     any i = createInstance(klassName, false);
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
    return(extractKlass(parts.get(1)));
  }
  
  extractKlass(String klass) String {
    try {
      return(extractKlassInner(klass));
    } catch (any e) {
      
    }
    return(klass);
  }
  
  extractKlassInner(String klass) String {
   if (undef(klass) || klass.begins("BEC_")!) {
       return(klass);
   }
   LinkedList kparts = klass.substring(6).split("_");
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

}

use Container:Single;
use Container:LinkedList:Node;