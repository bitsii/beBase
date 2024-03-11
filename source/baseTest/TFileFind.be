/*
 * Copyright (c) 2016-2023, the Brace Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

import Container:List;
import Container:Set;
import System:Parameters;
import Text:String;
import Text:String;
import Function:Mapper;

import Test:BaseTest;
import Test:Failure;
import Math:Int;
import IO:File;
import IO:File:Path;
import Time:Timestamp;
import Logic:Bool;

class Test:BaseTest:IO(BaseTest) {

   testIterateFile() {
   
      Method mapr = self;
      
      File dir = File:Path.apNew("test/inputs/diriter").file;
      File:RecursiveIterator iter = File:RecursiveIterator.new(dir);
      "RecursiveIterator".print();
      Set names = Mapper.mapIterator(iter, mapr, Set.new());
      assertTrue(names.contains("hi"));
      assertTrue(names.contains("there"));
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
      assertTrue(names.contains("a.xml"));
      assertTrue(names.contains("b.txt"));
      assertTrue(names.contains("c"));
      
      fdir = File:Path.apNew("test/inputs/fiter").file;
      fiter = File:FilterIterator.rNew(fdir);
      fiter.includeType("f");
      "FilterIterator type f".print();
      names = Mapper.mapIterator(fiter, mapr, Set.new());
      assertTrue(names.contains("a.xml"));
      assertTrue(names.contains("b.txt"));
      assertFalse(names.contains("c"));
      
      fdir = File:Path.apNew("test/inputs/fiter").file;
      fiter = File:FilterIterator.rNew(fdir);
      fiter.includeType("d");
      "FilterIterator type d".print();
      names = Mapper.mapIterator(fiter, mapr, Set.new());
      assertFalse(names.contains("a.xml"));
      assertFalse(names.contains("b.txt"));
      assertTrue(names.contains("c"));
      
      fdir = File:Path.apNew("test/inputs/fiter").file;
      fiter = File:FilterIterator.rNew(fdir);
      fiter.includeGlob("*.xml");
      "FilterIterator xml glob".print();
      names = Mapper.mapIterator(fiter, mapr, Set.new());
      assertTrue(names.contains("a.xml"));
      assertFalse(names.contains("b.txt"));
      assertFalse(names.contains("c"));
      
      fdir = File:Path.apNew("test/inputs/fiter").file;
      fiter = File:FilterIterator.rNew(fdir);
      fiter.includeGlob("*.xml");
      fiter.includeType("d");
      "FilterIterator xml glob d type".print();
      names = Mapper.mapIterator(fiter, mapr, Set.new());
      assertFalse(names.contains("a.xml"));
      assertFalse(names.contains("b.txt"));
      assertFalse(names.contains("c"));
      
      fdir = File:Path.apNew("test/inputs/fiter").file;
      fiter = File:FilterIterator.rNew(fdir);
      fiter.includeGlob("*.xml");
      fiter.includeGlob("b");
      fiter.includeGlob("*c");
      fiter.includeType("d");
      "FilterIterator xml *c glob d type".print();
      names = Mapper.mapIterator(fiter, mapr, Set.new());
      assertFalse(names.contains("a.xml"));
      assertFalse(names.contains("b.txt"));
      assertFalse(names.contains("b"));
      assertTrue(names.contains("c"));
      
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
      
      dyn w = f.writer.open();
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
      dyn w = tf.writer.open();
      w.write(line01);
      w.write(line02);
      w.write(line03);
      w.close();
      
      //return(self);
      
      String builder = String.new();
      
      dyn r = tf.reader.open();
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
      
      dyn br = tf.reader.open().byteReader(8);
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
      
      dyn w = f.writer.open();
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
      
      dyn w = f.writer.open();
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
      
      dyn w = f.writer.open();
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
      
      dyn w = f.writer.open();
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
      dyn r = File:Reader:Stdin.new();
      String b = r.readBufferLine();
      b.print();
      b = r.readBufferLine();
      b.print();
   }
   
}

