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
using System.IO;
//using System;
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
      llpath = String.new(); //to prime String
      var llpath = path.toString();
      if (self.exists) {
         emit(c) {
         """
         bevl_llpath = $llpath&*;
         DeleteFile(((char*) bevl_llpath[bercps]));
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

use IO:File:DirectoryIterator;

final DirectoryIterator {

   emit(c) {
   """
/*-attr- -nativeSlots/2/-*/
   """
   }
   
   emit(c) {
   """
/*-attr- -freeFirstSlot-*/
   """
   }
   
   new() self {
   
      properties {
         var fd;
         var handle;
         File dir;
         Bool opened = false;
         Bool closed = false;
         File current = null;
      }
      
   }
   
   fdGet() { return(null); }
   fdSet(var _fd) { }
   
   handleGet() { return(null); }
   handleSet(var _handle) { }
   
   new(File _dir) self {
      dir = _dir;
   }
   
   open() self {
      emit(c) {
      """
      /*-attr- -dec-*/
      WIN32_FIND_DATA* FindFileData;
      HANDLE hFind;
      """
      }
      
      String path;
      String newName;
      
      if (def(dir)) {
         path = dir.path.toString() + "\\*.*";
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
      emit(c) {
      """
      FindFileData = (WIN32_FIND_DATA*) BENoMalloc(sizeof(WIN32_FIND_DATA));
      hFind = FindFirstFile((char*)$path&*[bercps], FindFileData);
      if (hFind == INVALID_HANDLE_VALUE) {
         FindClose(hFind);
         BENoFree(FindFileData);
      } else {
         bevs[bercps] = (void*) FindFileData;
         bevs[bercps + 1] = (void*) hFind;
         $newName=* BERF_String_For_Chars(berv_sts, FindFileData->cFileName);
      }
      """
      }
      if (def(newName)) {
         //("open succeeded " + dir.path + " " + newName).print();
         opened = true;
         current = dir.path.copy().addStep(newName).file;
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
      emit(c) {
      """
      /*-attr- -dec-*/
      WIN32_FIND_DATA* FindFileData;
      HANDLE hFind;
      """
      }
   
      String newName;
      
      if (closed) { return(self); }
      if (opened!) { return(self); }
      if (undef(current)) { return(self); }
      emit(c) {
      """
      if (bevs[bercps] != NULL && bevs[bercps + 1] != NULL) {
         FindFileData = (WIN32_FIND_DATA*) bevs[bercps];
         hFind = (HANDLE) bevs[bercps + 1];
         if (FindNextFile(hFind, FindFileData)) {
            /*printf("found next file");*/
            $newName=* BERF_String_For_Chars(berv_sts, FindFileData->cFileName);
         } else {
            /*printf("not found next file");*/
            bevs[bercps] = NULL;
            bevs[bercps + 1] = NULL;
            FindClose(hFind);
            BENoFree(FindFileData);
         }
      }
      """
      }
      if (def(newName)) {
         opened = true;
         current = dir.path.copy().addStep(newName).file;
      } else {
         opened = false;
         closed = true;
         current = null;
      }
   }
   
   close() self {
      //for now, just finish the iteration
      while (hasNextGet()) {
         nextGet();
      }
   }

}

