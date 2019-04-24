// Copyright 2006 Craig Welch
//
// Licensed under the MIT license. See LICENSE.txt file in the project root 
// for full license information.

use IO:File;
use Text:String;
use Logic:Bool;
use Math:Int;
use Container:Set;
use Container:Stack;

emit(c) {
"""
#include <windows.h>
#include <utime.h>
"""
}

emit(cs) {
    """
using System;
using System.IO;
using System.Collections.Generic;
    """
}

emit(js) {
"""
var fs = require('fs');
"""
}

local class File {

   new() self {
      
      fields {
         IO:File:Path path;
         any reader;
         any writer;
      }
      
   }
   
   new(fpath) self {
      self.path = IO:File:Path.new(fpath);
   }
   
   apNew(fpath) self {
      self.path = IO:File:Path.apNew(fpath);
   }
   
   pathNew(IO:File:Path _path) self {
      self.path = _path;
   }
   
   readerGet() {
      if (undef(reader)) {
         reader = IO:File:Reader.new(path.toString());
      }
      return(reader);
   }
   
   writerGet() {
      if (undef(writer)) {
         writer = IO:File:Writer.new(path.toString());
      }
      return(writer);
   }
   
   delete() {
      emit(c) {
      """
/*-attr- -dec-*/
void** bevl_llpath;
      """
      }
      ifEmit(c) {
        llpath = String.new(); //to prime String
        any llpath = path.toString();
      }
      if (self.exists) {
         emit(c) {
         """
         bevl_llpath = $llpath&*;
         DeleteFile(((char*) bevl_llpath[bercps]));
         """
         }
         emit(jv) {
         """
         java.io.File bevls_f = new java.io.File(new String(bevp_path.bevp_path.bevi_bytes, 0, bevp_path.bevp_path.bevp_size.bevi_int, "UTF-8"));
         bevls_f.delete();
         """
         }
         emit(cs) {
          """
          string bevls_path = System.Text.Encoding.UTF8.GetString(bevp_path.bevp_path.bevi_bytes, 0, bevp_path.bevp_path.bevp_size.bevi_int);
          File.Delete(bevls_path);
          """
          }
          emit(cc) {
           """
           string path = bevp_path->bevp_path->bems_toCcString();
           struct stat buffer;   
           remove(path.c_str());
           """
           }
      }
   }
   
   copyFile(other) Bool {
      other.path.parent.file.makeDirs();
      IO:File:Writer outw = other.writer.open();
      IO:File:Reader inr = self.reader.open();
      inr.copyData(outw);
      inr.close();
      outw.close();
      return(true);
   }
   
   //because I'm constantly forgetting which it is
   mkdirs() {
     makeDirs();
   }
   mkdir() {
     makeDirs();
   }
   
   makeDirs() {
      emit(c) {
      """
/*-attr- -dec-*/
char* bevl_frc;
void** bevl_frv;
      """
      }
      String frs = path.toString();
      Bool r = false;
      Bool t = true;
      any strn = Text:Strings.new();
      if ((path.toString() != strn.empty) && (self.exists!)) {
         any parentpath = path.parent;
         if (path == parentpath) {
            //We're at the top and it doesn't exist
            return(self);
         }
         parentpath.file.makeDirs();
         emit(c) {
         """
         bevl_frv = $frs&*;
         bevl_frc = (char*) bevl_frv[bercps];
         if (CreateDirectory(bevl_frc, NULL)) {
            $t=* $strn*;
         }
         """
         }
         emit(jv) {
         """
         java.io.File bevls_f = new java.io.File(new String(bevp_path.bevp_path.bevi_bytes, 0, bevp_path.bevp_path.bevp_size.bevi_int, "UTF-8"));
         bevls_f.mkdir();
         """
         }
         emit(cs) {
         """
         Directory.CreateDirectory(
         System.Text.Encoding.UTF8.GetString(bevp_path.bevp_path.bevi_bytes, 0, bevp_path.bevp_path.bevp_size.bevi_int)
         );
         """
         }
         emit(cc) {
         """
         string path = bevp_path->bevp_path->bems_toCcString();
         mkdir(path.c_str(), 0775);
         """
         }
         emit(js) {
         """
         var bevls_path = this.bems_stringToJsString_1(this.bevp_path.bevp_path);
         if (!fs.existsSync(bevls_path)) {
            fs.mkdirSync(bevls_path);
         }
         """
         }
         
      }
   }
   
   isDirectoryGet() Bool {
      return(isDirGet());
   }
   
   lastUpdatedGet() Time:Interval {
   
     auto lu = Time:Interval.new();
     
     emit(cs) {
        """
        string bevls_path = System.Text.Encoding.UTF8.GetString(bevp_path.bevp_path.bevi_bytes, 0, bevp_path.bevp_path.bevp_size.bevi_int);
        long ctm = (long) (File.GetLastWriteTimeUtc(bevls_path) - BEC_2_4_8_TimeInterval.epochStart).TotalMilliseconds;
        bevl_lu.bevp_secs.bevi_int = (int) (ctm / 1000);
        bevl_lu.bevp_millis.bevi_int = (int) (ctm % 1000);
        """
        }
        
      emit(jv) {
        """
        java.io.File bevls_f = new java.io.File(new String(bevp_path.bevp_path.bevi_bytes, 0, bevp_path.bevp_path.bevp_size.bevi_int, "UTF-8"));
        long ctm = bevls_f.lastModified();
        bevl_lu.bevp_secs.bevi_int = (int) (ctm / 1000);
        bevl_lu.bevp_millis.bevi_int = (int) (ctm % 1000);
        """
        }
      return(lu);
   
   }
   
   lastUpdatedSet(Time:Interval lu) {
     
      emit(cs) {
        """
        string bevls_path = System.Text.Encoding.UTF8.GetString(bevp_path.bevp_path.bevi_bytes, 0, bevp_path.bevp_path.bevp_size.bevi_int);
        DateTime ts = new DateTime(1970, 1, 1, 0, 0, 0, DateTimeKind.Utc);
        ts = ts.AddSeconds(beva_lu.bevp_secs.bevi_int);
        ts = ts.AddMilliseconds(beva_lu.bevp_millis.bevi_int);
        File.SetLastWriteTimeUtc(bevls_path, ts);
        """
        }
    
        emit(jv) {
        """
        java.io.File bevls_f = new java.io.File(new String(bevp_path.bevp_path.bevi_bytes, 0, bevp_path.bevp_path.bevp_size.bevi_int, "UTF-8"));
        long ts = ((long)(beva_lu.bevp_secs.bevi_int)) * 1000L;
        ts = ts + beva_lu.bevp_millis.bevi_int;
        bevls_f.setLastModified(ts);
        """
        }
   
   }
   
   isDirGet() Bool {
   emit(c) {
      """
/*-attr- -dec-*/
struct stat sa;
void** bevl_spa;
      """
      }
      any spa;
      Bool result = false;
      spa = path.toString();
      if (self.exists) {
         emit(c) {
         """
         bevl_spa = $spa&*;
         if (stat(((char*) bevl_spa[bercps]), &sa) == 0 && sa.st_mode & S_IFDIR) {
            $result=* berv_sts->bool_True;
         }
         """
         }
         emit(jv) {
          """
          java.io.File bevls_f = new java.io.File(new String(bevp_path.bevp_path.bevi_bytes, 0, bevp_path.bevp_path.bevp_size.bevi_int, "UTF-8"));
          if (bevls_f.isDirectory()) {
            bevl_result = be.BECS_Runtime.boolTrue;
          }
          """
          }
          emit(cs) {
          """
          string bevls_path = System.Text.Encoding.UTF8.GetString(bevp_path.bevp_path.bevi_bytes, 0, bevp_path.bevp_path.bevp_size.bevi_int);
          if (Directory.Exists(bevls_path)) {
            bevl_result = be.BECS_Runtime.boolTrue;
          }
          """
          }
         emit(js) {
         """
         var bevls_path = this.bems_stringToJsString_1(this.bevp_path.bevp_path);
         if (fs.lstatSync(bevls_path).isDirectory()) {
            bevl_result = be_BECS_Runtime.prototype.boolTrue;
          }
         """
         }
         emit(cc) {
         """
         string path = bevp_path->bevp_path->bems_toCcString();
         struct stat buffer; 
         if (stat(path.c_str(), &buffer) == 0 && buffer.st_mode & S_IFDIR) {
            bevl_result = BECS_Runtime::boolTrue;
         }
         """
         }
      }
      return(result);
   }
   
   isFileGet() Bool {
   emit(c) {
      """
/*-attr- -dec-*/
struct stat sa;
void** bevl_spa;
      """
      }
      any spa;
      Bool result = false;
      spa = path.toString();
      if (self.exists) {
         emit(c) {
         """
         bevl_spa = $spa&*;
         if (stat(((char*) bevl_spa[bercps]), &sa) == 0 && sa.st_mode & S_IFREG) {
            $result=* berv_sts->bool_True;
         }
         """
         }
         emit(jv) {
          """
          java.io.File bevls_f = new java.io.File(new String(bevp_path.bevp_path.bevi_bytes, 0, bevp_path.bevp_path.bevp_size.bevi_int, "UTF-8"));
          if (bevls_f.isFile()) {
            bevl_result = be.BECS_Runtime.boolTrue;
          }
          """
          }
          emit(cs) {
          """
          string bevls_path = System.Text.Encoding.UTF8.GetString(bevp_path.bevp_path.bevi_bytes, 0, bevp_path.bevp_path.bevp_size.bevi_int);
          if (File.Exists(bevls_path)) {
            bevl_result = be.BECS_Runtime.boolTrue;
          }
          """
          }
         emit(js) {
         """
         var bevls_path = this.bems_stringToJsString_1(this.bevp_path.bevp_path);
         if (fs.lstatSync(bevls_path).isFile()) {
            bevl_result = be_BECS_Runtime.prototype.boolTrue;
          }
         """
         }
         emit(cc) {
         """
         string path = bevp_path->bevp_path->bems_toCcString();
         struct stat buffer; 
         if (stat(path.c_str(), &buffer) == 0 && buffer.st_mode & S_IFREG) {
            bevl_result = BECS_Runtime::boolTrue;
         }
         """
         }
      }
      return(result);
   }
   
   makeFile() {
      self.writer.open();
      self.writer.close();
   }
   
   contentsGet() String {
      if (self.exists!) {
        return(null);
      }
      return(self.contentsNoCheck);
   }
   
   contentsNoCheckGet() String {
      any r = self.reader;
      r.open();
      String res = r.readString();
      r.close();
      return(res);
   }
   
   contentsSet(String contents) self {
      if (self.path.parent.file.exists!) {
         self.path.parent.file.makeDirs();
      }
      self.contentsNoCheck = contents;
   }
   
   contentsNoCheckSet(String contents) self {
      any w = self.writer;
      w.open();
      w.write(contents);
      w.close();
   }
   
   sizeGet() Int {
   
    Int sz = Int.new();
    emit(jv) {
    """
    java.io.File bevls_f = new java.io.File(new String(bevp_path.bevp_path.bevi_bytes, 0, bevp_path.bevp_path.bevp_size.bevi_int, "UTF-8"));
    bevl_sz.bevi_int = (int) bevls_f.length();
    """
    }
    return(sz);
   
   }
   
   existsGet() Bool {
      emit(c) {
      """
/*-attr- -dec-*/
int i;
void** bevl_mpath;
      """
      }
      Bool tvala = false;
      any mpath = path.toString();
      emit(c) {
      """
      bevl_mpath = $mpath&*;
      i = access(((char*) bevl_mpath[bercps]), F_OK);
      if (i == 0) {
         $tvala=* berv_sts->bool_True;
      }
      """
      }
      emit(jv) {
      """
      java.io.File bevls_f = new java.io.File(new String(bevp_path.bevp_path.bevi_bytes, 0, bevp_path.bevp_path.bevp_size.bevi_int, "UTF-8"));
      if (bevls_f.exists()) {
        bevl_tvala = be.BECS_Runtime.boolTrue;
      }
      """
      }
      emit(cs) {
      """
      string bevls_path = System.Text.Encoding.UTF8.GetString(bevp_path.bevp_path.bevi_bytes, 0, bevp_path.bevp_path.bevp_size.bevi_int);
      if (File.Exists(bevls_path) || Directory.Exists(bevls_path)) {
        bevl_tvala = be.BECS_Runtime.boolTrue;
      }
      """
      }
     emit(js) {
     """
     var bevls_path = this.bems_stringToJsString_1(this.bevp_path.bevp_path);
     if (fs.existsSync(bevls_path)) {
        bevl_tvala = be_BECS_Runtime.prototype.boolTrue;
     }
     """
     }
     emit(cc) {
     """
     string path = bevp_path->bevp_path->bems_toCcString();
     struct stat buffer;   
     if (stat (path.c_str(), &buffer) == 0) {
       bevl_tvala = BECS_Runtime::boolTrue;
     }
     """
     }
      return(tvala);
   }
   
   absPathGet() IO:File:Path {
      //jv toRealPath, cs (new Uri(absolute_path)).LocalPath or Path.GetFullPath(absolute_path)
      //cs except on not exists to keep behavior
      IO:File:Path absp;
      String abstr;
      ifNotEmit(platDroid) {
        emit(jv) {
        """
        java.io.File bevls_f = new java.io.File(new String(bevp_path.bevp_path.bevi_bytes, 0, bevp_path.bevp_path.bevp_size.bevi_int, "UTF-8"));
        //bevl_abstr = new $class/Text:String$(bevls_f.toPath().toRealPath().toString());
        bevl_abstr = new $class/Text:String$(bevls_f.getCanonicalPath());
        """
        }
      }
      ifEmit(cs) {
        abstr = path.path;
      }
      absp = IO:File:Path.apNew(abstr);
      return(absp);
   }
   
   close() {
      if (def(reader)) {
         reader.close();
      }
      if (def(writer)) {
         writer.close();
      }
   }
   
   iteratorGet() {
      return(IO:File:DirectoryIterator.new(self));
   }
   
}

use final class System:Environment {

    getVariable(String name) String {
        String value;
        emit(cs) {
        """
            string value = Environment.GetEnvironmentVariable(beva_name.bems_toCsString());
            if (value != null) {
                bevl_value = new $class/Text:String$(System.Text.Encoding.UTF8.GetBytes(value));
            }
        """
        }
        emit(jv) {
        """
            String value = System.getenv().get(beva_name.bems_toJvString());
            if (value != null) {
                bevl_value = new $class/Text:String$(value);
            }
        """
        }
        return(value);
    }
    
    getVar(String name) String {
      return(getVariable(name));
    }

}

use IO:File:DirectoryIterator;

final class DirectoryIterator {

   emit(cs) {
   """
   
    public IEnumerator<string> bevi_dir;
    
   """
   }
   
   emit(jv) {
   """
   java.io.File[] bevi_dir;
   int bevi_pos = 0;
   """
   }
   
   emit(cc_classHead) {
   """
   DIR* bevi_dir;
   """
   }
   
   new() self {
   
      fields {
         File dir;
         Bool opened = false;
         Bool closed = false;
         File current = null;
      }
      
   }
   
   new(File _dir) self {
      new();
      dir = _dir;
   }
   
   open() self {
      
      String path;
      String newName;
      
      if (def(dir)) {
         path = dir.path.toString();
         //path.print();
      } else {
         throw(System:Exception.new("Directory not defined during open"));
      }
      
      if (closed) {
         //all used up, currently, not reusable
         throw(System:Exception.new("Attempting to re-open a closed IO:File:Iterator is not supported"));
      }
      if (opened) {
         throw(System:Exception.new("Only open IO:File:Iterator once"));
      }
      emit(cs) {
      """
      bevi_dir = Directory.EnumerateFileSystemEntries(bevl_path.bems_toCsString(), "*", SearchOption.TopDirectoryOnly).GetEnumerator();
      if (bevi_dir.MoveNext()) {
        bevl_newName = new $class/Text:String$(bevi_dir.Current);
      }
      """
      }
      emit(jv) {
      """
      java.io.File bevls_f = new java.io.File(bevl_path.bems_toJvString());
      bevi_dir = bevls_f.listFiles();
      bevi_pos = 0;
      if (bevi_dir != null && bevi_dir.length > bevi_pos) {
        bevl_newName = new $class/Text:String$(bevi_dir[bevi_pos].getPath());
        bevi_pos++;
      }
      """
      }
      emit(cc) {
      """
      string path = bevl_path->bems_toCcString();
      bevi_dir = opendir(path.c_str());
      struct dirent* buffer;  
      buffer = readdir(bevi_dir); 
      if (buffer != NULL) {
        string ccnm(buffer->d_name);
        bevl_newName = new $class/Text:String$(ccnm);
      }
      """
      }
      if (def(newName)) {
         //("open succeeded " + dir.path + " " + newName).print();
         opened = true;
         current = File.apNew(newName);
      } else {
         //("open failed " + dir.path).print();
         opened = false;
         closed = true;
      }
   }
   
   hasNextGet() Bool {
      if (closed) { return(false); }
      if (opened!) { open(); }
      return(def(current));
   }
   
   nextGet() File {
      if (closed) { return(null); }
      if (opened!) { open(); }
      File toRet = current;
      advance();
      return(toRet);
   }
   
   advance() self {
   
      String newName;
      
      if (closed) { return(self); }
      if (opened!) { return(self); }
      if (undef(current)) { return(self); }
      emit(cs) {
      """
      if (bevi_dir.MoveNext()) {
        bevl_newName = new $class/Text:String$(bevi_dir.Current);
      }
      """
      }
      emit(jv) {
      """
      if (bevi_dir != null && bevi_dir.length > bevi_pos) {
        bevl_newName = new $class/Text:String$(bevi_dir[bevi_pos].getPath());
        bevi_pos++;
      }
      """
      }
      emit(cc) {
      """
      struct dirent* buffer; 
      if (bevi_dir != NULL) { 
        buffer = readdir(bevi_dir); 
        if (buffer != NULL) {
          string ccnm(buffer->d_name);
          bevl_newName = new $class/Text:String$(ccnm);
        }
      }
      """
      }
      if (def(newName)) {
         opened = true;
         current = File.apNew(newName);
      } else {
         opened = false;
         closed = true;
         current = null;
      }
   }
   
   close() self {
      emit(cs) {
      """
      bevi_dir.Dispose();
      bevi_dir = null;
      """
      }
      emit(jv) {
      """
      bevi_dir = null;
      bevi_pos = 0;
      """
      }
      emit(cc) {
      """
      closedir(bevi_dir);
      bevi_dir = NULL;
      """
      }
   }

}

use Net:Socket:Listener;

emit(cs) {
"""
using System;
using System.Net;
using System.Net.Sockets;
"""
}
emit(jv) {
"""
import java.net.*;
"""
}
class Listener {

  emit(cs) {
  """
  public Socket bevi_listener;
  """
  }
  emit(jv) {
  """
  public ServerSocket bevi_listener;
  """
  }

  new(String _address, Int _port) self {

    fields {
      String address = _address;
      Int port = _port;
      Int backlog = 25;
    }

  }
  
  new(Int _port) self {

    address = "0.0.0.0";
    port = _port;
    backlog = 25;

  }

  bind() self {
    emit(jv) {
    """
    bevi_listener = new ServerSocket(bevp_port.bevi_int, bevp_backlog.bevi_int, InetAddress.getByName(bevp_address.bems_toJvString()));
    """
    }
    emit(cs) {
    """
    IPHostEntry ipHostInfo = Dns.Resolve(bevp_address.bems_toCsString());
    IPAddress ipAddress = ipHostInfo.AddressList[0];
    IPEndPoint localEndPoint = new IPEndPoint(ipAddress, bevp_port.bevi_int);

    bevi_listener = new Socket(AddressFamily.InterNetwork,
        SocketType.Stream, ProtocolType.Tcp );
    bevi_listener.Bind(localEndPoint);
    bevi_listener.Listen(bevp_backlog.bevi_int);
    """
    }
  }
  
  accept() Socket {
    Socket s = Socket.new();
    emit(jv) {
    """
    bevl_s.bevi_socket = bevi_listener.accept();
    """
    }
    emit(cs) {
    """
    bevl_s.bevi_socket = bevi_listener.Accept();
    """
    }
    return(s);
  }

}

use Net:Socket;

class Socket {

  emit(cs) {
  """
  public Socket bevi_socket;
  """
  }
  emit(jv) {
  """
  public Socket bevi_socket;
  """
  }
  
  readerGet() SocketReader {
    SocketReader sr = SocketReader.new();
    emit(jv) {
    """
    bevl_sr.bevi_is = bevi_socket.getInputStream();
    """
    }
    emit(cs) {
    """
    bevl_sr.bevi_is = new NetworkStream(bevi_socket);
    """
    }
    sr.extOpen();
    return(sr);
  }
  
  writerGet() SocketWriter {
    SocketWriter sw = SocketWriter.new();
    emit(jv) {
    """
    bevl_sw.bevi_os = bevi_socket.getOutputStream();
    """
    }
    emit(cs) {
    """
    bevl_sw.bevi_os = new NetworkStream(bevi_socket);
    """
    }
    sw.extOpen();
    return(sw);
  }
  
  new(String host, Int port) self {
  
    emit(jv) {
    """
    bevi_socket = new Socket(beva_host.bems_toJvString(), beva_port.bevi_int);
    """
    }
    
    emit(cs) {
    """
    IPHostEntry ipHostInfo = Dns.Resolve(beva_host.bems_toCsString());
    IPAddress ipAddress = ipHostInfo.AddressList[0];
    IPEndPoint remoteEP = new IPEndPoint(ipAddress,beva_port.bevi_int);

    bevi_socket = new Socket(AddressFamily.InterNetwork, 
        SocketType.Stream, ProtocolType.Tcp );
    bevi_socket.Connect(remoteEP);
    """
    }
  
  }

}

use Net:Socket:Reader as SocketReader;

class SocketReader(IO:Reader) {

}

use Net:Socket:Writer as SocketWriter;

class SocketWriter(IO:Writer) {

}

