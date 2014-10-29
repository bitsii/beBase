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

use Container:LinkedList;
use Container:Map;
use Container:Array;
use Text:String;
use Math:Int;
use Logic:Bool;
use Build:Visit;
use Build:NamePath;
use Build:VisitError;
use Build:Node;
use Build:ClassSyn;

final class Visit:Pass12(Visit:Visitor) {

   new() self {
      properties {
         NamePath classnp;
      }
   }
   
   getAccessor(node) {
      var myselfn = Node.new(build);
      myselfn.typename = ntypes.VAR;
      var myself = Build:Var.new();
      myself.name = "self";
      myself.isTyped = true;
      myself.namepath = classnp;
      myself.isArg = true;
      myselfn.held = myself;
      var mtdmyn = Node.new(build);
      mtdmyn.typename = ntypes.METHOD;
      var mtdmy = Build:Method.new();
      mtdmy.isGenAccessor = true;
      mtdmyn.held = mtdmy;
      var myparn = Node.new(build);
      myparn.typename = ntypes.PARENS;
      myparn.addValue(myselfn);
      mtdmyn.addValue(myparn);
      myselfn.addVariable();
      var mybr = Node.new(build);
      mybr.typename = ntypes.BRACES;
      mtdmyn.addValue(mybr);
      return(mtdmyn);
   }
      
   getRetNode(node) {
      var retnoden = Node.new(build);
      retnoden.typename = ntypes.CALL;
      var retnode = Build:Call.new();
      retnode.name = "return";
      retnoden.held = retnode;
      var sn = Node.new(build);
      sn.typename = ntypes.VAR;
      sn.held = "self";
      retnoden.addValue(sn);
      return(retnoden);
   }
      
   getAsNode(selfnode) {
      var asnoden = Node.new(build);
      asnoden.typename = ntypes.CALL;
      var asnode = Build:Call.new();
      asnode.name = "assign";
      asnoden.held = asnode;
      return(asnoden);
   }
   
   
   accept(Node node) Node {
      //if ((node.typename == ntypes.VAR) && (def(node.held.namepath))) {
      //   ("Found namepath typed var again " + node.held.name + " " + node.held.namepath.toString()).print();
      //}
      if (node.typename == ntypes.METHOD) {
         var ia = node.contained.first.contained.first; //self
         ia.held.isTyped = true;
         ia.held.namepath = classnp;
      } elif (node.typename == ntypes.CLASS) {
         classnp = node.held.namepath;
         var tst = Build:Call.new();
         for (var ii = node.held.orderedVars.iterator;ii.hasNext;;) {
            var i = ii.next.held;
            tst.name = i.name.copy();
            tst.accessorType = "GET";
            tst.toAccessorName();
            var ename = tst.name;
            tst.name = tst.name + "_0";
            if (i.isDeclared && (node.held.methods.has(tst.name)!)) {
            
               var anode = getAccessor(node);
               anode.held.property = i;
               anode.held.orgName = ename;
               anode.held.name = tst.name;
               anode.held.numargs = 0;
               node.held.methods.put(anode.held.name, anode);
               node.held.orderedMethods.addValue(anode);
               node.contained.last.addValue(anode);
               var rettnode = getRetNode(node);
               var rin = Node.new(build);
               rin.copyLoc(node);
               rin.typename = ntypes.VAR;
               rin.held = i.name.copy();
               rettnode.addValue(rin);
               anode.contained.last.addValue(rettnode);
               rettnode.contained.first.syncVariable(self);
               rin.syncVariable(self);
               if (i.isTyped) {
                  anode.held.rtype = i;
               }
            
            }
            
            tst.name = i.name.copy();
            tst.accessorType = "SET";
            tst.toAccessorName();
            ename = tst.name;
            tst.name = tst.name + "_1";
            if (i.isDeclared && (node.held.methods.has(tst.name)!)) {
            
               anode = getAccessor(node);
               anode.held.property = i;
               anode.held.orgName = ename;
               anode.held.name = tst.name;
               anode.held.numargs = 1;
               node.held.methods.put(anode.held.name, anode);
               node.held.orderedMethods.addValue(anode);
               node.contained.last.addValue(anode);
               
               var sv = anode.tmpVar("SET", build);
               sv.isArg = true;
               var svn = Node.new(build);
               svn.copyLoc(node);
               svn.typename = ntypes.VAR;
               svn.held = sv;
               
               anode.contained.first.addValue(svn);
               var svn2 = Node.new();
               svn2.copyLoc(node);
               svn2.typename = ntypes.VAR;
               svn2.held = sv;
               
               var asn = self.getAsNode(node);
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
         }
      } elif (node.typename == ntypes.CALL) {
         if (undef(node.held)) {
            throw(Build:VisitError.new("Call held is null", node));
         }
         if (node.held.isConstruct && undef(node.held.newNp)) {
            var newNp = node.contained.first;
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
            newNp.delete();
         }
         node.held.numargs = node.contained.length - 1;
         node.held.orgName = node.held.name;
         node.held.name = node.held.name + "_" + node.held.numargs.toString();
         if (node.held.orgName == "assign") {
            var c0 = node.contained.first;
            if ((def(c0)) && (c0.typename == ntypes.VAR)) {
               c0.held.numAssigns = c0.held.numAssigns++;
            }
            var c1 = node.contained.second;
            if (def(c1) && c1.typename == ntypes.CALL) {
               //if (c1.held.isLiteral) {
               //   node.held.isOnce = true;  //no longer always, since now mutable - node.isLiteralOnce used instead
               //}
               //for explicit ""@ and ""#
               if (c1.held.name == "once_0") {
                  node.held.isOnce = true;
               }
               if (c1.held.name == "many_0") {
                  node.held.isMany = true;
               }
            }
         }
      } elif (node.typename == ntypes.BRACES) {
         var bn = Node.new(build);
         if (def(node.contained) && def(node.contained.last)) {
            bn.nlc = node.contained.last.nlc;
         } else {
            bn.copyLoc(node);
         }
         bn.typename = ntypes.RBRACES;
         node.addValue(bn);
      } elif (node.typename == ntypes.PARENS) {
         var pn = Node.new(build);
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

final class Visit:Rewind(Visit:Visitor) {

   new() self {
      properties {
         var tvmap;
         var rmap;
         var inClass;
         var inClassNp;
         var inClassSyn;
         var nl;
         var emitter;
      }
   }
   
   accept(Node node) Node {
      if (node.typename == ntypes.CLASS) {
         inClass = node;
         inClassNp = node.held.namepath;
         inClassSyn = node.held.syn;
      }
      if (node.typename == ntypes.METHOD) {
         tvmap = Map.new();
         rmap = Map.new();
      } elif ((node.typename == ntypes.VAR) && node.held.isTmpVar) {
         tvmap.put(node.held.name, node.held);
         var ll = rmap.get(node.held.name);
         if (undef(ll)) {
            ll = Container:LinkedList.new();
            rmap.put(node.held.name, ll)
         }
         ll.addValue(node);
      } elif (node.typename == ntypes.RBRACES && def(node.container) && def(node.container.container) && node.container.container.typename == ntypes.METHOD) {
         //("!!! PROCESSING TMPS").print();
         processTmps();
      }
      return(node.nextDescend);
   }
   
   processTmps() {
      var foundone = true;
      var targ;
      var tvar;
      var tcall;
      ClassSyn syn;
      var targNp;
      var mtdc;
      var ovar;
      while (foundone) {
         foundone = false;
         for (var i = tvmap.valueIterator;i.hasNext;) {
            var nv = i.next;
            //("!!!Toplevel checking isTyped " + nv.name).print();
            if (nv.isTyped!) {
               //("!!!notTyped " + nv.name).print();
               //if it is typed it has already been found
               var nvname = nv.name;
               var ll = rmap.get(nvname);
               foreach (var k in ll) {
                  if (k.isFirst && k.container.typename == ntypes.CALL && k.container.held.orgName == "assign" && k.container.second.typename == ntypes.CALL) {
                     //("!!!Found to be first arg to assign").print();
                     tcall = k.container.second;
                     targNp = null;
                     if (def(tcall.held.newNp)) {
                        targNp = tcall.held.newNp;
                     } else {
                        targ = tcall.contained.first;
                        //targ.print();
                        //("Considering call " + tcall.held.name).print();
                        //targ.held.className.print();
                        if (targ.held.isDeclared) {
                           tvar = targ.held;
                        } else {
                           tvar = inClassSyn.ptyMap.get(targ.held.name).memSyn; //all non-declared mmbers caught
                           //in syn generation
                        }
                        if (tvar.isTyped) {
                           targNp = tvar.namepath;
                        }
                     }
                     if (def(targNp)) {
                        //("targNp not null " + targNp.toString()).print();
                        syn = build.getSynNp(targNp);
                        mtdc = syn.mtdMap.get(tcall.held.name);
                        if (def(mtdc)) {
                           //"Found ovar".print();
                           ovar = mtdc.rsyn;
                           if (def(ovar) && ovar.isTyped) {
                              foundone = true;
                              if (ovar.isSelf) {
                                 nv.namepath = targNp;
                              } else {
                                 nv.namepath = ovar.namepath;
                              }
                              nv.isTyped = ovar.isTyped;
                              inClass.held.addUsed(nv.namepath);
                              if (nv.namepath.toString() == "self") { ("FOUND A SELF TMPVAR rewind " + ovar.isSelf).print(); }
                           }
                        } elif (tcall.held.orgName != "return") {
                           throw(Build:VisitError.new("No such call " + tcall.held.name + " in class " + targNp.toString(), tcall));
                        }
                     } /* else {
                        //"Targ np null".print();
                     } */
                  } elif (k.isFirst && k.container.typename == ntypes.CALL && k.container.held.orgName == "assign" && k.container.second.typename == ntypes.VAR) {
                     targ = k.container.second.held;
                     //("Considering var " + targ.name).print();
                     if (targ.isTyped) {
                        //("FOUND REWINDABLE TMPVAR TYPE OPPORTUNITY VAR !!!").print();
                        foundone = true;
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

final class Visit:TypeCheck(Visit:Visitor) {
   
   new() self {
      properties {
         var emitter;   
         Node inClass;
         var inClassNp;
         var inClassSyn;
         Int cpos;
      }
   }
   
   accept(Node node) Node {
      if (node.typename == ntypes.CATCH) {
        if (node.contained.first.contained.first.held.isTyped) {
            throw(Build:VisitError.new("Catch variables must be declared untyped (var)"));
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
         node.held.cpos = cpos;
         cpos = cpos++;
         foreach (Node cci in node.contained) {
            if (cci.typename == ntypes.VAR) {
               cci.held.addCall(node);
            }
         }
         Node targ;
         var tvar;
         var ovar;
         ClassSyn syn;
         var mtdmy;
         Node ctarg;
         var cvar;
         var mtdc;
         if (node.held.orgName == "assign") {
            targ = node.contained.first;
            //("About to check " + targ.toString() + " " + targ.held.className.toString()).print();
            if (targ.held.isDeclared) {
               tvar = targ.held; //tvar is the variable being assigned to
            } else {
               tvar = inClassSyn.ptyMap.get(targ.held.name).memSyn; //all non-declared mmbers caught
               //in syn generation
            }
            if (tvar.isTyped!) {
               node.held.checkTypes = false;
            } else {
               Node org = node.second;
               if (org.typename == ntypes.TRUE || org.typename == ntypes.FALSE) {
                  //"SHORTCUT TRUE OR FALSE".print();
                  node.held.checkTypes = false;
               } else {
                  if (org.typename == ntypes.VAR) {
                     if (org.held.isDeclared) {
                        ovar = org.held;
                     } else { //TODO fix use of reserved word here
                        //targ.held.name.print();
                        ovar = inClassSyn.ptyMap.get(org.held.name).memSyn; //all non-declared mmbers caught
                        //in syn generation
                     }
                  } elif (org.typename == ntypes.CALL) {
                     ctarg = org.contained.first;//assigning to this node
                     //cvar is the var being assigned to
                     if (ctarg.held.isDeclared) {
                        //"2".print();
                        cvar = ctarg.held;
                     } else {
                        //"3".print();
                        cvar = inClassSyn.ptyMap.get(ctarg.held.name).memSyn; //all non-declared mmbers caught
                        //in syn generation
                     }
                     syn = null; //the syn where the call lives (target class for call)
                     if (def(org.held.newNp)) {
                        syn = build.getSynNp(org.held.newNp);
                     } elif (cvar.isTyped){
                        //something needs to be done for isSelf
                        syn = build.getSynNp(cvar.namepath);
                     }
                     if (def(syn)) {
                        mtdc = syn.mtdMap.get(org.held.name);
                        if (undef(mtdc)) {
                           throw(Build:VisitError.new("No such call", org));
                        } else {
                           ovar = mtdc.rsyn;
                        }
                     }
                  }
                  if (def(ovar) && (ovar.isTyped)) {
                     //here is where return type checking covariant / getEmitReturnType needs to happen
                     Bool castForSelf = false;
                     if (ovar.isSelf) {
                        //syn is call target class from above, nulled before set
                        if (undef(syn)) {
                           throw(Build:VisitError.new("Self ovar without syn target"));
                        }
                        //ovar type is what matters
                        //declaration is the first place ever defined, origin is where this method was last overridden
                        //correct thing should be to compare origin to destination of assign
                        if (mtdc.origin != tvar.namepath) { //TODO just test for tvar being BELOW mtdc.origin in hierarchy
                            //we will need to cast despite compatibility TODO FASTER this could be a fast-cast...
                            castForSelf = true;
                        } elif (def(build.emitCommon) && build.emitCommon.covariantReturns!) {
                            castForSelf = true;
                        }
                     } elif (def(mtdc)) {
                        syn = build.getSynNp(mtdc.getEmitReturnType(syn, build));
                     } else {
                        syn = build.getSynNp(ovar.namepath);//before switch to the above
                     }
                     //now syn is the syn of the return type of the call
                     //("Checking for targ " + tvar.namepath.toString() + " ovar " + ovar.namepath.toString()).print();
                     if (syn.castsTo(tvar.namepath)) {
                        //("!!!!Found compatible NOCHECK type assign").print();
                        node.held.checkTypes = false;
                     } else {
                        if (ovar.isSelf) {
                           var ovnp = syn.namepath;
                        } else {
                           ovnp = ovar.namepath;
                        }
                        syn = build.getSynNp(tvar.namepath);
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
                     }
                  }
                  if (def(targ.held.namepath)) {
                     //("!!!Target name " + targ.held.name + " namepath " + targ.held.namepath.toString()).print();
                  }
               }
            }
         } elif (node.held.orgName == "return") {
            targ = node.second;
            if (targ.typename == ntypes.VAR) {
               if (targ.held.isDeclared) {
                  tvar = targ.held;
               } else {
                  tvar = inClassSyn.ptyMap.get(targ.held.name).memSyn; //all non-declared mmbers caught
                  //in syn generation
               }
               mtdmy = node.scope;
               if (targ.held.isDeclared) {
                  tvar = targ.held;
               } else {
                  tvar = inClassSyn.ptyMap.get(targ.held.name).memSyn; //all non-declared mmbers caught
                  //in syn generation
               }
               if (def(mtdmy.held.rtype) && mtdmy.held.rtype.isTyped) {
                  if (tvar.isTyped!) {
                     //("Found typed return untyped target").print();
                     node.held.checkTypes = true;
                  } else {
                     // self type ret in here...
                     // check for impossible types
                     if (mtdmy.held.rtype.isSelf) {
                        if (tvar.name == "self") {
                           //("Found self return for self rtype, NOCHECK " + node.toString() + " " + tvar.isSelf).print();
                           node.held.checkTypes = false;
                        } else {
                           var targsyn = build.getSynNp(tvar.namepath);
                           if (inClassSyn.castsTo(tvar.namepath) || targsyn.castsTo(inClassSyn.namepath)) {
                              //("Found non-self return for self rtype, CHECK " + node.toString();).print();
                              node.held.checkTypes = true;
                           } else {
                              throw(Build:VisitError.new("Incorrect type on return, returned type not castable to self type. " + inClassSyn.namepath + " " + tvar.namepath, node));
                           }
                        }
                     } else {
                        syn = build.getSynNp(tvar.namepath);
                        if (syn.castsTo(mtdmy.held.rtype.namepath)) {
                           //("!!!Found compatible NOCHECK typed return").print();
                           node.held.checkTypes = false;
                        } else {
                           syn = build.getSynNp(mtdmy.held.rtype.namepath);
                           if (syn.castsTo(tvar.namepath)) {
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
            //("About to check " + targ.toString() + " " + targ.held.className.toString()).print();
            if (targ.held.isDeclared) {
               tvar = targ.held;
            } else {
               tvar = inClassSyn.ptyMap.get(targ.held.name).memSyn; //all non-declared mmbers caught
               //in syn generation
            }
            if (tvar.isTyped! || node.held.orgName == "throw") {
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
                  syn = build.getSynNp(tvar.namepath);
                  mtdc = syn.mtdMap.get(node.held.name);
               }
               if (undef(mtdc)) {
                  throw(Build:VisitError.new("No such call", node));
               }
               Array argSyns = mtdc.argSyns;
               Node nnode = targ.nextPeer; //the call argument
               for (Int i = 1;i < argSyns.length;i = i++;) {
                  Build:VarSyn marg = argSyns.get(i);//the method argument (from the syn)
                  if (marg.isTyped) {
                     if (undef(nnode)) {
                        throw(Build:VisitError.new("Got a null nnode", nnode));//should be impossible
                     } elif (nnode.typename != ntypes.VAR && nnode.typename != ntypes.NULL) {
                        throw(Build:VisitError.new("nnode is not a var " + nnode.typename.toString(), nnode));
                     }
                     if (nnode.typename == ntypes.VAR) {
                        Build:Var carg = nnode.held;
                        if (carg.isTyped!) {
                           node.held.checkTypes = true;
                           node.held.argCasts.put(i, marg.namepath);//we need to cast this arg during the call
                           //("Putting in argcast ").print();
                        } else {
                           syn = build.getSynNp(carg.namepath);
                           if (syn.castsTo(marg.namepath)!) {
                              throw(Build:VisitError.new("Found incompatible argument type for call, required " + syn.namepath.toString() + " got " + marg.namepath.toString(), nnode));
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
      return(node.nextDescend);
   }
   
}
