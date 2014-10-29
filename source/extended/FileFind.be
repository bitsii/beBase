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


use Logic:Bool;
use Container:Set;
use Container:LinkedList;
use Text:String;
use Text:Glob;

use IO:File;
use IO:File:RecursiveIterator;
use IO:File:DirectoryIterator;
use IO:File:FilterIterator;

final RecursiveIterator {

   new(File _dir) {
      properties {
         File dir = _dir;
         RecursiveIterator innerIter = null;
         DirectoryIterator dirIter = DirectoryIterator.new(dir);
      }
   }
   
   hasNextGet() Bool {
      if (def(innerIter) && innerIter.hasNext) {
         return(true);
      } elif (def(innerIter)) {
         innerIter = null;
      }
      return(dirIter.hasNext);
   }
   
   nextGet() File {
      if (def(innerIter) && innerIter.hasNext) {
         return(innerIter.next);
      } elif (def(innerIter)) {
         innerIter = null;
      }
      File toRet = dirIter.next;
      if (def(toRet) && toRet.isDirectory && toRet.path.name != "." && toRet.path.name != "..") {
         innerIter = RecursiveIterator.new(toRet);
      }
      return(toRet);
   }
   
   close() self {
      if (def(innerIter)) {
         innerIter.close();
         innerIter = null;
      }
      dirIter.close();
   }

}

final FilterIterator {

   new(_fiter) self {
      properties {
         var fiter = _fiter;
         Bool needsInit = true;
         File current = null;
         Set includeTypes = null;
         LinkedList includeGlobs = null;
      }
   }
   
   includeGlob(String pat) self {
      if (undef(includeGlobs)) {
         includeGlobs = LinkedList.new();
      }
      includeGlobs += Glob.new(pat);
   }
   
   includeType(String type) self {
      if (undef(includeTypes)) {
         includeTypes = Set.new();
      }
      includeTypes += type;
   }
   
   recursiveNew(File f) {
      rNew(f);
   }
   
   rNew(File f) {
      new(RecursiveIterator.new(f));
   }
   
   directoryNew(File f) {
      dNew(f);
   }
   
   dNew(File f) {
      new(DirectoryIterator.new(f));
   }
   
   hasNextGet() Bool {
      if (needsInit) { needsInit = false; advance(); }
      if (def(current)) {
         return(true);
      }
      return(false);
   }
   
   nextGet() File {
      if (needsInit) { needsInit = false; advance(); }
      File toRet = current;
      advance();
      return(toRet);
   }
   
   advance() {
      current = null;
      while (undef(current) && fiter.hasNext) {
         current = fiter.next;
         if (exclude(current)) {
            current = null;
         }
      }
   }
   
   exclude(File f) Bool {
      Bool typeResult = false; //default unfiltered by type
      if (def(includeTypes)) {
         typeResult = true; //if there is an include type filter, default is to filter unless a match is found
         if (includeTypes.has("d")) {
            if (def(f)) {
               if (f.isDirectory) {
                  typeResult = false;
               }
            }
         }
         if (includeTypes.has("f")) {
            if (def(f)) {
               if (f.isFile) {
                  typeResult = false;
               }
            }
         }
      }
      if (undef(includeGlobs) || typeResult) {
         //if there are no globs, only type result matters
         //if excluded based on type, glob match irrelevant
         return(typeResult);
      }
      
      Bool globResult = false; //default unfiltered by glob
      if (def(includeGlobs)) {
         globResult = true;//if there are a glob includes, one needs to match
         var giter = includeGlobs.iterator;
         //go until we match or get to end
         while (globResult && giter.hasNext) {
            if (giter.next.match(f.path.toString())) {
               globResult = false;//matched one
            }
         }
      }
      return(globResult);
   }
   
   close() self {
      fiter.close();
   }

}
