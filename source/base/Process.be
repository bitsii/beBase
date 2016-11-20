// Copyright 2006 Craig Welch
//
// Licensed under the MIT license. See LICENSE.txt file in the project root 
// for full license information.

use System:Thing;
use Container:NodeList;
use IO:File;

final class System:Process {
   
    create() self { }
   
   default() self {
      
      fields {
         Container:List args;
         Math:Int numArgs;
         any execName;
   
         any target;
         any result;
         any except;
         
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
      any arg;
      if (ac.otherClass(System:Types.new().int)) {
         throw(System:IncorrectType.new(" Wanted type Math:Int not type " + ac.className));
      }
      if (av.otherClass(System:Types.new().thing)) {
         throw(System:IncorrectType.new(" Wanted type System:Thing not type " + av.className));
      }
      any thing = Thing.new(); //make inline include if possible
      args = Container:List.new(ac - 1);
      any ix = 1;
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
      } catch (any e) {
         except = e;
         e.print();
         return(1);//return non-0 for main usecases (process exit code)
      }
      return(result);
   }
   
   startByName(_name) {
      any t = createInstance(_name).new();
      return(start(t));
   }

}
