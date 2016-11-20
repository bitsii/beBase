// Copyright 2006 Craig Welch
//
// Licensed under the MIT license. See LICENSE.txt file in the project root 
// for full license information.


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
      fields {
         File dir = _dir;
         RecursiveIterator innerIter = null;
         DirectoryIterator dirIter = DirectoryIterator.new(dir);
      }
   }
   
   hasNextGet() Bool {
      if (def(innerIter) && innerIter.hasNext) {
         return(true);
      } elseIf (def(innerIter)) {
         innerIter = null;
      }
      return(dirIter.hasNext);
   }
   
   nextGet() File {
      if (def(innerIter) && innerIter.hasNext) {
         return(innerIter.next);
      } elseIf (def(innerIter)) {
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
      fields {
         any fiter = _fiter;
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
         any giter = includeGlobs.iterator;
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
