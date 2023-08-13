/*
 * Copyright (c) 2006-2023, the Brace Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

 use System:Random;
 
 emit(cs) {
     """
 using System;
 using System.Security.Cryptography;
    """
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

   seed(Int seed) Random {
      emit(cc) {
      """
      srand(beq->beva_seed->bevi_int);
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
      beq->beva_value->bevi_int = rand();
      """
      }
      emit(js) {
      """
      beva_value.bevi_int = Math.floor(Math.random() * Number.MAX_SAFE_INTEGER);
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
        str.setIntUnchecked(size, 0);
      }
      //TODO for jv, cs could just call nextBytes
      Int value = Int.new();
      for (Int i = 0;i < size;i++=) {
          //TODO lc and ints too
          str.setIntUnchecked(i, getIntMax(value, 26).addValue(65));
      }
      return(str);
   }
   
}
