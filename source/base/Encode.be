// Copyright 2006 Craig Welch
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

use Math:Int;
use Text:String;
use Text:String;
use Encode:Url;
use Logic:Bool;

use Encode:Hex;

local class Hex {

    create() self { }
    
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
        bevl_res = new $class/Text:String$(bevi_md.digest());
        """
        }
        emit(cs) {
        """
        bevl_res = new $class/Text:String$(
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

class Encode:Html {

   create() self { }
   
   default() self {
      
   }

  encode(String str) String {
  
      String r = String.new(str.size * 2); //?why
      Text:ByteIterator tb = Text:ByteIterator.new(str);
      String pt = String.new(2);
      while (tb.hasNext) {
         tb.next(pt);
         Int ac = pt.getCode(0);//TODO instead, tb.currentInt(int), more efficient
         if (ac > 127 || pt == '"' || pt == '<' || pt == '>' || pt == '&') {
            r.addValue("&#");
            r.addValue(ac.toString());
            r.addValue(";");
         } else {
            r.addValue(pt);
         }
      }
      return(r);
  }
  
}
   
local class Url {

   create() self { }
   
   default() self {
      
   }
   
   //http://www.eskimo.com/~bloo/indexdot/html/topics/urlencoding.htm
   //http://www.w3schools.com/TAGS/ref_urlencode.asp
   
   encode(String str) String {
      String r = String.new(str.size * 2); //?why
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
