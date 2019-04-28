// Copyright 2006 Craig Welch
//
// Licensed under the MIT license. See LICENSE.txt file in the project root 
// for full license information.

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
      fields {
         String command = _command;
      }
   }
   
   listNew(List _commands) self {
     fields {
       List commands = _commands;
     }
     command = "";
     for (String c in commands) {
      if (TS.notEmpty(command)) {
        command += " ";
      }
      command += c;
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
      
      if (def(commands)) {
        Int cl = commands.size;
        emit(jv) {
        """
        String[] cmds = new String[bevl_cl.bevi_int]; 
        """
        }
        for (Int i = 0;i < cl;i++=) {
          String cmdi = commands[i];
          emit(jv) {
          """
          cmds[bevl_i.bevi_int] = bevl_cmdi.bems_toJvString();
          """
          }
        }
        
        emit(jv) {
        """
        bevi_p = Runtime.getRuntime().exec(cmds);
        """
        }
        
      } else {
      
        emit(jv) {
        """
        bevi_p = Runtime.getRuntime().exec(bevp_command.bems_toJvString());
        """
        }
        
      }
      
      return(res);
   }
   
   open() self {
     run();
   }
   
   outputGet() IO:File:Reader {
     fields {
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
     try {
       if (def(outputReader)) {
         outputReader.close();
         outputReader = null;
       }
      } catch (any e) { }
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
   
   outputContentGet() String {
     String res;
     try {
       res = self.open().output.readString();
       self.close();
     } catch (any e) {
       try {
         self.close();
       } catch (any ee) { }
     }
     return(res);
   }
}

use System:Host;

local class Host {

   create() self { }
   
   default() self {
      
   }
   
   hostnameGet() String {
      //Not cached, could change
      String name;
      any r = IO:File:Reader:Command.new("hostname -s").open();
      String o = r.readString();
      r.close();
      any l = o.splitLines();
      name = l.first;
      //("Got name " + name).print();
      return(name);
   }
   
}
