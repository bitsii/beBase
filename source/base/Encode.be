/*
 * Copyright (c) 2006-2023, the Beysant Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

use Encode:Hex;

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
        bevi_md.update(beva_with.bevi_bytes, 0, beva_with.bevp_length.bevi_int);
        bevl_res = new $class/Text:String$(bevi_md.digest());
        """
        }
        emit(cs) {
        """
        bevl_res = new $class/Text:String$(
          bevi_md.ComputeHash(beva_with.bevi_bytes, 0, beva_with.bevp_length.bevi_int)
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
        bevi_md.update(beva_with.bevi_bytes, 0, beva_with.bevp_length.bevi_int);
        bevl_res = new $class/Text:String$(bevi_md.digest());
        """
        }
        emit(cs) {
        """
        bevl_res = new $class/Text:String$(
          bevi_md.ComputeHash(beva_with.bevi_bytes, 0, beva_with.bevp_length.bevi_int)
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
  
      String r = String.new(str.length * 2); //?why
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
