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

emit(cs) {
    """
using System;
using System.Reflection;
    """
}

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
         
         System:CurrentPlatform platform = System:CurrentPlatform.new();
      }
      
      prepArgs();
  }
  
  execNameGet() {
    if (true) { return(self.fullExecName); }
    if (undef(execName)) {
        emit(cs) {
            """
            bevp_execName = new BEC_4_6_TextString(System.Text.Encoding.UTF8.GetBytes(Environment.GetCommandLineArgs()[0]));
            //bevp_execName = new BEC_4_6_TextString(System.Text.Encoding.UTF8.GetBytes(Assembly.GetEntryAssembly().Location));
            """
        }
    }
    return(execName);
  }
  
  execPathGet() IO:File:Path {
    return(IO:File:Path.apNew(self.execName));
  }
  
  fullExecNameGet() {
    vars {
        var fullExecName;
    }
    if (undef(fullExecName)) {
        emit(cs) {
            """
            //bevp_execName = new BEC_4_6_TextString(System.Text.Encoding.UTF8.GetBytes(Environment.GetCommandLineArgs()[0]));
            bevp_fullExecName = new BEC_4_6_TextString(System.Text.Encoding.UTF8.GetBytes(System.Reflection.Assembly.GetEntryAssembly().Location));
            """
        }
    }
    return(fullExecName);
  }
  
  prepArgs() self {
      
      ifEmit(jv,cs,js) {
        if (undef(args)) {
          args = Container:Array.new();
          emit(jv) {
          """
            for (int i = 0;i < abe.BELS_Base.BECS_Runtime.args.length;i++) {
                bevp_args.bem_addValue_1(new BEC_4_6_TextString(abe.BELS_Base.BECS_Runtime.args[i].getBytes("UTF-8")));
            }
          """
          }
          emit(cs) {
          """
            for (int i = 0;i < abe.BELS_Base.BECS_Runtime.args.Length;i++) {
                bevp_args.bem_addValue_1(new BEC_4_6_TextString(System.Text.Encoding.UTF8.GetBytes(abe.BELS_Base.BECS_Runtime.args[i])));
            }
          """
          }
          emit(js) {
          """
            for (var i = abe_BELS_Base_BECS_Runtime.prototype.minArg;i < abe_BELS_Base_BECS_Runtime.prototype.args.length;i++) {
                var bevls_arg = this.bems_stringToBytes_1(abe_BELS_Base_BECS_Runtime.prototype.args[i]);
                bevls_arg = new abe_BEL_4_Base_BEC_4_6_TextString().beml_set_bevi_bytes_len_copy(bevls_arg, bevls_arg.length);
                this.bevp_args.bem_addValue_1(bevls_arg);
            }
          """
          }
          numArgs = args.size;//do we even need numargs?
        }
      }
   
   }
   
   exit() {
     exit(0);
   }
   
   exit(Math:Int code) {
     emit(jv) {
     """
     System.exit(beva_code.bevi_int);
     """
     }
     emit(cs) {
     """
     Environment.Exit(beva_code.bevi_int);
     """
     }
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
