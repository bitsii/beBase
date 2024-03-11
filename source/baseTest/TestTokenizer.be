/*
 * Copyright (c) 2016-2023, the Brace Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

import Math:Int;

class Test:TestTokenizer{
   
   main() {
      return(testTokenizer());
   }
   
   testTokenizer() {
      dyn delims = ",.;:";
      dyn str = "Hi;There,George.TaDa";
      dyn toker = Text:Tokenizer.new(delims, true);
      dyn toks = toker.tokenize(str);
      for (dyn i = toks.iterator;i.hasNext;;) {
         i.next.print();
      }
      
      /*
      if (uux + uuy == " Hi There. ") {
      (" PASSED add, equals" + uux + uuy).print();
      } else {
      "!FAILED add, equals".print();
      return(false);
      }
      */
      
      return(true);
   }
   
}

