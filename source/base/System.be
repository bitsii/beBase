// Copyright 2006 The Brace Authors. All rights reserved.
// Use of this source code is governed by the BSD-3-Clause
// license that can be found in the LICENSE file.

 use Container:LinkedList;
 use Container:LinkedList:Node;
 use Container:LinkedList:Iterator as LIter;
 use Container:Map;
 use System:Random;
 use System:Identity;
 
 emit(cs) {
     """
 using System;
 using System.Security.Cryptography;
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
      any init;
      emit(jv,cs,js) {
      """
      bevl_init = beva_inst.bemc_getInitial();
      """
      }
      emit(cc) {
      """
      bevl_init = beva_inst->bemc_getInitial();
      """
      }
      if (undef(init)) {
        init = inst;
          emit(jv,cs,js) {
          """
          beva_inst.bemc_setInitial(bevl_init);
          """
          }
          emit(cc) {
          """
          beva_inst->bemc_setInitial(bevl_init);
          """
          }
      }
      return(init);
    }
    
    //second pass - calling default - can only be called on instances which have the method :-)
    notNullInitDefault(inst) {
      any init;
      emit(jv,cs,js) {
      """
      bevl_init = beva_inst.bemc_getInitial();
      """
      }
      emit(cc) {
      """
      bevl_init = beva_inst->bemc_getInitial();
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
      any init;
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
      any init;
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
      emit(cc) {
      """
      srand(time(0));
      """
      }
      
   }
   
   getInt() Int {
     return(getInt(Int.new()));
   }
   
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
      emit(cc) {
      """
      beva_value->bevi_int = rand();
      """
      }
      emit(js) {
      """
      beva_value.bevi_int = Math.random() * Number.MAX_SAFE_INTEGER;
      """
      }
      return(value);
   }
   
   getIntMax(Int max) Int {
      return(getInt(Int.new()).absValue().modulusValue(max));
   }
   
   getIntMax(Int value, Int max) Int {
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
          str.setIntUnchecked(i, getIntMax(value, 26@).addValue(65@));
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
         //any vthing;
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
                    bevl_platformName = new BEC_2_4_6_TextString(BECS_Runtime::platformName);
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




