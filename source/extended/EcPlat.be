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
         File:Path path;
         var reader;
         var writer;
      }
      
   }
   
   new(fpath) self {
      self.path = File:Path.new(fpath);
   }
   
   apNew(fpath) self {
      self.path = File:Path.apNew(fpath);
   }
   
   pathNew(File:Path _path) self {
      self.path = _path;
   }
   
   readerGet() {
      if (undef(reader)) {
         reader = File:Reader.new(path.toString());
      }
      return(reader);
   }
   
   writerGet() {
      if (undef(writer)) {
         writer = File:Writer.new(path.toString());
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
            bevl_result = abe.BELS_Base.BECS_Runtime.boolTrue;
          }
          """
          }
          emit(cs) {
          """
          string bevls_path = System.Text.Encoding.UTF8.GetString(bevp_path.bevp_path.bevi_bytes, 0, bevp_path.bevp_path.bevp_size.bevi_int);
          if (Directory.Exists(bevls_path)) {
            bevl_result = abe.BELS_Base.BECS_Runtime.boolTrue;
          }
          """
          }
         emit(js) {
         """
         var bevls_path = this.bems_stringToJsString_1(this.bevp_path.bevp_path);
         if (fs.lstatSync(bevls_path).isDirectory()) {
            bevl_result = abe_BELS_Base_BECS_Runtime.prototype.boolTrue;
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
            bevl_result = abe.BELS_Base.BECS_Runtime.boolTrue;
          }
          """
          }
          emit(cs) {
          """
          string bevls_path = System.Text.Encoding.UTF8.GetString(bevp_path.bevp_path.bevi_bytes, 0, bevp_path.bevp_path.bevp_size.bevi_int);
          if (File.Exists(bevls_path)) {
            bevl_result = abe.BELS_Base.BECS_Runtime.boolTrue;
          }
          """
          }
         emit(js) {
         """
         var bevls_path = this.bems_stringToJsString_1(this.bevp_path.bevp_path);
         if (fs.lstatSync(bevls_path).isFile()) {
            bevl_result = abe_BELS_Base_BECS_Runtime.prototype.boolTrue;
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
        bevl_tvala = abe.BELS_Base.BECS_Runtime.boolTrue;
      }
      """
      }
      emit(cs) {
      """
      string bevls_path = System.Text.Encoding.UTF8.GetString(bevp_path.bevp_path.bevi_bytes, 0, bevp_path.bevp_path.bevp_size.bevi_int);
      if (File.Exists(bevls_path) || Directory.Exists(bevls_path)) {
        bevl_tvala = abe.BELS_Base.BECS_Runtime.boolTrue;
      }
      """
      }
     emit(js) {
     """
     var bevls_path = this.bems_stringToJsString_1(this.bevp_path.bevp_path);
     if (fs.existsSync(bevls_path)) {
        bevl_tvala = abe_BELS_Base_BECS_Runtime.prototype.boolTrue;
     }
     """
     }
      return(tvala);
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
         throw(System:Exception.new("Attempting to re-open a closed File:Iterator is not supported"));
      }
      if (opened) {
         throw(System:Exception.new("Only open File:Iterator once"));
      }
      emit(cs) {
      """
      bevi_dir = Directory.EnumerateFileSystemEntries(bevl_path.bems_toCsString(), "*", SearchOption.TopDirectoryOnly).GetEnumerator();
      if (bevi_dir.MoveNext()) {
        bevl_newName = new BEC_4_6_TextString(bevi_dir.Current);
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
   }

}

