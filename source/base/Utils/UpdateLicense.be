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

use Container:Array;
use System:Utils;
use System:Parameters;
use Text:String;
use IO:ByteBuffer;
use IO:File;
use Logic:Bool;

use Math:Int;

class Utils:ApplyLicense {

   main(Array args, Parameters params) {
      ("In Main").print();
      if (params.has("inFile")) {
         single(args, params);
      } elif (params.has("dir")) {
         dir(args, params);
      }
   }
   
   dir(Array args, Parameters params) {
      String dir = params.get("dir").first;
      String oldLic = params.get("oldLic").first;
      String newLic = params.get("newLic").first;
      
      IO:File:Find find = IO:File:Find.new(IO:File.new(dir));
      find.includeType("f");
      foreach (File f in find.open()) {
         f.path.print();
         updateLicense(f.path.toString(), oldLic, newLic);
      }
   }
   
   single(Array args, Parameters params) {
      String inFile = params.get("inFile").first;
      String oldLic = params.get("oldLic").first;
      String newLic = params.get("newLic").first;
      updateLicense(inFile, oldLic, newLic);
   }
   
   updateLicense(String inFile, String oldLic, String newLic) {
      String outFile = inFile + ".tmp";
      var oldLicR = IO:File.new(oldLic).reader.open();
      var newLicR = IO:File.new(newLic).reader.open();
      var inFileR = IO:File.new(inFile).reader.open();
      ByteBuffer olLine = ByteBuffer.new();
      ByteBuffer irLine = ByteBuffer.new();
      Bool foundIt = false;
      loop {
         olLine.clear();
         irLine.clear();
         olLine = oldLicR.readBufferLine(olLine);
         if (undef(olLine)) {
            foundIt = true;
            break; 
         }
         irLine = inFileR.readBufferLine(irLine);
         ("Found " + olLine + "\n" + irLine).print();
         if (undef(irLine) || irLine != olLine) {
            ("NotEqual\n" + irLine + " " + olLine).print();
            break;
         }
      }
      if (foundIt) {
         ("Found it").print();
         var outFileW = IO:File.new(outFile).writer.open();
         outFileW.write(newLicR.readBuffer());
         outFileW.write(inFileR.readBuffer());
         outFileW.close();
         var ofi = IO:File.new(outFile);
         var ifi = IO:File.new(inFile);
         ofi.copyFile(ifi);
         ofi.delete();
      }
      oldLicR.close();
      newLicR.close();
      inFileR.close();
      
   }
   
}

