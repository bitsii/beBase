// Copyright 2006 The Brace Authors. All rights reserved.
// Use of this source code is governed by the BSD-3-Clause
// license that can be found in the LICENSE file.

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
