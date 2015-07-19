// Copyright 2006 Craig Welch
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

use Container:Array;
use Container:Set;
use System:Parameters;
use Text:String;
use Text:String;
use Function:Mapper;

use Test:BaseTest;
use Test:Failure;
use Math:Int;
use IO:File;
use IO:File:Path;
use Logic:Bool;

class Test:BaseTest:IO(BaseTest) {

   fileToName(File f) String {
      ("Next file name :" + f.path.name + ":").print();
      ("Next file " + f.path).print();
      ("Exists " + f.exists).print();
      ("Is directory " + f.isDirectory).print();
      ("Is file " + f.isFile).print();
      return(f.path.name);
   }
   
   main() {
      ("Test:BaseTest:IO:main").print();
      
      IO:File.new("test/tmp").makeDirs();
      
      testFileTypes();
      
      testReadBufferLine();
      testWRFile();
      
      //if(true) { return(self); }
      
      testPath();
      ifEmit(cs) {
        testDirIter(); //only works for cs right now
      }
      //testReadStdin();
      //testReadCommand();
      //testSize();
      //testCopyFile();
      
      
   }
   
   testDirIter() {
      ("testDirIter").print();
      Set names = Set.new();
      File d = File.apNew("test/inputs/diriter");
      foreach (File f in d) {
        f.path.print();
        names.put(f.path.name);
      }
      assertEqual(names.size, 3);
      assertTrue(names.has("d2"));
      assertTrue(names.has("hi"));
      assertTrue(names.has("there"));
   }
   
   testFileTypes() {
   
      File d = File.apNew("test/tmp/mydir");
      if (d.exists!) {
         d.makeDirs();
      }
      ("doing isDir").print();
      assertTrue(d.isDir);
      ("doing isFile").print();
      assertFalse(d.isFile);
      //if (true) { return(self); }
      File rg = File.apNew("test/tmp/myFile");
      rg.makeFile();
      ("doing isFile for made file").print();
      assertTrue(rg.isFile);
      
   }
   
   testReadBufferLine() {
   
      String nl = Text:Strings.newline;
      
      File tf = File.apNew("test/tmp/tbuf.txt");
      //("nl size " + nl.size.toString()).print();
      String line01 = "Hi" + nl;
      String line02 = "There" + nl;
      String line03 = "Newcastle" + nl;
      
      if (tf.exists) { tf.delete(); }
      var w = tf.writer.open();
      w.write(line01);
      w.write(line02);
      w.write(line03);
      w.close();
      
      //if (true) { return(self); }
      
      String builder = String.new();
      
      var r = tf.reader.open();
      String rl01 = r.readBufferLine(builder);
      //rl01.print();
      assertNotNull(rl01);
      assertEquals(line01, rl01.toString());
      ("Builder " + builder).print();
      builder.clear();
      String rl02 = r.readBufferLine(builder);
      assertNotNull(rl02);
      assertEquals(line02, rl02.toString());
      ("Builder " + builder).print();
      builder.clear();
      String rl03 = r.readBufferLine(builder);
      assertNotNull(rl03);
      assertEquals(line03, rl03.toString());
      ("Builder " + builder).print();
      builder.clear();
      
      tf.reader.close();
      
      var br = tf.reader.open().byteReader(8);
      String brb = br.next;
      while (br.hasNext) {
         brb.print();
         br.next(brb);
      }
      
   }
   
   testWRFile() {
      String nl = Text:Strings.newline;
      
      String dataIn = String.new();
      dataIn += "Here's some data" += nl;
      dataIn += "And, a bit more" += nl;
      dataIn += "This is all..." += nl;
      ("dataIn sz after 3 lines " + dataIn.size).print();
      
      testWRFile("test/tmp/wrfilesmall.txt", dataIn);
      
      
      for (Int i = 0;i < 1500;i = i++) {
          dataIn += "_";
      }
      ("dataIn sz after 1500 _ " + dataIn.size).print();
      
      testWRFile("test/tmp/wrfilebig.txt", dataIn);
   }
   
   testWRFile(String fpath, String dataIn) {
 
      File tf = File.apNew(fpath);
      
      if (tf.exists) { tf.delete(); }
      
      var w = tf.writer.open();
      w.write(dataIn);
      w.close();
      ("dataIn " + dataIn).print();
      
      var r = tf.reader.open();
      String dataOut = r.readString();
      r.close();
      ("dataOut " + dataOut).print();
      ("dataIn sz " + dataIn.size + " dataOut sz " + dataOut.size).print();
      assertEqual(dataIn, dataOut);
      
   }
   
   testReadCommand() {
   
      File:Reader:Command.new("echo 'hi'").open().readString().print();
      
   }
   
   testCopyFile() {
      
      File f = File.apNew("test/tmp/boo hiss.txt");
      
      var w = f.writer.open();
      w.write("boo");
      w.close();
      
      File f2 = File.apNew("test/tmp/boo2 hiss2.txt");
      f2.delete();
      assertFalse(f2.exists);
      assertTrue(f.copyFile(f2));
      assertTrue(f2.exists);
      
      assertEquals(f.size, f2.size);
      
      w = f2.writer.open();
      w.write("x");
      w.close();
      
      assertTrue(f.copyFile(f2));
      assertTrue(f2.exists);
      
      assertEquals(f.size, f2.size);
      
      f.delete();
      f2.delete();
   
	  //File fbig = File.apNew("Base_linux.zip");
	  //File fbigcp = File.apNew("Base_linux_Copy.zip");
	  //assertTrue(fbig.copyFile(fbigcp));
	  //assertEquals(fbig.size, fbigcp.size);
   }
   
   testSize() {
      
      File f = File.apNew("test/tmp/boo.txt");
      
      var w = f.writer.open();
      w.write("boo");
      w.close();
      
      assertTrue(f.size > 0);
      
      f.delete();
   
   }
   
   testPath() {
   
      String res1 = "A/Path/Or/Two".swap("/", System:CurrentPlatform.separator);
      String res2 = "Or/Two".swap("/", System:CurrentPlatform.separator);
      
      //New constructor which fixes up separators, meant for "all platoforms" or "any platform"
      Path ps1 = Path.apNew("\\Yo\\Baby");
      Path ps2 = Path.apNew("/yukka/yukka");
      Path ps3 = Path.apNew("C:\\boo");
      
      assertTrue(def(ps3.driveLetter));
      
      ps1.print();
      ps2.print();
      ps3.print();
      
      Path p1 = Path.apNew("/A/Path/Or/Two");
      Path p2 = Path.new();
      Path p3 = Path.apNew("/Hi/There");
      
      p1.copy().makeNonAbsolute().toString().print();
      
      assertEquals(p1.copy().makeNonAbsolute().toString(), res1)
      
      p1.trimParents(2);
      p1.print();
      assertEquals(p1.toString(), res2);
      
      p2.trimParents(4);
      assertEquals(p2.toString(), "");
      
      p3.trimParents(2);
      assertEquals(p3.toString(), "");
   }
   
   testReadStdin() {
      var r = File:Reader:Stdin.new();
      String b = r.readBufferLine();
      b.print();
      b = r.readBufferLine();
      b.print();
   }
   
}

