// Copyright 2006 Craig Welch
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

 use Text:String;
 use Logic:Bool;
 use Container:LinkedList;
 use Container:LinkedList:Node;
 use Container:Map;
 use Math:Int;
 use System:Random;
 use System:Identity;
 
emit(cs) {
    """
using System;
using System.Security.Cryptography;
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

use final class System:Initializer {

    initializeIfShould(inst) {
        if (inst.can("default", 0)) {
            return(initializeIt(inst));
        }
        return(inst.new());
    }
    
    //don't you call this, it's just for use by the lang init TODO expose notNull characteristic on the runtime class and key off that
    //also, this is one of the "special" calls, it can't reference itself (in c it's called with a null self reference)
    //first pass, just construct and set the class inst
    notNullInitConstruct(inst) {
     emit(c) {
      """
/*-attr- -dec-*/
BERT_ClassDef* bevl_scldef;
      """
      }
      var init;
      emit(c) {
      """
         bevl_scldef = (BERT_ClassDef*) $inst&*[berdef];
         $init=* berv_sts->onceInstances[bevl_scldef->classId];
      """
      }
      emit(jv,cs,js) {
      """
      bevl_init = beva_inst.bemc_getInitial();
      """
      }
      if (undef(init)) {
        init = inst;
        emit(c) {
          """
             berv_sts->onceInstances[bevl_scldef->classId] = $init*;
             BERF_Add_Once(berv_sts, $init&*);
          """
          }
          emit(jv,cs,js) {
          """
          beva_inst.bemc_setInitial(bevl_init);
          """
          }
      }
      return(init);
    }
    
    //second pass - calling default - can only be called on instances which have the method :-)
    notNullInitDefault(inst) {
    emit(c) {
          """
/*-attr- -dec-*/
BERT_ClassDef* bevl_scldef;
      """
      }
      var init;
      emit(c) {
      """
         bevl_scldef = (BERT_ClassDef*) $inst&*[berdef];
         $init=* berv_sts->onceInstances[bevl_scldef->classId];
      """
      }
      emit(jv,cs,js) {
      """
      bevl_init = beva_inst.bemc_getInitial();
      """
      }
      init.default();
    }
    
    //don't you call this, it's just for use by the lang init TODO expose notNull characteristic on the runtime class and key off that
    //also, this is one of the "special" calls, it can't reference itself (in c it's called with a null self reference)
    notNullInitIt(inst) {
     emit(c) {
      """
/*-attr- -dec-*/
BERT_ClassDef* bevl_scldef;
      """
      }
      var init;
      emit(c) {
      """
         bevl_scldef = (BERT_ClassDef*) $inst&*[berdef];
         $init=* berv_sts->onceInstances[bevl_scldef->classId];
      """
      }
      emit(jv,cs,js) {
      """
      bevl_init = beva_inst.bemc_getInitial();
      """
      }
      if (undef(init)) {
        init = inst;
        if (init.can("default", 0)) {
            init.default();
        }
        emit(c) {
          """
             berv_sts->onceInstances[bevl_scldef->classId] = $init*;
             BERF_Add_Once(berv_sts, $init&*);
          """
          }
          emit(jv,cs,js) {
          """
          beva_inst.bemc_setInitial(bevl_init);
          """
          }
      }
      return(init);
    }
    
    //this is one of the "special" calls, it can't reference itself (in c it's called with a null self reference)
    initializeIt(inst) {
     emit(c) {
      """
/*-attr- -dec-*/
BERT_ClassDef* bevl_scldef;
      """
      }
      var init;
      emit(c) {
      """
         bevl_scldef = (BERT_ClassDef*) $inst&*[berdef];
         $init=* berv_sts->onceInstances[bevl_scldef->classId];
      """
      } 
      emit(jv,cs,js) {
      """
      bevl_init = beva_inst.bemc_getInitial();
      """
      }
      if (undef(init)) {
        init = inst;
        init.default();
        emit(c) {
          """
             berv_sts->onceInstances[bevl_scldef->classId] = $init*;
             BERF_Add_Once(berv_sts, $init&*);
          """
          }
          emit(jv,cs,js) {
          """
          beva_inst.bemc_setInitial(bevl_init);
          """
          }
      }
      return(init);
    }

}

//have PseudoRandom for faster, no crypto option

final class Random {

   emit(jv) {
   """
   
    public java.security.SecureRandom srand = new java.security.SecureRandom();
    
   """
   }
   
   emit(cs) {
   """
   
   public RandomNumberGenerator srand = RNGCryptoServiceProvider.Create();
   
   """
   }

   create() self { }
   
   default() self {
      
      seedNow();
   }
   
   seedNow() Random {
      emit(c) {
      """
      srand(time(0));
      """
      }
      emit(jv) {
      """
      srand.setSeed(srand.generateSeed(8));
      """
      }
      emit(cs) {
      """
      srand = RNGCryptoServiceProvider.Create();
      """
      }
      
   }
   
   //needs to be "getIntoInt", "getInt" makes a new one
   getInt(Int value) Int {
      emit(c) {
      """
      *((BEINT*) ($value&* + bercps)) = rand();
      """
      }
      emit(jv) {
      """
      beva_value.bevi_int = srand.nextInt();
      """
      }
      emit(cs) {
      """
      byte[] rb = new byte[4];
      srand.GetBytes(rb);
      beva_value.bevi_int = BitConverter.ToInt32(rb, 0);
      """
      }
      return(value);
   }
   
   getInt(Int value, Int max) Int {
      return(getInt(value).absValue().modulusValue(max));
   }
   
   getString(Int size) String {
      return(getString(String.new(size), size));
   }
   
   getString(String str, Int size) String {
      if (str.capacity < size) {
        str.capacity = size;
      }
      str.size = size.copy();
      ifEmit(c) {
        str.setIntUnchecked(size, 0@);
      }
      //TODO for jv, cs could just call nextBytes
      Int value = Int.new();
      for (Int i = 0;i < size;i++=) {
          //TODO lc and ints too
          str.setIntUnchecked(i, getInt(value, 26@).addValue(65@));
      }
      return(str);
   }
   
}

final class System:Thing {
   
   emit(c) {
   """
/*-attr- -firstSlotNative-*/
   """
   }
   
   vthingGet() { }
   
   vthingSet(vthing) { }
   
   new() self {
      
      fields {
         var vthing;
      }
      
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
   
   add(other) System:BasePath {
      if (other.path == Text:Strings.new().empty) {
         return(copy());
      }
      if (other.isAbsolute) {
         return(other.copy());
      }
      LinkedList fpath = path.split(separator);
      LinkedList spath = other.path.split(separator);
      for (var i = spath.iterator;i.hasNext;;) {
         var l = i.next;
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
      for (var i = fpath.iterator;i.hasNext;;) {
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
   
   makeNonAbsolute() System:BasePath {
      if (self.isAbsolute) {
         path = path.substring(1, path.size);
      }
   }
   
   makeAbsolute() System:BasePath {
      if (self.isAbsolute!) {
         path = separator + path;
      }
   }
   
   trimParents(Int howMany) System:BasePath {
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
   
   addStep(step) System:BasePath {
      LinkedList fpath = path.split(separator);
      fpath.addValue(step);
      path = path.join(separator, fpath);
   }
   
   deleteFirstStep() System:BasePath {
      Int fp = path.find(separator);
      if (undef(fp)) {
         path = Text:Strings.new().empty;
      } else {
         path = path.substring(fp + 1, path.size);
      }
   }
   
   addStepList(LinkedList sl) {
      LinkedList fpath = path.split(separator);
      for (var i = sl.iterator;i.hasNext;;) {
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
   
   copy() {
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
         var ll = st.subList(start);
      } else {
         ll = st.subList(start, end);
      }
      var res = create();
      res.separator = separator;
      res.path = Text:Strings.join(separator, ll);
      return(res);
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

final class System:CurrentPlatform (System:Platform) {

    create() self { }
   
   default() self {
       ifEmit(jv,cs, js) {
           if (undef(name)) {
                String platformName;
                emit(jv) {
                """
                    bevl_platformName = new BEC_4_6_TextString(be.BELS_Base.BECS_Runtime.platformName.getBytes("UTF-8"));
                """
                }
                emit(cs) {
                """
                    bevl_platformName = new BEC_4_6_TextString(System.Text.Encoding.UTF8.GetBytes(be.BELS_Base.BECS_Runtime.platformName));
                """
                }
                emit(js) {
                """
                    bevls_name = this.bems_stringToBytes_1(be_BELS_Base_BECS_Runtime.prototype.platformName);
                    bevl_platformName = new be_BEL_4_Base_BEC_4_6_TextString().beml_set_bevi_bytes_len_copy(bevls_name, bevls_name.length);
                """
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
      var strings = Text:Strings.new();
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
         Logic:Bool isNix;
         Logic:Bool isWin;
         Text:String separator;
         Text:String newline;
         Text:String otherSeparator;
         Text:String nullFile;
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
      } elif (name == "mswin") {
         isNix = false;
         isWin = true;
         separator = "\\";
         otherSeparator = "/";
         nullFile = "nul";
      } else {
         throw(System:Exception.new("Platform " + name + " is not defined, platform must be defined in System:Platform"));
      }
      var strings = Text:Strings.new();
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
     BEC_6_10_SystemThinThread st = (BEC_6_10_SystemThinThread) sysThreadInst;
     st.bem_main_0();
   }
   """
   }
   emit(jv) {
   """
   volatile public Thread bevi_thread;
   static class BECS_Runnable implements Runnable {
    volatile BEC_6_10_SystemThinThread bevi_sysThread = null;
    BECS_Runnable(BEC_6_10_SystemThinThread bevi_sysThread) {
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
   
   new(_toRun) self {
     fields {
       var toRun = _toRun;
     }
   }
   
   start() self {
     emit(cs) {
     """
     bevi_thread = new Thread(BEC_6_10_SystemThinThread.bems_run);
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
   }
   
   main() {
     var e;
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
     var e;
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
  
  lock() Bool {
    emit(cs) {
    """
    Monitor.Enter(this);
    """
    }
    emit(jv) {
    """
    bevi_lock.lock();
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
    return(true);
  }

}

use System:Thread:ContainerLocker as CLocker;
class System:Thread:ContainerLocker {
  
  new(_container) self {
    fields {
      Lock lock = Lock.new();
      var container;
    }
    lock.lock();
    try {
      container = _container;
      lock.unlock();
    } catch (var e) {
      lock.unlock();
      throw(e);
    }
  }
  
  has(key) Bool {
    lock.lock();
    try {
      Bool r = container.has(key);
      lock.unlock();
    } catch (var e) {
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
    } catch (var e) {
      lock.unlock();
      throw(e);
    }
    return(r);
  }
  
  get() {
    lock.lock();
    try {
      var r = container.get();
      lock.unlock();
    } catch (var e) {
      lock.unlock();
      throw(e);
    }
    return(r);
  }
  
  get(key) {
    lock.lock();
    try {
      var r = container.get(key);
      lock.unlock();
    } catch (var e) {
      lock.unlock();
      throw(e);
    }
    return(r);
  }
  
  getAndClear(key) {
    lock.lock();
    try {
      var r = container.get(key);
      container.delete(key);
      lock.unlock();
    } catch (var e) {
      lock.unlock();
      throw(e);
    }
    return(r);
  }
  
  get(p, k) {
    lock.lock();
    try {
      var r = container.get(p, k);
      lock.unlock();
    } catch (var e) {
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
    } catch (var e) {
      lock.unlock();
      throw(e);
    }
  }
  
  putReturn(key) {
    lock.lock();
    try {
      var r = container.put(key);
      lock.unlock();
    } catch (var e) {
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
    } catch (var e) {
      lock.unlock();
      throw(e);
    }
  }
  
  putReturn(key, value) {
    lock.lock();
    try {
      var r = container.put(key, value);
      lock.unlock();
    } catch (var e) {
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
    } catch (var e) {
      lock.unlock();
      throw(e);
    }
  }
  
  testAndPut(key, oldValue, value) {
    lock.lock();
    try {
      var rc = container.testAndPut(key, oldValue, value);
      lock.unlock();
    } catch (var e) {
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
    } catch (var e) {
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
    } catch (var e) {
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
    } catch (var e) {
      lock.unlock();
      throw(e);
    }
    return(didPut);
  }
  
  getOrPut(key, value) {
    lock.lock();
    try {
      if (container.has(key)) {
        var result = container.get(key);
      } else {
        container.put(key, value);
        result = value;
      }
      lock.unlock();
    } catch (var e) {
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
    } catch (var e) {
      lock.unlock();
      throw(e);
    }
  }
  
  delete(key) {
    lock.lock();
    try {
      var r = container.delete(key);
      lock.unlock();
    } catch (var e) {
      lock.unlock();
      throw(e);
    }
    return(r);
  }
  
  delete(p, k) {
    lock.lock();
    try {
      var r = container.delete(p, k);
      lock.unlock();
    } catch (var e) {
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
    } catch (var e) {
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
    } catch (var e) {
      lock.unlock();
      throw(e);
    }
    return(r);
  }
  
  copyContainer() {
    lock.lock();
    try {
      var r = container.copy();
      lock.unlock();
    } catch (var e) {
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
    } catch (var e) {
      lock.unlock();
      throw(e);
    }
  }
  
  close() self {
    lock.lock();
    try {
      container.close();
      lock.unlock();
    } catch (var e) {
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
      var obj;
    }
    lock.lock();
    try {
      obj = _obj;
      lock.unlock();
    } catch (var e) {
      lock.unlock();
      throw(e);
    }
  }
  
  oGet() {
    lock.lock();
    try {
      var r = obj;
      lock.unlock();
    } catch (var e) {
      lock.unlock();
      throw(e);
    }
    return(r);
  }
  
  getAndClear() {
    lock.lock();
    try {
      var r = obj;
      obj = null;
      lock.unlock();
    } catch (var e) {
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
    } catch (var e) {
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
    } catch (var e) {
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


