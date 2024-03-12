/*
 * Copyright (c) 2006-2023, the Brace Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

import Math:Float;

final class Float {

   emit(c) {
   """
/*-attr- -firstSlotNative-*/
   """
   }
   
   emit(jv,cs) {
   """
   
    public float bevi_float;
    public $class/Math:Float$(float bevi_float) { this.bevi_float = bevi_float; }
    
   """
   }
   
  emit(cc_classHead) {
  """
    float bevi_float;
    BEC_2_4_5_MathFloat() { 
    #ifdef BEDCC_SGC
        struct bes {  BEC_2_6_6_SystemObject* bevr_this;  };
        BECS_FrameStack* bevs_myStack = &BECS_Runtime::bevs_currentStack;
        bes* beq = (bes*) bevs_myStack->bevs_hs;
        beq->bevr_this = this;
        BECS_StackFrame bevs_stackFrame(1);
    #endif
    bevi_float = 0.0; 
    }
    BEC_2_4_5_MathFloat(float a_bevi_float) { 
    #ifdef BEDCC_SGC
        struct bes {  BEC_2_6_6_SystemObject* bevr_this;  };
        BECS_FrameStack* bevs_myStack = &BECS_Runtime::bevs_currentStack;
        bes* beq = (bes*) bevs_myStack->bevs_hs;
        beq->bevr_this = this;
        BECS_StackFrame bevs_stackFrame(1);
    #endif
    bevi_float = a_bevi_float; 
    }
  """
  }
   
   emit(js) {
   """
   
    be_$class/Math:Float$.prototype.beml_set_bevi_float = function(bevi_float) {
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
   
      fields {
         //dyn vfloat;
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
            if (dec + 1 < si.length) {
                Int rhs = Int.new(si.substring(dec + 1));
            } else {
                rhs = 0;
            }
        } else {
            lhs = Int.new(si);
            rhs = 0;
        }
        Int divby = 10.power(rhs.toString().length);
        if (neg) {
            rhs *= -1;
            lhs *= -1;
        }
        Float rhsf = Float.intNew(rhs) / Float.intNew(divby);
        Float lhsf = Float.intNew(lhs);
        Float res = lhsf + rhsf;
        return(res);
   }
   
   
   intNew(Int int) self {
      emit(jv, cs) {
      """
      bevi_float = (float) beva_int.bevi_int;
      """
      }
      emit(js) {
      """
      this.bevi_float = beva_int.bevi_int * 1.0;
      """
      }
      emit(cc) {
      """
      bevi_float = (float) beq->beva_int->bevi_int;
      """
      }
   }
   
   create() self { return(Float.new()); }
   
   serializeToString() String {
      return(toString());
   }
   
   deserializeFromStringNew(String snw) self {
      self.new(snw);
   }
   
   serializeContentsGet() Bool {
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
      emit(jv, cs) {
      """
      bevl_ii.bevi_int = (int) bevi_float;
      """
      }
      emit(js) {
      """
      bevl_ii.bevi_int = Math.trunc(this.bevi_float);
      """
      }
      emit(cc) {
        """
        beq->bevl_ii->bevi_int = (int32_t) bevi_float;
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
      Float rh = self - Float.intNew(lhi);
      rh = rh * 1000000.0;//arbitrary... TODO support specifying this
      Int rhi = rh.toInt();
      return(lhi.toString() + "." + rhi.toString());
   }
   
   incrementValue() Float {
      ifEmit(jv,cs,js,cc) {
            emit(jv,cs,js) {
            """
                bevi_float = this.bevi_float + 1;
            """
            }
            emit(cc) {
            """
              bevi_float = bevi_float + 1;
            """
            }
        }
   }
   
   decrementValue() Float {
        ifEmit(jv,cs,js,cc) {
            emit(jv,cs,js) {
            """
                bevi_float = this.bevi_float - 1;
            """
            }
            emit(cc) {
            """
              bevi_float = bevi_float - 1;
            """
            }
        }
   }
   
   add(Float xi) Float {
      ifEmit(jv,cs,js,cc) {
            Float res = Float.new();
            emit(jv,cs,js) {
            """
                bevl_res.bevi_float = this.bevi_float + beva_xi.bevi_float;
            """
            }
            emit(cc) {
            """
               beq->bevl_res->bevi_float = bevi_float + beq->beva_xi->bevi_float;
            """
            }
            return(res);
        }
      ifEmit(c) {
        return(self + xi);
      }
   }
   
   subtract(Float xi) Float {
    ifEmit(jv,cs,js,cc) {
            Float res = Float.new();
            emit(jv,cs,js) {
            """
                bevl_res.bevi_float = this.bevi_float - beva_xi.bevi_float;
            """
            }
            emit(cc) {
            """
                beq->bevl_res->bevi_float = bevi_float - beq->beva_xi->bevi_float;
            """
            }
            return(res);
        }
      ifEmit(c) {
      return(self - xi);
      }
   }
   
   multiply(Float xi) Float {
    ifEmit(jv,cs,js,cc) {
            Float res = Float.new();
            emit(jv,cs,js) {
            """
                bevl_res.bevi_float = this.bevi_float * beva_xi.bevi_float;
            """
            }
            emit(cc) {
            """
                beq->bevl_res->bevi_float = bevi_float * beq->beva_xi->bevi_float;
            """
            }
            return(res);
        }
      ifEmit(c) {
        return(self * xi);
      }
   }
   
   divide(Float xi) Float {
    ifEmit(jv,cs,js,cc) {
            Float res = Float.new();
            emit(jv,cs,js) {
            """
                bevl_res.bevi_float = this.bevi_float / beva_xi.bevi_float;
            """
            }
            emit(cc) {
            """
              beq->bevl_res->bevi_float = bevi_float / beq->beva_xi->bevi_float;
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
      if (this.bevi_float == (($class/Math:Float$)beva_xi).bevi_float) {
        return be.BECS_Runtime.boolTrue;
      }
      """
      }
      emit(cs) {
      """
      var bevls_xi = beva_xi as $class/Math:Float$;
      if (this.bevi_float == bevls_xi.bevi_float) {
        return be.BECS_Runtime.boolTrue;
      }
      """
      }
      emit(js) {
      """
      if (this.bevi_float === beva_xi.bevi_float) {
        return be_BECS_Runtime.prototype.boolTrue;
      }
      """
      }
      emit(cc) {
      """
#ifndef BEDCC_NORTTI
      BEC_2_4_5_MathFloat* bevls_xi = dynamic_cast<BEC_2_4_5_MathFloat*>(beq->beva_xi);
#endif
#ifdef BEDCC_NORTTI
      BEC_2_4_5_MathFloat* bevls_xi = static_cast<BEC_2_4_5_MathFloat*>(beq->beva_xi);
#endif
      if (bevi_float == bevls_xi->bevi_float) {
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
      emit(jv) {
      """
      if (this.bevi_float != (($class/Math:Float$)beva_xi).bevi_float) {
        return be.BECS_Runtime.boolTrue;
      }
      """
      }
      emit(cs) {
      """
      var bevls_xi = beva_xi as $class/Math:Float$;
      if (this.bevi_float != bevls_xi.bevi_float) {
        return be.BECS_Runtime.boolTrue;
      }
      """
      }
      emit(js) {
      """
      if (this.bevi_float !== beva_xi.bevi_float) {
        return be_BECS_Runtime.prototype.boolTrue;
      }
      """
      }
      emit(cc) {
      """
#ifndef BEDCC_NORTTI
      BEC_2_4_5_MathFloat* bevls_xi = dynamic_cast<BEC_2_4_5_MathFloat*>(beq->beva_xi);
#endif
#ifdef BEDCC_NORTTI
      BEC_2_4_5_MathFloat* bevls_xi = static_cast<BEC_2_4_5_MathFloat*>(beq->beva_xi);
#endif
      if (bevi_float != bevls_xi->bevi_float) {
        return BECS_Runtime::boolTrue;
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
        return be.BECS_Runtime.boolTrue;
      }
      """
      }
      emit(js) {
      """
      if (this.bevi_float > beva_xi.bevi_float) {
        return be_BECS_Runtime.prototype.boolTrue;
      }
      """
      }
      emit(cc) {
      """
      if (bevi_float > beq->beva_xi->bevi_float) {
        return BECS_Runtime::boolTrue;
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
        return be.BECS_Runtime.boolTrue;
      }
      """
      }
      emit(js) {
      """
      if (this.bevi_float < beva_xi.bevi_float) {
        return be_BECS_Runtime.prototype.boolTrue;
      }
      """
      }
      emit(cc) {
      """
      if (bevi_float < beq->beva_xi->bevi_float) {
        return BECS_Runtime::boolTrue;
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
        return be.BECS_Runtime.boolTrue;
      }
      """
      }
      emit(js) {
      """
      if (this.bevi_float >= beva_xi.bevi_float) {
        return be_BECS_Runtime.prototype.boolTrue;
      }
      """
      }
      emit(cc) {
      """
      if (bevi_float >= beq->beva_xi->bevi_float) {
        return BECS_Runtime::boolTrue;
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
        return be.BECS_Runtime.boolTrue;
      }
      """
      }
      emit(js) {
      """
      if (this.bevi_float <= beva_xi.bevi_float) {
        return be_BECS_Runtime.prototype.boolTrue;
      }
      """
      }
      emit(cc) {
      """
      if (bevi_float <= beq->beva_xi->bevi_float) {
        return BECS_Runtime::boolTrue;
      }
      """
      }
      return(false);
   }
   
}


