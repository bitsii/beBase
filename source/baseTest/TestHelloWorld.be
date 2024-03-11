/*
 * Copyright (c) 2016-2023, the Brace Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

import Text:String;
import Math:Int;
import System:Object;

class Test:TestHelloWorld {
   
   main() {
      //Time:Sleep.sleepSeconds(120);
      String yo = "yo";
      String yar = "yar";
      emit(ccc) {
     """
printf("The address of bevl_yo is %p\n", (void *) bevl_yo);
//bevl_yo->bevg_gcMark = 9;
std::cout << "bevl_yo->bevg_gcMark is " << bevl_yo->bevg_gcMark << std::endl;
BECS_Object** bevs_ohs = bevs_myStack->bevs_ohs;
BECS_Object** bevs_hs = bevs_myStack->bevs_hs;
printf("The address of bevs_ohs is %p\n", (void *) bevs_ohs);
printf("The address of bevs_hs is %p\n", (void *) bevs_hs);

bevs_myStack->bevs_hs -= bevs_stackFrame.bevs_numVars;
BECS_Object** bevs_hs2 = bevs_myStack->bevs_hs;
printf("The address of bevs_hs2 is %p\n", (void *) bevs_hs2);
bevs_myStack->bevs_hs += bevs_stackFrame.bevs_numVars;

BECS_Object* bevg_leo = *(bevs_ohs);
printf("The address of bevg_leo is %p\n", (void *) bevg_leo);
//std::cout << "bevg_leo->bevg_gcMark is " << bevg_leo->bevg_gcMark << std::endl;
     """
     }
      tns(yo, yar);
      tns2(yo, yar);

      "Content-type: text/html\n\n<html><body>Hello there</body></html>".print();
   }

   tns(String yo, yar) {
     String boo;
     Int hi;
     Object there;
     emit(ccc) {
     """

     """
     }
   }

   tns2(String yo, yar) {
     String boo;
     Int hi;
     Object there;
     emit(ccc) {
     """
printf("The address of beva_yo is %p\n", (void *) beva_yo);
beva_yo->bevg_gcMark = 9;
std::cout << "beva_yo->bevg_gcMark is " << beva_yo->bevg_gcMark << std::endl;
printf("The address of beq->beva_yo is %p\n", (void *) beq->beva_yo);
bevs_myStack->bevs_hs -= bevs_stackFrame.bevs_numVars;
BECS_Object** bevs_hs = bevs_myStack->bevs_hs;
BECS_Object* bevg_leo = *(bevs_hs);
printf("The address of bevg_leo is %p\n", (void *) bevg_leo);
std::cout << "bevg_leo->bevg_gcMark is " << bevg_leo->bevg_gcMark << std::endl;
bevs_myStack->bevs_hs += bevs_stackFrame.bevs_numVars;

//for tns()
BECS_StackFrame* bevs_priorFrame = bevs_stackFrame.bevs_priorFrame;
bevs_myStack->bevs_hs -= bevs_stackFrame.bevs_numVars;
bevs_myStack->bevs_hs -= bevs_priorFrame->bevs_numVars;

bevg_leo = *(bevs_hs);
printf("The address of bevg_leo hsp is %p\n", (void *) bevg_leo);
std::cout << "bevg_leo->bevg_gcMark hsp is " << bevg_leo->bevg_gcMark << std::endl;

bevs_myStack->bevs_hs += bevs_stackFrame.bevs_numVars;
bevs_myStack->bevs_hs += bevs_priorFrame->bevs_numVars;

//also make sure actually hit the value coming from beginning
BECS_Object** bevs_ohs = bevs_myStack->bevs_ohs;
bevs_hs = bevs_myStack->bevs_hs;
bevg_leo = nullptr;
while (bevs_ohs < bevs_hs) {
   bevg_leo = *(bevs_ohs);
   if (bevg_leo != nullptr) {
   printf("The address of bevg_leo gcloop is %p\n", (void *) bevg_leo);
   std::cout << "bevg_leo->bevg_gcMark gcloop is " << bevg_leo->bevg_gcMark << std::endl;
   } else {
     printf("null in gcloop\n");
   }
   bevs_ohs++;
}
     """
     }
   }
   
}

