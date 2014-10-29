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
use Time:Timestamp;
use Logic:Bool;

class Test:BaseTest:IO(BaseTest) {

   testIterateFile() {
   
      Method mapr = self;
      
      File dir = File:Path.apNew("test/inputs/diriter").file;
      File:RecursiveIterator iter = File:RecursiveIterator.new(dir);
      "RecursiveIterator".print();
      Set names = Mapper.mapIterator(iter, mapr, Set.new());
      assertTrue(names.has("hi"));
      assertTrue(names.has("there"));
      "RecursiveIterator close".print();
      iter = File:RecursiveIterator.new(dir);
      Bool worked = false;
      if (iter.hasNext) {
         iter.next;//iter.next;iter.next;
         iter.close();
         assertFalse(iter.hasNext);
         worked = true;
      }
      assertTrue(worked);
      
      File fdir = File:Path.apNew("test/inputs/fiter").file;
      File:FilterIterator fiter = File:FilterIterator.rNew(fdir);
      "FilterIterator".print();
      names = Mapper.mapIterator(fiter, mapr, Set.new());
      assertTrue(names.has("a.xml"));
      assertTrue(names.has("b.txt"));
      assertTrue(names.has("c"));
      
      fdir = File:Path.apNew("test/inputs/fiter").file;
      fiter = File:FilterIterator.rNew(fdir);
      fiter.includeType("f");
      "FilterIterator type f".print();
      names = Mapper.mapIterator(fiter, mapr, Set.new());
      assertTrue(names.has("a.xml"));
      assertTrue(names.has("b.txt"));
      assertFalse(names.has("c"));
      
      fdir = File:Path.apNew("test/inputs/fiter").file;
      fiter = File:FilterIterator.rNew(fdir);
      fiter.includeType("d");
      "FilterIterator type d".print();
      names = Mapper.mapIterator(fiter, mapr, Set.new());
      assertFalse(names.has("a.xml"));
      assertFalse(names.has("b.txt"));
      assertTrue(names.has("c"));
      
      fdir = File:Path.apNew("test/inputs/fiter").file;
      fiter = File:FilterIterator.rNew(fdir);
      fiter.includeGlob("*.xml");
      "FilterIterator xml glob".print();
      names = Mapper.mapIterator(fiter, mapr, Set.new());
      assertTrue(names.has("a.xml"));
      assertFalse(names.has("b.txt"));
      assertFalse(names.has("c"));
      
      fdir = File:Path.apNew("test/inputs/fiter").file;
      fiter = File:FilterIterator.rNew(fdir);
      fiter.includeGlob("*.xml");
      fiter.includeType("d");
      "FilterIterator xml glob d type".print();
      names = Mapper.mapIterator(fiter, mapr, Set.new());
      assertFalse(names.has("a.xml"));
      assertFalse(names.has("b.txt"));
      assertFalse(names.has("c"));
      
      fdir = File:Path.apNew("test/inputs/fiter").file;
      fiter = File:FilterIterator.rNew(fdir);
      fiter.includeGlob("*.xml");
      fiter.includeGlob("b");
      fiter.includeGlob("*c");
      fiter.includeType("d");
      "FilterIterator xml *c glob d type".print();
      names = Mapper.mapIterator(fiter, mapr, Set.new());
      assertFalse(names.has("a.xml"));
      assertFalse(names.has("b.txt"));
      assertFalse(names.has("b"));
      assertTrue(names.has("c"));
      
   }
   
   map(File f) String {
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
      
      //testIterateFile();
      //return(self);
      
      testFileTypes();
      testRWAttr();
      
      testReadBufferLine();
      testPath();
      //testReadStdin();
      testReadCommand();
      testTimestamps();
      testSize();
      testIterateFile();
      testLink();
      testCopyFile();
      testReadBufferLine();
   }
   
   testFileTypes() {
   
      File d = File.apNew("test/tmp/mydir");
      if (d.exists!) {
         d.makeDirs();
      }
      assertTrue(d.isDir);
      assertFalse(d.isFile);
      
      File rg = File.apNew("test/tmp/myFile");
      rg.makeFile();
      assertTrue(rg.isFile);
      
   }
   
   testRWAttr() {
      
      File f = File.apNew("test/tmp/rw.txt");
      
      if (f.exists && f.writable!) { f.writable = true;f.delete(); }
      
      var w = f.writer.open();
      w.write("boo");
      w.close();
      
      ("Exists " + f.exists).print();
      assertTrue(f.exists);
      ("readable " + f.readable).print();
      assertTrue(f.readable);
      ("writable " + f.writable).print();
      assertTrue(f.writable);
      f.writable = false;
      ("writable " + f.writable).print();
      assertFalse(f.writable);
      f.writable = true;
      ("writable " + f.writable).print();
      assertTrue(f.writable);
      f.delete();
      ("Exists " + f.exists).print();
      assertFalse(f.exists);
   
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
      
      //return(self);
      
      String builder = String.new();
      
      var r = tf.reader.open();
      String rl01 = r.readBufferLine(builder);
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
   
   testReadCommand() {
   
      File:Reader:Command.new("echo 'hi'").open().readString().print();
      
   }
   
   testLink() {
      
      File f = File.apNew("test/tmp/boo.txt");
      
      var w = f.writer.open();
      w.write("boo");
      w.close();
      
      File f2 = File.apNew("test/tmp/boo2.txt");
      f2.delete();
      assertFalse(f2.exists);
      f.link(f2);
      assertTrue(f2.exists);
      
      f.delete();
      f2.delete();
   
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
   
   testTimestamps() {
      
      File f = File.apNew("test/tmp/boo.txt");
      
      var w = f.writer.open();
      w.write("boo");
      w.close();
      
      Timestamp tnow = Timestamp.new();
      Timestamp tpast = tnow.copy().subtractDays(2000);
      
      tnow.print();
      tpast.print();
      
      assertTrue(tnow > tpast);
      
      f.lastModified = tpast;
      f.lastModified.print();
      assertEquals(f.lastModified, tpast);
      
      f.delete();
   
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

