/*
 * Copyright (c) 2016-2023, the Bennt Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

use Container:List;
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
      for (File f in d) {
        f.path.print();
        names.put(f.path.name);
      }
      assertEqual(names.length, 3);
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
      //("nl length " + nl.length.toString()).print();
      String line01 = "Hi" + nl;
      String line02 = "There" + nl;
      String line03 = "Newcastle" + nl;
      "rbl1".print();
      if (tf.exists) { tf.delete(); }
      "rbl2".print();
      any w = tf.writer.open();
      "write".print();
      w.write(line01);
      "write".print();
      w.write(line02);
      w.write(line03);
      "close".print();
      w.close();
      
      "write done".print();
      //if (true) { return(self); }
      
      String builder = String.new();
      "start read".print();
      any r = tf.reader.open();
      String rl01 = r.readBufferLine(builder);
      "after read".print();
      //rl01.print();
      assertNotNull(rl01);
      ("l1 rl01 " + line01 + " " + rl01).print();
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
      
      any br = tf.reader.open().byteReader(8);
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
      ("dataIn sz after 3 lines " + dataIn.length).print();
      
      testWRFile("test/tmp/wrfilesmall.txt", dataIn);
      
      
      for (Int i = 0;i < 1500;i++) {
          dataIn += "_";
      }
      ("dataIn sz after 1500 _ " + dataIn.length).print();
      
      testWRFile("test/tmp/wrfilebig.txt", dataIn);
   }
   
   testWRFile(String fpath, String dataIn) {
 
      File tf = File.apNew(fpath);
      
      if (tf.exists) { tf.delete(); }
      
      any w = tf.writer.open();
      w.write(dataIn);
      w.close();
      ("dataIn " + dataIn).print();
      
      any r = tf.reader.open();
      String dataOut = r.readString();
      r.close();
      ("dataOut " + dataOut).print();
      ("dataIn sz " + dataIn.length + " dataOut sz " + dataOut.length).print();
      assertEqual(dataIn, dataOut);
      
   }
   
   testReadCommand() {
   
      //IO:File:Reader:Command.new("echo 'hi'").open().readString().print();
      
   }
   
   testCopyFile() {
      
      File f = File.apNew("test/tmp/boo hiss.txt");
      
      any w = f.writer.open();
      w.write("boo");
      w.close();
      
      File f2 = File.apNew("test/tmp/boo2 hiss2.txt");
      f2.delete();
      assertFalse(f2.exists);
      assertTrue(f.copyFile(f2));
      assertTrue(f2.exists);
      
      assertEquals(f.length, f2.length);
      
      w = f2.writer.open();
      w.write("x");
      w.close();
      
      assertTrue(f.copyFile(f2));
      assertTrue(f2.exists);
      
      assertEquals(f.length, f2.length);
      
      f.delete();
      f2.delete();
   
	  //File fbig = File.apNew("Base_linux.zip");
	  //File fbigcp = File.apNew("Base_linux_Copy.zip");
	  //assertTrue(fbig.copyFile(fbigcp));
	  //assertEquals(fbig.length, fbigcp.length);
   }
   
   testSize() {
      
      File f = File.apNew("test/tmp/boo.txt");
      
      any w = f.writer.open();
      w.write("boo");
      w.close();
      
      assertTrue(f.length > 0);
      
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
      any r = IO:File:Reader:Stdin.new();
      String b = r.readBufferLine();
      b.print();
      b = r.readBufferLine();
      b.print();
   }
   
}

use Net:Socket:Listener;
use Net:Socket;
use Net:Socket:Reader as SocketReader;

class Util:Net:EchoServer {

     main() {
      ("Util:Net:EchoServer start").print();
      List args = System:Process.new().args;
      if (def(args) && args.length > 1) {
        String ports = args[1];
      } else {
        ports = "9090";
      }
      ("Listening on " + ports).print();
      Listener l = Listener.new("127.0.0.1", Int.new(ports));
      //Listener l = Listener.new(Int.new(ports));
      //Listener l = Listener.new("0.0.0.0", Int.new(ports));
      l.bind();
      ("Waiting for conn").print();
      Socket s = l.accept();
      ("Connected").print();
      SocketReader sr = s.reader;
      //("Got from socket " + sr.readString()).print();
      String buf = String.new(4096);
      sr.readIntoBuffer(buf);
      ("Got from socket " + buf).print();
      s.writer.write("Got Message: " + buf);
      Time:Sleep.sleepSeconds(3);
   }

}

class Util:Net:EchoClient {

     main() {
      ("Util:Net:EchoClient start").print();
      List args = System:Process.new().args;
      if (def(args) && args.length > 1) {
        String ports = args[1];
      } else {
        ports = "9090";
      }
      if (def(args) && args.length > 2) {
        String msg = args[2];
      } else {
        msg = "Yo";
      }
      ("Sending " + msg + " on " + ports).print();
      Socket s = Socket.new("127.0.0.1", Int.new(ports));
      s.writer.write(msg);
      String reply = String.new(1024);
      s.reader.readIntoBuffer(reply);
      ("Reply " + reply).print();
   }

}

