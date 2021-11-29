// Copyright 2006 The Brace Authors. All rights reserved.
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
use class Digest:SHA256 {

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

use class Digest:SHA1 {

   emit(jv) {
   """
   
    public MessageDigest bevi_md;
    
   """
   }
   
   emit(cs) {
   """
    public SHA1Managed bevi_md; 
   """
   }

    new() self {
        emit(jv) {
        """
        bevi_md = MessageDigest.getInstance("SHA-1");
        """
        }
        emit(cs) {
        """
        bevi_md = new SHA1Managed();
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
