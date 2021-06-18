// Copyright 2006 The Brace Authors. All rights reserved.
// Use of this source code is governed by the BSD-3-Clause
// license that can be found in the LICENSE file.

use IO:File;
use Text:String;
use Logic:Bool;
use Math:Int;

emit(c) {
"""
#include <fcntl.h>
#include <dirent.h>
#include <utime.h>
#ifdef BENP_linux
#include <sys/sendfile.h>
#endif
"""
}

local class File {

   new() self {
      fields {
         any path;
         any reader;
         any writer;
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
int i;
void** bevl_llpath;
      """
      }
      any llpath = path.toString();
      emit(c) {
      """
      bevl_llpath = $llpath&*;
      i = access(((char*) bevl_llpath[bercps]), F_OK);
      if (i == 0) {
         i = unlink(((char*) bevl_llpath[bercps]));
      }
      """
      }
   }
   
   copyFile(other) Bool {
   emit(c) {
   """
   int infd;
   int outfd;
   void** inpath;
   void** outpath;
   int success;
#ifdef BENP_linux
   ssize_t scount = 0;
   ssize_t sent = 0;
   off_t offset = 0;
   struct stat stat_buf;
#else
   char buf[4096];
   int rcount;
   int wcount;
#endif
   """
   }
      String frs;
      String tos;
      if (undef(path) || undef(other) || undef(other.path)) {
		return(false);
      }
      frs = path.toString();
      tos = other.path.toString();
      other.path.parent.file.makeDirs();
      emit(c) {
      """
      success = 0;
      inpath = $frs&*;
      outpath = $tos&*;
      infd = open(((char*) inpath[bercps]), O_RDONLY);
      outfd = open(((char*) outpath[bercps]), O_WRONLY | O_CREAT, 0666);
      if (infd != -1 && outfd != -1) {
#ifdef BENP_linux
/* Use sendfile for linux (good on anything recent, may not be good for android) */
fstat (infd, &stat_buf);
while (1) {
scount = sendfile(outfd, infd, &offset, stat_buf.st_size - sent);
if (scount == -1) {
	/*printf("copy failed %d", errno);*/
	break;
}
sent = sent + scount;
if (sent == stat_buf.st_size) {
	success = 1;
	break;
}
}
#else      
/* Generic Nix, copy using read, write, and a buffer */
	       while (1) {
				rcount = read(infd, &buf[0], sizeof(buf));
				if (!rcount) {
					success = 1;
					break;
			    }
				if (rcount < 0) {
					break;
				}
				wcount = write(outfd, &buf[0], rcount);
				if (rcount != wcount) {
					break;
				}
			}
#endif				
      }
      if (infd != -1) {
         close(infd);
      }
      if (outfd != -1) {
         close(outfd);
      }
      if (success) { /* } */
      """
      }
      return(true);
      emit(c) {
      """
      /* { */
      }
      """
      }
      return(false);
   }
   
   makeDirs() {
      emit(c) {
      """
/*-attr- -dec-*/
char* bevl_frc;
void** bevl_frv;
int nmode;
      """
      }
      String frs = path.toString();
      Bool r = false;
      Bool t = true;
      any strn = Text:Strings.new();
      if ((path.toString() != strn.empty) && (self.exists!)) {
         any parentpath = path.parent;
         if (path == parentpath) {
            //We're at the top and it doesn't exist
            return(self);
         }
         parentpath.file.makeDirs();
         emit(c) {
         """
         nmode = (S_IRWXU | S_IRWXG | S_IRWXO);
         bevl_frv = $frs&*;
         bevl_frc = (char*) bevl_frv[bercps];
         if (mkdir(bevl_frc, nmode)) {
            $r=* $t*;
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
      any spa;
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
      any spa;
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
      any spa;
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
      any mpath = path.toString();
      emit(c) {
      """
      bevl_mpath = $mpath&*;
      i = access(((char*) bevl_mpath[bercps]), F_OK);
      if (i == 0) {
         $tvala=* berv_sts->bool_True;
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
/*-attr- -firstSlotNative-*/
   """
   }
   
   emit(c) {
   """
/*-attr- -freeFirstSlot-*/
   """
   }
   
   new() self {
   
      fields {
         any fd;
         any handle;
         File dir;
         Bool opened = false;
         Bool closed = false;
         File current = null;
      }
      
   }
   
   fdGet() { return(null); }
   fdSet(any _fd) { }
   
   handleGet() { return(null); }
   handleSet(any _handle) { }
   
   new(File _dir) self {
      dir = _dir;
   }
   
   open() self {
      emit(c) {
      """
      /*-attr- -dec-*/
      DIR *dp;
	  struct dirent *entry;
      """
      }
      
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
      emit(c) {
      """
      dp = opendir((char*)$path&*[bercps]);
      if (dp != NULL) {
		 entry = readdir(dp);
		 if (entry != NULL) {
			 bevs[bercps] = (void*) dp;
			 $newName=* BERF_String_For_Chars(berv_sts, entry->d_name);
		 } else {
			closedir(dp);
		 }
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
      DIR *dp;
	  struct dirent *entry;
      """
      }
   
      String newName;
      
      if (closed) { return(self); }
      if (opened!) { return(self); }
      if (undef(current)) { return(self); }
      emit(c) {
      """
      if (bevs[bercps] != NULL) {
         dp = (DIR*) bevs[bercps];
         entry = readdir(dp);
         if (entry != NULL) {
            /*printf("found next file");*/
            $newName=* BERF_String_For_Chars(berv_sts, entry->d_name);
         } else {
            /*printf("not found next file");*/
            bevs[bercps] = NULL;
            closedir(dp);
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


