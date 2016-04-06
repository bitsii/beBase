// Copyright 2006 Craig Welch
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

use System:Thing;
use Container:NodeList;
use IO:File;

final class System:Process {
   
    create() self { }
   
   default() self {
      
      fields {
         Container:Array args;
         Math:Int numArgs;
         var execName;
   
         var target;
         var result;
         var except;
         
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
      var arg;
      if (ac.otherClass(System:Types.new().int)) {
         throw(System:IncorrectType.new(" Wanted type Math:Int not type " + ac.className));
      }
      if (av.otherClass(System:Types.new().thing)) {
         throw(System:IncorrectType.new(" Wanted type System:Thing not type " + av.className));
      }
      var thing = Thing.new(); //make inline include if possible
      args = Container:Array.new(ac - 1);
      var ix = 1;
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
      } catch (var e) {
         except = e;
         e.print();
         return(1);//return non-0 for main usecases (process exit code)
      }
      return(result);
   }
   
   startByName(_name) {
      var t = createInstance(_name).new();
      return(start(t));
   }

}
