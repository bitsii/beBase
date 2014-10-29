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

use Math:Int;
use Text:String;
use Text:String;
use Encode:Url;
use Logic:Bool;

use Encode:Hex;

local class Hex {

    create() { }
    
    default() self { }
    
    encode(String str) String {
      String cur = String.new(2);
      Int ssz = str.size;
      String r = String.new(ssz * 2);
      for (Int pos = 0;pos < ssz;pos = pos++) {
         Int ac = str.getCode(pos);
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
         pos = pos++;
      }
      return(r)
   }
   
}

//in future, could support file reader also
emit(jv) {
"""
import java.security.MessageDigest;
"""
}
emit(cs) {
"""
using System.Security.Cryptography;
"""
}
use local class Digest:SHA256 {

   emit(jv) {
   """
   
    public MessageDigest bevi_md;
    
   """
   }
   
   emit(cs) {
   """
    public SHA256Managed bevi_md; 
   """
   }

    new() self {
        emit(jv) {
        """
        bevi_md = MessageDigest.getInstance("SHA-256");
        """
        }
        emit(cs) {
        """
        bevi_md = new SHA256Managed();
        """
        }
    }
    
    digest(String with) String {
        new();
        String res;
        emit(jv) {
        """
        bevi_md.update(beva_with.bevi_bytes, 0, beva_with.bevp_size.bevi_int);
        bevl_res = new BEC_4_6_TextString(bevi_md.digest());
        """
        }
        emit(cs) {
        """
        bevl_res = new BEC_4_6_TextString(
          bevi_md.ComputeHash(beva_with.bevi_bytes, 0, beva_with.bevp_size.bevi_int)
        );
        """
        }
        return(res);
    }
    
    digestToHex(String input) String {
        return(Hex.encode(digest(input));
    }

}
   
local class Url {

   create() { }
   
   default() self {
      
   }
   
   //http://www.eskimo.com/~bloo/indexdot/html/topics/urlencoding.htm
   //http://www.w3schools.com/TAGS/ref_urlencode.asp
   
   encode(String str) String {
      String r = String.new(str.size * 2);
      Text:ByteIterator tb = Text:ByteIterator.new(str);
      String pt = String.new(2);
      while (tb.hasNext) {
         tb.next(pt);
         Int ac = pt.getCode(0);//TODO instead, tb.currentInt(int), more efficient
         if ((ac > 47 && ac < 58) || (ac > 64 && ac < 94) || (ac > 94 && ac < 123) || (ac > 44 && ac < 47) || ac == 42) {
            r.addValue(pt);
         } elif (ac == 32) {
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
      String r = String.new(str.size);
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
      
      Int len = str.size;
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
