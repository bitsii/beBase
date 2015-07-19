// Copyright 2006 Craig Welch
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

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

