/*
 * Copyright (c) 2006-2023, the Beysant Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

use Build:Visit;
use Build:NamePath;
use Build:VisitError;
use Build:Node;
use Build:ClassSyn;

local class Build:Visit:ChkIfEmit(Build:Visit:Visitor) {

      acceptIfEmit(Node node) {
      Bool include = true;
      String emitLang = build.emitLangs.first;
      if (node.held.value == "ifNotEmit") {
        Bool negate = true;
      } else {
        negate = false;
      }
      if (negate) {
        if (node.held.langs.has(emitLang)) {
          include = false;
        }
        if (def(build.emitFlags)) {
          for (String flag in build.emitFlags) {
            if (node.held.langs.has(flag)) {
              include = false;
            }
          }
        }
      } else {
        Bool foundFlag = false;
        if (def(build.emitFlags)) {
          for (flag in build.emitFlags) {
            if (node.held.langs.has(flag)) {
              foundFlag = true;
            }
          }
        }
        if (foundFlag! && node.held.langs.has(emitLang)!) {
          include = false;
        }
      }
      if (include) {
        return(node.nextDescend);
      }
      return(node.nextPeer);
   }

}

final class Build:Visit:Pass12(Build:Visit:ChkIfEmit) {

   new() self {
      fields {
         NamePath classnp;
      }
   }
   
   getAccessor(node) {
      any myselfn = Node.new(build);
      myselfn.typename = ntypes.VAR;
      any myself = Build:Var.new();
      myself.name = "self";
      myself.isTyped = true;
      myself.namepath = classnp;
      myself.isArg = true;
      myselfn.held = myself;
      any mtdmyn = Node.new(build);
      mtdmyn.typename = ntypes.METHOD;
      any mtdmy = Build:Method.new();
      mtdmy.isGenAccessor = true;
      mtdmyn.held = mtdmy;
      any myparn = Node.new(build);
      myparn.typename = ntypes.PARENS;
      myparn.addValue(myselfn);
      mtdmyn.addValue(myparn);
      myselfn.addVariable();
      any mybr = Node.new(build);
      mybr.typename = ntypes.BRACES;
      mtdmyn.addValue(mybr);
      mtdmy.rtype = Build:Var.new();
      mtdmy.rtype.isSelf = true;
      mtdmy.rtype.isThis = true;
      mtdmy.rtype.isTyped = true;
      mtdmy.rtype.namepath = Build:NamePath.new("self");
      return(mtdmyn);
   }
      
   getRetNode(node) {
      any retnoden = Node.new(build);
      retnoden.typename = ntypes.CALL;
      any retnode = Build:Call.new();
      retnode.name = "return";
      retnoden.held = retnode;
      any sn = Node.new(build);
      sn.typename = ntypes.VAR;
      sn.held = "self";
      retnoden.addValue(sn);
      return(retnoden);
   }
      
   getAsNode(selfnode) {
      any asnoden = Node.new(build);
      asnoden.typename = ntypes.CALL;
      any asnode = Build:Call.new();
      asnode.name = "assign";
      asnoden.held = asnode;
      return(asnoden);
   }
   
   
   accept(Node node) Node {
      //if ((node.typename == ntypes.VAR) && (def(node.held.namepath))) {
      //   ("Found namepath typed any again " + node.held.name + " " + node.held.namepath.toString()).print();
      //}
      if (node.typename == ntypes.IFEMIT) {
         return(acceptIfEmit(node));
      }
      if (node.typename == ntypes.METHOD) {
         any ia = node.contained.first.contained.first; //self
         ia.held.isTyped = true;
         ia.held.namepath = classnp;
         //if (def(node.held.rtype) && node.held.rtype.isThis) {
         //   ("FOUND A THIS RETURN TYPE " + node.held.isGenAccessor).print();
         //}
      } elseIf (node.typename == ntypes.CLASS) {
         classnp = node.held.namepath;
         any tst = Build:Call.new();
         for (any ii = node.held.orderedVars.iterator;ii.hasNext;;) {
            any i = ii.next.held;
            any ename;
            any anode;
            any rettnode;
            any rin;
            
            any sv;
            any svn;
            any svn2;
            any asn;
            
            //reg get
            tst.name = i.name.copy();
            tst.accessorType = "GET";
            tst.toAccessorName();
            ename = tst.name;
            tst.name = tst.name + "_0";
            if (i.isDeclared && i.isSlot! && (node.held.methods.has(tst.name)!)) {
            
               anode = getAccessor(node);
               anode.held.property = i;
               anode.held.orgName = ename;
               anode.held.name = tst.name;
               anode.held.numargs = 0;
               node.held.methods.put(anode.held.name, anode);
               node.held.orderedMethods.addValue(anode);
               node.contained.last.addValue(anode);
               rettnode = getRetNode(node);
               rin = Node.new(build);
               rin.copyLoc(node);
               rin.typename = ntypes.VAR;
               rin.held = i.name.copy();
               rettnode.addValue(rin);
               anode.contained.last.addValue(rettnode);
               rettnode.contained.first.syncVariable(self);
               rin.syncVariable(self);
               if (i.isTyped) {
                  anode.held.rtype = i;
               } else {
                  anode.held.rtype = null;
               }
            
            }
            //end reg get
            
            //reg set
            tst.name = i.name.copy();
            tst.accessorType = "SET";
            tst.toAccessorName();
            ename = tst.name;
            tst.name = tst.name + "_1";
            if (i.isDeclared && i.isSlot! && (node.held.methods.has(tst.name)!)) {
            
               anode = getAccessor(node);
               anode.held.property = i;
               anode.held.orgName = ename;
               anode.held.name = tst.name;
               anode.held.numargs = 1;
               node.held.methods.put(anode.held.name, anode);
               node.held.orderedMethods.addValue(anode);
               node.contained.last.addValue(anode);
               
               sv = anode.tmpVar("SET", build);
               sv.isArg = true;
               svn = Node.new(build);
               svn.copyLoc(node);
               svn.typename = ntypes.VAR;
               svn.held = sv;
               
               anode.contained.first.addValue(svn);
               svn2 = Node.new();
               svn2.copyLoc(node);
               svn2.typename = ntypes.VAR;
               svn2.held = sv;
               
               asn = self.getAsNode(node);
               rin = Node.new(build);
               rin.copyLoc(node);
               rin.typename = ntypes.VAR;
               rin.held = i.name.copy();
               asn.addValue(rin);
               asn.addValue(svn2);
               anode.contained.last.addValue(asn);
               
               svn.addVariable();
               rin.syncVariable(self);

               //TODO first arg should be typed same as property
            
            }
            //end reg set
            
         }
      } elseIf (node.typename == ntypes.CALL) {
         if (undef(node.held)) {
            throw(Build:VisitError.new("Call held is null", node));
         }
         if (node.held.isConstruct && undef(node.held.newNp)) {
            any newNp = node.contained.first;
            if (newNp.typename != ntypes.NAMEPATH) {
               if ((newNp.typename == ntypes.VAR) && (newNp.held.name == "self")) {
                  newNp = node.second;
                  if (newNp.typename != ntypes.NAMEPATH) {
                     ("Incorrect first argument for new, second try, first argument is " + newNp.toString()).print();
                     throw(Build:VisitError.new("Incorrectly formed new, second try, namepath not first argument, namepath probably does not exist, verify name and use declarations", node));
                  }
               } else {
                  ("Incorrect first argument for new, first argument is " + newNp.toString()).print();
                  throw(Build:VisitError.new("Incorrectly formed new, namepath not first argument", node));
               }
            }
            node.held.newNp = newNp.held;
            newNp.remove();
         }
         node.held.numargs = node.contained.length - 1;
         node.held.orgName = node.held.name;
         node.held.name = node.held.name + "_" + node.held.numargs.toString();
         if (node.held.orgName == "assign") {
            any c0 = node.contained.first;
            if ((def(c0)) && (c0.typename == ntypes.VAR)) {
               c0.held.numAssigns++;
            }
            any c1 = node.contained.second;
         }
      } elseIf (node.typename == ntypes.BRACES) {
         any bn = Node.new(build);
         if (def(node.contained) && def(node.contained.last)) {
            bn.nlc = node.contained.last.nlc;
         } else {
            bn.copyLoc(node);
         }
         bn.typename = ntypes.RBRACES;
         node.addValue(bn);
      } elseIf (node.typename == ntypes.PARENS) {
         any pn = Node.new(build);
         if (def(node.contained) && def(node.contained.last)) {
            pn.nlc = node.contained.last.nlc;
         } else {
            pn.copyLoc(node);
         }
         pn.typename = ntypes.RPARENS;
         node.addValue(pn);
      }
      return(node.nextDescend);
   }
   
}

final class Build:Visit:Rewind(Build:Visit:ChkIfEmit) {

   new() self {
      fields {
         any tvmap;
         any rmap;
         any inClass;
         any inClassNp;
         any inClassSyn;
         any nl;
         any emitter;
      }
   }
   
   accept(Node node) Node {
      if (node.typename == ntypes.IFEMIT) {
         return(acceptIfEmit(node));
      }
      if (node.typename == ntypes.CALL && node.held.wasForeachGenned) {
        //("in wasforgenned 1").print();
        if (node.container.typename == ntypes.CALL && node.container.held.orgName == "assign" && node.isSecond) {
          //("in wasforgenned 2").print();
          if (node.contained.first.typename == ntypes.VAR && node.contained.first.held.isTyped) {
            NamePath fgnp = node.contained.first.held.namepath;
            String fgcn = fgnp.steps.last;
            String fgin = fgcn.substring(0,1).lowerValue() + fgcn.substring(1) + "IteratorGet";
            //("in wasforgenned 3 " + fgin + " for " + fgnp).print();
            ClassSyn fgsy = build.getSynNp(fgnp);
            Build:MtdSyn fgms = fgsy.mtdMap.get(fgin + "_0");
            if (def(fgms)) {
              //("did forgenned for iterator for " + fgnp).print();
              node.held.orgName = fgin;
              node.held.name = fgin + "_0";
            }
          }
        }
      }
      if (node.typename == ntypes.CLASS) {
         inClass = node;
         inClassNp = node.held.namepath;
         inClassSyn = node.held.syn;
      }
      if (node.typename == ntypes.METHOD) {
         tvmap = Map.new();
         rmap = Map.new();
      } elseIf ((node.typename == ntypes.VAR) && node.held.autoType) {
         tvmap.put(node.held.name, node.held);
         any ll = rmap.get(node.held.name);
         if (undef(ll)) {
            ll = Container:LinkedList.new();
            rmap.put(node.held.name, ll)
         }
         ll.addValue(node);
      } elseIf (node.typename == ntypes.RBRACES && def(node.container) && def(node.container.container) && node.container.container.typename == ntypes.METHOD) {
         //("!!! PROCESSING TMPS").print();
         processTmps();
      }
      return(node.nextDescend);
   }
   
   processTmps() {
      any foundone = true;
      any targ;
      any tany;
      any tcall;
      ClassSyn syn;
      any targNp;
      any mtdc;
      any oany;
      while (foundone) {
         foundone = false;
         for (any i = tvmap.valueIterator;i.hasNext;) {
            any nv = i.next;
            //("!!!Toplevel checking isTyped " + nv.name).print();
            if (nv.isTyped!) {
               //("!!!notTyped " + nv.name).print();
               //if it is typed it has already been found
               any nvname = nv.name;
               any ll = rmap.get(nvname);
               for (any k in ll) {
                  if (k.isFirst && k.container.typename == ntypes.CALL && k.container.held.orgName == "assign" && k.container.second.typename == ntypes.CALL) {
                     //("!!!Found to be first arg to assign").print();
                     tcall = k.container.second;
                     targNp = null;
                     if (def(tcall.held.newNp)) {
                        targNp = tcall.held.newNp;
                     } else {
                        targ = tcall.contained.first;
                        if (targ.held.isDeclared) {
                           tany = targ.held;
                        } else {
                           tany = inClassSyn.ptyMap.get(targ.held.name).memSyn; //all non-declared mmbers caught
                           //in syn generation
                        }
                        if (tany.isTyped) {
                           targNp = tany.namepath;
                        }
                     }
                     if (def(targNp)) {
                        //("targNp not null " + targNp.toString()).print();
                        syn = build.getSynNp(targNp);
                        mtdc = syn.mtdMap.get(tcall.held.name);
                        if (def(mtdc)) {
                           //"Found oany".print();
                           oany = mtdc.rsyn;
                           if (def(oany) && oany.isTyped) {
                              foundone = true;
                              //("typing a tmpvar a").print();
                              if (oany.isSelf) {
                                 nv.namepath = targNp;
                              } else {
                                 nv.namepath = oany.namepath;
                              }
                              nv.isTyped = oany.isTyped;
                              inClass.held.addUsed(nv.namepath);
                              if (nv.namepath.toString() == "self") { ("FOUND A SELF TMPVAR rewind " + oany.isSelf).print(); }
                           }
                        } elseIf (tcall.held.orgName != "return") {
                           Build:MtdSyn fcms = syn.mtdMap.get("forwardCall_2");
                           if (def(fcms) && fcms.origin.toString() != "System:Object") {
                             tcall.held.isForward = true;
                           } else {
                           throw(Build:VisitError.new("(A) No such call " + tcall.held.name + " in class " + targNp.toString(), tcall));
                           }
                        }
                     } /* else {
                        //"Targ np null".print();
                     } */
                  } elseIf (k.isFirst && k.container.typename == ntypes.CALL && k.container.held.orgName == "assign" && k.container.second.typename == ntypes.VAR) {
                     targ = k.container.second.held;
                     //("Considering any " + targ.name).print();
                     if (targ.isTyped) {
                        //("FOUND REWINDABLE TMPVAR TYPE OPPORTUNITY VAR !!!").print();
                        foundone = true;
                        //("typing a tmpvar b").print();
                        nv.isTyped = targ.isTyped;
                        nv.namepath = targ.namepath;
                     }
                  }
               }
            }
         }
      }
   }

}

final class Build:Visit:TypeCheck(Build:Visit:ChkIfEmit) {
   
   new() self {
      fields {
         any emitter;
         Node inClass;
         any inClassNp;
         any inClassSyn;
         Int cpos;
      }
   }
   
   accept(Node node) Node {
      if (node.typename == ntypes.IFEMIT) {
         return(acceptIfEmit(node));
      }
      if (node.typename == ntypes.CATCH) {
        if (node.contained.first.contained.first.held.isTyped) {
            throw(Build:VisitError.new("Catch variables must be declared untyped (any)"));
        }
      }
      if (node.typename == ntypes.CLASS) {
         inClass = node;
         inClassNp = node.held.namepath;
         inClassSyn = node.held.syn;
      }
      if (node.typename == ntypes.METHOD) {
         cpos = 0;
      }
      if (node.typename == ntypes.CALL) {
         node.held.cpos = cpos.copy();
         cpos++;
         for (Node cci in node.contained) {
            if (cci.typename == ntypes.VAR) {
               cci.held.addCall(node);
            }
         }
         Node targ;
         any tany;
         any oany;
         ClassSyn syn;
         any mtdmy;
         Node ctarg;
         any cany;
         any mtdc;
         if (node.held.orgName == "assign") {
            targ = node.contained.first;
            if (targ.held.isDeclared) {
               tany = targ.held; //tany is the variable being assigned to
            } else {
               tany = inClassSyn.ptyMap.get(targ.held.name).memSyn; //all non-declared mmbers caught
               //in syn generation
            }
            if (tany.isTyped!) {
               node.held.checkTypes = false;
            } else {
               Node org = node.second;
               if (org.typename == ntypes.TRUE || org.typename == ntypes.FALSE) {
                  //"SHORTCUT TRUE OR FALSE".print();
                  node.held.checkTypes = false;
               } else {
                  if (org.typename == ntypes.VAR) {
                     if (org.held.isDeclared) {
                        oany = org.held;
                     } else { //TODO fix use of reserved word here
                        //targ.held.name.print();
                        oany = inClassSyn.ptyMap.get(org.held.name).memSyn; //all non-declared mmbers caught
                        //in syn generation
                     }
                  } elseIf (org.typename == ntypes.CALL) {
                     ctarg = org.contained.first;//assigning to this node
                     //cany is the any being assigned to
                     if (ctarg.held.isDeclared) {
                        //"2".print();
                        cany = ctarg.held;
                     } else {
                        //"3".print();
                        cany = inClassSyn.ptyMap.get(ctarg.held.name).memSyn; //all non-declared mmbers caught
                        //in syn generation
                     }
                     syn = null; //the syn where the call lives (target class for call)
                     if (def(org.held.newNp)) {
                        syn = build.getSynNp(org.held.newNp);
                     } elseIf (cany.isTyped){
                        //something needs to be done for isSelf
                        syn = build.getSynNp(cany.namepath);
                     }
                     if (def(syn)) {
                        mtdc = syn.mtdMap.get(org.held.name);
                        if (undef(mtdc)) {
                           Build:MtdSyn fcms = syn.mtdMap.get("forwardCall_2");
                           if (def(fcms) && fcms.origin.toString() != "System:Object") {
                             org.held.isForward = true;
                           } else {
                           throw(Build:VisitError.new("(B) No such call " + org.held.name + " in class " + syn.namepath, org));
                           }
                        } else {
                           oany = mtdc.rsyn;
                        }
                     }
                  }
                  if (def(oany) && (oany.isTyped)) {
                     //here is where return type checking covariant / getEmitReturnType needs to happen
                     Bool castForSelf = false;
                     if (oany.isSelf) {
                        //syn is call target class from above, nulled before set
                        if (undef(syn)) {
                           throw(Build:VisitError.new("Self oany without syn target"));
                        }
                        //oany type is what matters
                        //declaration is the first place ever defined, origin is where this method was last overridden
                        //correct thing should be to compare origin to destination of assign
                        if (mtdc.origin != tany.namepath) { //TODO just test for tany being BELOW mtdc.origin in hierarchy
                            //we will need to cast despite compatibility TODO FASTER this could be a fast-cast...
                            castForSelf = true;
                        } elseIf (def(build.emitCommon) && build.emitCommon.covariantReturns!) {
                            castForSelf = true;
                        }
                     } elseIf (def(mtdc)) {
                        syn = build.getSynNp(mtdc.getEmitReturnType(syn, build));
                     } else {
                        syn = build.getSynNp(oany.namepath);//before switch to the above
                     }
                     //now syn is the syn of the return type of the call
                     //("Checking for targ " + tany.namepath.toString() + " oany " + oany.namepath.toString()).print();
                     if (syn.castsTo(tany.namepath)) {
                        //("!!!!Found compatible NOCHECK type assign").print();
                        node.held.checkTypes = false;
                     } else {
                        if (oany.isSelf) {
                           any ovnp = syn.namepath;
                        } else {
                           ovnp = oany.namepath;
                        }
                        syn = build.getSynNp(tany.namepath);
                        if (syn.castsTo(ovnp)) {
                           //("!!!!Found compatible CHECK type assign " + ovnp + " " + syn.namepath).print();
                           node.held.checkTypes = true;
                        } else {
                           throw(Build:VisitError.new("Incorrect type on assignment, " + syn.namepath.toString() + " cannot be cast to " + ovnp.toString(), node));
                        }
                     }
                     //override for self cases where cast is needed anyway                     
                     if (castForSelf) {
                     //("castForSelf").print();
                        node.held.checkTypes = true;
                        node.held.checkTypesType = "unchecked";
                     }
                  }
                  if (def(targ.held.namepath)) {
                     //("!!!Target name " + targ.held.name + " namepath " + targ.held.namepath.toString()).print();
                  }
               }
            }
         } elseIf (node.held.orgName == "return") {
            targ = node.second;
            if (targ.typename == ntypes.VAR) {
               if (targ.held.isDeclared) {
                  tany = targ.held;
               } else {
                  tany = inClassSyn.ptyMap.get(targ.held.name).memSyn; //all non-declared mmbers caught
                  //in syn generation
               }
               mtdmy = node.scope;
               if (targ.held.isDeclared) {
                  tany = targ.held;
               } else {
                  tany = inClassSyn.ptyMap.get(targ.held.name).memSyn; //all non-declared mmbers caught
                  //in syn generation
               }
               if (def(mtdmy.held.rtype) && mtdmy.held.rtype.isTyped) {
                  if (tany.isTyped!) {
                     if (mtdmy.held.rtype.isThis) {
                       throw(Build:VisitError.new("Incorrect type on return, can only return(self); (actual self reference) for \"this\" return typed methods", node));
                     }
                     //("Found typed return untyped target").print();
                     node.held.checkTypes = true;
                  } else {
                     // self type ret in here...
                     // check for impossible types
                     if (mtdmy.held.rtype.isSelf) {
                        if (tany.name == "self") {
                           //("Found self return for self rtype, NOCHECK " + node.toString() + " " + tany.isSelf).print();
                           node.held.checkTypes = false;
                        } else {
                           if (mtdmy.held.rtype.isThis) {
                             throw(Build:VisitError.new("Incorrect type on return, can only return(self); (actual self reference) for \"this\" return typed methods", node));
                           }
                           any targsyn = build.getSynNp(tany.namepath);
                           if (inClassSyn.castsTo(tany.namepath) || targsyn.castsTo(inClassSyn.namepath)) {
                              //("Found non-self return for self rtype, CHECK " + node.toString();).print();
                              node.held.checkTypes = true;
                           } else {
                              throw(Build:VisitError.new("Incorrect type on return, returned type not castable to self type. " + inClassSyn.namepath + " " + tany.namepath, node));
                           }
                        }
                     } else {
                        syn = build.getSynNp(tany.namepath);
                        if (syn.castsTo(mtdmy.held.rtype.namepath)) {
                           //("!!!Found compatible NOCHECK typed return").print();
                           node.held.checkTypes = false;
                        } else {
                           syn = build.getSynNp(mtdmy.held.rtype.namepath);
                           if (syn.castsTo(tany.namepath)) {
                              //("!!!Found compatible CHECK typed return").print();
                              node.held.checkTypes = true;
                           } else {
                              throw(Build:VisitError.new("Incorrect type on return.", node));
                           }
                        }
                     }
                  }
               } else {
                  //("Found return untyped").print();
                  node.held.checkTypes = false;
               }
            } else {
               node.held.checkTypes = false; //WILL BE literal NULL null
            }
         } else {
            targ = node.contained.first;
            if (targ.held.isDeclared) {
               tany = targ.held;
            } else {
               tany = inClassSyn.ptyMap.get(targ.held.name).memSyn; //all non-declared mmbers caught
               //in syn generation
            }
            if (tany.isTyped! || node.held.orgName == "throw") {
               node.held.checkTypes = true; //this is what will be passed with call... receiver should check types
            } else {
               node.held.checkTypes = false; 
               if (node.held.isConstruct) {
                  if (undef(node.held.newNp)) {
                     throw(Build:VisitError.new("newNp is null while typechecking constructor call"));
                  }
                  syn = build.getSynNp(node.held.newNp);
                  mtdc = syn.mtdMap.get(node.held.name);
               } else {
                  syn = build.getSynNp(tany.namepath);
                  mtdc = syn.mtdMap.get(node.held.name);
               }
               if (undef(mtdc)) {
                   fcms = syn.mtdMap.get("forwardCall_2");
                   if (def(fcms) && fcms.origin.toString() != "System:Object") {
                     node.held.isForward = true;
                   } else {
                  throw(Build:VisitError.new("No such call " + node.held.name + " in class " + syn.namepath.toString(), node));
                  }
               }
               if (def(mtdc)) {
               List argSyns = mtdc.argSyns;
               Node nnode = targ.nextPeer; //the call argument
               for (Int i = 1;i < argSyns.length;i++;) {
                  Build:VarSyn marg = argSyns.get(i);//the method argument (from the syn)
                  if (marg.isTyped) {
                     if (undef(nnode)) {
                        throw(Build:VisitError.new("Got a null nnode", nnode));//should be impossible
                     } elseIf (nnode.typename != ntypes.VAR && nnode.typename != ntypes.NULL) {
                        throw(Build:VisitError.new("nnode is not a any " + nnode.typename.toString(), nnode));
                     }
                     if (nnode.typename == ntypes.VAR) {
                        Build:Var carg = nnode.held;
                        if (carg.isTyped!) {
                           node.held.checkTypes = true;
                           node.held.argCasts.put(i.copy(), marg.namepath);//we need to cast this arg during the call
                           //("Putting in argcast ").print();
                        } else {
                           ClassSyn argSyn = build.getSynNp(carg.namepath);
                           if (argSyn.castsTo(marg.namepath)!) {
                              fcms = syn.mtdMap.get("forwardCall_2");
                              if (def(fcms) && fcms.origin.toString() != "System:Object") {
                                node.held.isForward = true;
                              } else {
                                throw(Build:VisitError.new("Found incompatible argument type for call, required " + argSyn.namepath.toString() + " got " + marg.namepath.toString(), nnode));
                              }
                           }
                           //at this point either marg (the method arg) is untyped 
                           //(so no cast needed) or marg is typed and either it is the same class or a superclass of carg or (if carg is
                           //untyped) we have marked carg for casting, (or carg is incompatible and we've thrown an exception)
                           //there should be a cast down case too, something that was casted up and now needs to cast down
                        }
                     }
                  }
                  nnode = nnode.nextPeer;
               }
               }
            }
         }
      }
      return(node.nextDescend);
   }
   
}
