/*
 * Copyright (c) 2006-2023, the Bennt Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

final class Text:Tokenizer {
   
   new(String delims) self {
      fields {
         Map tmap; //String key, eq String value
         Bool includeTokens;
      }
      includeTokens = false;
      tokensStringSet(delims);
   }
   
   new(String delims, Bool _includeTokens) self {
      includeTokens = _includeTokens;
      tokensStringSet(delims);
   }
   
   tokensStringSet(String delims) {
      tmap = Map.new();
      for (String chi in delims) {
         tmap.put(chi, chi.toString());
      }
   }
   
   addToken(String _delim) {
      String delim = String.new();
      delim += _delim;
      tmap.put(delim, _delim);
   }
   
   tokenize(str) {
      return(tokenizeIterator(Text:MultiByteIterator.new(str)));
   }
   
   tokenize(str, tokenAcceptor) {
      return(tokenizeIterator(Text:MultiByteIterator.new(str), tokenAcceptor));
   }
   
   tokenizeIterator(i, acceptor) {
      String accum = String.new();
      String chi = String.new();
      while (i.hasNext) {
         i.next(chi);
         any cc = tmap.get(chi);
         if (def(cc)) {
            if (accum.length > 0) {
               acceptor.acceptToken(accum.extractString());
            }
            if (includeTokens) {
               acceptor.acceptToken(cc);
            }
         } else {
            accum += chi;
         }
      }
      if (accum.length > 0) {
         acceptor.acceptToken(accum.extractString());
      }
   }
   
   tokenizeIterator(i) {
      LinkedList splits = LinkedList.new();
      String accum = String.new();
      String chi = String.new();
      while (i.hasNext) {
         i.next(chi);
         any cc = tmap.get(chi);
         if (def(cc)) {
            if (accum.length > 0) {
               splits.addValue(accum.extractString());
            }
            if (includeTokens) {
               splits.addValue(cc);
            }
         } else {
            accum += chi;
         }
      }
      if (accum.length > 0) {
         splits.addValue(accum.extractString());
      }
      return(splits);
   }
   
}

use Container:LinkedList;
use Container:LinkedList:Node;
use Container:Stack;
use Container:Single;
