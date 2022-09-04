// Copyright 2006 The Brace Authors. All rights reserved.
// Use of this source code is governed by the BSD-3-Clause
// license that can be found in the LICENSE file.

use Container:Set:Relations;
use Container:Set:SetNode;
use Container:Set:IdentityRelations;
use Container:Map;
use Container:Set;
use Container:IdentityMap;
use Container:IdentitySet;
use Container:Map:MapNode;
use Container:List;
use Math:Float;

class IdentityRelations(Relations) {
   
   getHash(k) {
      return(k.tag);
   }
   
   isEqual(k, l) {
      return(k.sameObject(l));
   }
   
}

class IdentityMap(Map) {
   
   new() self {
      self.new(11);
   }
   
   new(Int _modu) self {
      slots = List.new(_modu);
      modu = _modu;
      multi = 2;
      rel = IdentityRelations.new();
      baseNode = MapNode.new();
      size = 0;
   }
}

class IdentitySet(Set) {
   
   new() self {
      self.new(11);
   }
   
   new(Int _modu) self {
      slots = List.new(_modu);
      modu = _modu;
      multi = 2;
      rel = IdentityRelations.new();
      baseNode = SetNode.new();
      size = 0;
   }
}
