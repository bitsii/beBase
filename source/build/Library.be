/*
 * Copyright (c) 2006-2023, the Brace Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

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
         dyn libnameNp = Build:NamePath.new();
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
