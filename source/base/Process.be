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

use System:Thing;
use Container:NodeList;
use IO:File;

final class System:Process {
   
    create() { }
   
   default() self {
      
      properties {
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
      var t = getInstance(_name).new();
      return(start(t));
   }

}
