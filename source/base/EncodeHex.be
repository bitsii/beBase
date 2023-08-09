// Copyright 2006 The Bennt Authors. All rights reserved.
// Use of this source code is governed by the BSD-3-Clause
// license that can be found in the LICENSE file.

use Encode:Hex;

local class Hex {

    create() self { }
    
    default() self { }
    
    encode(String str) String {
      Int ac = Int.new();
      String cur = String.new(2);
      Int ssz = str.size;
      String r = String.new(ssz * 2);
      for (Int pos = 0;pos < ssz;pos++=) {
         str.getCode(pos, ac);
         r += ac.toHexString(cur);
      }
      return(r);
   }
   
   decode(String str) String {
      Int ssz = str.size;
      if (ssz < 1) {
        return(str);
      }
      if (ssz % 2 != 0) {
        throw(System:Exception.new("Invalid hex string length " + ssz));
      }
      String cur = String.new(2);
      String r = String.new(ssz / 2);
      r.size = ssz / 2;
      Text:ByteIterator tb = Text:ByteIterator.new(str);
      String pta = String.new(1);
      String ptb = String.new(1);
      Int pos = 0;
      while (tb.hasNext) {
         tb.next(pta);
         tb.next(ptb);
         r.setCodeUnchecked(pos, Int.hexNew(pta + ptb));
         pos++=;
      }
      return(r)
   }
   
}
