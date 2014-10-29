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

use Container:Array;

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


