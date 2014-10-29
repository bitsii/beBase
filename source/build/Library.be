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
