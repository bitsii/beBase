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
		properties {
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

class File:Reader(IO:Reader) {
   
   new(fpath) self {
      new();
      blockSize = 1024;//why?
      properties {
         File:Path path;
      }
      self.path = File:Path.new(fpath);
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
      bevp_isClosed = abe.BELS_Base.BECS_Runtime.boolFalse;
      """
      }
      emit(cs) {
      """
      if (this.bevi_is == null) {
        string bevls_spath = System.Text.Encoding.UTF8.GetString(bevp_path.bevp_path.bevi_bytes, 0, bevp_path.bevp_path.bevp_size.bevi_int);
        this.bevi_is = new FileStream(bevls_spath, FileMode.Open);
      }
      bevp_isClosed = abe.BELS_Base.BECS_Runtime.boolFalse;
      """
      }
      emit(js) {
      """
      if (this.bevi_is == null) {
        var bevls_spath = this.bems_stringToJsString_1(this.bevp_path.bevp_path);
        this.bevi_is = fs.openSync(bevls_spath, 'r');
      }
      this.bevp_isClosed = abe_BELS_Base_BECS_Runtime.prototype.boolFalse;
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


    new() self {
      properties {
         var vfile;
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
		return(readIntoBuffer(readBuf, 0));
   }
   
   readIntoBuffer(String readBuf, Int at) Int {
   emit(c) {
      """
/*-attr- -dec-*/
BEINT at;
BEINT got;
BEINT* readsz;
BEINT blen;
char* buf;
      """
      }
      Int readsz;
      String intoi;
      Int bleni;
      if (isClosed) {
         throw(System:Exception.new("File is not open, read attempted."));
      }
      readsz = Int.new();
      intoi = readBuf;
      bleni = intoi.capacity;
      if (bleni <= at) {
         throw(System:Exception.new("Trying to begin read beyond buffer capacity"));
      }
      emit(c) {
      """
         at = *((BEINT*) ($at&* + bercps));
         got = 0;
         readsz = ((BEINT*) ($readsz&* + bercps));
         buf = (char*) $intoi&*[bercps];
         buf = buf + (at * sizeof(char));
         blen = *((BEINT*) ($bleni&* + bercps));
         if (!feof(((FILE*) bevs[bercps])) && at < blen) {
            got = fread(buf, 1, blen - at, ((FILE*) bevs[bercps]));
            at = at + got;
            buf = buf + (got * sizeof(char));
         }
         buf[0] = '\0'; /*not a bug, the actual buffer alloc is always one greater than the capacity*/
         *readsz = at;
      """
      }
      emit(jv) {
      """
      int bevls_read = this.bevi_is.read(beva_readBuf.bevi_bytes, beva_at.bevi_int, beva_readBuf.bevi_bytes.length - beva_at.bevi_int);
      if (bevls_read < 0) {
        bevls_read = 0;
      }
      bevl_readsz.bevi_int = bevls_read + beva_at.bevi_int;
      """
      }
      emit(cs) {
      """
      bevl_readsz.bevi_int = this.bevi_is.Read(beva_readBuf.bevi_bytes, beva_at.bevi_int, beva_readBuf.bevi_bytes.Length - beva_at.bevi_int) + beva_at.bevi_int;
      """
      }
      emit(js) {
      """
      var bevls_bytes = beva_readBuf.bevi_bytes;
      var bevls_at = beva_at.bevi_int;
      var bevls_rlen = beva_readBuf.bevp_capacity.bevi_int - bevls_at;
      var bevls_rbuf = new Buffer(bevls_rlen);
      bevl_readsz.bevi_int = fs.readSync(this.bevi_is, bevls_rbuf, 0, bevls_rlen) + bevls_at;
      //console.log("read this:");
      //console.log(bevls_rbuf.toString());
      for (var i = 0;i < bevls_rlen;i++) {
        bevls_bytes[i + bevls_at] = bevls_rbuf[i];
      }
      """
      }
      //("read " + readsz).print();
      intoi.size = readsz;//TODO setValue
      return(readsz);
   }
   
   readBuffer() String {
      return(readBuffer(String.new(blockSize)));
   }
   
   readBuffer(String builder) String {
      Int at = 0;
      Int nowAt = readIntoBuffer(builder, at);
      while (nowAt > at) {
		 at = nowAt;
		 if (builder.capacity - at < 2) {
			Int nsize = ((at + blockSize + 16) * 3) / 2;
			builder.capacitySet(nsize);
		 }
         nowAt = readIntoBuffer(builder, at);
      }
      return(builder);
   }
   
   altReadBuffer() String {
      String rbuf = String.new(blockSize);
      String builder = String.new();
      Int got = readIntoBuffer(rbuf);
      builder += rbuf;
      while (got != 0) {
         got = readIntoBuffer(rbuf);
         builder += rbuf;
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
      return(readBuffer(builder).copy());//TODO this is no longer a very useful pattern (extra copy)
   }

}

class File:Writer(IO:Writer) {
    
    new(fpath) self {
      properties {
         File:Path path;
      }
      isClosed = true;
      self.path = File:Path.new(fpath);
      emit(c) {
      """
         bevs[bercps] = (void*) NULL;
      """
      }
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
      bevp_isClosed = abe.BELS_Base.BECS_Runtime.boolFalse;
      """
      }
      emit(cs) {
      """
      if (this.bevi_os == null) {
        string bevls_spath = System.Text.Encoding.UTF8.GetString(bevp_path.bevp_path.bevi_bytes, 0, bevp_path.bevp_path.bevp_size.bevi_int);
        if (bevl_append.bevi_bool) {
            this.bevi_os = new FileStream(bevls_spath, FileMode.Append);
        } else {
            this.bevi_os = new FileStream(bevls_spath, FileMode.Create);
        }
      }
      bevp_isClosed = abe.BELS_Base.BECS_Runtime.boolFalse;
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
      this.bevp_isClosed = abe_BELS_Base_BECS_Runtime.prototype.boolFalse;
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
   
   new() self {
      
      properties {
         var vfile;
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
        this.bevi_os.Dispose();
        this.bevi_os = null;
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
   
   //TODO seems unused, dump it
   writeIfPossible(stri) {
   emit(c) {
      """
/*-attr- -dec-*/
BEINT blen;
BEINT at;
BEINT got;
char* buf;
void** bevl_intoi;
void** bevl_bleni;
void** bevl_toret;
      """
      }
      Int bleni;
      if (isClosed || undef(stri)) {
         return(self);
      }
      bleni = stri.size;
      System:Types types = System:Types.new();
      if ((stri.sameType(types.string)!) && (stri.sameType(types.byteBuffer)!)) {
         return(self);
      }
      emit(c) {
      """
         bevl_intoi = $stri&*;
         bevl_bleni = $bleni&*;
         blen = *((BEINT*) (bevl_bleni + bercps));
         at = 0;
         got = 0;
         buf = (char*) bevl_intoi[bercps];
         while (at < blen) {
            got = fwrite(buf, 1, blen - at, ((FILE*) bevs[bercps]));
            at = at + got;
            buf = buf + (got * sizeof(char));
         }
      """
      }
      return(self);
   }
   
   write(String stri) {
   emit(c) {
      """
/*-attr- -dec-*/
BEINT blen;
BEINT at;
BEINT got;
char* buf;
void** bevl_intoi;
void** bevl_bleni;
void** bevl_toret;
      """
      }
      Int bleni;
      var failed;
      if (isClosed) {
         throw(System:Exception.new("File is not open, write attempted."));
      }
      bleni = stri.size;
      emit(c) {
      """
         bevl_intoi = $stri&*;
         bevl_bleni = $bleni&*;
         blen = *((BEINT*) (bevl_bleni + bercps));
         at = 0;
         got = 0;
         buf = (char*) bevl_intoi[bercps];
         while (at < blen) {
            got = fwrite(buf, 1, blen - at, ((FILE*) bevs[bercps]));
            at = at + got;
            buf = buf + (got * sizeof(char));
            if (got == 0 && at < blen) {
               $failed=* $bleni*;
               break;
            }
         }
      """
      }
      emit(jv) {
      """
      this.bevi_os.write(beva_stri.bevi_bytes, 0, beva_stri.bevp_size.bevi_int);
      """
      }
      emit(cs) {
      """
      this.bevi_os.Write(beva_stri.bevi_bytes, 0, beva_stri.bevp_size.bevi_int);
      """
      }
      emit(js) {
      """
      fs.writeSync(this.bevi_os,new Buffer(beva_stri.bevi_bytes), 0, beva_stri.bevp_size.bevi_int);
      """
      }
      if (def(failed)) {
         throw(System:Exception.new("Write operation failed."));
      }
   }
   
}

final class File:NamedReaders {
   create() { }
   
   default() self {
      
      properties {
         File:Reader input;
      }
      self.input = File:Reader:Stdin.new();
   }
   
   inputSet(File:Reader _input) {
      input = _input;
      if (input.isClosed) {
         input.open();
      }
   }
   
}

final class File:NamedWriters {
   create() { }
   default() self {
      
      properties {
         File:Writer output;
         File:Writer error;
         File:Writer exceptionConsole;
      }
      self.output = File:Writer:Stdout.new();
      self.error = File:Writer:Stderr.new();
      self.exceptionConsole = File:Writer:NoOutput.new();
   }
   
   outputSet(File:Writer _output) {
      output = _output;
      if (output.isClosed) {
         output.open();
      }
   }
   
   errorSet(File:Writer _error) {
      error = _error;
      if (error.isClosed) {
         error.open();
      }
   }
   
   exceptionConsoleSet(File:Writer _exceptionConsole) {
      exceptionConsole = _exceptionConsole;
      if (exceptionConsole.isClosed) {
         exceptionConsole.open();
      }
   }
}

final class File:Writer:Stdout(File:Writer) {

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
   
   create() { }
   
   isClosedGet() Bool { return(false); }
   
   isClosedSet(_isClosed) { }
   
   open() {   }
   
   close() {   }
}

final class File:Writer:Stderr(File:Writer) {

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
   
   create() { }
   
   isClosedGet() Bool { return(false); }
   
   isClosedSet(_isClosed) { }
   
   open() {   }
   
   close() {   }
}

final class File:Reader:Stdin(File:Reader) {

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
   
   create() { }
   
   isClosedGet() Bool { return(false); }
   
   isClosedSet(_isClosed) { }
   
   open() {   }
   
   close() {   }
}

final class File:Writer:NoOutput(File:Writer) {

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
   
   create() { }
   
   isClosedGet() Bool { return(false); }
   
   isClosedSet(_isClosed) { }
   
   open() {   }
   
   close() {   }
}

final class File:Reader:Command(File:Reader) {

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
      properties {
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

