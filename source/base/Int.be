/*
 * Copyright (c) 2006-2023, the Brace Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

emit(cs) {
    """
using System.IO;
using System;
    """
}

final class Int {
   
   emit(jv,cs) {
   """
   
    public int bevi_int;
    public $class/Math:Int$(int bevi_int) { this.bevi_int = bevi_int; }
    
   """
   }
   
  emit(cc_classHead) {
  """
    int32_t bevi_int = 0;
    BEC_2_4_3_MathInt() { 
    #ifdef BEDCC_SGC
#ifdef BECC_SS
      BEC_2_6_6_SystemObject** bevls_stackRefs[0] = { };
      BECS_StackFrame bevs_stackFrame(bevls_stackRefs, 0, this);
#endif
#ifdef BECC_HS
        struct bes {  BEC_2_6_6_SystemObject* bevr_this;  };
        BECS_FrameStack* bevs_myStack = &BECS_Runtime::bevs_currentStack;
        bes* beq = (bes*) bevs_myStack->bevs_hs;
        BEQP(bevr_this) = this;
        BECS_StackFrame bevs_stackFrame(1);
#endif
    #endif
    }
    BEC_2_4_3_MathInt(int32_t a_bevi_int) { 
    #ifdef BEDCC_SGC
#ifdef BECC_SS
      BEC_2_6_6_SystemObject** bevls_stackRefs[0] = { };
      BECS_StackFrame bevs_stackFrame(bevls_stackRefs, 0, this);
#endif
#ifdef BECC_HS
        struct bes {  BEC_2_6_6_SystemObject* bevr_this;  };
        BECS_FrameStack* bevs_myStack = &BECS_Runtime::bevs_currentStack;
        bes* beq = (bes*) bevs_myStack->bevs_hs;
        BEQP(bevr_this) = this;
        BECS_StackFrame bevs_stackFrame(1);
#endif
    #endif
      bevi_int = a_bevi_int; 
    }
  """
  }
   
   emit(js) {
   """
   
    be_$class/Math:Int$.prototype.beml_set_bevi_int = function(bevi_int) {
        this.bevi_int = bevi_int;
        return this;
    }
    
   """
   }
   
   new() self {
      
      emit(js) {
      """
      this.bevi_int = 0;
      """
      }
      
      emit(cc) {
      """
      bevi_int = 0;
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
      setStringValue(str, 10, 58, 65, 97);
   }
   
   setStringValueHex(String str) self {
      setStringValue(str, 16, 58, 71, 103);
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
      Int j = str.length.copy();
      j--;
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
        }  elseIf (ic > 64 && ic < maxA) {
            ic -= 55;
            ic *= pow;
            self += ic;
        }  elseIf (ic > 96 && ic < maxa) {
            ic -= 87;
            ic *= pow;
            self += ic;
        } elseIf (ic == 45) {
            //negate, and it should always be the last one
            self *= -1;
        } elseIf (ic == 43) {
            //positive is ok but noop, should always be the last one
        } else {
            throw(System:Exception.new("String is not an int " + str + " " + ic));
        }
        j--;
        pow *= radix;
      }
   }
   
   serializeToString() String {
      return(toString());
   }
   
   deserializeFromStringNew(String snw) self {
      self.new(snw);
   }
   
   serializeContentsGet() Bool {
      return(false);
   }
   
   hashGet() Math:Int {
      return(self);
   }
   
   toString() Text:String {
       return(toString(String.new(1), 1, 10, null));
   }
   
   toHexString() Text:String {
       return(toHexString(String.new(2)));
   }
   
   toHexString(String res) Text:String {
       return(toString(res, 2, 16));
   }
   
   toString(Int zeroPad, Int radix) Text:String {
        return(toString(String.new(zeroPad), zeroPad, radix, 55));
   }
   
   toString(String res, Int zeroPad, Int radix) Text:String {
        return(toString(res, zeroPad, radix, 55));
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
        if (res.capacity <= res.length) {
            res.capacity = res.capacity + 4;
        }
        res.setIntUnchecked(res.length, val);
        res.length = res.length + 1;//TODO setValue
        ifEmit(c) {
            res.setIntUnchecked(res.length, 0);
        }
        ts /= radix;
      }
      //if insufficient positions, zero pad
      while (res.length < zeroPad) {
        if (res.capacity <= res.length) {
            res.capacity = res.capacity + 4;
        }
        res.setIntUnchecked(res.length, 48);
        res.length = res.length + 1;//TODO setValue
        ifEmit(c) {
            res.setIntUnchecked(res.length, 0);
        }
      }
      if (self < 0) {
        res += "-";
      }
      return(res.reverseBytes());
   }
   
   copy() self {
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
      emit(jv,cs,js) {
"""
this.bevi_int = beva_xi.bevi_int;
"""
      }
      emit(cc) {
"""
bevi_int = BEQP(beva_xi)->bevi_int;
"""
      }
      
      return(self);
   }
   
   incrementValue() Int {
      emit(jv,cs,js) {
      """
      this.bevi_int++;
      """
      }
      emit(cc) {
      """
      bevi_int++;
      """
      }
      return(self);
   }
   
   decrementValue() Int {
      emit(jv,cs,js) {
      """
      this.bevi_int--;
      """
      }
      emit(cc) {
      """
      bevi_int--;
      """
      }
      return(self);
   }
   
   add(Int xi) Int {
            Int res = Int.new();
            emit(jv,cs,js) {
            """
                bevl_res.bevi_int = this.bevi_int + beva_xi.bevi_int;
            """
            }
            emit(cc) {
            """
                BEQP(bevl_res)->bevi_int = bevi_int + BEQP(beva_xi)->bevi_int;
            """
            }
            return(res);
   }
   
   addValue(Int xi) Int {
      emit(jv,cs,js) {
      """
      this.bevi_int += beva_xi.bevi_int;
      """
      }
      emit(cc) {
      """
      this->bevi_int += BEQP(beva_xi)->bevi_int;
      """
      }
      return(self);
   }
   
   subtract(Int xi) Int {
            Int res = Int.new();
            emit(jv,cs,js) {
            """
                bevl_res.bevi_int = this.bevi_int - beva_xi.bevi_int;
            """
            }
            emit(cc) {
            """
                BEQP(bevl_res)->bevi_int = bevi_int - BEQP(beva_xi)->bevi_int;
            """
            }
            return(res);
   }
   
   subtractValue(Int xi) Int {
      emit(jv,cs,js) {
      """
      this.bevi_int -= beva_xi.bevi_int;
      """
      }
      emit(cc) {
      """
      bevi_int -= BEQP(beva_xi)->bevi_int;
      """
      }
      return(self);
   }
   
   multiply(Int xi) Int {
        Int res = Int.new();
        emit(jv,cs,js) {
        """
            bevl_res.bevi_int = this.bevi_int * beva_xi.bevi_int;
        """
        }
        emit(cc) {
        """
            BEQP(bevl_res)->bevi_int = bevi_int * BEQP(beva_xi)->bevi_int;
        """
        }
        return(res);
   }
   
   multiplyValue(Int xi) Int {
      emit(jv,cs,js) {
      """
      this.bevi_int *= beva_xi.bevi_int;
      """
      }
      emit(cc) {
      """
      bevi_int *= BEQP(beva_xi)->bevi_int;
      """
      }
      return(self);
   }
   
   divide(Int xi) Int {
            Int res = Int.new();
            emit(jv,cs) {
            """
                bevl_res.bevi_int = this.bevi_int / beva_xi.bevi_int;
            """
            }
            emit(cc) {
            """
                BEQP(bevl_res)->bevi_int = bevi_int / BEQP(beva_xi)->bevi_int;
            """
            }
            emit(js) {
            """
                //bevl_res.bevi_int = Math.floor(this.bevi_int / beva_xi.bevi_int);
                bevl_res.bevi_int = ~~(this.bevi_int / beva_xi.bevi_int);
            """
            }
            return(res);
   }
   
   divideValue(Int xi) Int {
      emit(jv,cs) {
      """
      this.bevi_int /= beva_xi.bevi_int;
      """
      }
      emit(cc) {
      """
      bevi_int /= BEQP(beva_xi)->bevi_int;
      """
      }
      emit(js) {
      """
      //this.bevi_int = Math.floor(this.bevi_int / beva_xi.bevi_int);
      this.bevi_int = ~~(this.bevi_int / beva_xi.bevi_int);
      """
      }
      return(self);
   }
   
   modulus(Int xi) Int {
            Int res = Int.new();
            emit(jv,cs,js) {
            """
                bevl_res.bevi_int = this.bevi_int % beva_xi.bevi_int;
            """
            }
            emit(cc) {
            """
                BEQP(bevl_res)->bevi_int = bevi_int % BEQP(beva_xi)->bevi_int;
            """
            }
            return(res);
   }
   
   modulusValue(Int xi) Int {
      emit(jv,cs,js) {
      """
      this.bevi_int %= beva_xi.bevi_int;
      """
      }
      emit(cc) {
      """
      bevi_int %= BEQP(beva_xi)->bevi_int;
      """
      }
      return(self);
   }
   
   and(Int xi) Int {
    Int toReti = Int.new();
    emit(jv,cs,js) {
    """
        bevl_toReti.bevi_int = this.bevi_int & beva_xi.bevi_int;
    """
    }
    emit(cc) {
    """
        BEQP(bevl_toReti)->bevi_int = bevi_int & BEQP(beva_xi)->bevi_int;
    """
    }
    return(toReti);
   }
   
   andValue(Int xi) Int {
      emit(jv,cs,js) {
    """
        this.bevi_int &= beva_xi.bevi_int;
    """
    }
    emit(cc) {
    """
        bevi_int &= BEQP(beva_xi)->bevi_int;
    """
    }
      return(self);
   }
   
   or(Int xi) Int {
     Int toReti = Int.new();
      emit(jv,cs,js) {
    """
        bevl_toReti.bevi_int = this.bevi_int | beva_xi.bevi_int;
    """
    }
    emit(cc) {
    """
        BEQP(bevl_toReti)->bevi_int = bevi_int | BEQP(beva_xi)->bevi_int;
    """
    }
      return(toReti);
   }
   
   orValue(Int xi) Int {
       emit(jv,cs,js) {
    """
        this.bevi_int |= beva_xi.bevi_int;
    """
    }
    emit(cc) {
    """
        bevi_int |= BEQP(beva_xi)->bevi_int;
    """
    }
      return(self);
   }
   
   shiftLeft(Int xi) Int {
     Int toReti = Int.new();
      emit(jv,cs,js) {
    """
        bevl_toReti.bevi_int = this.bevi_int << beva_xi.bevi_int;
    """
    }
    emit(cc) {
    """
        BEQP(bevl_toReti)->bevi_int = bevi_int << BEQP(beva_xi)->bevi_int;
    """
    }
      return(toReti);
   }
   
   shiftLeftValue(Int xi) Int {
       emit(jv,cs,js) {
    """
        this.bevi_int <<= beva_xi.bevi_int;
    """
    }
    emit(cc) {
    """
        bevi_int <<= BEQP(beva_xi)->bevi_int;
    """
    }
      return(self);
   }
   
   shiftRight(Int xi) Int {
     Int toReti = Int.new();
      emit(jv,cs,js) {
    """
        bevl_toReti.bevi_int = this.bevi_int >> beva_xi.bevi_int;
    """
    }
    emit(cc) {
    """
        BEQP(bevl_toReti)->bevi_int = bevi_int >> BEQP(beva_xi)->bevi_int;
    """
    }
      return(toReti);
   }
   
   shiftRightValue(Int xi) Int {
      emit(jv,cs,js) {
    """
        this.bevi_int >>= beva_xi.bevi_int;
    """
    }
    emit(cc) {
    """
        bevi_int >>= BEQP(beva_xi)->bevi_int;
    """
    }
      return(self);
   }
   
   //2 power 3 = 2 * 2* 2
   power(Int other) Int {
      Int result = 1;
      //2 0 1 2: 1 * 2 * 2 * 2
      for (Int i = 0; i < other;i++) {
         result *= self;
      }
      return(result);
   }

   squaredGet() Int {
     return (self * self);
   }

   squareRootGet() Int {
     Int res = Int.new();
     emit(jv) {
      """
      double rd = Math.sqrt((double) bevi_int);
      bevl_res.bevi_int = (int) rd;
      """
     }
     return(res);
   }
   
   equals(xi) Bool {
      ifEmit(c) {
        return(self == xi);
      }
      if (undef(xi)) { return(false); }
      emit(jv) {
      """
      if (this.bevi_int == (($class/Math:Int$)beva_xi).bevi_int) {
        return be.BECS_Runtime.boolTrue;
      }
      """
      }
      emit(cs) {
      """
      var bevls_xi = beva_xi as $class/Math:Int$;
      if (this.bevi_int == bevls_xi.bevi_int) {
        return be.BECS_Runtime.boolTrue;
      }
      """
      }
      emit(js) {
      """
      //console.log("in equals for js " + this.bevi_int + " " +  beva_xi.bevi_int);
      if (this.bevi_int === beva_xi.bevi_int) {
        //console.log("is eq");
        return be_BECS_Runtime.prototype.boolTrue;
      }
      //console.log("not eq");
      """
      }
      emit(cc) {
      """
#ifndef BEDCC_NORTTI
      BEC_2_4_3_MathInt* bevls_xi = dynamic_cast<BEC_2_4_3_MathInt*>(BEQP(beva_xi));
#endif
#ifdef BEDCC_NORTTI
      BEC_2_4_3_MathInt* bevls_xi = static_cast<BEC_2_4_3_MathInt*>(BEQP(beva_xi));
#endif
      if (bevi_int == bevls_xi->bevi_int) {
        return BECS_Runtime::boolTrue;
      }
      """
      }
      return(false);
   }
   
   notEquals(xi) Bool {
      ifEmit(c) {
        return(self != xi);
      }
      if (undef(xi)) { return(true); }
      emit(jv) {
      """
      if (this.bevi_int != (($class/Math:Int$)beva_xi).bevi_int) {
        return be.BECS_Runtime.boolTrue;
      }
      """
      }
      emit(cs) {
      """
      var bevls_xi = beva_xi as $class/Math:Int$;
      if (this.bevi_int != bevls_xi.bevi_int) {
        return be.BECS_Runtime.boolTrue;
      }
      """
      }
      emit(js) {
      """
      if (this.bevi_int !== beva_xi.bevi_int) {
        return be_BECS_Runtime.prototype.boolTrue;
      }
      """
      }
      emit(cc) {
      """
#ifndef BEDCC_NORTTI
      BEC_2_4_3_MathInt* bevls_xi = dynamic_cast<BEC_2_4_3_MathInt*>(BEQP(beva_xi));
#endif
#ifdef BEDCC_NORTTI
      BEC_2_4_3_MathInt* bevls_xi = static_cast<BEC_2_4_3_MathInt*>(BEQP(beva_xi));
#endif
      if (bevi_int != bevls_xi ->bevi_int) {
        return BECS_Runtime::boolTrue;
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
        return be.BECS_Runtime.boolTrue;
      }
      """
      }
      emit(js) {
      """
      if (this.bevi_int > beva_xi.bevi_int) {
        return be_BECS_Runtime.prototype.boolTrue;
      }
      """
      }
      emit(cc) {
      """
      if (bevi_int > BEQP(beva_xi)->bevi_int) {
        return BECS_Runtime::boolTrue;
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
        return be.BECS_Runtime.boolTrue;
      }
      """
      }
      emit(js) {
      """
      if (this.bevi_int < beva_xi.bevi_int) {
        return be_BECS_Runtime.prototype.boolTrue;
      }
      """
      }
      emit(cc) {
      """
      if (bevi_int < BEQP(beva_xi)->bevi_int) {
        return BECS_Runtime::boolTrue;
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
        return be.BECS_Runtime.boolTrue;
      }
      """
      }
      emit(js) {
      """
      if (this.bevi_int >= beva_xi.bevi_int) {
        return be_BECS_Runtime.prototype.boolTrue;
      }
      """
      }
      emit(cc) {
      """
      if (bevi_int >= BEQP(beva_xi)->bevi_int) {
        return BECS_Runtime::boolTrue;
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
        return be.BECS_Runtime.boolTrue;
      }
      """
      }
      emit(js) {
      """
      if (this.bevi_int <= beva_xi.bevi_int) {
        return be_BECS_Runtime.prototype.boolTrue;
      }
      """
      }
      emit(cc) {
      """
      if (bevi_int <= BEQP(beva_xi)->bevi_int) {
        return BECS_Runtime::boolTrue;
      }
      """
      }
      return(false);
   }
   
}

final class Math:Ints {

   create() self { }
   
   default() self {
      
      Int _max = Int.new();
      Int _min = Int.new();

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
      emit(cc) {
      """
      BEQP(bevl__max)->bevi_int = std::numeric_limits<int32_t>::max();
      BEQP(bevl__min)->bevi_int = std::numeric_limits<int32_t>::min();
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

