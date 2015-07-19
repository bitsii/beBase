// Copyright 2006 Craig Welch
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

 use Text:String;
 use Logic:Bool;
 use Container:LinkedList;
 use Math:Int;
 use System:Random;
 use System:Identity;
 
use System:Command;

emit(cs) {
"""
using System;
using System.Diagnostics;
"""
}

final class Command {

   emit(cs) {
   """
   public Process bevi_p;
   """
   }
   
   emit(jv) {
   """
   public Process bevi_p;
   """
   }
   
   new(String _command) self {
      properties {
         String command = _command;
      }
   }
   
   run(String _command) Int {
      new(_command);
      return(run());
   }
   
   run() Int {
      Int res;  //get rid of res
      
      ifEmit(cs) {
        Int sp = command.find(" ");
        if (def(sp)) {
          String cmdRun = command.substring(0, sp);
          String cmdArgs = command.substring(sp + 1);
         } else {
          cmdRun = command;
          cmdArgs = "";
         }
         //("cmdRun " + cmdRun).print();
         //("cmdArgs " + cmdArgs).print();
          emit(cs) {
          """
          bevi_p = new Process();
          bevi_p.StartInfo.FileName = bevl_cmdRun.bems_toCsString();
          bevi_p.StartInfo.Arguments = bevl_cmdArgs.bems_toCsString();
          bevi_p.StartInfo.CreateNoWindow = true;
          bevi_p.StartInfo.UseShellExecute = false;
          bevi_p.StartInfo.RedirectStandardOutput = true;   
          //bevi_p.StartInfo.WorkingDirectory = strWorkingDirectory;
          bevi_p.Start();
          //bevi_p.StandardOutput.ReadToEnd();
          //bevi_p.WaitForExit();
          """
          }
      }
      
      emit(jv) {
      """
      bevi_p = Runtime.getRuntime().exec(bevp_command.bems_toJvString());
      """
      }
      return(res);
   }
   
   open() self {
     run();
   }
   
   outputGet() IO:File:Reader {
     vars {
      IO:File:Reader outputReader;
     }
     if (def(outputReader)) {
       return(outputReader);
     }
     outputReader = IO:File:Reader.new();
     emit(cs) {
     """
     bevp_outputReader.bevi_is = bevi_p.StandardOutput.BaseStream;
     """
     }
     emit(jv) {
     """
     bevp_outputReader.bevi_is = bevi_p.getInputStream();
     """
     }
     outputReader.extOpen();
     return(outputReader);
   }
   
   closeOutput() {
     if (def(outputReader)) {
       outputReader.close();
       outputReader = null;
     }
   }
   
   close() {
     closeOutput();
     emit(cs) {
     """
     bevi_p = null;
     """
     }
     emit(jv) {
     """
     bevi_p = null;
     """
     }
   }
}

use System:Host;

local class Host {

   create() { }
   
   default() self {
      
   }
   
   hostnameGet() String {
      //Not cached, could change
      String name;
      var r = IO:File:Reader:Command.new("hostname -s").open();
      String o = r.readString();
      r.close();
      var l = o.splitLines();
      name = l.first;
      //("Got name " + name).print();
      return(name);
   }
   
}
