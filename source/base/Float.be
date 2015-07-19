/*
Copyright 2006 Craig Welch
All rights reserved.

Developed by:

    Craig Welch

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal with
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

    * Redistributions of source code must retain the above copyright notice,
      this list of conditions and the following disclaimers.

    * Redistributions in binary form must reproduce the above copyright notice,
      this list of conditions and the following disclaimers in the
      documentation and/or other materials provided with the distribution.

    * Neither the name of the Software nor the names of its contributors may be used 
      to endorse or promote products derived from this Software without specific
      prior written permission.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
CONTRIBUTORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS WITH THE
SOFTWARE.
*/

use Math:Int;
use Math:Float;
use Logic:Bool;
use Text:String;

final class Float {

   emit(c) {
   """
/*-attr- -firstSlotNative-*/
   """
   }
   
   emit(jv,cs) {
   """
   
    public float bevi_float;
    public BEC_4_5_MathFloat(float bevi_float) { this.bevi_float = bevi_float; }
    
   """
   }
   
   emit(js) {
   """
   
    be_BEL_4_Base_BEC_4_5_MathFloat.prototype.beml_set_bevi_float = function(bevi_float) {
        this.bevi_float = bevi_float;
        return this;
    }
    
   """
   }
   
   vfloatGet() {
   }
   
   vfloatSet() {
   }
   
   new() self { 
   
      properties {
         var vfloat;
      }
      
      emit(js) {
      """
      this.bevi_float = 0.0;
      """
      }
   
   }
   
   new(si) self {
        if (si.begins("-")) {
            Bool neg = true;
            si = si.substring(1);
        } else {
            neg = false;
        }
        Int dec = si.find(".");
        if (def(dec)) {
            if (dec > 0) {
                Int lhs = Int.new(si.substring(0, dec));
            } else {
                lhs = 0;
            }
            if (dec + 1 < si.size) {
                Int rhs = Int.new(si.substring(dec + 1));
            } else {
                rhs = 0;
            }
        } else {
            lhs = Int.new(si);
            rhs = 0;
        }
        Int divby = 10.power(rhs.toString().size);
        if (neg) {
            rhs *= -1;
            lhs *= -1;
        }
        Float rhsf = rhs.toFloat() / divby.toFloat();
        Float lhsf = lhs.toFloat();
        Float res = lhsf + rhsf;
        return(res);
   }
   
   create() { return(Float.new()); }
   
   serializeToString() String {
      return(toString());
   }
   
   deserializeFromStringNew(String snw) self {
      self.new(snw);
   }
   
   serializeContents() Bool {
      return(false);
   }
   
   toInt() Math:Int {
   emit(c) {
      """
/*-attr- -dec-*/
BEINT* bevl_int;
void** bevl_ii;
      """
      }
      Math:Int ii = Math:Int.new();
      emit(c) {
"""
bevl_ii = $ii&*;
bevl_int = (BEINT*) (bevl_ii + bercps);
*bevl_int = (int) *((BEFLOAT*) (bevs + bercps));
"""
      }
      return(ii);
   }
   
   hashGet() Math:Int {
      //TODO make better
      return(toInt());
   }
   
   toString() Text:String {
      Int lhi = toInt();
      Float rh = self - lhi.toFloat();
      rh = rh * 1000000.0;//arbitrary... TODO support specifying this
      Int rhi = rh.toInt();
      return(lhi.toString() + "." + rhi.toString());
   }
   
   increment() Float {
      ifEmit(jv,cs,js) {
            Float res = Float.new();
            emit(jv,cs,js) {
            """
                bevl_res.bevi_float = this.bevi_float + 1;
            """
            }
            return(res);
        }
      ifEmit(c) {
        return(self++);
      }
   }
   
   decrement() Float {
        ifEmit(jv,cs,js) {
            Float res = Float.new();
            emit(jv,cs,js) {
            """
                bevl_res.bevi_float = this.bevi_float - 1;
            """
            }
            return(res);
        }
      ifEmit(c) {
         return(self--);
      }
   }
   
   add(Float xi) Float {
      ifEmit(jv,cs,js) {
            Float res = Float.new();
            emit(jv,cs,js) {
            """
                bevl_res.bevi_float = this.bevi_float + beva_xi.bevi_float;
            """
            }
            return(res);
        }
      ifEmit(c) {
        return(self + xi);
      }
   }
   
   subtract(Float xi) Float {
    ifEmit(jv,cs,js) {
            Float res = Float.new();
            emit(jv,cs,js) {
            """
                bevl_res.bevi_float = this.bevi_float - beva_xi.bevi_float;
            """
            }
            return(res);
        }
      ifEmit(c) {
      return(self - xi);
      }
   }
   
   multiply(Float xi) Float {
    ifEmit(jv,cs,js) {
            Float res = Float.new();
            emit(jv,cs,js) {
            """
                bevl_res.bevi_float = this.bevi_float * beva_xi.bevi_float;
            """
            }
            return(res);
        }
      ifEmit(c) {
        return(self * xi);
      }
   }
   
   divide(Float xi) Float {
    ifEmit(jv,cs,js) {
            Float res = Float.new();
            emit(jv,cs,js) {
            """
                bevl_res.bevi_float = this.bevi_float / beva_xi.bevi_float;
            """
            }
            return(res);
        }
      ifEmit(c) {
        return(self / xi);
      }
   }
   
   modulus(Float xi) Float {
      return(0.0);
   }
   
   equals(xi) Bool {
      ifEmit(c) {
        return(self == xi);
      }
      emit(jv) {
      """
      if (beva_xi instanceof BEC_4_5_MathFloat && this.bevi_float == ((BEC_4_5_MathFloat)beva_xi).bevi_float) {
        return be.BELS_Base.BECS_Runtime.boolTrue;
      }
      """
      }
      emit(cs) {
      """
      var bevls_xi = beva_xi as BEC_4_5_MathFloat;
      if (bevls_xi != null && this.bevi_float == bevls_xi.bevi_float) {
        return be.BELS_Base.BECS_Runtime.boolTrue;
      }
      """
      }
      emit(js) {
      """
      if (this.bevi_float === beva_xi.bevi_float) {
        return be_BELS_Base_BECS_Runtime.prototype.boolTrue;
      }
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
      if (beva_xi instanceof BEC_4_5_MathFloat && this.bevi_float != ((BEC_4_5_MathFloat)beva_xi).bevi_float) {
        return be.BELS_Base.BECS_Runtime.boolTrue;
      }
      """
      }
      emit(cs) {
      """
      var bevls_xi = beva_xi as BEC_4_5_MathFloat;
      if (bevls_xi != null && this.bevi_float != bevls_xi.bevi_float) {
        return be.BELS_Base.BECS_Runtime.boolTrue;
      }
      """
      }
      emit(js) {
      """
      if (this.bevi_float !== beva_xi.bevi_float) {
        return be_BELS_Base_BECS_Runtime.prototype.boolTrue;
      }
      """
      }
      return(false);
   }
   
   greater(Float xi) Bool {
      ifEmit(c) {
        return(self > xi);
      }
      emit(jv,cs) {
      """
      if (this.bevi_float > beva_xi.bevi_float) {
        return be.BELS_Base.BECS_Runtime.boolTrue;
      }
      """
      }
      emit(js) {
      """
      if (this.bevi_float > beva_xi.bevi_float) {
        return be_BELS_Base_BECS_Runtime.prototype.boolTrue;
      }
      """
      }
      return(false);
   }
   
   lesser(Float xi) Bool {
      ifEmit(c) {
        return(self < xi);
      }
      emit(jv,cs) {
      """
      if (this.bevi_float < beva_xi.bevi_float) {
        return be.BELS_Base.BECS_Runtime.boolTrue;
      }
      """
      }
      emit(js) {
      """
      if (this.bevi_float < beva_xi.bevi_float) {
        return be_BELS_Base_BECS_Runtime.prototype.boolTrue;
      }
      """
      }
      return(false);
   }
   
   greaterEquals(Float xi) Bool {
      ifEmit(c) {
        return(self >= xi);
      }
      emit(jv,cs) {
      """
      if (this.bevi_float >= beva_xi.bevi_float) {
        return be.BELS_Base.BECS_Runtime.boolTrue;
      }
      """
      }
      emit(js) {
      """
      if (this.bevi_float >= beva_xi.bevi_float) {
        return be_BELS_Base_BECS_Runtime.prototype.boolTrue;
      }
      """
      }
      return(false);
   }
   
   lesserEquals(Float xi) Bool {
      ifEmit(c) {
        return(self <= xi);
      }
      emit(jv,cs) {
      """
      if (this.bevi_float <= beva_xi.bevi_float) {
        return be.BELS_Base.BECS_Runtime.boolTrue;
      }
      """
      }
      emit(js) {
      """
      if (this.bevi_float <= beva_xi.bevi_float) {
        return be_BELS_Base_BECS_Runtime.prototype.boolTrue;
      }
      """
      }
      return(false);
   }
   
}


