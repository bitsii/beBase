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
         Container:List args;
         Math:Int numArgs;
         dyn execName;
   
         dyn target;
         dyn result;
         dyn except;
         
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
        dyn fullExecName;
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
      
      ifEmit(jv,cs,js,cc) {
        if (undef(args)) {
          args = Container:List.new();
          emit(jv) {
          """
            for (int i = 0;i < be.BECS_Runtime.args.length;i++) {
                bevp_args.bem_addValue_1(new $class/Text:String$(be.BECS_Runtime.args[i].getBytes("UTF-8")));
            }
          """
          }
          emit(cs) {
          """
            for (int i = 0;i < be.BECS_Runtime.args.Length;i++) {
                bevp_args.bem_addValue_1(new $class/Text:String$(System.Text.Encoding.UTF8.GetBytes(be.BECS_Runtime.args[i])));
            }
          """
          }
          emit(cc) {
          """
            for (int i = 1;i < BECS_Runtime::argc;i++) {
                bevp_args->bem_addValue_1(new BEC_2_4_6_TextString(std::string(BECS_Runtime::argv[i])));
            }
          """
          }
          emit(js) {
          """
            if (typeof(be_BECS_Runtime.prototype.args) !== 'undefined') {
            for (var i = be_BECS_Runtime.prototype.minArg;i < be_BECS_Runtime.prototype.args.length;i++) {
                var bevls_arg = this.bems_stringToBytes_1(be_BECS_Runtime.prototype.args[i]);
                bevls_arg = new be_$class/Text:String$().beml_set_bevi_bytes_len_copy(bevls_arg, bevls_arg.length);
                this.bevp_args.bem_addValue_1(bevls_arg);
            }
            }
          """
          }
          numArgs = args.length;//do we even need numargs?
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
     emit(cc) {
     """
     exit(beq->beva_code->bevi_int);
     """
     }
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
