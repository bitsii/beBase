/*
 * Copyright (c) 2016-2023, the Bennt Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

use Math:Int;

class Test:TestTokenizer{
   
   main() {
      return(testTokenizer());
   }
   
   testTokenizer() {
      any delims = ",.;:";
      any str = "Hi;There,George.TaDa";
      any toker = Text:Tokenizer.new(delims, true);
      any toks = toker.tokenize(str);
      for (any i = toks.iterator;i.hasNext;;) {
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

