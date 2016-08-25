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

emit(cs) {
    """
using System;
using System.Reflection;
    """
}

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
         
         System:CurrentPlatform platform = System:CurrentPlatform.new();
      }
      
      prepArgs();
  }
  
  execNameGet() {
    if (true) { return(self.fullExecName); }
    if (undef(execName)) {
        emit(cs) {
            """
            bevp_execName = new $class/Text:String$(System.Text.Encoding.UTF8.GetBytes(Environment.GetCommandLineArgs()[0]));
            //bevp_execName = new $class/Text:String$(System.Text.Encoding.UTF8.GetBytes(Assembly.GetEntryAssembly().Location));
            """
        }
    }
    return(execName);
  }
  
  execPathGet() IO:File:Path {
    return(IO:File:Path.apNew(self.execName));
  }
  
  fullExecNameGet() {
    fields {
        var fullExecName;
    }
    if (undef(fullExecName)) {
        emit(cs) {
            """
            //bevp_execName = new $class/Text:String$(System.Text.Encoding.UTF8.GetBytes(Environment.GetCommandLineArgs()[0]));
            bevp_fullExecName = new $class/Text:String$(System.Text.Encoding.UTF8.GetBytes(System.Reflection.Assembly.GetEntryAssembly().Location));
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
            for (int i = 0;i < be.BELS_Base.BECS_Runtime.args.length;i++) {
                bevp_args.bem_addValue_1(new $class/Text:String$(be.BELS_Base.BECS_Runtime.args[i].getBytes("UTF-8")));
            }
          """
          }
          emit(cs) {
          """
            for (int i = 0;i < be.BELS_Base.BECS_Runtime.args.Length;i++) {
                bevp_args.bem_addValue_1(new $class/Text:String$(System.Text.Encoding.UTF8.GetBytes(be.BELS_Base.BECS_Runtime.args[i])));
            }
          """
          }
          emit(js) {
          """
            for (var i = be_BELS_Base_BECS_Runtime.prototype.minArg;i < be_BELS_Base_BECS_Runtime.prototype.args.length;i++) {
                var bevls_arg = this.bems_stringToBytes_1(be_BELS_Base_BECS_Runtime.prototype.args[i]);
                bevls_arg = new be_BEL_4_Base_$class/Text:String$().beml_set_bevi_bytes_len_copy(bevls_arg, bevls_arg.length);
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
      var t = createInstance(_name).new();
      return(start(t));
   }

}
