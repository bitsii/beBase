// Copyright 2006 Craig Welch
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

use IO:File;
use Text:String;
use Logic:Bool;
use Math:Int;
use Container:Set;
use Container:Stack;

emit(c) {
"""
#include <windows.h>
#include <utime.h>
"""
}

emit(cs) {
    """
using System;
using System.IO;
using System.Collections.Generic;
    """
}

emit(js) {
"""
var fs = require('fs');
"""
}

local class File {

   new() self {
      
      properties {
         IO:File:Path path;
         var reader;
         var writer;
      }
      
   }
   
   new(fpath) self {
      self.path = IO:File:Path.new(fpath);
   }
   
   apNew(fpath) self {
      self.path = IO:File:Path.apNew(fpath);
   }
   
   pathNew(IO:File:Path _path) self {
      self.path = _path;
   }
   
   readerGet() {
      if (undef(reader)) {
         reader = IO:File:Reader.new(path.toString());
      }
      return(reader);
   }
   
   writerGet() {
      if (undef(writer)) {
         writer = IO:File:Writer.new(path.toString());
      }
      return(writer);
   }
   
   delete() {
      emit(c) {
      """
/*-attr- -dec-*/
void** bevl_llpath;
      """
      }
      ifEmit(c) {
        llpath = String.new(); //to prime String
        var llpath = path.toString();
      }
      if (self.exists) {
         emit(c) {
         """
         bevl_llpath = $llpath&*;
         DeleteFile(((char*) bevl_llpath[bercps]));
         """
         }
         emit(jv) {
         """
         java.io.File bevls_f = new java.io.File(new String(bevp_path.bevp_path.bevi_bytes, 0, bevp_path.bevp_path.bevp_size.bevi_int, "UTF-8"));
         bevls_f.delete();
         """
         }
         emit(cs) {
          """
          string bevls_path = System.Text.Encoding.UTF8.GetString(bevp_path.bevp_path.bevi_bytes, 0, bevp_path.bevp_path.bevp_size.bevi_int);
          File.Delete(bevls_path);
          """
          }
      }
   }
   
   copyFile(other) Bool {
      emit(c) {
      """
/*-attr- -dec-*/
char* bevl_frc;
char* bevl_toc;
void** bevl_frv;
void** bevl_tov;
      """
      }
      //TODO make sure works across file systems and network
      String frs = path.toString();
      String tos = other.path.toString();
      Bool r = false;
      Bool t = true;
      other.path.parent.file.makeDirs();
      emit(c) {
      """
      bevl_frv = $frs&*;
      bevl_tov = $tos&*;
      bevl_frc = (char*) bevl_frv[bercps];
      bevl_toc = (char*) bevl_tov[bercps];
      if (CopyFile(bevl_frc, bevl_toc, 0)) {
         $r=* $t*;
      }
      """
      }
      return(r);
   }
   
   //because I'm constantly forgetting which it is
   mkdirs() {
     makeDirs();
   }
   mkdir() {
     makeDirs();
   }
   
   makeDirs() {
      emit(c) {
      """
/*-attr- -dec-*/
char* bevl_frc;
void** bevl_frv;
      """
      }
      String frs = path.toString();
      Bool r = false;
      Bool t = true;
      var strn = Text:Strings.new();
      if ((path.toString() != strn.empty) && (self.exists!)) {
         var parentpath = path.parent;
         if (path == parentpath) {
            //We're at the top and it doesn't exist
            return(self);
         }
         parentpath.file.makeDirs();
         emit(c) {
         """
         bevl_frv = $frs&*;
         bevl_frc = (char*) bevl_frv[bercps];
         if (CreateDirectory(bevl_frc, NULL)) {
            $t=* $strn*;
         }
         """
         }
         emit(jv) {
         """
         java.io.File bevls_f = new java.io.File(new String(bevp_path.bevp_path.bevi_bytes, 0, bevp_path.bevp_path.bevp_size.bevi_int, "UTF-8"));
         bevls_f.mkdir();
         """
         }
         emit(cs) {
         """
         Directory.CreateDirectory(
         System.Text.Encoding.UTF8.GetString(bevp_path.bevp_path.bevi_bytes, 0, bevp_path.bevp_path.bevp_size.bevi_int)
         );
         """
         }
         emit(js) {
         """
         var bevls_path = this.bems_stringToJsString_1(this.bevp_path.bevp_path);
         if (!fs.existsSync(bevls_path)) {
            fs.mkdirSync(bevls_path);
         }
         """
         }
         
      }
   }
   
   isDirectoryGet() Bool {
      return(isDirGet());
   }
   
   isDirGet() Bool {
   emit(c) {
      """
/*-attr- -dec-*/
struct stat sa;
void** bevl_spa;
      """
      }
      var spa;
      Bool result = false;
      spa = path.toString();
      if (self.exists) {
         emit(c) {
         """
         bevl_spa = $spa&*;
         if (stat(((char*) bevl_spa[bercps]), &sa) == 0 && sa.st_mode & S_IFDIR) {
            $result=* berv_sts->bool_True;
         }
         """
         }
         emit(jv) {
          """
          java.io.File bevls_f = new java.io.File(new String(bevp_path.bevp_path.bevi_bytes, 0, bevp_path.bevp_path.bevp_size.bevi_int, "UTF-8"));
          if (bevls_f.isDirectory()) {
            bevl_result = be.BELS_Base.BECS_Runtime.boolTrue;
          }
          """
          }
          emit(cs) {
          """
          string bevls_path = System.Text.Encoding.UTF8.GetString(bevp_path.bevp_path.bevi_bytes, 0, bevp_path.bevp_path.bevp_size.bevi_int);
          if (Directory.Exists(bevls_path)) {
            bevl_result = be.BELS_Base.BECS_Runtime.boolTrue;
          }
          """
          }
         emit(js) {
         """
         var bevls_path = this.bems_stringToJsString_1(this.bevp_path.bevp_path);
         if (fs.lstatSync(bevls_path).isDirectory()) {
            bevl_result = be_BELS_Base_BECS_Runtime.prototype.boolTrue;
          }
         """
         }
      }
      return(result);
   }
   
   isFileGet() Bool {
   emit(c) {
      """
/*-attr- -dec-*/
struct stat sa;
void** bevl_spa;
      """
      }
      var spa;
      Bool result = false;
      spa = path.toString();
      if (self.exists) {
         emit(c) {
         """
         bevl_spa = $spa&*;
         if (stat(((char*) bevl_spa[bercps]), &sa) == 0 && sa.st_mode & S_IFREG) {
            $result=* berv_sts->bool_True;
         }
         """
         }
         emit(jv) {
          """
          java.io.File bevls_f = new java.io.File(new String(bevp_path.bevp_path.bevi_bytes, 0, bevp_path.bevp_path.bevp_size.bevi_int, "UTF-8"));
          if (bevls_f.isFile()) {
            bevl_result = be.BELS_Base.BECS_Runtime.boolTrue;
          }
          """
          }
          emit(cs) {
          """
          string bevls_path = System.Text.Encoding.UTF8.GetString(bevp_path.bevp_path.bevi_bytes, 0, bevp_path.bevp_path.bevp_size.bevi_int);
          if (File.Exists(bevls_path)) {
            bevl_result = be.BELS_Base.BECS_Runtime.boolTrue;
          }
          """
          }
         emit(js) {
         """
         var bevls_path = this.bems_stringToJsString_1(this.bevp_path.bevp_path);
         if (fs.lstatSync(bevls_path).isFile()) {
            bevl_result = be_BELS_Base_BECS_Runtime.prototype.boolTrue;
          }
         """
         }
      }
      return(result);
   }
   
   makeFile() {
      self.writer.open();
      self.writer.close();
   }
   
   contentsGet() String {
      if (self.exists!) {
        return(null);
      }
      return(self.contentsNoCheck);
   }
   
   contentsNoCheckGet() String {
      var r = self.reader;
      r.open();
      String res = r.readString();
      r.close();
      return(res);
   }
   
   contentsSet(String contents) self {
      if (self.path.parent.file.exists!) {
         self.path.parent.file.makeDirs();
      }
      self.contentsNoCheck = contents;
   }
   
   contentsNoCheckSet(String contents) self {
      var w = self.writer;
      w.open();
      w.write(contents);
      w.close();
   }
   
   sizeGet() Int {
   emit(c) {
      """
/*-attr- -dec-*/
struct stat sa;
void** bevl_spa;
BEINT* bevl_sz;
      """
      }
      var spa;
      Int _size = Int.new();
      spa = path.toString();
      if (self.exists) {
         emit(c) {
         """
         bevl_spa = $spa&*;
         bevl_sz = (BEINT*) ($_size&* + bercps);
         stat(((char*) bevl_spa[bercps]), &sa);
         *bevl_sz = sa.st_size;
         """
         }
      }
      return(_size);
   }
   
   existsGet() Bool {
      emit(c) {
      """
/*-attr- -dec-*/
int i;
void** bevl_mpath;
      """
      }
      Bool tvala = false;
      var mpath = path.toString();
      emit(c) {
      """
      bevl_mpath = $mpath&*;
      i = access(((char*) bevl_mpath[bercps]), F_OK);
      if (i == 0) {
         $tvala=* berv_sts->bool_True;
      }
      """
      }
      emit(jv) {
      """
      java.io.File bevls_f = new java.io.File(new String(bevp_path.bevp_path.bevi_bytes, 0, bevp_path.bevp_path.bevp_size.bevi_int, "UTF-8"));
      if (bevls_f.exists()) {
        bevl_tvala = be.BELS_Base.BECS_Runtime.boolTrue;
      }
      """
      }
      emit(cs) {
      """
      string bevls_path = System.Text.Encoding.UTF8.GetString(bevp_path.bevp_path.bevi_bytes, 0, bevp_path.bevp_path.bevp_size.bevi_int);
      if (File.Exists(bevls_path) || Directory.Exists(bevls_path)) {
        bevl_tvala = be.BELS_Base.BECS_Runtime.boolTrue;
      }
      """
      }
     emit(js) {
     """
     var bevls_path = this.bems_stringToJsString_1(this.bevp_path.bevp_path);
     if (fs.existsSync(bevls_path)) {
        bevl_tvala = be_BELS_Base_BECS_Runtime.prototype.boolTrue;
     }
     """
     }
      return(tvala);
   }
   
   absPathGet() IO:File:Path {
      //jv toRealPath, cs (new Uri(absolute_path)).LocalPath or Path.GetFullPath(absolute_path)
      //cs except on not exists to keep behavior
      IO:File:Path absp;
      String abstr;
      ifNotEmit(platDroid) {
        emit(jv) {
        """
        java.io.File bevls_f = new java.io.File(new String(bevp_path.bevp_path.bevi_bytes, 0, bevp_path.bevp_path.bevp_size.bevi_int, "UTF-8"));
        //bevl_abstr = new BEC_4_6_TextString(bevls_f.toPath().toRealPath().toString());
        bevl_abstr = new BEC_4_6_TextString(bevls_f.getCanonicalPath());
        """
        }
      }
      absp = IO:File:Path.apNew(abstr);
      return(absp);
   }
   
   close() {
      if (def(reader)) {
         reader.close();
      }
      if (def(writer)) {
         writer.close();
      }
   }
   
   iteratorGet() {
      return(IO:File:DirectoryIterator.new(self));
   }
   
}

use final class System:Environment {

    getVariable(String name) String {
        String value;
        emit(cs) {
        """
            string value = Environment.GetEnvironmentVariable(beva_name.bems_toCsString());
            if (value != null) {
                bevl_value = new BEC_4_6_TextString(System.Text.Encoding.UTF8.GetBytes(value));
            }
        """
        }
        emit(jv) {
        """
            String value = System.getenv().get(beva_name.bems_toJvString());
            if (value != null) {
                bevl_value = new BEC_4_6_TextString(value);
            }
        """
        }
        return(value);
    }

}

use IO:File:DirectoryIterator;

final class DirectoryIterator {

   emit(cs) {
   """
   
    public IEnumerator<string> bevi_dir;
    
   """
   }
   
   emit(jv) {
   """
   java.io.File[] bevi_dir;
   int bevi_pos = 0;
   """
   }
   
   new() self {
   
      properties {
         File dir;
         Bool opened = false;
         Bool closed = false;
         File current = null;
      }
      
   }
   
   new(File _dir) self {
      new();
      dir = _dir;
   }
   
   open() self {
      
      String path;
      String newName;
      
      if (def(dir)) {
         path = dir.path.toString();
         //path.print();
      } else {
         throw(System:Exception.new("Directory not defined during open"));
      }
      
      if (closed) {
         //all used up, currently, not reusable
         throw(System:Exception.new("Attempting to re-open a closed IO:File:Iterator is not supported"));
      }
      if (opened) {
         throw(System:Exception.new("Only open IO:File:Iterator once"));
      }
      emit(cs) {
      """
      bevi_dir = Directory.EnumerateFileSystemEntries(bevl_path.bems_toCsString(), "*", SearchOption.TopDirectoryOnly).GetEnumerator();
      if (bevi_dir.MoveNext()) {
        bevl_newName = new BEC_4_6_TextString(bevi_dir.Current);
      }
      """
      }
      emit(jv) {
      """
      java.io.File bevls_f = new java.io.File(bevl_path.bems_toJvString());
      bevi_dir = bevls_f.listFiles();
      bevi_pos = 0;
      if (bevi_dir != null && bevi_dir.length > bevi_pos) {
        bevl_newName = new BEC_4_6_TextString(bevi_dir[bevi_pos].getPath());
        bevi_pos++;
      }
      """
      }
      if (def(newName)) {
         //("open succeeded " + dir.path + " " + newName).print();
         opened = true;
         current = File.apNew(newName);
      } else {
         //("open failed " + dir.path).print();
         opened = false;
         closed = true;
      }
   }
   
   hasNextGet() Bool {
      if (closed) { return(false); }
      if (opened!) { open(); }
      return(def(current));
   }
   
   nextGet() File {
      if (closed) { return(null); }
      if (opened!) { open(); }
      File toRet = current;
      advance();
      return(toRet);
   }
   
   advance() self {
   
      String newName;
      
      if (closed) { return(self); }
      if (opened!) { return(self); }
      if (undef(current)) { return(self); }
      emit(cs) {
      """
      if (bevi_dir.MoveNext()) {
        bevl_newName = new BEC_4_6_TextString(bevi_dir.Current);
      }
      """
      }
      emit(jv) {
      """
      if (bevi_dir != null && bevi_dir.length > bevi_pos) {
        bevl_newName = new BEC_4_6_TextString(bevi_dir[bevi_pos].getPath());
        bevi_pos++;
      }
      """
      }
      if (def(newName)) {
         opened = true;
         current = File.apNew(newName);
      } else {
         opened = false;
         closed = true;
         current = null;
      }
   }
   
   close() self {
      emit(cs) {
      """
      bevi_dir.Dispose();
      bevi_dir = null;
      """
      }
      emit(jv) {
      """
      bevi_dir = null;
      bevi_pos = 0;
      """
      }
   }

}

