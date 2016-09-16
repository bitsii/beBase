// Copyright 2006 Craig Welch
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

use Container:List;

use System:Parameters;
use Text:String;
use Text:String;

use Test:BaseTest;
use Test:Failure;
use Math:Int;

use Logic:Bool;

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


