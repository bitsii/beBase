/*
 * Copyright (c) 2006-2023, the Brace Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

/*
go to serialization
*/

use IO:File;
use Build:ClassSyn;
use Container:Set;
use Build:NamePath;
use Build:VarSyn;

final class VarSyn {

   new() self {
      isTyped = false;
   }
   
   npNew(NamePath np) self {
      namepath = np;
      isTyped = true;
   }
   
   anyNew(Build:Var full) self {
      fields {
         String name = full.name;
         NamePath namepath = full.namepath;
         Bool isTyped = full.isTyped;
         Bool isSelf = full.isSelf;
         Bool isThis = full.isThis;
      }
   }
   
   contentsEqual(VarSyn o) Bool {
      if (undef(o)) { return(false); }
      if (def(name) && def(o.name) && name != o.name) {
         return(false);
      }
      if (isTyped != o.isTyped) {
         return(false);
      }
      if (isTyped && namepath != o.namepath) {
         return(false);
      }
      return(true);
   }

}

final class ClassSyn {
   
   new() self {
      fields {
         Build:NamePath superNp;
         Int depth;
         Build:NamePath namepath;
         IO:File:Path fromFile;
         String libName;
         Bool isLocal;
         Bool isNotNull;
         Int newMbrs;
         Int newMtds;
         Int defMtds;
         Bool directProperties;
         Bool directMethods;
         
         //map of compat types
         Map allTypes = Map.new();
         //superclass ordered list
         LinkedList superList = LinkedList.new();
         //method map
         Map mtdMap = Map.new();
         //method ordered list
         List mtdList = List.new();
         Map ptyMap = Map.new();
         List ptyList = List.new();
         Map allNames = Map.new();
         Map foreignClasses = Map.new();
         Bool allAncestorsClose = false;
         Bool integrated = false;
         Bool iChecked = false;
         //used in Build:Class is a linked list of namepaths, this will be a set of strings from
         Set uses = Set.new();
         Bool isFinal = false;
         Bool signatureChanged = true;
         Bool signatureChecked = false;
      }
   }
   
   maxMtdxGet() Int {
		Int maxMtdx = 0;
		for (Container:Map:ValueIterator vi = mtdMap.valueIterator;vi.hasNext) {
			Build:MtdSyn ms = vi.next;
			if (ms.mtdx > maxMtdx) {
				maxMtdx = ms.mtdx;
			}
		}
		return(maxMtdx);
   }
   
   hasDefaultGet() Bool {
        any dmtd = mtdMap.get("default_0");
        if (def(dmtd)) {
            //(namepath.toString() + " has default").print();
            return(true);
        }
        return(false);
   }
   
   new(klass, psyn) self {
      allTypes = Map.new();
      mtdMap = Map.new();
      ptyMap = Map.new();
      allNames = Map.new();
      foreignClasses = Map.new();
      allAncestorsClose = false;
      integrated = false;
      iChecked = false;
      signatureChanged = true;
      signatureChecked = false;
      uses = Set.new();
      superList = psyn.superList.copy();
      superList.addValue(psyn.namepath);
      mtdList = psyn.mtdList.copy();
      ptyList = psyn.ptyList.copy();
      any pmr;
      any omr;
      for (any iv = klass.held.orderedVars.iterator;iv.hasNext;;) {
         any ov = iv.next;
         any pv = psyn.ptyMap.get(ov.held.name);
         if ((ov.held.name != "super") && (undef(pv)) && (ov.held.isDeclared!)) {
            throw(Build:VisitError.new("Variable " + ov.held.name + " is not declared in class or super class of " + klass.held.namepath.toString(), ov));
         }
         
      }
      
      for (iv = psyn.ptyList.iterator;iv.hasNext;;) {
         ov = iv.next;
         if (ov.memSyn.isTyped) {
            klass.held.addUsed(ov.memSyn.namepath);
         }
      }
      
      for (any im = klass.held.orderedMethods.iterator;im.hasNext;;) {
         any om = im.next;
         any pm = psyn.mtdMap.get(om.held.name);
         if (def(pm)) {
            if (def(pm.rsyn)) {
               if (undef(om.held.rtype)) {
                  throw(Build:VisitError.new("Parent method has return type but return type not specified in child in class " + klass.held.name + " for method " + om.held.name, om));
               }
            }
         }
      }
      loadClass(klass);
      depth = psyn.depth + 1;
   }
   
   castsTo(NamePath cto) {
      return(allTypes.has(cto));
   }
   
   integrate(Build:Build build) {
     if (integrated) { return(self); }
     integrated = true;
     directProperties = true;
     directMethods = true;
     allAncestorsClose = true;
     if (undef(superNp)) {
        allAncestorsClose = true;
        newMbrs = ptyList.length;
        newMtds = mtdList.length;
        defMtds = newMtds;
        for (Build:MtdSyn om in mtdList) {
			build.emitData.methodIndexes.put(Build:MethodIndex.new(self, om));
		}
        return(self);
     }
     ClassSyn psyn = build.getSynNp(superNp);
     newMtds = 0;
     defMtds = 0;
     //namepath.print();
     newMbrs = ptyList.length - psyn.ptyList.length;
     if (psyn.libName == libName) { psyn.integrate(build); }
     if (psyn.isFinal) {
      throw(Build:VisitError.new("Attempting to extend a final class in " + namepath.toString()));
     }
     if (psyn.isLocal && psyn.libName != libName) {
      throw(Build:VisitError.new("Attempting to extend a local class from outside parent's library in " + namepath.toString()));
     }
     if (psyn.isLocal && isLocal! && isFinal!) {
      throw(Build:VisitError.new("Descendents of classes declared local must also be local, this one is not  " + namepath.toString()));
     }
     for (NamePath pn in superList) {
         Build:ClassSyn pnsyn = build.getSynNp(pn);
         if (build.closeLibraries.has(pnsyn.libName)! && pn.toString() != "System:Object") {
            //("Not directProperties " + pn.toString() + " " + pnsyn.libName).print();
            directProperties = false;
            directMethods = false;
         }
         if (build.closeLibraries.has(pnsyn.libName)!) {
			allAncestorsClose = false;
         }
     }
     //("allAncestorsClose " + allAncestorsClose + " " + namepath + " " + psyn.namepath).print();
     for (any im = mtdMap.valueIterator;im.hasNext;;) {
         om = im.next;
         Build:MtdSyn pm = psyn.mtdMap.get(om.name);
         if (def(pm)) {
            if (om != pm) {
               pm.lastDef = false;
               om.isOverride = true;
               defMtds++;
            }
         } else {
            om.isOverride = false;
            newMtds++;
            defMtds++;
            build.emitData.methodIndexes.put(Build:MethodIndex.new(self, om));
         }
      }
      //("For class " + namepath.toString() + " newMtds " + newMtds.toString() + " defMtds " + defMtds.toString() + " newMbrs " + newMbrs.toString()).print();
   }
   
   checkInheritance(build, klass) {
     if (iChecked) { return(self); }
     iChecked = true;
     if (undef(superNp)) { return(self); }
     any psyn = build.getSynNp(superNp);
     for (any iv = klass.held.orderedVars.iterator;iv.hasNext;;) {
         any ov = iv.next;
         any pv = psyn.ptyMap.get(ov.held.name);
         if (def(pv)) {
            if (ov.held.isDeclared) {
               throw(Build:VisitError.new("Error, property from superclass re-declared in subclass property:" + ov.held.name + " subclass: " + klass.held.namepath.toString()));
            } else {
               ov.held.isTyped = pv.memSyn.isTyped;
               ov.held.namepath = pv.memSyn.namepath;
            }
         }
      }
      for (any im = klass.held.orderedMethods.iterator;im.hasNext;;) {
         any om = im.next;
         any pm = psyn.mtdMap.get(om.held.name);
         if (def(pm)) {
            if (pm.isFinal) {
               throw(Build:VisitError.new("Attempt to override final method " + om.held.name + " " + klass.held.namepath.toString(), om));
            }
            any oa = om.contained.first.contained;
            for (any i = 1;i < pm.argSyns.length;i++) {
               any pmr = pm.argSyns.get(i);
               any omr = oa.get(i).held;
               //("Checking argtypes").print();
               checkTypes(klass, build, omr, pmr, om);
            }
            pmr = pm.rsyn;
            omr = om.held.rtype;
            if (undef(pmr) || undef(omr)) {
               if (undef(pmr)! || undef(omr)!) {
                  /*if (def(pmr)) { ("pmr " + pmr).print(); }
                  if (def(omr)) { ("omr " + omr).print(); }
                  if (def(omr) && undef(omr.name)) { "omr name undef".print(); } 
                  elseIf (def(omr)) { ("omr name " + omr.name).print(); }*/
                  throw(Build:VisitError.new("Inheritance type mismatch error for return, one of parent or child are typed but not both!!!!! " + klass.held.namepath.toString(), om));
               }
            } else {
               //("Checking returntypes").print();
               if (pmr.isThis && (pmr.isThis != omr.isThis)) {
                 throw(Build:VisitError.new("Inheritance type mismatch error for return, parent return type is \"this\" but child is not " + klass.held.namepath.toString(), om));
               }
               checkTypes(klass, build, pmr, omr, om);
            }  
         }
      }
   }
   
   checkTypes(klass, build, pmr, omr, om) {
      if (pmr.isTyped != omr.isTyped) {
         throw(Build:VisitError.new("Inheritance type mismatch error, one of parent or child are typed but not both!!!!! " + klass.held.namepath.toString(), om));
      } elseIf (pmr.isTyped) {
         //TODO complete inheritance polymorph checktypes
         //pmr.namepath.toString() != omr.namepath.toString()
         if (pmr.isSelf && omr.isSelf) {
            return(self); //both are self typed (return type), OK
         }
         any osyn = build.getSynNp(omr.namepath);
         if (osyn.allTypes.has(pmr.namepath)!) {
            throw(Build:VisitError.new("Inheritance type mismatch error, child type does not match parent type namepath " + klass.held.namepath.toString(), om));
         }
      }
   }
   
   new(klass) self {
      self.new();
      for (any iv = klass.held.orderedVars.iterator;iv.hasNext;;) {
         any ov = iv.next;
         if (ov.held.isDeclared!) {
            throw(Build:VisitError.new("Variable " + ov.held.name + " is not declared in class " + klass.held.namepath.toString(), ov));
         }
      }
      loadClass(klass);
      depth = 0;
   }
   
   loadClass(klass) {
      //("In loadClass for " +klass.held.namepath.toString()).print();
      fromFile = klass.held.fromFile;
      namepath = klass.held.namepath;
      libName = klass.held.libName;
      isFinal = klass.held.isFinal;
      isLocal = klass.held.isLocal;
      isNotNull = klass.held.isNotNull;
      for (any iu = klass.held.used.iterator;iu.hasNext;;) {
         any ou = iu.next;
         uses.put(ou.toString());
      }
      for (any iv = klass.held.orderedVars.iterator;iv.hasNext;;) {
         any ov = iv.next;
         any prop = Build:PtySyn.new(ov, namepath);
         ptyList.addValue(prop);
      }
      for (any im = klass.held.orderedMethods.iterator;im.hasNext;;) {
         any om = im.next;
         any msyn = Build:MtdSyn.new(om, namepath);
         mtdList.addValue(msyn);
      }
      postLoad();
   }
   
   postLoad() {
      List nptyList = List.new();
      List mtdnList = List.new();
      Map unq;
      
      for (any iv = ptyList.iterator;iv.hasNext;;) {
         any ov = iv.next;
         if (ptyMap.has(ov.name)!) {
            //The list should containe only the first property by name and heritage
            ptyMap.put(ov.name, ov);
         }
      }
      
      unq = Map.new();
      any mpos = 0;
      for (iv = ptyList.iterator;iv.hasNext;;) {
         ov = iv.next;
         if (unq.has(ov.name)!) {
            any nom = ptyMap.get(ov.name);
            nom.mpos = mpos;
            mpos = mpos + 1;
            nptyList.addValue(nom);
            unq.put(ov.name, ov.name);
         }
      }
      ptyList = nptyList;
      
      Map mtdOmap = Map.new();
      
      for (any im = mtdList.iterator;im.hasNext;;) {
         any om = im.next;
         //The list should containe only the last method by name and heritage
         mtdMap.put(om.name, om);
         //This map is to find the origin of an overriden method
         if (mtdOmap.has(om.name)!) {
			mtdOmap.put(om.name, om);
         }
      }
      
      unq = Map.new();
      Int mtdx = 0;
      for (im = mtdList.iterator;im.hasNext;;) {
         om = im.next;
         if (unq.has(om.name)!) {
            any oma = mtdMap.get(om.name);
            //store where mtd was first declared
            //if msyno declaration is null then
            //this first instance of this method in hierarchy
            //has no declaration yet, so it is the top one
            //and it's declaration == it's origin
            //(it will be, in fact, this very class
            //since this happens in order top to bottom)
            //otherwise, take the existing one which was previously so-set
            Build:MtdSyn msyno = mtdOmap.get(om.name);
            if (undef(msyno.declaration)) {
				msyno.declaration = msyno.origin;
			}
            oma.declaration = msyno.declaration;
            oma.mtdx = mtdx.copy();
            mtdx++;
            mtdnList.addValue(oma);
            unq.put(om.name, om.name);
         }
      }
      mtdList = mtdnList;
      
      for (any s in superList) {
         allTypes.put(s, s);
         superNp = s;
      }
      
      allTypes.put(namepath, namepath);
   }
   
}

final class Build:MtdSyn {
   
   new(snode, _origin) self {
      
      any s = snode.held;
      
      fields {
         Int hpos;
         Int mtdx;
   
         Int numargs = s.numargs;
         String name = s.name;
         String orgName = s.orgName;
         Bool isGenAccessor = s.isGenAccessor;
         List argSyns = List.new(numargs + 1); //also self arg
         //declaration is the first place ever defined, origin is where this method was last overridden
         Build:NamePath origin = _origin;
         Build:NamePath declaration;
         Bool lastDef = true;
         Bool isOverride = false;
         Bool isFinal = s.isFinal;
         if (def(s.property)) {
            String propertyName = s.property.name;
         }
         if (def(s.rtype)) {
            VarSyn rsyn = VarSyn.anyNew(s.rtype);
         }
      }
      
      any args = snode.contained.first.contained;
      for (any i = 0;i < argSyns.length;i++;) {
         argSyns.put(i, VarSyn.anyNew(args[i].held));
      }
   }
   
   toString() Text:String {
      //("MtdSyn toString for " + name).print();
      any nl = Text:Strings.new().newline;
      any toRet = "method" + nl + "name" + nl + name + nl + "orgName" + nl + orgName + nl + "numargs" + nl + numargs.toString() + nl;
      toRet = toRet + "origin" + nl + origin.toString() + nl;
      toRet = toRet + "lastDef" + nl + lastDef.toString() + nl;
      toRet = toRet + "isFinal" + nl + isFinal.toString() + nl;
      if (def(propertyName)) {
         toRet = toRet + "propertyName" + nl + propertyName + nl;
      }
      toRet = toRet + "isGenAccessor" + nl + isGenAccessor.toString() + nl;
      toRet = toRet + "rsyn" + nl;
      if ((def(rsyn)) && (rsyn.isTyped)) {
         toRet = toRet + rsyn.namepath.toString() + nl;
      } else {
         toRet = toRet + "any" + nl;
      }
      for (any i = 0;i < argSyns.length;i = i++;) {
         any arg = argSyns.get(i);
         //("Doing " + i.toString()).print();
         toRet = toRet + "argType" + nl;
         if (arg.isTyped) {
            toRet = toRet + arg.namepath.toString() + nl;
         } else {
            toRet = toRet + "any" + nl;
         }
      }
      return(toRet);
   }
   
   getEmitReturnType(ClassSyn csyn, Build:Build build) NamePath {
      Bool covariantReturns = true;
      Build:EmitCommon ec = build.emitCommon;
      if (def(ec)) {
        covariantReturns = ec.covariantReturns;
      }
      if (def(rsyn)) {
          if (covariantReturns) {
            if (rsyn.isSelf) {
                return(csyn.namepath);
            } else {
                return(rsyn.namepath);
            }
          } else {
            if (rsyn.isSelf) {
                return(declaration);
            } else {
                Build:ClassSyn cs = build.getSynNp(declaration);
                Build:MtdSyn ms = cs.mtdMap.get(name);
                return(ms.rsyn.namepath);
             }
          }
      }
      return(null);
   }
   
}

final class Build:PtySyn {
   
   new(vnode, _origin) self {
      
      Build:Var v = vnode.held;
      
      fields {
         Int mpos;
         String name = v.name;
         Build:NamePath origin = _origin;
         VarSyn memSyn = VarSyn.anyNew(v);
         Bool isSlot = v.isSlot;
      }
   }
   
   toString() Text:String {
      any nl = Text:Strings.new().newline;
      any toRet = "property" + nl + "name" + nl + name + nl;
      toRet = toRet + "origin" + nl + origin.toString() + nl;
      toRet = toRet + "memType" + nl;
      if (memSyn.isTyped) {
         toRet = toRet + memSyn.namepath.toString() + nl;
      } else {
         toRet = toRet + "any" + nl;
      }
      return(toRet);
   }
}
