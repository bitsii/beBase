// Copyright 2006 The Bennt Authors. All rights reserved.
// Use of this source code is governed by the BSD-3-Clause
// license that can be found in the LICENSE file.

use Container:PropertyMap;
use System:Env;
use Container:Map;
use Text:String;
use Math:Int;
use IO:File;

class PropertyMap {
   
   new() self {
      
      fields {
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
   create() self { }
   
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
   
   workingDirectoryGet() IO:File:Path {
      return(IO:File:Path.apNew(self.cwd));
   }
   
}
