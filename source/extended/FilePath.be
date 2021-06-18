// Copyright 2006 The Brace Authors. All rights reserved.
// Use of this source code is governed by the BSD-3-Clause
// license that can be found in the LICENSE file.

use IO:File;
use Text:Glob;

local class IO:File:Path(System:BasePath) {
   
   
   new(String spath) self {
      
      fields {
         File file;
         String driveLetter; //letter with :, like C:
      }
      
      separator = System:CurrentPlatform.separator;
      fromString(spath);
   }
   
   apNew(String spath) self {
      //WARNING assumes X: is a drive letter, may not be the case
      if (spath.size > 1 && spath.getPoint(1) == ":") {
         driveLetter = spath.substring(0, 2);
         spath = spath.substring(2, spath.size);
      }
      System:Platform p = System:Process.platform;
      spath = spath.swap(p.otherSeparator, p.separator);
      return(new(spath));
   }
   
   isAbsoluteGet() Bool {
      //if (def(driveLetter)) {
      //  return(true);
      //}
      return(super.isAbsoluteGet());
   }
   
   serializeToString() String {
      return(toString());
   }
   
   deserializeFromStringNew(String snw) self {
      self.apNew(snw);
   }
   
   serializeContents() Bool {
      return(false);
   }
   
   //TODO override equals compare drive letters
   
   fileGet() File {
      if (undef(file)) {
         file = File.new();
         file.path = self;
      }
      return(file);
   }
   
   copy() self {
      IO:File:Path other = create();
      copyTo(other);
      other.path = path.copy();
      other.file = null;
      return(other);
   }
   
   toString() Text:String {
      if (def(driveLetter)) {
         return(driveLetter + path);
      }
      return(path);
   }
   
   parentGet() IO:File:Path {
      return(super.parent);
   }
   
   makeNonAbsolute() self {
      if (self.isAbsolute) {
         driveLetter = null;
         super.makeNonAbsolute();
      }
   }
   
   matchesGlob(String glob) {
      return(Glob.new(glob).match(toString()));
   }

   subPath(Int start, Int end) {
      any res = super.subPath(start, end);
      res.driveLetter = driveLetter;
      return(res);
   }
   
   nameGet() String {
      return(self.lastStep);
   }
}

