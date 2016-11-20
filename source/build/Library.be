// Copyright 2006 Craig Welch
//
// Licensed under the MIT license. See LICENSE.txt file in the project root 
// for full license information.

final class Build:Library {
   
   new(Text:String spath, Build:Build _build) self {
      fields {
         Text:String libName;
         Text:String exeName;
         Build:ClassInfo libnameInfo;
         Build:Build build = _build;
         IO:File:Path basePath;
         IO:File:Path emitPath;
      }
      if (undef(libName)) {
         IO:File:Path libPath = IO:File:Path.new(spath);
         basePath = libPath.parent;
         emitPath = basePath.copy();
         libName = libPath.steps.last;
      } else {
         basePath = IO:File:Path.new(spath);
         emitPath = basePath.copy();
      }
      if (def(libName)) {
         any libnameNp = Build:NamePath.new();
         libnameNp.fromString(libName);
         if (undef(exeName)) { exeName = libName; }
         libnameInfo = Build:ClassInfo.new(libnameNp, build.emitter, emitPath, libName, exeName);
      }
   }
   
   new(Text:String spath, Build:Build _build, Text:String _libName, Text:String _exeName) self {
      libName = _libName;
      exeName = _exeName;
      self.new(spath, _build);
   }
   
}
