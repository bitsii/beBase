/*
 * Copyright (c) 2006-2023, the Brace Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

import System:Thing;
import Container:NodeList;
import IO:File;

final class System:Process {
   
    create() self { }
   
   default() self {
      
      fields {
         Container:List args;
         Math:Int numArgs;
         dyn execName;
   
         dyn target;
         dyn result;
         dyn except;
         
         System:CurrentPlatform platform;
      }
   
   }
   
   //platformSet(_platform) {   } //TODO was not allowed...
   
   setup(ac, av, plat) {
      emit(c) {
      """
/*-attr- -dec-*/
char** v;
void** bevl_av;
void** bevl_ix;
      """
      }
      dyn arg;
      dyn int = Int.new();
      if (System:Classes.otherClass(ac, int)) {
         throw(System:IncorrectType.new(" Wanted type Math:Int not type " + System:Classes.className(ac));
      }
      dyn thing = Thing.new();
      if (System:Classes.otherClass(av, thing)) {
         throw(System:IncorrectType.new(" Wanted type System:Thing not type " + System:Classes.className(av));
      }
      args = Container:List.new(ac - 1);
      dyn ix = 1;
      emit(c) {
      """
      bevl_av = $av&*;
      v = (char**) bevl_av[bercps];
      """
      }
      for (ix = ix--;ix < ac;ix = ix++;) {
         emit(c) {
         """
         bevl_ix = $ix&*;
         $arg=* BERF_String_For_Chars(berv_sts, v[*((BEINT*) (bevl_ix + bercps))]);
         """
         }
         if (ix == 0) {
            execName = arg;
         } else {
            args.put(ix - 1, arg);
         }
      }
      numArgs = ac - 1;
      platform = System:CurrentPlatform.new();
      platform.setName(plat);
   }
   
   start(_target) {
      target = _target;
      try {
         result = target.main();
      } catch (dyn e) {
         except = e;
         e.print();
         return(1);//return non-0 for main usecases (process exit code)
      }
      return(result);
   }
   
   startByName(_name) {
      dyn t = System:Objects.createInstance(_name).new();
      return(start(t));
   }

}
