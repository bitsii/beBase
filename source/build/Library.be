// Copyright 2006 Craig Welch
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

final class Build:Library {
   
   new(Text:String spath, Build:Build _build) self {
      properties {
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
         var libnameNp = Build:NamePath.new();
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
