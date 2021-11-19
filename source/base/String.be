// Copyright 2006 The Brace Authors. All rights reserved.
// Use of this source code is governed by the BSD-3-Clause
// license that can be found in the LICENSE file.

/*
UTF-8 is OK
-strstr is fine for utf8 since all bytes involved in a multibyte start with bit 1 (find)
and strlen (not always ok, embedded nulls) let's decide not to support embedded nulls and to technically only support
"Modified UTF8" or "javastyle utf8 http://stackoverflow.com/questions/6439766/java-utf-8-differences"

lower and upper are not ok, TODO rename to asciiLower and asciiUpper.  (full internationalization should use an external lib)

Keep the ByteIterator as is - it iterates single bytes at a time.  
This is only a problem if we want to be able to tokenize where tokens might be multi-byte character strings.  Use multi-byte
aware byteiterator (MultiByteIterator) and use that by default in tokenizer and string, but use ByteIterator in String (as it is about
bytes, unaware of String/Characters).

It would be great to have a converter for common other formats (UTF-16, etc) to UTF-8
It would be nice to support non-ascii names for methods, variables, etc, could convert to escaped versions while generating

(currently, we only use strlen once when building the string and use internal length value the rest of the time,
there an option to drop independent length value, if we disallow embedded null (modified or js style utf8) then we can just compute length
whenver needed.  Otherwise we would need to keep a separate notion of length, could be a long/int TWINT prepended to buffer with length...).
*/

emit(cs) {
    """
using System.IO;
using System;
    """
}

//size is used mutably, capacity is used immutably, the capacity instance can never = the size instance (cannot be same instance, can be
//same value, of course)
final class String {
   
   emit(c) {
   """
/*-attr- -firstSlotNative-*/
   """
   }
   
   emit(c) {
   """
/*-attr- -freeFirstSlot-*/
   """
   }
   
   emit(c) {
   """
#include <wchar.h>
   """
   }
   
   emit(jv) {
   """
   
    public byte[] bevi_bytes;
    public $class/Text:String$(byte[] bevi_bytes) {
        this.bevi_bytes = bevi_bytes; 
        bevp_size = new $class/Math:Int$(bevi_bytes.length);
        bevp_capacity = new $class/Math:Int$(bevi_bytes.length);
    }
    public $class/Text:String$(byte[] bevi_bytes, int bevi_length) {
      //do copy, isOnce
      this.bevi_bytes = new byte[bevi_length];
      System.arraycopy( bevi_bytes, 0, this.bevi_bytes, 0, bevi_length );
      bevp_size = new $class/Math:Int$(bevi_length);
      bevp_capacity = new $class/Math:Int$(bevi_length);
    }
    public $class/Text:String$(int bevi_length, byte[] bevi_bytes) {
        //do copy, not isOnce
        this.bevi_bytes = new byte[bevi_length];
        System.arraycopy( bevi_bytes, 0, this.bevi_bytes, 0, bevi_length );
        bevp_size = new $class/Math:Int$(bevi_length);
        bevp_capacity = new $class/Math:Int$(bevi_length);
    }
    public $class/Text:String$(String bevi_string) throws Exception {
        byte[] bevi_bytes = bevi_string.getBytes("UTF-8");
        this.bevi_bytes = bevi_bytes; 
        bevp_size = new $class/Math:Int$(bevi_bytes.length);
        bevp_capacity = new $class/Math:Int$(bevi_bytes.length);
    }
    public String bems_toJvString() throws Exception {
        String jvString = new String(bevi_bytes, 0, bevp_size.bevi_int, "UTF-8");
        return jvString;
    }
    
   """
   }
   
   emit(cs) {
   """
   
    public byte[] bevi_bytes;
    public $class/Text:String$(byte[] bevi_bytes) { 
        this.bevi_bytes = bevi_bytes; 
        bevp_size = new $class/Math:Int$(bevi_bytes.Length);
        bevp_capacity = new $class/Math:Int$(bevi_bytes.Length);
    }
    public $class/Text:String$(byte[] bevi_bytes, int bevi_length) { 
      //do copy, isOnce
      this.bevi_bytes = new byte[bevi_length];
      Array.Copy( bevi_bytes, 0, this.bevi_bytes, 0, bevi_length );
      bevp_size = new $class/Math:Int$(bevi_length);
      bevp_capacity = new $class/Math:Int$(bevi_length);
    }
    public $class/Text:String$(int bevi_length, byte[] bevi_bytes) { 
        //do copy, not isOnce
        this.bevi_bytes = new byte[bevi_length];
        Array.Copy( bevi_bytes, 0, this.bevi_bytes, 0, bevi_length );
        bevp_size = new $class/Math:Int$(bevi_length);
        bevp_capacity = new $class/Math:Int$(bevi_length);
    }
    public $class/Text:String$(string bevi_string) {
        byte[] bevi_bytes = System.Text.Encoding.UTF8.GetBytes(bevi_string);
        this.bevi_bytes = bevi_bytes; 
        bevp_size = new $class/Math:Int$(bevi_bytes.Length);
        bevp_capacity = new $class/Math:Int$(bevi_bytes.Length);
    }
    public string bems_toCsString() {
        string csString = System.Text.Encoding.UTF8.GetString(bevi_bytes, 0, bevp_size.bevi_int);
        return csString;
    }
    
   """
   }
   
   emit(cc_classHead) {
   """

#ifdef BEDCC_BGC
    std::vector<unsigned char, gc_allocator<unsigned char>> bevi_bytes;
#endif

#ifdef BEDCC_SGC
    std::vector<unsigned char> bevi_bytes;
#endif

#ifdef BEDCC_BGC
    BEC_2_4_6_TextString(int32_t bevi_length, std::vector<unsigned char, gc_allocator<unsigned char>>& a_bevi_bytes) { 
#endif

#ifdef BEDCC_SGC
    BEC_2_4_6_TextString(int32_t bevi_length, std::vector<unsigned char>& a_bevi_bytes) { 
      BEC_2_6_6_SystemObject** bevls_stackRefs[0] = { };
      BECS_StackFrame bevs_stackFrame(bevls_stackRefs, 0, this);
#endif 
      bevi_bytes = a_bevi_bytes;
      bevp_size = new BEC_2_4_3_MathInt(bevi_length);
      bevp_capacity = new BEC_2_4_3_MathInt(bevi_length);
    } //}
    
    #ifdef BEDCC_BGC
        BEC_2_4_6_TextString(int32_t bevi_length, std::initializer_list<unsigned char> a_bevi_bytes) { 
    #endif
    
    #ifdef BEDCC_SGC
        BEC_2_4_6_TextString(int32_t bevi_length, std::initializer_list<unsigned char> a_bevi_bytes) { 
          BEC_2_6_6_SystemObject** bevls_stackRefs[0] = { };
          BECS_StackFrame bevs_stackFrame(bevls_stackRefs, 0, this);
    #endif 
          bevi_bytes = a_bevi_bytes;
          bevp_size = new BEC_2_4_3_MathInt(bevi_length);
          bevp_capacity = new BEC_2_4_3_MathInt(bevi_length);
        } //}
    
    BEC_2_4_6_TextString() { }
    
    BEC_2_4_6_TextString(std::string bevi_string) {
      BEC_2_6_6_SystemObject** bevls_stackRefs[0] = { };
      BECS_StackFrame bevs_stackFrame(bevls_stackRefs, 0, this);
      bevi_bytes.insert(bevi_bytes.begin(), bevi_string.begin(), bevi_string.end());
      bevp_size = new BEC_2_4_3_MathInt(bevi_string.length()); //is this right?
      bevp_capacity = new BEC_2_4_3_MathInt(bevi_bytes.size());
    }
    
    std::string bems_toCcString();
    
   """
   }
   
   emit("cc") {
   """
   std::string BEC_2_4_6_TextString::bems_toCcString() {
      std::string ccString(bevi_bytes.begin(), bevi_bytes.end());
      ccString.resize(bevp_size->bevi_int);
      return ccString;
    }
   """
   }
   
   emit(js) {
   """
   
    be_$class/Text:String$.prototype.beml_set_bevi_bytes = function(bevi_bytes) {
        this.bevi_bytes = bevi_bytes;
        this.bevp_size = new be_$class/Math:Int$().beml_set_bevi_int(bevi_bytes.length);
        this.bevp_capacity = new be_$class/Math:Int$().beml_set_bevi_int(bevi_bytes.length);
        return this;
    }
    be_$class/Text:String$.prototype.beml_set_bevi_bytes_len = function(bevi_bytes, bevi_length) {
        this.bevi_bytes = bevi_bytes.slice(0);
        this.bevp_size = new be_$class/Math:Int$().beml_set_bevi_int(bevi_length);
        this.bevp_capacity = new be_$class/Math:Int$().beml_set_bevi_int(bevi_length);
        return this;
    }
    be_$class/Text:String$.prototype.beml_set_bevi_bytes_len_copy = function(bevi_bytes, bevi_length) {
        this.bevi_bytes = bevi_bytes.slice(0);
        this.bevp_size = new be_$class/Math:Int$().beml_set_bevi_int(bevi_length);
        this.bevp_capacity = new be_$class/Math:Int$().beml_set_bevi_int(bevi_length);
        return this;
    }
    be_$class/Text:String$.prototype.beml_set_bevi_bytes_len_nocopy = function(bevi_bytes, bevi_length) {
        this.bevi_bytes = bevi_bytes;
        this.bevp_size = new be_$class/Math:Int$().beml_set_bevi_int(bevi_length);
        this.bevp_capacity = new be_$class/Math:Int$().beml_set_bevi_int(bevi_length);
        return this;
    }
    be_$class/Text:String$.prototype.bems_toJsString = function() {
        return this.bems_stringToJsString_1(this);
    }
    be_$class/Text:String$.prototype.bems_new = function(str) {
      this.beml_set_bevi_bytes(this.bems_stringToBytes_1(str));
      return this;
    }
    
   """
   }
   
   vstringGet() {
   //place holder for pointer to native char* string
   }
   
   vstringSet() {
   }
   
   new(Int _capacity) self {
      size = 0;
      capacitySet(_capacity);
      fields {
         //any vstring;
         Int size;
         Int capacity;
         
         //for no alloc copyValue et all
         Int leni;
         Int sizi;
      }
   }
   
   new() self {
      new(0);
   }
   
   capacitySet(Int ncap) self {
      if (undef(capacity)) {
         capacity = 0;
      } elseIf (capacity == ncap) {
        return(self);//nothing to do
      }
      emit(jv) {
      """
      if (this.bevi_bytes == null) {
        this.bevi_bytes = new byte[beva_ncap.bevi_int];
      } else {
        this.bevi_bytes = java.util.Arrays.copyOf(this.bevi_bytes, beva_ncap.bevi_int);
      }
      """
      }
      emit(cs) {
      """
      if (this.bevi_bytes == null) {
        this.bevi_bytes = new byte[beva_ncap.bevi_int];
      } else {
        byte[] bevls_bytes = new byte[beva_ncap.bevi_int];
        Array.Copy(this.bevi_bytes, bevls_bytes, Math.Min(this.bevi_bytes.Length, bevls_bytes.Length));
        this.bevi_bytes = bevls_bytes;
      }
      """
      }
      emit(cc) {
      """
        bevi_bytes.resize(beva_ncap->bevi_int, 0);
      """
      }
      emit(js) {
      """
      if (this.bevi_bytes == null) {
        this.bevi_bytes = new Array(beva_ncap.bevi_int);
      } else {
        this.bevi_bytes = this.bevi_bytes.slice(0, Math.min(beva_ncap.bevi_int, this.bevp_size.bevi_int));
      }
      """
      }
      if (size > ncap) {
        size.setValue(ncap);
      }
      capacity.setValue(ncap);
   }
   
   hexNew(String val) self {
     new(1);
     size.setValue(1);
     setHex(0, val);
   }
   
   getHex(Int pos) String {
        return(getCode(pos, Int.new()).toString(String.new(), 2, 16));
   }
   
   setHex(Int pos, String hval) self {
        Int val = Int.hexNew(hval);
        setCode(pos, val);
   }
   
   addValue(astr) self {
      String str = astr.toString();
      if (undef(leni)) {
        leni = Int.new();
        sizi = Int.new();
      }
      sizi.setValue(str.size);
      sizi.addValue(size);
      //used to add +1 to the right hand of compare, should not be needed
      if (capacity < sizi) { 
        Int nsize = ((sizi + 16) * 3) / 2;
        capacitySet(nsize);
      }
      copyValue(str, 0, str.size, size);
   }
   
   readBuffer() String {
      return(self);
   }
   
   readString() String {
      return(self);
   }
   
   write(stri) {
      self += stri;
   }
   
   writeTo(w) {
      w.write(self);
   }
   
   open() { }
   
   close() { }
   
   //sizeSet TODO check vs capacity, set a null at size + 1
   
   extractString() String {
      String str = copy();
      clear();
      return(str);
   }
   
   clear() this {
      if (size > 0) {
        setIntUnchecked(0, 0);
        size.setValue(0);
      }
   }
   
   codeNew(codei) self {
        new(1);
        size.setValue(1);
        setCodeUnchecked(0, codei);
   }
   
   chomp() String {
      String nl = "\n";
      if (ends(nl)) {
         return(substring(0, size - nl.size));
      }
      nl = "\n";
      if (ends(nl)) {
         return(substring(0, size - nl.size));
      }
      return(self);
   }
   
   copy() self {
      String c = String.new(size + 1);
      c.addValue(self);
      return(c);
   }
   
   begins(String str) Bool {
      Int found = find(str);
      if (undef(found) || found != 0) {
         return(false);
      }
      return(true);
   }
   
   ends(String str) Bool {
      if (undef(str)) { return(false); }
      Int found = find(str, size - str.size);
      if (undef(found)) {
         return(false);
      }
      return(true);
   }
   
   has(String str) Bool {
      if (undef(str) || undef(find(str))) {
        return(false);
      }
      return(true);
   }
   
   isIntegerGet() Bool {
     return(isInteger());
   }
   
   isInteger() Bool {
      Int ic = Int.new();
      for (Int j = 0;j < size;j++=;) {
        getInt(j, ic);
        if (j == 0 && (ic == 43 || ic == 45)) {
          //+-ok
        } elseIf (ic > 57 || ic < 48) {
            return(false);
        }
      }
      return(true);
   }
   
   isAlphaNumGet() Bool {
      Int ic = Int.new();
      for (Int j = 0;j < size;j++=;) {
        getInt(j, ic);
        unless ((ic > 47 && ic < 58) || (ic > 64 && ic < 91) || (ic > 96 && ic < 123)) {
            return(false);
        }
      }
      return(true);
   }
   
   isAlphaNumericGet() Bool {
     return(isAlphaNumGet());
   }
   
   lowerValue() self {
      Int vc = Int.new();
      for (Int j = 0;j < size;j++=;) {
        getInt(j, vc);
        if ((vc > 64) && (vc < 91)) {
            vc += 32;
            setIntUnchecked(j, vc);
         }
      }
   }
   
   lower() String {
      return(copy().lowerValue());
   }
   
   upperValue() self {
      Int vc = Int.new();
      for (Int j = 0;j < size;j++=;) {
        getInt(j, vc);
        if ((vc > 96) && (vc < 123)) {
            vc -= 32;
            setIntUnchecked(j, vc);
        }
      }
   }
   
   upper() String {
       return(copy().upperValue());
   }
   
   swap0(String from, String to) {
      return(Text:Strings.join(to, self.split(from)));//so, change the values....TODO and have this be a mutator
      //doesn't work in some cases (trailing case)
   }
   
   swapFirst(String from, String to) {
      //("in swap 2").print();
      String res = String.new();
      Int last = 0;
      nxt = 0;
      Int nxt = find(from, last);
      if (def(nxt)) {
        res += substring(last, nxt);
        res += to;
        last = nxt + from.size;
        res += substring(last, self.size);
      } else {
        return(from.copy());
      }
      return(res);
   }
   
   swap(String from, String to) {
      //("in swap 2").print();
      String res = String.new();
      Int last = 0;
      nxt = 0;
      while (def(nxt)) {
        Int nxt = find(from, last);
        if (def(nxt)) {
          res += substring(last, nxt);
          res += to;
          last = nxt + from.size;
          //("res 1 " + res).print();
        } else {
          res += substring(last, self.size);
          //("res 2 " + res).print();
        }
      }
      return(res);
   }
   
   //UTF 8 point
   getPoint(Int posi) String {
      String buf = String.new(2);//Would it be better if this was 4?
      Text:MultiByteIterator j = self.mbiter;
      for (Int i = 0;i < posi;i++=) {
         j.next(buf);
      }
      String y = j.next(buf).toString();
      return(y);
   }
   
   hashValue(Int into) Int {
      Int c = Int.new();
      into.setValue(0);
      for (Int j = 0;j < size;j++=;) {
        getInt(j, c);
        into *= 31;
        into += c;
      }
      //return(into.absValue());
      return(into);
   }
   
   hashGet() Int {
      return(hashValue(Int.new()));
   }
   
   getCode(Int pos) Int {
      return(getCode(pos, Int.new()));
   }
   
   getInt(Int pos, Int into) Int {
   emit(c) {
   """
/*-attr- -dec-*/
char* bevl_str;
   """
      }
      if (pos >= 0 && size > pos) {
         emit(c) {
         """
         bevl_str = (char*) bevs[bercps];
         *((BEINT*) ($into&* + bercps)) = (BEINT) bevl_str[*((BEINT*) ($pos&* + bercps))];
         """
         }
         emit(jv) {
         """
         beva_into.bevi_int = (int) bevi_bytes[beva_pos.bevi_int];
         """
         }
         emit(cs) {
         """
         beva_into.bevi_int = (int) bevi_bytes[beva_pos.bevi_int];
         if (beva_into.bevi_int > 127) {
            beva_into.bevi_int -= 256;
         }
         """
         }
         emit(js) {
         """
         beva_into.bevi_int = this.bevi_bytes[beva_pos.bevi_int];
         if (beva_into.bevi_int > 127) {
            beva_into.bevi_int -= 256;
         }
         """
         }
         emit(cc) {
         """
         beva_into->bevi_int = (int32_t) bevi_bytes[beva_pos->bevi_int];
         if (beva_into->bevi_int > 127) {
            beva_into->bevi_int -= 256;
         }
         """
         }
      } else {
        return(null);
      }
      return(into);
   }
   
   getCode(Int pos, Int into) Int {
   emit(c) {
   """
/*-attr- -dec-*/
char* bevl_str;
BEINT bevl_val;
   """
      }
      if (pos >= 0 && size > pos) {
         emit(c) {
         """
         bevl_str = (char*) bevs[bercps];
         bevl_val = (BEINT) bevl_str[*((BEINT*) ($pos&* + bercps))];
         if (bevl_val < 0) {
            bevl_val = bevl_val + 256;
         }
         *((BEINT*) ($into&* + bercps)) = bevl_val;
         """
         }
         emit(jv) {
         """
         beva_into.bevi_int = (int) bevi_bytes[beva_pos.bevi_int];
         if (beva_into.bevi_int < 0) {
            beva_into.bevi_int += 256;
         }
         """
         }
         emit(cs) {
         """
         beva_into.bevi_int = (int) bevi_bytes[beva_pos.bevi_int];
         """
         }
         emit(js) {
         """
         beva_into.bevi_int = this.bevi_bytes[beva_pos.bevi_int];
         """
         }
         emit(cc) {
         """
         beva_into->bevi_int = bevi_bytes[beva_pos->bevi_int];
         """
         }
      } else {
        return(null);
      }
      return(into);
   }
   
   setInt(Int pos, Int into) self {
      if (pos >= 0 && size > pos) {
           setIntUnchecked(pos, into);
      }
   }
   
   setCode(Int pos, Int into) self {
      if (pos >= 0 && size > pos) {
           setCodeUnchecked(pos, into);
      }
   }
   
   toAlphaNum() String {
     String input = self;
     Int insz = input.size.copy();
     String output = String.new(insz);
     Int c = Int.new();
     Int p = 0;
     for (Int i = 0;i < insz;i++=) {
       input.getInt(i, c);
       if ((c > 64 && c < 91) || (c > 96 && c < 123) || (c > 47 && c < 58)) {
        output.setIntUnchecked(p, c);
        p++=;
       }
     }
     output.size = p;
     return(output);
   }
   
   isEmptyGet() Bool {
    if (size <= 0) {
        return(true);
    }
    return(false);
   }
   
   setIntUnchecked(Int pos, Int into) self {
   emit(c) {
   """
/*-attr- -dec-*/
char* bevl_str;
   """
      }
      
     emit(c) {
     """
     bevl_str = (char*) bevs[bercps];
     bevl_str[*((BEINT*) ($pos&* + bercps))] = (char) *((BEINT*) ($into&* + bercps));
     """
     }
     emit(jv) {
     """
     bevi_bytes[beva_pos.bevi_int] = (byte) beva_into.bevi_int;
     """
     }
     emit(cs) {
     """
     int twvls_b = beva_into.bevi_int;
     if (twvls_b < 0) {
        twvls_b += 256;
     }
     bevi_bytes[beva_pos.bevi_int] = (byte) twvls_b;
     """
     }
     emit(js) {
     """
     var twvls_b = beva_into.bevi_int;
     if (twvls_b < 0) {
        twvls_b += 256;
     }
     this.bevi_bytes[beva_pos.bevi_int] = twvls_b;
     """
     }
     emit(cc) {
     """
     int32_t twvls_b = beva_into->bevi_int;
     if (twvls_b < 0) {
        twvls_b += 256;
     }
     bevi_bytes[beva_pos->bevi_int] = (unsigned char) twvls_b;
     """
     }
   }
   
   setCodeUnchecked(Int pos, Int into) self {
   emit(c) {
   """
/*-attr- -dec-*/
char* bevl_str;
BEINT bevl_val;
   """
      }
      
     emit(c) {
     """
     bevl_str = (char*) bevs[bercps];
     bevl_val = *((BEINT*) ($into&* + bercps));
     if (bevl_val > 127) {
        bevl_val = bevl_val - 256;
     }
     bevl_str[*((BEINT*) ($pos&* + bercps))] = (char) bevl_val;
     """
     }
     emit(jv) {
     """
     int twvls_b = beva_into.bevi_int;
     if (twvls_b > 127) {
        twvls_b -= 256;
     }
     bevi_bytes[beva_pos.bevi_int] = (byte) twvls_b;
     """
     }
     emit(cs) {
     """
     bevi_bytes[beva_pos.bevi_int] = (byte) beva_into.bevi_int;
     """
     }
     emit(js) {
     """
     this.bevi_bytes[beva_pos.bevi_int] = beva_into.bevi_int;
     """
     }
     emit(cc) {
     """
     bevi_bytes[beva_pos->bevi_int] = (unsigned char) beva_into->bevi_int;
     """
     }
   }
   
   reverseFind(String str) Int {
     return(rfind(str));
   }
   
   rfind(String str) Int {
     //this could be better :-) probably with an override direction to the main find call
     //also, should do utf8 aware reverse
     Int rpos = copy().reverseBytes().find(str.copy().reverseBytes());
     //("rpos " + rpos).print();
     if (def(rpos)) {
        rpos += str.size;
        return(size - rpos);
     }
     return(null);
   }
   
   find(String str) Int {
      return(find(str, 0));
   }
   
   find(String str, Int start) Int {
      //naive version
      //Boyer–Moore if str.size > some value?  all current uses practically speaking are single-char
      if (undef(str) || undef(start) || start < 0 || start >= size || str.size > size || size == 0 || str.size == 0) {
         return(null);
      }
      
      Int end = size;//this should be able to be reduced based on str.size TODO
      Int current = start.copy();
      Int myval = Int.new();
      Int strfirst = Int.new();
      str.getInt(0, strfirst);
      
      Int strsize = str.size;
      
      if (strsize > 1) {
          Int strval = Int.new();
          Int current2 = Int.new();
          Int end2 = Int.new();
      }
      Int currentstr2 = Int.new();
      while (current < end) {
         self.getInt(current, myval);
         if (myval == strfirst) {
                if (strsize == 1) {
                    return(current);
                }
                current2.setValue(current);
                current2++=;
                end2.setValue(current);
                end2 += str.size;
                if (end2 > size) {
                    return(null);//doesn't fit
                }
                currentstr2.setValue(1);
                while (current2 < end2) {
                    self.getInt(current2, myval);
                    str.getInt(currentstr2, strval);
                    if (myval != strval) {
                        break;
                    }
                    current2++=;
                    currentstr2++=;
                }
                if (current2 == end2) {
                    return(current);
                }
         }
         current++=;
      }
      return(null);
   }
   
   split(String delim) Container:LinkedList {
      Container:LinkedList splits = Container:LinkedList.new();
      Int last = 0;
      Int i = find(delim, last);
      Int ds = delim.size;
      while (def(i)) {
            splits.addValue(substring(last, i));
            last = i + ds;
            i = find(delim, last);
      }
      if (last < size) {
         splits.addValue(substring(last, size));
      }
      return(splits);
   }
   
   join(String delim, splits) String {
      return(Text:Strings.join(delim, splits));
   }
   
   splitLines() Container:LinkedList {
      return(Text:Strings.lineSplitter.tokenize(self));
   }

   toString() Text:String {
      return(self);
   }
   
    compare(stri) Int {
        Int mysize;
        Int osize;
        Int maxsize;
        Int myret;
        if (undef(stri) || stri.otherType(self)) {
            return(null);
        }
        mysize = size;
        osize = stri.size;
        if (mysize > osize) {
            maxsize = osize;
        } else {
            maxsize = mysize;
        }
        myret = Int.new();
        Int mv = Int.new();
        Int ov = Int.new();
        for (Int i = 0;i < maxsize;i++=) {
            self.getCode(i, mv);
            stri.getCode(i, ov);
            if (mv != ov) {
                if (mv > ov) {
                    return(1);
                } else {
                    return(-1);
                }
            }
        }
        if (myret == 0) {
            if (mysize > osize) {
                myret = 1;
            } elseIf (osize > mysize) {
                myret = -1;
            }
        }
        return(myret);
    }
   
   lesser(String stri) Logic:Bool {
      if (undef(stri)) { return(null); }
      if (compare(stri) == -1) {
         return(true);
      }
      return(false);
   }
   
   greater(String stri) Logic:Bool {
      if (undef(stri)) { return(null); }
      if (compare(stri) == 1) {
         return(true);
      }
      return(false);
   }
   
   equals(stri) Logic:Bool {
   emit(jv) {
  """
    $class/Text:String$ bevls_stri = ($class/Text:String$) beva_stri;
    if (this.bevp_size.bevi_int == bevls_stri.bevp_size.bevi_int) {
       for (int i = 0;i < this.bevp_size.bevi_int;i++) {
          if (this.bevi_bytes[i] != bevls_stri.bevi_bytes[i]) {
            return be.BECS_Runtime.boolFalse;
          }
       }
       return be.BECS_Runtime.boolTrue;
   }
  """
  }
  emit(cs) {
  """
  var bevls_stri = beva_stri as $class/Text:String$;
    if (this.bevp_size.bevi_int == bevls_stri.bevp_size.bevi_int) {
       for (int i = 0;i < this.bevp_size.bevi_int;i++) {
          if (this.bevi_bytes[i] != bevls_stri.bevi_bytes[i]) {
            return be.BECS_Runtime.boolFalse;
          }
       }
       return be.BECS_Runtime.boolTrue;
   }
  """
  }
  emit(cc) {
  """
#ifndef BEDCC_NORTTI
      BEC_2_4_6_TextString* bevls_stri = dynamic_cast<BEC_2_4_6_TextString*>(beva_stri);
#endif
#ifdef BEDCC_NORTTI
      BEC_2_4_6_TextString* bevls_stri = static_cast<BEC_2_4_6_TextString*>(beva_stri);
#endif
    if (bevp_size->bevi_int == bevls_stri->bevp_size->bevi_int) {
       for (int32_t i = 0;i < bevp_size->bevi_int;i++) {
          if (bevi_bytes[i] != bevls_stri->bevi_bytes[i]) {
            return BECS_Runtime::boolFalse;
          }
       }
       return BECS_Runtime::boolTrue;
   }
  """
  }
  emit(js) {
   """
   if (this.bevp_size.bevi_int === beva_stri.bevp_size.bevi_int) {
       for (var i = 0;i < this.bevp_size.bevi_int;i++) {
          if (this.bevi_bytes[i] !== beva_stri.bevi_bytes[i]) {
            //console.log("diff bytes at " + i);
            //console.log(this.bevi_bytes[i]);
            //console.log(beva_stri.bevi_bytes[i]);
            return be_BECS_Runtime.prototype.boolFalse;
          }
       }
       return be_BECS_Runtime.prototype.boolTrue;
   }
   """
   }
   return(false);
   }
   
   notEquals(str) Logic:Bool {
      return(equals(str).not());
   }
   
    add(astr) String {
        String str = astr.toString();
        String res = String.new(size + str.size);
        res.copyValue(self, 0, size, 0);
        res.copyValue(str, 0, str.size, size);
        return(res);
    }
   
   create() self { return(String.new()); }
   
   // Reader:readIntoBuffer (buffer, offset)
   copyValue(String org, Int starti, Int endi, Int dstarti) self {
      if ((starti < 0) || ((starti > org.size) || (endi > org.size))) {
         throw(System:Exception.new("copyValue request out of bounds"));
      } else {
      
         //these are members to avoid alloc cost during repeat operations (leni, sizi) (only where capacity unchanged)
         if (undef(leni)) {
            leni = Int.new();
            sizi = Int.new();
         }
         leni.setValue(endi);
         leni -= starti;
         Int mleni = leni;//for inline ref, until props supported
         
         sizi.setValue(dstarti);
         sizi += leni;
         
         if (sizi > capacity) {
            self.capacity = sizi;
         }
         
         emit(jv) {
         """
         //source, sourceStart, dest, destStart, length
         System.arraycopy(beva_org.bevi_bytes, beva_starti.bevi_int, this.bevi_bytes, beva_dstarti.bevi_int, bevl_mleni.bevi_int); 
         """
         }
         
         emit(cs) {
         """
         //source, sourceStart, dest, destStart, length
         Array.Copy(beva_org.bevi_bytes, beva_starti.bevi_int, this.bevi_bytes, beva_dstarti.bevi_int, bevl_mleni.bevi_int); 
         """
         }
         
         emit(cc) {
         """
         for (int32_t i = 0; i < bevl_mleni->bevi_int;i++) {
            bevi_bytes[i + beva_dstarti->bevi_int] = beva_org->bevi_bytes[i + beva_starti->bevi_int];
         }
         """
         }
         
         emit(js) {
         """
         for (var i = 0; i < bevl_mleni.bevi_int;i++) {
            this.bevi_bytes[i + beva_dstarti.bevi_int] = beva_org.bevi_bytes[i + beva_starti.bevi_int];
         }
         """
         }
         
         if (sizi > size) {
            ifEmit(c) {
                setIntUnchecked(sizi, 0);
            }
            size.setValue(sizi);
         }
         return(self);
      }
   }
   
   substring(Int starti) String {
      return(substring(starti, self.size));
   }
   
   substring(Int starti, Int endi) String {
      return(String.new(endi - starti).copyValue(self, starti, endi, 0));
   }
   
   output() {
      emit(c) {
"""
printf("%s", (char*) bevs[bercps]);
"""
      }
      
      emit(jv) {
"""
System.out.write(bevi_bytes, 0, bevi_bytes.length - 1);
"""
      }
      
      emit(cs) {
"""
Stream stdout = Console.OpenStandardOutput();
stdout.Write(bevi_bytes, 0, bevi_bytes.Length - 1);
"""
      }
      
      emit(js) {
      """
        //there's not really an general / portable way to skip the newline, so we don't try to
        //down the line we could have specific versions for node and such which do TODO
        console.log(this.bems_stringToJsString_1(this));

      """
      }
      
   }
    
    print() {
    
     emit(cc) {
     """
#ifdef BEDCC_ISIOS
    NSLog(@"%@", @(this->bems_toCcString().c_str()));
#endif

#ifndef BEDCC_ISIOS
     std::cout.write(reinterpret_cast<const char*>(&bevi_bytes[0]), bevp_size->bevi_int);
     std::cout << std::endl;
#endif
     """
     }
      
     emit(c) {
"""
printf("%s\n", (char*) bevs[bercps]);
"""
      }
      
      emit(jv) {
"""
System.out.write(bevi_bytes, 0, bevp_size.bevi_int);
System.out.write('\n');
"""
      }
      
      emit(cs) {
"""
Stream stdout = Console.OpenStandardOutput();
stdout.Write(bevi_bytes, 0, bevp_size.bevi_int);
stdout.WriteByte(10);
"""
      }
      
      emit(js) {
      """
      //console.log("Hi from JS!");
      //try/catch, figure out what's up
      try {
        
        
        console.log(this.bems_stringToJsString_1(this));
        
        //console.log(this.bems_bytesToString_1(this.bems_stringToBytes_1(this.bems_bytesToString_1(this.bevi_bytes))));
        
        
      } catch (e) {
        //console.log(e);
        //console.log(e.stack);
      }
      """
      }
      
    }
    
    echo() {
      //IO:File:Writer output = IO:File:NamedWriters.new().output;
      //output.writeIfPossible(self);
      output();
    }
   
   iteratorGet() {
      return(Text:MultiByteIterator.new(self));
   }
   
   byteIteratorGet() Text:ByteIterator {
      return(Text:ByteIterator.new(self));
   }
   
   multiByteIteratorGet() Text:MultiByteIterator {
      return(Text:MultiByteIterator.new(self));
   }
   
   biterGet() Text:ByteIterator {
      return(Text:ByteIterator.new(self));
   }
   
   mbiterGet() Text:MultiByteIterator {
      return(Text:MultiByteIterator.new(self));
   }
   
   stringIteratorGet() Text:MultiByteIterator {
      return(Text:MultiByteIterator.new(self));
   }
   
   serializeToString() String {
      return(self);
   }
   
   deserializeFromStringNew(String snw) self {
      if (undef(snw)) {
         self.new();
      } else {
         self.new(snw.size + 1);
         self.addValue(snw);
      }
   }
   
   serializeContents() Bool {
      return(false);
   }
   
   strip() {     
      return(Text:Strings.strip(self));
   }
   
    reverseBytes() self {
        Int vb = Int.new();
        Int ve = Int.new();
        Int b = 0;
        Int e = size - 1;
        while (e > b) {
            getInt(b, vb);
            getInt(e, ve);
            setInt(b, ve);
            setInt(e, vb);
            b++=;
            e--=;
        }
    }

}

final class Text:Strings {

    create() self { }
   
   default() self {
      
      fields {
         String space = " ";
         String empty = Text:String.new();
         String quote = String.codeNew(34);
         String tab = String.codeNew(9); //tab
         String dosNewline = "\r\n";
         String unixNewline = "\n";
         String newline; //get rid of platform stuff and just set this
         String cr = String.codeNew(13); //carriage return
         String lf = "\n";
         String colon = ":";
         Text:Tokenizer lineSplitter = Text:Tokenizer.new(dosNewline);
         Set ws = Set.new();
      }
      
      ws.put(space);
      ws.put(tab);
      ws.put(cr);
      ws.put(unixNewline);
   }
   
   join(String delim, splits) String {
      return(joinBuffer(delim, splits));
   }
   
   joinBuffer(String delim, splits) String {
      any i = splits.iterator;
      if (i.hasNext!) {
         return(String.new());
      }
      String buf = String.new();
      buf += i.next;
      while (i.hasNext) {
         buf += delim;
         buf += i.next;
      }
      return(buf);
   }
   
   strip(String str) {
      Int beg = 0;
      Int end = 0;
      Bool foundChar = false;
      Text:MultiByteIterator mb = str.mbiter;
      while (mb.hasNext) {
         String step = mb.next;
         if (ws.has(step)) {
            if (foundChar) {
               end++=;
            } else {
               beg++=;
            }
         } else {
            end.setValue(0);
            foundChar = true;
         }
      }
      if (foundChar) {
         String toRet = str.substring(beg, str.size - end);
      } else {
         toRet = "";
      }
      return(toRet);
   }
   
   commonPrefix(String a, String b) String {
      if (undef(a) || undef(b)) { return(null); }
      Int sz = Math:Ints.min(a.size, b.size);
      any ai = a.biter;
      any bi = b.biter;
      String av = String.new();
      String bv = String.new();
      for (Int i = 0;i < sz;i++=) {
        ai.next(av);
        bi.next(bv);
        if (av != bv) {
            return(a.substring(0, i));
        }
      }
      return(a.substring(0, i));
   }
   
   anyEmpty(strs) Bool {
     for (String i in strs) {
       if (isEmpty(i)) {
         return(true);
       }
     }
     return(false);
   }
   
   isEmpty(String value) Bool {
     if (undef(value) || value.size < 1) {
       return(true);
     }
     return(false);
   }
   
   notEmpty(String value) Bool {
     if (def(value) && value != "") {
       return(true);
     }
     return(false);
   }
   
}

local class Text:ByteIterator {
   
   new() self {
      self.new(Text:Strings.empty);
   }
   
   containerGet() String {
      return(str);
   }
   
   serializeToString() String {
      return(str);
   }
   
   deserializeFromStringNew(String str) self {
      self.new(str);
   }
   
   new(String _str) self {
      fields {
         String str = _str;
         Int pos = 0;
         Int vcopy = Int.new();
      }
   }
   
   hasNextGet() Bool {
      if (str.size > pos) {
         return(true);
      }
      return(false);
   }
      
   nextGet() String {
      return(next(String.new(1)));
   }
   
   next(String buf) String {
      if (str.size > pos) {
         if (buf.capacity < 1) { //byte + null
            buf.capacitySet(1);
         }
         if (buf.size != 1) {
            buf.size.setValue(1);
         }
         buf.setIntUnchecked(0, str.getInt(pos, vcopy));
         ifEmit(c) {
            buf.setIntUnchecked(1, 0);
         }
         pos++=;
      }
      return(buf);
   }
   
   nextInt(Int into) Int {
      if (str.size > pos) {
         str.getInt(pos, into);
         pos++=;
      }
      return(into);
   }
   
   currentInt(Int into) Int {
      if (pos > 0 && str.size >= pos) {
         pos--=;//iterator is pre-increment, this approach saves an alloc at the cost of an extra op (increment, below)
         str.getInt(pos, into);
         pos++=;
      }
      return(into);
   }
   
   currentIntSet(Int into) self {
      if (pos > 0 && str.size >= pos) {
         pos--=;//iterator is pre-increment, this approach saves an alloc at the cost of an extra op (increment, below)
         str.setIntUnchecked(pos, into);
         pos++=;
      }
   }
   
   //trick to allow for use with either iter, for (x in y.biter) or for (x in y.mbiter)
   iteratorGet() any {
      return(self);
   }
   
   byteIteratorIteratorGet() Text:ByteIterator {
      return(self);
   }
   
}

final class Text:MultiByteIterator(Text:ByteIterator) {

   new(String _str) self {
      fields {
        Int bcount = Int.new();
        Int ival = Int.new();
      }
      super.new(_str);
   }
      
   nextGet() String {
      return(next(String.new(5)));
   }
   
   next(String buf) String {
      if (str.size > pos) {
        str.getInt(pos, ival);
        if (ival >= 0 && ival <= 127) { /* 0x7F 127 */
            bcount = 1;
        } elseIf ((ival & -32) == -64) { /* 0xE0 224 -32, 0xC0 192 -64 */
            bcount = 2;
        } elseIf ((ival & -16) == -32) { /* 0xF0 240 -16, 0xE0 224 -32 */
            bcount = 3;
        } elseIf ((ival & -8) == -16) { /* 0xF8 248 -8, 0xF0 240 -16 */
           bcount = 4;
        } else {
            throw(System:Exception.new("Malformed string, utf-8 multibyte sequence is greater than 4 bytes"));
        }
        if (buf.size != bcount) {
            buf.size.setValue(bcount);
        }
        bcount += pos;
        buf.copyValue(str, pos, bcount, 0);
        pos.setValue(bcount);
      }
      return(buf);
   }
   
   multiByteIteratorIteratorGet() Text:MultiByteIterator {
      return(self);
   }
   
   iteratorGet() any {
      return(self);
   }
   
}
