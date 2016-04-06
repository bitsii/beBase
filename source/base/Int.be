// Copyright 2006 Craig Welch
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

use Math:Int;
use Math:Float;
use Logic:Bool;
use Text:String;

emit(cs) {
    """
using System.IO;
using System;
    """
}

final class Int {

   emit(c) {
   """
/*-attr- -firstSlotNative-*/
   """
   }
   
   emit(jv,cs) {
   """
   
    public int bevi_int;
    public BEC_4_3_MathInt(int bevi_int) { this.bevi_int = bevi_int; }
    
   """
   }
   
   emit(js) {
   """
   
    be_BEL_4_Base_BEC_4_3_MathInt.prototype.beml_set_bevi_int = function(bevi_int) {
        this.bevi_int = bevi_int;
        return this;
    }
    
   """
   }
   
   vintGet() {
   }
   
   vintSet() {
   }
   
   new() self {
   
      fields {
         var vint;
      }
      
      emit(js) {
      """
      this.bevi_int = 0;
      """
      }
      
   }
   
   create() self { return(Int.new()); }
   
   new(str) self {
      setStringValueDec(str);
   }
   
   hexNew(String str) self {
      setStringValueHex(str);
   }
   
   setStringValueDec(String str) self {
      setStringValue(str, 10@, 58@, 65@, 97@);
   }
   
   setStringValueHex(String str) self {
      setStringValue(str, 16@, 58@, 71@, 103@);
   }
   
   setStringValue(String str, Int radix) self {
      if (radix < 2 || radix > 24) {
        throw(System:Exception.new("Don't know how to handle radix of size " + radix));
      }
      if (radix < 10) {
        Int max0 = radix.copy();
      } else {
        max0 = 10;
      }
      max0 += 48;
      Int maxA = 65 + (radix - 10);
      Int maxa = 97 + (radix - 10);
      setStringValue(str, radix, max0, maxA, maxa); 
   }
   
   setStringValue(String str, Int radix, Int max0, Int maxA, Int maxa) self {
      self.setValue(0);
      Int j = str.size.copy();
      j--=;
      Int pow = 1;
      Int ic = Int.new();
      while (j >= 0) {
        //("j is " + j).print();
        str.getInt(j, ic);
        //("ic is " + ic).print();
        if (ic > 47 && ic < max0) {
            ic -= 48;
            ic *= pow;
            self += ic;
        }  elif (ic > 64 && ic < maxA) {
            ic -= 55;
            ic *= pow;
            self += ic;
        }  elif (ic > 96 && ic < maxa) {
            ic -= 87;
            ic *= pow;
            self += ic;
        } elif (ic == 45) {
            //negate, and it should always be the last one
            self *= -1;
        } else {
            throw(System:Exception.new("String is not an int " + str + " " + ic));
        }
        j--=;
        pow *= radix;
      }
   }
   
   serializeToString() String {
      return(toString());
   }
   
   deserializeFromStringNew(String snw) self {
      self.new(snw);
   }
   
   serializeContents() Bool {
      return(false);
   }
   
   hashGet() Math:Int {
      return(self);
   }
   
   toFloat() Float {
   emit(c) {
      """
/*-attr- -dec-*/
BEFLOAT* bevl_float;
void** bevl_fi;
      """
      }
      Float fi = Float.new();
      emit(c) {
"""
bevl_fi = $fi&*;
bevl_float = (BEFLOAT*) (bevl_fi + bercps);
*bevl_float = (BEFLOAT) *((BEINT*) (bevs + bercps));
"""
      }
      emit(jv, cs) {
      """
      bevl_fi.bevi_float = (float) this.bevi_int;
      """
      }
      emit(js) {
      """
      bevl_fi.bevi_float = this.bevi_int * 1.0;
      """
      }
      return(fi);
   }
   
   toString() Text:String {
       return(toString(String.new(1), 1@, 10@, null));
   }
   
   toHexString() Text:String {
       return(toHexString(String.new(2)));
   }
   
   toHexString(String res) Text:String {
       return(toString(res, 2@, 16@));
   }
   
   toString(Int zeroPad, Int radix) Text:String {
        return(toString(String.new(zeroPad), zeroPad, radix, 55@));
   }
   
   toString(String res, Int zeroPad, Int radix) Text:String {
        return(toString(res, zeroPad, radix, 55@));
   }
   
   toString(String res, Int zeroPad, Int radix, Int alphaStart) Text:String {
      res.clear();
      Int ts = abs();
      Int val = Int.new();
      while (ts > 0) {
        val.setValue(ts);
        val %= radix;
        if (val < 10) {
            val += 48;
        } else {
            val += alphaStart
        }
        //add to res
        if (res.capacity <= res.size) {
            res.capacity = res.capacity + 4;
        }
        res.setIntUnchecked(res.size, val);
        res.size = res.size + 1;//TODO setValue
        ifEmit(c) {
            res.setIntUnchecked(res.size, 0@);
        }
        ts /= radix;
      }
      //if insufficient positions, zero pad
      while (res.size < zeroPad) {
        if (res.capacity <= res.size) {
            res.capacity = res.capacity + 4;
        }
        res.setIntUnchecked(res.size, 48@);
        res.size = res.size + 1;//TODO setValue
        ifEmit(c) {
            res.setIntUnchecked(res.size, 0@);
        }
      }
      if (self < 0) {
        res += "-";
      }
      return(res.reverseBytes());
   }
   
   copy() {
     Int c = Int.new();
     c.setValue(self);
     return(c);
   }
   
   abs() Int {
      return(copy().absValue());
   }
   
   absValue() Int {
      if (self < 0) {
        self *= -1;
      }
   }
   
   setValue(Int xi) Int {
      emit(c) {
"""
(*((BEINT*) (bevs + bercps))) = (*((BEINT*) ($xi&* + bercps)));
"""
      }
      emit(jv,cs,js) {
"""
this.bevi_int = beva_xi.bevi_int;
"""
      }
      
      return(self);
   }
   
    increment() Int {
        ifEmit(jv,cs,js) {
            Int res = Int.new();
            emit(jv,cs,js) {
            """
                bevl_res.bevi_int = this.bevi_int + 1;
            """
            }
            return(res);
        }
        ifEmit(c) {
            return(self++);
        }
    }
   
    decrement() Int {
        ifEmit(jv,cs,js) {
            Int res = Int.new();
            emit(jv,cs,js) {
            """
                bevl_res.bevi_int = this.bevi_int - 1;
            """
            }
            return(res);
        }
        ifEmit(c) {
            return(self--);
        }
    }
   
   incrementValue() Int {
      emit(c) {
"""
(*((BEINT*) (bevs + bercps)))++;
"""
      }
      emit(jv,cs,js) {
      """
      this.bevi_int++;
      """
      }
      return(self);
   }
   
   decrementValue() Int {
      emit(c) {
"""
(*((BEINT*) (bevs + bercps)))--;
"""
      }
      emit(jv,cs,js) {
      """
      this.bevi_int--;
      """
      }
      return(self);
   }
   
   add(Int xi) Int {
        ifEmit(jv,cs,js) {
            Int res = Int.new();
            emit(jv,cs,js) {
            """
                bevl_res.bevi_int = this.bevi_int + beva_xi.bevi_int;
            """
            }
            return(res);
        }
        ifEmit(c) {
            return(self + xi);
        }
   }
   
   addValue(Int xi) Int {
      emit(c) {
"""
(*((BEINT*) (bevs + bercps))) += (*((BEINT*) ($xi&* + bercps)));
"""
      }
      emit(jv,cs,js) {
      """
      this.bevi_int += beva_xi.bevi_int;
      """
      }
      return(self);
   }
   
   subtract(Int xi) Int {
      ifEmit(jv,cs,js) {
            Int res = Int.new();
            emit(jv,cs,js) {
            """
                bevl_res.bevi_int = this.bevi_int - beva_xi.bevi_int;
            """
            }
            return(res);
        }
        ifEmit(c) {
            return(self - xi);
        }
   }
   
   subtractValue(Int xi) Int {
      emit(c) {
"""
(*((BEINT*) (bevs + bercps))) -= (*((BEINT*) ($xi&* + bercps)));
"""
      }
      emit(jv,cs,js) {
      """
      this.bevi_int -= beva_xi.bevi_int;
      """
      }
      return(self);
   }
   
   multiply(Int xi) Int {
    ifEmit(jv,cs,js) {
        Int res = Int.new();
        emit(jv,cs,js) {
        """
            bevl_res.bevi_int = this.bevi_int * beva_xi.bevi_int;
        """
        }
        return(res);
    }
    ifEmit(c) {
        return(self * xi);
    }
   }
   
   multiplyValue(Int xi) Int {
      emit(c) {
"""
(*((BEINT*) (bevs + bercps))) *= (*((BEINT*) ($xi&* + bercps)));
"""
      }
      emit(jv,cs,js) {
      """
      this.bevi_int *= beva_xi.bevi_int;
      """
      }
      return(self);
   }
   
   divide(Int xi) Int {
        ifEmit(jv,cs,js) {
            Int res = Int.new();
            emit(jv,cs) {
            """
                bevl_res.bevi_int = this.bevi_int / beva_xi.bevi_int;
            """
            }
            emit(js) {
            """
                bevl_res.bevi_int = Math.floor(this.bevi_int / beva_xi.bevi_int);
            """
            }
            return(res);
        }
        ifEmit(c) {
            return(self / xi);
        }
   }
   
   divideValue(Int xi) Int {
      emit(c) {
"""
(*((BEINT*) (bevs + bercps))) /= (*((BEINT*) ($xi&* + bercps)));
"""
      }
      emit(jv,cs) {
      """
      this.bevi_int /= beva_xi.bevi_int;
      """
      }
      emit(js) {
      """
      this.bevi_int = Math.floor(this.bevi_int / beva_xi.bevi_int);
      """
      }
      return(self);
   }
   
   modulus(Int xi) Int {
       ifEmit(jv,cs,js) {
            Int res = Int.new();
            emit(jv,cs,js) {
            """
                bevl_res.bevi_int = this.bevi_int % beva_xi.bevi_int;
            """
            }
            return(res);
        }
        ifEmit(c) {
            return(self % xi);
        }
   }
   
   modulusValue(Int xi) Int {
      emit(c) {
"""
(*((BEINT*) (bevs + bercps))) %= (*((BEINT*) ($xi&* + bercps)));
"""
      }
      emit(jv,cs,js) {
      """
      this.bevi_int %= beva_xi.bevi_int;
      """
      }
      return(self);
   }
   
   and(Int xi) Int {
    Int toReti = Int.new();
    emit(c) {
    """
        *((BEINT*) ($toReti&* + bercps)) = *((BEINT*) (bevs + bercps)) & *((BEINT*) ($xi&* + bercps));
    """
    }
    emit(jv,cs,js) {
    """
        bevl_toReti.bevi_int = this.bevi_int & beva_xi.bevi_int;
    """
    }
    return(toReti);
   }
   
   andValue(Int xi) Int {
      emit(c) {
"""
*((BEINT*) (bevs + bercps)) &= *((BEINT*) ($xi&* + bercps));
"""
      }
      emit(jv,cs,js) {
    """
        this.bevi_int &= beva_xi.bevi_int;
    """
    }
      return(self);
   }
   
   or(Int xi) Int {
     Int toReti = Int.new();
      emit(c) {
"""
*((BEINT*) ($toReti&* + bercps)) = *((BEINT*) (bevs + bercps)) | *((BEINT*) ($xi&* + bercps));
"""
      }
      emit(jv,cs,js) {
    """
        bevl_toReti.bevi_int = this.bevi_int | beva_xi.bevi_int;
    """
    }
      return(toReti);
   }
   
   orValue(Int xi) Int {
      emit(c) {
"""
*((BEINT*) (bevs + bercps)) |= *((BEINT*) ($xi&* + bercps));
"""
      }
       emit(jv,cs,js) {
    """
        this.bevi_int |= beva_xi.bevi_int;
    """
    }
      return(self);
   }
   
   shiftLeft(Int xi) Int {
     Int toReti = Int.new();
      emit(c) {
"""
*((BEINT*) ($toReti&* + bercps)) = *((BEINT*) (bevs + bercps)) << *((BEINT*) ($xi&* + bercps));
"""
      }
      emit(jv,cs,js) {
    """
        bevl_toReti.bevi_int = this.bevi_int << beva_xi.bevi_int;
    """
    }
      return(toReti);
   }
   
   shiftLeftValue(Int xi) Int {
      emit(c) {
"""
*((BEINT*) (bevs + bercps)) <<= *((BEINT*) ($xi&* + bercps));
"""
      }
       emit(jv,cs,js) {
    """
        this.bevi_int <<= beva_xi.bevi_int;
    """
    }
      return(self);
   }
   
   shiftRight(Int xi) Int {
     Int toReti = Int.new();
      emit(c) {
"""
*((BEINT*) ($toReti&* + bercps)) = *((BEINT*) (bevs + bercps)) >> *((BEINT*) ($xi&* + bercps));
"""
      }
      emit(jv,cs,js) {
    """
        bevl_toReti.bevi_int = this.bevi_int >> beva_xi.bevi_int;
    """
    }
      return(toReti);
   }
   
   shiftRightValue(Int xi) Int {
      emit(c) {
"""
*((BEINT*) (bevs + bercps)) >>= *((BEINT*) ($xi&* + bercps));
"""
      }
      emit(jv,cs,js) {
    """
        this.bevi_int >>= beva_xi.bevi_int;
    """
    }
      return(self);
   }
   
   //2 power 3 = 2 * 2* 2
   power(Int other) Int {
      Int result = 1;
      //2 0 1 2: 1 * 2 * 2 * 2
      for (Int i = 0; i < other;i++=) {
         result *= self;
      }
      return(result);
   }
   
   equals(xi) Bool {
      ifEmit(c) {
        return(self == xi);
      }
      emit(jv) {
      """
      if (beva_xi instanceof BEC_4_3_MathInt && this.bevi_int == ((BEC_4_3_MathInt)beva_xi).bevi_int) {
        return be.BELS_Base.BECS_Runtime.boolTrue;
      }
      """
      }
      emit(cs) {
      """
      var bevls_xi = beva_xi as BEC_4_3_MathInt;
      if (bevls_xi != null && this.bevi_int == bevls_xi.bevi_int) {
        return be.BELS_Base.BECS_Runtime.boolTrue;
      }
      """
      }
      emit(js) {
      """
      //console.log("in equals for js " + this.bevi_int + " " +  beva_xi.bevi_int);
      if (beva_xi !== null && this.bevi_int === beva_xi.bevi_int) {
        //console.log("is eq");
        return be_BELS_Base_BECS_Runtime.prototype.boolTrue;
      }
      //console.log("not eq");
      """
      }
      return(false);
   }
   
   notEquals(xi) Bool {
      ifEmit(c) {
        return(self != xi);
      }
      emit(jv) {
      """
      if (!(beva_xi instanceof BEC_4_3_MathInt) || this.bevi_int != ((BEC_4_3_MathInt)beva_xi).bevi_int) {
        return be.BELS_Base.BECS_Runtime.boolTrue;
      }
      """
      }
      emit(cs) {
      """
      var bevls_xi = beva_xi as BEC_4_3_MathInt;
      if (bevls_xi == null || this.bevi_int != bevls_xi.bevi_int) {
        return be.BELS_Base.BECS_Runtime.boolTrue;
      }
      """
      }
      emit(js) {
      """
      if (beva_xi === null || this.bevi_int !== beva_xi.bevi_int) {
        return be_BELS_Base_BECS_Runtime.prototype.boolTrue;
      }
      """
      }
      return(false);
   }
   
   greater(Int xi) Bool {
      ifEmit(c) {
        return(self > xi);
      }
      emit(jv,cs) {
      """
      if (this.bevi_int > beva_xi.bevi_int) {
        return be.BELS_Base.BECS_Runtime.boolTrue;
      }
      """
      }
      emit(js) {
      """
      if (this.bevi_int > beva_xi.bevi_int) {
        return be_BELS_Base_BECS_Runtime.prototype.boolTrue;
      }
      """
      }
      return(false);
   }
   
   lesser(Int xi) Bool {
      ifEmit(c) {
        return(self < xi);
      }
      emit(jv,cs) {
      """
      if (this.bevi_int < beva_xi.bevi_int) {
        return be.BELS_Base.BECS_Runtime.boolTrue;
      }
      """
      }
      emit(js) {
      """
      if (this.bevi_int < beva_xi.bevi_int) {
        return be_BELS_Base_BECS_Runtime.prototype.boolTrue;
      }
      """
      }
      return(false);
   }
   
   greaterEquals(Int xi) Bool {
      ifEmit(c) {
        return(self >= xi);
      }
      emit(jv,cs) {
      """
      if (this.bevi_int >= beva_xi.bevi_int) {
        return be.BELS_Base.BECS_Runtime.boolTrue;
      }
      """
      }
      emit(js) {
      """
      if (this.bevi_int >= beva_xi.bevi_int) {
        return be_BELS_Base_BECS_Runtime.prototype.boolTrue;
      }
      """
      }
      return(false);
   }
   
   lesserEquals(Int xi) Bool {
      ifEmit(c) {
        return(self <= xi);
      }
      emit(jv,cs) {
      """
      if (this.bevi_int <= beva_xi.bevi_int) {
        return be.BELS_Base.BECS_Runtime.boolTrue;
      }
      """
      }
      emit(js) {
      """
      if (this.bevi_int <= beva_xi.bevi_int) {
        return be_BELS_Base_BECS_Runtime.prototype.boolTrue;
      }
      """
      }
      return(false);
   }
   
}

final class Math:Ints {

   create() self { }
   
   default() self {
      
      emit(c) {
      """
/*-attr- -dec-*/
BEINT* bevl_int;
void** bevl__max;
void** bevl__min;
      """
      }
      Int _max = Int.new();
      Int _min = Int.new();
      emit(c) {
      """
      bevl__max = $_max&*;
      bevl__min = $_min&*;
      
      bevl_int = (BEINT*) (bevl__max + bercps);
      *bevl_int = INT_MAX;
      
      bevl_int = (BEINT*) (bevl__min + bercps);
      *bevl_int = INT_MIN;
      """
      }
      emit(jv) {
      """
      bevl__max.bevi_int = Integer.MAX_VALUE;
      bevl__min.bevi_int = Integer.MIN_VALUE;
      //System.out.println(bevl__max.bevi_int);
      //System.out.println(bevl__min.bevi_int);
      """
      }
      emit(cs) {
      """
      bevl__max.bevi_int = int.MaxValue;
      bevl__min.bevi_int = int.MinValue;
      //Stream stdout = Console.OpenStandardOutput();
      //Console.WriteLine(bevl__max.bevi_int.ToString());
      //Console.WriteLine(bevl__min.bevi_int.ToString());
      """
      }
      emit(js) {
      """
      bevl__max.bevi_int = Math.pow(2, 31) - 1;
      bevl__min.bevi_int = (Math.pow(2, 31) - 1) * -1;//this is one more than the others (ends with 7 instead of 8)
      //console.log(bevl__max.bevi_int);
      //console.log(bevl__min.bevi_int);
      """
      }
      fields {
         Int max = _max;
         Int min = _min;
         Int zero = 0;
         Int one = 1;
      }
   }
   
   min(Int a, Int b) {
    if (undef(a) || a < b) {
        return(a);
    }
    return(b);
   }
   
   max(Int a, Int b) {
    if (undef(a) || a > b) {
        return(a);
    }
    return(b);
   }
}

