// Copyright 2006 The Brace Authors. All rights reserved.
// Use of this source code is governed by the BSD-3-Clause
// license that can be found in the LICENSE file.

use IO:File;
use Text:String;
use Logic:Bool;
use Math:Int;
use Text:Strings;

use Text:String;

emit(cs) {
    """
using System.IO;
//using System;
    """
}

use class IO:ByteReader {

	readerBufferNew(IO:Reader _reader, String _buf) self {
		fields {
			IO:Reader reader = _reader;
			String buf = _buf;
			Text:ByteIterator iter = buf.biter;
		}
	}
	
	readerNew(IO:Reader _reader) self {
		return(readerBlockNew(_reader, 256));
	}

	readerBlockNew(IO:Reader _reader, Int _blockSize) self {
		return(readerBufferNew(_reader, String.new(_blockSize)));
	}
	
	hasNextGet() Bool {
		if (iter.hasNext!) {
			reader.readIntoBuffer(buf);
			iter.pos = 0;
		}
		return(iter.hasNext);
	}
	
	nextGet() String {
		return(next(String.new(2)));
	}
	
	next(String dest) String {
		if (iter.hasNext!) {
			reader.readIntoBuffer(buf);
			iter.pos = 0;
		}
		return(iter.next(dest));
	}

}

class IO:File:Reader(IO:Reader) {
   
   new(fpath) self {
      new();
      blockSize = 1024;//why?
      fields {
         IO:File:Path path;
      }
      self.path = IO:File:Path.new(fpath);
      emit(c) {
      """
         bevs[bercps] = (void*) NULL;
      """
      }
   }
   
   open() {
   emit(c) {
      """
/*-attr- -dec-*/
void** bevl_fhpatha;
      """
      }
      String fhpatha = path.toString();
      Bool _isClosed;
      emit(c) {
      """
         bevl_fhpatha = $fhpatha&*;
         if (((FILE*) bevs[bercps]) == NULL) {
            bevs[bercps] = (void*) fopen(((char*) bevl_fhpatha[bercps]), "rb");
         }
         if (bevs[bercps] == NULL) {
            $_isClosed=* berv_sts->bool_True;
         } else {
            $_isClosed=* berv_sts->bool_False;
         }
      """
      }
      ifEmit(c) {
	isClosed = _isClosed;
      }
      emit(jv) {
      """
      if (this.bevi_is == null) {
        java.io.File bevls_f = new java.io.File(new String(bevp_path.bevp_path.bevi_bytes, 0, bevp_path.bevp_path.bevp_size.bevi_int, "UTF-8"));
        this.bevi_is = new java.io.FileInputStream(bevls_f);
      }
      bevp_isClosed = be.BECS_Runtime.boolFalse;
      """
      }
      emit(cs) {
      """
      if (this.bevi_is == null) {
        string bevls_spath = System.Text.Encoding.UTF8.GetString(bevp_path.bevp_path.bevi_bytes, 0, bevp_path.bevp_path.bevp_size.bevi_int);
        this.bevi_is = new FileStream(bevls_spath, FileMode.Open);
      }
      bevp_isClosed = be.BECS_Runtime.boolFalse;
      """
      }
      emit(cc) {
      """
      if (bevi_is == NULL) {
        bevi_is = fopen(bevp_path->bevp_path->bems_toCcString().c_str(), "rb");
      }
      bevp_isClosed = BECS_Runtime::boolFalse;
      """
      }
      emit(js) {
      """
      if (this.bevi_is == null) {
        var bevls_spath = this.bems_stringToJsString_1(this.bevp_path.bevp_path);
        this.bevi_is = fs.openSync(bevls_spath, 'r');
      }
      this.bevp_isClosed = be_BECS_Runtime.prototype.boolFalse;
      """
      }
      if (undef(isClosed) || isClosed) {
         throw(System:Exception.new("File " + fhpatha + " could not be opened for read."));
      }
   }

}

class IO:Reader {

   emit(c) {
   """
/*-attr- -firstSlotNative-*/
   """
   }
   
   emit(jv) {
   """
    public java.io.InputStream bevi_is;
   """
   }
   
   emit(cs) {
   """
    public System.IO.Stream bevi_is;
    
   """
   }
   
   emit(cc_classHead) {
   """
    FILE* bevi_is = NULL;
   """
   }

    new() self {
      fields {
         any vfile;
         Bool isClosed = true; 
         Int blockSize = 256;
      }
    }
   
   //ONLY for use where an external functionality (in an emit lang...) provides the stream, this is for convenience
   extOpen() {
      isClosed = false;
   }
   
   close() {
      emit(c) {
      """
         if (((FILE*) bevs[bercps]) != NULL) {
            fclose(((FILE*) bevs[bercps]));
            bevs[bercps] = (void*) NULL;
         }
      """
      }
      emit(jv) {
      """
      if (this.bevi_is != null) {
        this.bevi_is.close();
        this.bevi_is = null;
      }
      """
      }
      emit(cs) {
      """
      if (this.bevi_is != null) {
        this.bevi_is.Dispose();
        this.bevi_is = null;
      }
      """
      }
      emit(cc) {
      """
         if (bevi_is != NULL) {
            fclose(bevi_is);
            bevi_is = NULL;
         }
      """
      }
      emit(js) {
      """
      if (this.bevi_is != null) {
        fs.closeSync(this.bevi_is);
        this.bevi_is = null;
      }
      """
      }
      isClosed = true;
   }
   
   vfileGet() { }
   
   vfileSet(vfile) { }
   
   byteReaderGet() ByteReader {
       return(ByteReader.readerNew(self));
   }
   
   byteReader(Int blockSize) ByteReader {
       return(ByteReader.readerBlockNew(self, blockSize));
   }
   
   readIntoBuffer(String readBuf) Int {
		return(readIntoBuffer(readBuf, 0@));
   }
   
   readIntoBuffer(String readBuf, Int at) Int {
    return(readIntoBuffer(readBuf, at, Int.new()));
   }
   
   readIntoBuffer(String readBuf, Int at, Int readsz) Int {
      //if (isClosed) {
      //   throw(System:Exception.new("File is not open, read attempted."));
      //}
      emit(jv) {
      """
      int bevls_read = this.bevi_is.read(beva_readBuf.bevi_bytes, beva_at.bevi_int, beva_readBuf.bevi_bytes.length - beva_at.bevi_int);
      if (bevls_read < 0) {
        bevls_read = 0;
      }
      beva_readsz.bevi_int = bevls_read + beva_at.bevi_int;
      """
      }
      emit(cs) {
      """
      beva_readsz.bevi_int = this.bevi_is.Read(beva_readBuf.bevi_bytes, beva_at.bevi_int, beva_readBuf.bevi_bytes.Length - beva_at.bevi_int) + beva_at.bevi_int;
      """
      }
      emit(cc) {
      """
       int bevls_read = fread(&(beva_readBuf->bevi_bytes[beva_at->bevi_int]), sizeof(unsigned char), beva_readBuf->bevi_bytes.size() - beva_at->bevi_int, bevi_is);
       beva_readsz->bevi_int = bevls_read + beva_at->bevi_int;
      """
      }
      emit(js) {
      """
      var bevls_bytes = beva_readBuf.bevi_bytes;
      var bevls_at = beva_at.bevi_int;
      var bevls_rlen = beva_readBuf.bevp_capacity.bevi_int - bevls_at;
      var bevls_rbuf = new Buffer(bevls_rlen);
      beva_readsz.bevi_int = fs.readSync(this.bevi_is, bevls_rbuf, 0, bevls_rlen) + bevls_at;
      //console.log("read this:");
      //console.log(bevls_rbuf.toString());
      for (var i = 0;i < bevls_rlen;i++) {
        bevls_bytes[i + bevls_at] = bevls_rbuf[i];
      }
      """
      }
      //("read " + readsz).print();
      readBuf.size.setValue(readsz);
      return(readsz);
   }
   
   copyData(IO:Writer outw, String rwbufE, Int rsz) {
      Int at =@ 0;
      while (readIntoBuffer(rwbufE, at, rsz) > 0) {
        outw.write(rwbufE);
      }
   }
   
   copyData(IO:Writer outw) {
      String rwbufE = String.new(4096);
      Int rsz = Int.new();
      copyData(outw, rwbufE, rsz);
   }
   
   readBuffer() String {
      return(readBuffer(String.new(blockSize)));
   }
   
   readBuffer(String builder) String {
      Int at = 0;
      Int nowAt = Int.new();
      readIntoBuffer(builder, at, nowAt);
      while (nowAt > at) {
		    at.setValue(nowAt);
		    if (builder.capacity - at < 2) {
          Int nsize = ((at + blockSize + 16) * 3) / 2;
			    builder.capacitySet(nsize);
		    }
        readIntoBuffer(builder, at, nowAt);
      }
      return(builder);
   }
   
   readBufferLine() String {
      return(readBufferLine(String.new()));
   }
   
   readBufferLine(String builder) String {
      //handles both cr an crlf cases, since it looks for lf as the end, it finds
      //the end either way :-) it includes the newline (meaning, it includes 
      //the cr and the lf if both are present, only the lf if the lf is present)
      String crb = String.new().addValue(Text:Strings.new().newline);
      String rbuf = String.new(1);
      Int got = readIntoBuffer(rbuf);
      if (got == 0) {
         builder = null;
         return(builder);
      }
      builder += rbuf;
      while (got != 0) {
         if (rbuf == crb) {
            return(builder);
         }
         got = readIntoBuffer(rbuf);
         builder += rbuf;
      }
      return(builder);
   }
   
   readString() String {
      return(readBuffer());
   }
   
   readString(String builder) String {
      return(readBuffer(builder));
   }
   
   readStringClose() String {
    String res = readString();
    close();
    return(res);
   }

}

class IO:File:Writer(IO:Writer) {
    
    new(fpath) self {
      fields {
         IO:File:Path path;
      }
      isClosed = true;
      self.path = IO:File:Path.new(fpath);
   }
   
   openTruncate() {
      open("wb");
   }
   
   openAppend() {
      open("ab");
   }
   
   open() {
      open("wb");
   }
   
   open(String mode) {
   emit(c) {
      """
/*-attr- -dec-*/
void** bevl_fhpatha;
void** bevl_mode;
      """
      }
      String fhpatha = path.toString();
      Bool _isClosed;
      emit(c) {
      """
         bevl_fhpatha = $fhpatha&*;
         bevl_mode = $mode&*;
         if (((FILE*) bevs[bercps]) == NULL) {
            bevs[bercps] = (void*) fopen(((char*) bevl_fhpatha[bercps]), ((char*) bevl_mode[bercps]));
         }
         if (bevs[bercps] == NULL) {
            $_isClosed=* berv_sts->bool_True;
         } else {
            $_isClosed=* berv_sts->bool_False;
         }
      """
      }
      ifEmit(jv,cs,js) {
        if (def(mode) && mode == "ab") {
            Bool append = true;
        } else {
            append = false;
        }
      }
      emit(jv) {
      """
      if (this.bevi_os == null) {
        java.io.File bevls_f = new java.io.File(new String(bevp_path.bevp_path.bevi_bytes, 0, bevp_path.bevp_path.bevp_size.bevi_int, "UTF-8"));
        this.bevi_os = new java.io.FileOutputStream(bevls_f, bevl_append.bevi_bool);
      }
      bevp_isClosed = be.BECS_Runtime.boolFalse;
      """
      }
      emit(cs) {
      """
      if (this.bevi_os == null) {
        string bevls_spath = System.Text.Encoding.UTF8.GetString(bevp_path.bevp_path.bevi_bytes, 0, bevp_path.bevp_path.bevp_size.bevi_int);
        if (bevl_append.bevi_bool) {
            this.bevi_os = new FileStream(bevls_spath, FileMode.Append, FileAccess.Write, FileShare.Write, 64);
        } else {
            this.bevi_os = new FileStream(bevls_spath, FileMode.Create, FileAccess.Write, FileShare.Write, 64);
        }
      }
      bevp_isClosed = be.BECS_Runtime.boolFalse;
      """
      }
      emit(cc) {
      """
         if (bevi_os == NULL) {
           bevi_os = fopen(bevp_path->bevp_path->bems_toCcString().c_str(), beva_mode->bems_toCcString().c_str());
           //cout << "opened f" << endl;
         }
      """
      }
      emit(js) {
      """
      if (this.bevi_os == null) {
        var bevls_spath = this.bems_stringToJsString_1(this.bevp_path.bevp_path);
        if (bevl_append.bevi_bool) {
            this.bevi_os = fs.openSync(bevls_spath, 'a');
        } else {
            this.bevi_os = fs.openSync(bevls_spath, 'w');
        }
      }
      this.bevp_isClosed = be_BECS_Runtime.prototype.boolFalse;
      """
      }
      ifEmit(c) {
          isClosed = _isClosed;
          if (isClosed) {
             throw(System:Exception.new("File " + fhpatha + " could not be opened for write."));
          }
      }
   }
   
}

class IO:Writer {

   emit(c) {
   """
/*-attr- -firstSlotNative-*/
   """
   }
   
   emit(jv) {
   """
   
    public java.io.OutputStream bevi_os;
    
   """
   }
   
   emit(cs) {
   """
   
    public System.IO.Stream bevi_os;
    
   """
   }
   
   emit(cc_classHead) {
   """
    FILE* bevi_os = NULL;
   """
   }
   
   new() self {
      
      fields {
         any vfile;
         Bool isClosed = true;
      }
      
   }
   
   vfileGet() { }
   
   vfileSet(vfile) { }
   
   //ONLY for use where an external functionality (in an emit lang...) provides the stream, this is for convenience
   extOpen() {
      isClosed = false;
   }
   
   close() {
      emit(c) {
      """
         if (((FILE*) bevs[bercps]) != NULL) {
            fflush(((FILE*) bevs[bercps]));
            fclose(((FILE*) bevs[bercps]));
            bevs[bercps] = (void*) NULL;
         }
      """
      }
      emit(jv) {
      """
      if (this.bevi_os != null) {
        this.bevi_os.close();
        this.bevi_os = null;
      }
      """
      }
      emit(cs) {
      """
      if (this.bevi_os != null) {
        this.bevi_os.Flush();
        this.bevi_os.Dispose();
        this.bevi_os = null;
      }
      """
      }
      emit(cc) {
      """
        if (bevi_os != NULL) {
            fflush(bevi_os);
            fclose(bevi_os);
            bevi_os = NULL;
         }
      """
      }
      emit(js) {
      """
      if (this.bevi_os != null) {
        fs.closeSync(this.bevi_os);
        this.bevi_os = null;
      }
      """
      }
      isClosed = true;
   }
   
   write(String stri) {
      emit(jv) {
      """
      this.bevi_os.write(beva_stri.bevi_bytes, 0, beva_stri.bevp_size.bevi_int);
      """
      }
      emit(cs) {
      """
      this.bevi_os.Write(beva_stri.bevi_bytes, 0, beva_stri.bevp_size.bevi_int);
      this.bevi_os.Flush();
      """
      }
      emit(cc) {
      """
      fwrite(&(beva_stri->bevi_bytes)[0], sizeof(unsigned char), beva_stri->bevp_size->bevi_int, bevi_os);
      """
      }
      emit(js) {
      """
      fs.writeSync(this.bevi_os,new Buffer(beva_stri.bevi_bytes), 0, beva_stri.bevp_size.bevi_int);
      """
      }
   }
   
   writeStringClose(String stri) {
     write(stri);
     close();
   }
   
}

final class IO:File:NamedReaders {
   create() self { }
   
   default() self {
      
      fields {
         IO:File:Reader input;
      }
      self.input = IO:File:Reader:Stdin.new();
   }
   
   inputSet(IO:File:Reader _input) {
      input = _input;
      if (input.isClosed) {
         input.open();
      }
   }
   
}

final class IO:File:NamedWriters {
   create() self { }
   default() self {
      
      fields {
         IO:File:Writer output;
         IO:File:Writer error;
         IO:File:Writer exceptionConsole;
      }
      self.output = IO:File:Writer:Stdout.new();
      self.error = IO:File:Writer:Stderr.new();
      self.exceptionConsole = IO:File:Writer:NoOutput.new();
   }
   
   outputSet(IO:File:Writer _output) {
      output = _output;
      if (output.isClosed) {
         output.open();
      }
   }
   
   errorSet(IO:File:Writer _error) {
      error = _error;
      if (error.isClosed) {
         error.open();
      }
   }
   
   exceptionConsoleSet(IO:File:Writer _exceptionConsole) {
      exceptionConsole = _exceptionConsole;
      if (exceptionConsole.isClosed) {
         exceptionConsole.open();
      }
   }
}

final class IO:File:Writer:Stdout(IO:File:Writer) {

   emit(c) {
   """
/*-attr- -firstSlotNative-*/
   """
   }
   new() self { }
   default() self {
      
      emit(c) {
      """
         bevs[bercps] = (void*) stdout;
      """
      }
      isClosed = false;
   }
   
   create() self { }
   
   isClosedGet() Bool { return(false); }
   
   isClosedSet(_isClosed) this { }
   
   open() {   }
   
   close() {   }
}

final class IO:File:Writer:Stderr(IO:File:Writer) {

   emit(c) {
   """
/*-attr- -firstSlotNative-*/
   """
   }
   new() self { }
   default() self {
      
      emit(c) {
      """
         bevs[bercps] = (void*) stderr;
      """
      }
      isClosed = false;
   }
   
   create() self { }
   
   isClosedGet() Bool { return(false); }
   
   isClosedSet(_isClosed) this { }
   
   open() {   }
   
   close() {   }
}

final class IO:File:Reader:Stdin(IO:File:Reader) {

   emit(c) {
   """
/*-attr- -firstSlotNative-*/
   """
   }
   new() self { }
   default() self {
      
      emit(c) {
      """
         bevs[bercps] = (void*) stdin;
      """
      }
      isClosed = false;
      blockSize = 1024;
   }
   
   create() self { }
   
   isClosedGet() Bool { return(false); }
   
   isClosedSet(_isClosed) this { }
   
   open() {   }
   
   close() {   }
}

final class IO:File:Writer:NoOutput(IO:File:Writer) {

   emit(c) {
   """
/*-attr- -firstSlotNative-*/
   """
   }
   
   default() self {
      
      isClosed = false;
   }
   
   writeIfPossible(str) { }
   
   write(String str) { }
   
   create() self { }
   
   isClosedGet() Bool { return(false); }
   
   isClosedSet(_isClosed) this { }
   
   open() {   }
   
   close() {   }
}

final class IO:File:Reader:Command(IO:File:Reader) {

   emit(c) {
   """
/*-attr- -firstSlotNative-*/
   """
   }
   
   new() self {
      super.new();
   }
   
   new(_command) self {
      commandNew(_command);
   }
   
   commandNew(String _command) self {
      super.new();
      fields {
         String command = _command;
      }
   }
   
   open() {
   emit(c) {
      """
/*-attr- -dec-*/
void** bevl_command;
      """
      }
      String _command = command;
      Bool _isClosed;
      emit(c) {
      """
         bevl_command = $_command&*;
         if (((FILE*) bevs[bercps]) == NULL) {
            bevs[bercps] = (void*) popen(((char*) bevl_command[bercps]), "r");
         }
         if (bevs[bercps] == NULL) {
            $_isClosed=* berv_sts->bool_True;
         } else {
            $_isClosed=* berv_sts->bool_False;
         }
      """
      }
      isClosed = _isClosed;
      if (isClosed) {
         throw(System:Exception.new("Command " + command + " could not be opened for read."));
      }
   }
   
   close() {
      emit(c) {
      """
         if (((FILE*) bevs[bercps]) != NULL) {
            pclose(((FILE*) bevs[bercps]));
            bevs[bercps] = (void*) NULL;
         }
      """
      }
      isClosed = true;
   }
   
}

