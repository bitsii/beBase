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

use Container:PropertyMap;
use System:Env;
use Container:Map;
use Text:String;
use Math:Int;
use IO:File;

class PropertyMap {
   
   new() self {
      
      properties {
         Map map = Map.new();
      }
      
   }
   
   set(String key, String value) {
      map.put(key, value);
   }
   
   get(String key) String {
      return(map.get(key));
   }
   
   getCached(String key) String {
      return(map.get(key));
   }
   
   unset(String key) {
      map.delete(key);
   }
   
   mapGet() Map { return(null); }
   mapSet(Map _map) { return(self); }
   
   load() { }
   
   iteratorGet() {
      return(map.iterator);
   }
   
   //special serialization, not # &
   
}

final class Env(PropertyMap) {

   new() self { }
   create() { }
   
   default() self {
      
      super.new();
   }
   
   set(String key, String value) {
      emit(c) {
      """
#ifdef BENM_ISNIX
      setenv((char*) $key&*[bercps], (char*) $value&*[bercps], 1);
#endif
      """
      }
      map.put(key, value);
   }
   
   get(String key) String {
   emit(c) {
      """
/*-attr- -dec-*/
char* bevl_rc;
      """
   }
      String toRet;
      emit(c) {
      """
      bevl_rc = getenv((char*) $key&*[bercps]);
      if (bevl_rc == NULL) {
         $toRet=* NULL;
      } else {
         $toRet=* BERF_String_For_Chars(berv_sts, bevl_rc);
      }
      """
      }
      if (def(toRet)) {
         map.put(key, toRet);
      }
      return(toRet);
   }
   
   getCached(String key) String {
      if (map.has(key)) { return(map.get(key)); }
      return(get(key));
   }
   
   unset(String key) {
      emit(c) {
      """
#ifdef BENM_ISNIX
      unsetenv((char*) $key&*[bercps]);
#endif
      """
      }
      map.delete(key);
   }
   
   load() {
   emit(c) {
   """
/*-attr- -dec-*/
int i;
   """
   }
      String next;
      emit(c) {
      """
      for (i = 0;environ[i] != NULL;i++) {
         $next=* BERF_String_For_Chars(berv_sts, environ[i]);
      """
      }
      Int p = next.find("=");
      String k = next.substring(0, p);
      String v = next.substring(p + 1, next.size);
      map.put(k, v);
      emit(c) {
      """
      }
      """
      }
   }
   
   iteratorGet() {
      load();
      return(map.iterator);
   }
   
   cwdGet() String {
      emit(c) {
      """
/*-attr- -dec-*/
char* twcwd;
      """
      }
      
      String cwd;
      
      emit(c) {
      """
#ifdef BENM_ISNIX
     twcwd = getcwd(NULL, 0);
#endif
#ifdef BENM_ISWIN
     twcwd = _getcwd(NULL, 0);
#endif
     if (twcwd != NULL) {
        $cwd=* BERF_String_For_Chars(berv_sts, twcwd);
     }
      """
      }
      return(cwd);
   }
   
   workingDirectoryGet() File:Path {
      return(File:Path.apNew(self.cwd));
   }
   
}
