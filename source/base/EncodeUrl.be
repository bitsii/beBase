/*
 * Copyright (c) 2006-2023, the Beysant Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

use Encode:Url;

local class Url {

   create() self { }
   
   default() self {
      
   }
   
   //http://www.eskimo.com/~bloo/indexdot/html/topics/urlencoding.htm
   //http://www.w3schools.com/TAGS/ref_urlencode.asp
   
   encode(String str) String {
      String r = String.new(str.length * 2); //?why
      Text:ByteIterator tb = Text:ByteIterator.new(str);
      String pt = String.new(2);
      while (tb.hasNext) {
         tb.next(pt);
         Int ac = pt.getCode(0);//TODO instead, tb.currentInt(int), more efficient
         if ((ac > 47 && ac < 58) || (ac > 64 && ac < 94) || (ac > 94 && ac < 123) || (ac > 44 && ac < 47) || ac == 42) {
            r.addValue(pt);
         } elseIf (ac == 32) {
            r.addValue("+");
         } else {
            r.addValue("%");
            String hcs = pt.getHex(0);
            r.addValue(hcs);
         }
      }
      return(r.toString());//TODO no reason to do toString here anymore
   }
   
   decode(String str) String {
      String r = String.new(str.length);
      Int last = 0;
      Int npl;
      Int npe;
      Int i;
      Bool ispl;
      
      npl = str.find("+", last);
      npe = str.find("%", last);
      if (undef(npe) || (def(npl) && npl < npe)) {
         ispl = true;
         i = npl;
      } else {
         ispl = false;
         i = npe;
      }
      
      Int len = str.length;
      while (def(i)) {
         if (i > last) {
            r.addValue(str.substring(last, i));
            last = i;
         }
         if (ispl) {
            r.addValue(" ");
            last = i + 1;
         } else {
            if (i + 2 < len) {
               r.addValue(String.hexNew(str.substring(i + 1, i + 3)));
               last = i + 3;
            }
         }
         npl = str.find("+", last);
         npe = str.find("%", last);
         if (undef(npe) || (def(npl) && npl < npe)) {
            ispl = true;
            i = npl;
         } else {
            ispl = false;
            i = npe;
         }
      }
      if (last < len) {
         r.addValue(str.substring(last, len));
      }
      return(r.toString());
   }
   
}
