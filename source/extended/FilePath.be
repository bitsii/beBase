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
use Text:Glob;

local class File:Path(System:BasePath) {
   
   
   new(String spath) self {
      
      properties {
         File file;
         String driveLetter; //letter with :, like C:
      }
      
      separator = System:CurrentPlatform.new().separator;
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
   
   copy() {
      File:Path other = create();
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
   
   parentGet() File:Path {
      return(super.parent);
   }
   
   makeNonAbsolute() File:Path {
      if (self.isAbsolute) {
         driveLetter = null;
         super.makeNonAbsolute();
      }
   }
   
   matchesGlob(String glob) {
      return(Glob.new(glob).match(toString()));
   }

   subPath(Int start, Int end) {
      var res = super.subPath(start, end);
      res.driveLetter = driveLetter;
      return(res);
   }
   
   nameGet() String {
      return(self.lastStep);
   }
}

