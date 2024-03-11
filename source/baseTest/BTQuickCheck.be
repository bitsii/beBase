/*
 * Copyright (c) 2016-2023, the Brace Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

import Container:List;

import System:Parameters;
import Text:String;
import Text:String;

import Test:BaseTest;
import Test:Failure;
import Math:Int;

import Logic:Bool;

class Test:BaseTest:QuickCheck(BaseTest) {
   
      main() {
		("Test:BaseTest:QuickCheck:main begin").print();
		
		checkClassdefSizes();
		
		("Test:BaseTest:QuickCheck:main end").print();
      }
      
      checkClassdefSizes() {
      
         emit(c) {
"""
/*-attr- -dec-*/
size_t size;
"""
}

		  emit(c) {
"""
size = sizeof(BERT_ClassDef);
printf("Size of classdef %d\n", size);

size = sizeof(void*);
printf("Size of void* %d\n", size);

size = sizeof(int);
printf("Size of int %d\n", size);

size = sizeof(unsigned int);
printf("Size of unsigned int %d\n", size);

size = sizeof(long);
printf("Size of long %d\n", size);

size = sizeof(long long);
printf("Size of long long %d\n", size);

size = sizeof(float);
printf("Size of float %d\n", size);

size = sizeof(double);
printf("Size of double %d\n", size);

size = sizeof(int32_t);
printf("Size of int32_t %d\n", size);

size = sizeof(uint32_t);
printf("Size of uint32_t %d\n", size);

size = sizeof(BEINT);
printf("Size of BEINT %d\n", size);

"""
		}

		}
   
}


