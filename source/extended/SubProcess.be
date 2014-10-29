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

use Container:Array;
use Text:String;
use Math:Int;
use Logic:Bool;

use System:SubProcess;

class SubProcess {
   new() self { }
   
   new(String _klass, String _execName, Array _args) SubProcess {
      properties {
         Array args = _args;
         String execName = _execName;
         String klass = _klass;
         Bool isOpen = false;
         var heldBy;
      }
   }
      
   run(Int _argc, Thing _argv, Thing _klassChar, Thing _platChar) {
emit(c) {
      """
/*-attr- -dec-*/
int i_argc;
char** cc_argv;
char* c_klasschar;
char* c_platchar;
void** v_tmp;
      """
      }
      Int argc;
      Thing argv;
      Thing klassChar;
      Thing platChar;
      
      argc = _argc;
      argv = _argv;
      klassChar = _klassChar;
      platChar = _platChar;
      
emit(c) {
"""
/* Clearing of v_tmp bercps after value assign is to assure gc in this process
does not free the memory */

v_tmp = $argc&*;
i_argc = *((BEINT*) (v_tmp + bercps));
v_tmp[bercps] = NULL;

v_tmp = $argv&*;
cc_argv = (char**) v_tmp[bercps];
v_tmp[bercps] = NULL;

v_tmp = $klassChar&*;
c_klasschar = (char*) v_tmp[bercps];
v_tmp[bercps] = NULL;

v_tmp = $platChar&*;
c_platchar = (char*) v_tmp[bercps];
v_tmp[bercps] = NULL;

/* printf("Starting process %d, %s %s %s\n", i_argc, cc_argv[0], c_klasschar, c_platchar); */
BERF_Start_Process_Free_Args(i_argc, cc_argv, c_klasschar, c_platchar);
"""
}
   }
   
   run() SubProcess {
emit(c) {
      """
/*-attr- -dec-*/
void** v_argc;
int i_argc;
char** a_argv;
char* c_arg;
char* c_klass;
char* c_plat;
int i;
void** v_args;
void** vv_args;
void** v_argo;
void** v_thing;
      """
      }
      
      Int argc;
      Thing argv;
      Thing klassChar;
      Thing platChar;
      Array _args;
      String lplat;
      String lklass;
      String lename;
      
      _args = args;
      argc = args.size + 1;
      lklass = klass;
      lplat = System:Process.platform.name;
      argv = Thing.new();
      klassChar = Thing.new();
      platChar = Thing.new();
      lename = execName;
      
      //Allocate strings, copy, for threads
emit(c) {
"""
v_argc = $argc&*;
v_args = $_args&*;
vv_args = (void**) v_args[bercps];
i_argc = *((BEINT*) (v_argc + bercps));
a_argv = (char**) BENoMalloc(i_argc * sizeof(char*));

v_argo = $lename&*;
c_arg = (char*) v_argo[bercps];
a_argv[0] = BERF_Copy_Chars(c_arg);

for (i = 1;i < i_argc;i++) {
   v_argo = (void**) vv_args[i - 1];
   c_arg = (char*) v_argo[bercps];
   a_argv[i] = BERF_Copy_Chars(c_arg);
   /* printf("arg is %s\n", a_argv[i]); */
}

v_thing = $argv&*;
v_thing[bercps] = (void*) a_argv;

v_argo = $lklass&*;
c_arg = (char*) v_argo[bercps];
c_klass = BERF_Copy_Chars(c_arg);
v_thing = $klassChar&*;
v_thing[bercps] = (void*) c_klass;
/* printf("klass is %s\n", c_klass); */

v_argo = $lplat&*;
c_arg = (char*) v_argo[bercps];
c_plat = BERF_Copy_Chars(c_arg);
v_thing = $platChar&*;
v_thing[bercps] = (void*) c_plat;
/* printf("plat is %s\n", c_plat); */
"""
}
   run(argc, argv, klassChar, platChar);
   }
   
   open() {
      isOpen = true;
      System:Process.addSubProcess(self);
   }
   
   close() {
      System:Process.deleteSubProcess(self);
      isOpen = false;
   }
     
}

