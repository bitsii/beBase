/*
 * Copyright (c) 2006-2023, the Brace Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

import Container:Set:Relations;
import Container:Set:SetNode;
import Container:Set:IdentityRelations;
import Container:Map;
import Container:Set;
import Container:IdentityMap;
import Container:IdentitySet;
import Container:Map:MapNode;
import Container:List;
import Math:Float;

class IdentityRelations(Relations) {
   
   getHash(k) {
      return(System:Objects.tag(k));
   }
   
   isEqual(k, l) {
      return(System:Objects.sameObject(k, l));
   }
   
}

class IdentityMap(Map) {
   
   new() self {
      self.new(11);
   }
   
   new(Int _modu) self {
      buckets = List.new(_modu);
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
      buckets = List.new(_modu);
      modu = _modu;
      multi = 2;
      rel = IdentityRelations.new();
      baseNode = SetNode.new();
      size = 0;
   }
}
