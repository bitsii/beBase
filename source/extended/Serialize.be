/*
 * Copyright (c) 2006-2023, the Bennt Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

// Need to tokenize readers
// Serialize contents could be more efficient

use System:Serializer;
use Math:Int;
use Logic:Bool;
use Container:Stack;
use Container:LinkedList;
use Container:List;
use Container:Map;
use Container:Pair;
use Text:String;
use Text:String;
use Text:Tokenizer;
use Encode:Url;
use System:Class;
use IO:File;

use System:Serializer:Session;

class Session {
   new() self {
      fields {
         Map classTagMap = Map.new();
         Int classTagCount = 1;
         Int serialCount = 1; // Zero reserved for special cases
         Container:IdentityMap unique = Container:IdentityMap.new();
         any instWriter;
      }
   }
   
   new(_instWriter) Session {
      new();
      instWriter = _instWriter;
   }
}

final class Serializer {
   
   //"...Only alphanumerics [0-9a-zA-Z], the special characters "$-_.+!*'()," [not including the quotes - ed], and reserved characters used for their reserved purposes may be used unencoded within a URL."
   //beginGroupXdefineInstanceOrAddressInstanceXdioaiXdioaiXendGroup
   
   //| == group
   //# == defineReference
   //& == getReference
   //@ == constructString
   //; == nullMark
   //? == getClassTag
   //^ == shift
   //# == shift - defineClassTag
   //& == shift - unusedTag
   //@ == shift - unusedTag
   //; == shift - multi nullMark
   new() self {
      new("|", "#", "&", "@", ";", "?", "^", "#", ";", "|");
   }
   
   new(String _group, String _defineReference, String _getReference, String _constructString, String _nullMark, 
   String _getClassTag, String _shift, String _defineClassTag, String _multiNullMark, String _endGroup) Serializer {
      fields {
         String group = _group;
         String defineReference = _defineReference;
         String getReference = _getReference;
         String constructString = _constructString;
         String nullMark = _nullMark;
         String getClassTag = _getClassTag;
         String shift = _shift;
         String defineClassTag = _defineClassTag;
         String multiNullMark = _multiNullMark;
         String endGroup = _endGroup;
         Tokenizer toker = Tokenizer.new(
         group + defineReference + getReference + constructString + nullMark + defineClassTag + getClassTag + shift, 
			true);
         //Url encoder = Url.new();
         Encode:Hex encoder = Encode:Hex.new();
         Bool saveIdentity = true;
      }
   }
   
   serialize(instance) {
      Text:String res = Text:String.new();
      serialize(instance, res);
      return(res);
   }
   
   serialize(instance, instWriter) {
      if (def(instance)) {
         serializeI(instance, Session.new(instWriter));
      }
   }
   
   serializeI(instance, session) {
      defineInstance(instance, session);
      if (instance.can("serializeContentsGet", 0)) {
        Bool dosc = instance.serializeContents;
      } else {
        dosc = true;
      }
      if (dosc) {
         serializeC(instance, session);
      }
   }
   
   serializeC(instance, session) {
      any instWriter = session.instWriter;
      Int multiNull = 0;
      if (instance.can("serializationIteratorGet", 0)) {
        any iter = instance.serializationIterator;
      } else {
        iter = instance.iterator;
      }
      if (iter.hasNext) {
         instWriter.write(group);
         while (iter.hasNext) {
            any i = iter.next;
            if (undef(i)) {
               //instWriter.write(nullMark);
               multiNull = multiNull + 1;
            } else {
               // Complete multiNullMark
               if (multiNull == 1) {
                  instWriter.write(nullMark);
                  multiNull = 0;
               } elseIf (multiNull == 2) {
                  instWriter.write(nullMark);
                  instWriter.write(nullMark);
                  multiNull = 0;
               } elseIf (multiNull > 2) {
                  instWriter.write(shift);
                  instWriter.write(nullMark);
                  instWriter.write(multiNull.toString());
                  multiNull = 0;
               }
               if (saveIdentity!) {
                  instSerial = null;
               } else {
                  Int instSerial = session.unique.get(i);
               }
               if (undef(instSerial)) {
                  //First time
                  serializeI(i, session);
               } else {
                  //Seen it before
                  instWriter.write(getReference);
                  instWriter.write(instSerial.toString());
               }
            }
         }
         // Complete multiNullMark
         if (multiNull == 1) {
            instWriter.write(nullMark);
            multiNull = 0;
         } elseIf (multiNull == 2) {
            instWriter.write(nullMark);
            instWriter.write(nullMark);
            multiNull = 0;
         } elseIf (multiNull > 2) {
            instWriter.write(shift);
            instWriter.write(nullMark);
            instWriter.write(multiNull.toString());
            multiNull = 0;
         }
         instWriter.write(shift);
         instWriter.write(group);
      }
   }
   
   defineInstance(instance, Session session) {
      Int scount = session.serialCount;
      session.serialCount = scount + 1;
      
      any instWriter = session.instWriter;
      if (instance.can("deserializeClassNameGet", 0)) {
        String instClass = instance.deserializeClassName;
      } else {
         instClass = System:Classes.className(instance);
      }
      Int instClassTag = session.classTagMap.get(instClass);
      if (undef(instClassTag)) {
         instClassTag = session.classTagCount;
         String instClassTagStr = instClassTag.toString();
         session.classTagCount = instClassTag + 1;
         session.classTagMap.put(instClass, instClassTag);
         instWriter.write(shift);
         instWriter.write(defineClassTag);
         instWriter.write(instClass);
         instWriter.write(shift);
         instWriter.write(defineClassTag);
         instWriter.write(instClassTagStr);
      } else {
         instClassTagStr = instClassTag.toString();
      }
      if (saveIdentity) {
         instWriter.write(defineReference);
         instWriter.write(scount.toString());
      }

      if (instance.can("serializeToString", 0)) {
        String serializedString = instance.serializeToString();
      } else {
        serializedString = null;
      }
      if (def(serializedString) && serializedString != "") {
         instWriter.write(constructString);
         instWriter.write(encoder.encode(serializedString));
      }
      instWriter.write(getClassTag);
      instWriter.write(instClassTagStr);
      if (saveIdentity) {
         session.unique.put(instance, scount);
      }
   }
   
   deserialize(instReader) {
      Int state = 0;
      List postDeserialize = List.new();
      Session session = Session.new();
      Stack iterStack = Stack.new();
      if (System:Types.sameType(instReader, Text:Strings.empty)) {
         toks = toker.tokenize(instReader);
      } else {
         LinkedList toks = toker.tokenize(instReader.readString());
      }
      Map instances = Map.new();
      any rootInst;
      any groupInstIter;
      String defineClassTagName;
      for (any i = toks.linkedListIterator;i.hasNext;) {
         String token = i.next;
         if (state == 0) {
            if (token == defineReference) {
               state = 1;
            } elseIf (token == constructString) {
               state = 2;
            } elseIf (token == getClassTag) {
               state = 8;
            } elseIf (token == shift) {
               state = 1000;
            } elseIf (token == getReference) {
               state = 4;
            } elseIf (token == nullMark) {
               //Do group insert
               if (def(groupInstIter)) {
                  groupInstIter.next = null;
               }
            } elseIf (token == group) {
               //Begin a group
               if (def(inst)) {
                  if (def(groupInstIter)) {
                     iterStack.push(groupInstIter);
                  }
                  if (inst.can("serializationIteratorGet", 0)) {
                    groupInstIter = inst.serializationIterator;
                  } else {
                    groupInstIter = inst.iterator;
                  }
                  if (groupInstIter.can("postDeserialize", 0)) {
                     postDeserialize += groupInstIter;
                  }
               }
            }
         } elseIf (state == 1000) {
            // Shift
            if (token == defineClassTag) {
               if (undef(defineClassTagName)) {
                  state = 6;
               } else {
                  state = 7;
               }
            } elseIf (token == multiNullMark) {
               state = 9;
            } elseIf (token == group) {
               //End a group
               groupInstIter = iterStack.pop();
               state = 0;
            }
         } else {
            if (state == 1) {
               if (saveIdentity!) {
                  throw(System:Exception.new("Found define reference while saveIdentity is false during deserialization"));
               }
               Int instSerial = Int.new(token);
               state = 0;
            } elseIf (state == 2) {
               String instString = encoder.decode(token);
               state = 0;
            } elseIf (state == 8) {
               Int glassTagVal = Int.new(token);
               String klass = session.classTagMap.get(glassTagVal);
               any inst = System:Objects.createInstance(klass);
               if (inst.can("deserializeFromStringNew", 1)) {
                  inst = inst.deserializeFromStringNew(instString);
               }
               if (inst.can("deserializeFromString", 1)) {
                  inst = inst.deserializeFromString(instString);
               }
               if (undef(rootInst)) {
                  rootInst = inst;
               }
               if (saveIdentity) {
                  instances.put(instSerial, inst);
               }
               instString = null;
               //Do group insert
               if (def(groupInstIter)) {
                  groupInstIter.next = inst;
               }
               state = 0;
            } elseIf (state == 4) {
               if (saveIdentity!) {
                  throw(System:Exception.new("Found reference while saveIdentity is false during deserialization"));
               }
               instSerial = Int.new(token);
               inst = instances.get(instSerial);
               if (def(groupInstIter)) {
                  groupInstIter.next = inst;
               }
               state = 0;
            } elseIf (state == 6) {
               defineClassTagName = token;
               state = 0;
            } elseIf (state == 7) {
               //add to map
               Int defineClassTagValue = Int.new(token);
               session.classTagMap.put(defineClassTagValue, defineClassTagName);
               defineClassTagName = null;
               state = 0;
            } elseIf (state == 9) {
               //Do group insert
               if (def(groupInstIter)) {
                  Int multiNullCount = Int.new(token);
                  groupInstIter.skip(multiNullCount);
               }
               state = 0;
            }
         }
      }
      inst = null;
      for (groupInstIter in postDeserialize) {
         groupInstIter.postDeserialize();
      }
      return(rootInst);
   }
   
}

use Db:DirStoreString;

class DirStoreString(DirStore) {
    
    put(String id, object) {
      if (def(id) && id != "") {
         IO:File:Path p = getPath(id);
         if (def(p)) {
            p.file.contents = object.toString();
         }
      }
   }
   
   get(String id) {
      if (def(id) && id != "") {
         IO:File:Path p = getPath(id);
         if (def(p) && p.file.exists) {
            return(p.file.contents);
         }
      }
      return(null);
   }
   
}

use Db:DirStore;

class DirStore {
   
   new(String storageDir, _keyEncoder) self {
      new(storageDir);
      keyEncoder = _keyEncoder;
   }
   
   new(String storageDir) self {
      pathNew(IO:File:Path.apNew(storageDir));
   }
   
   pathNew(IO:File:Path _storageDir) self {
      fields {
         Serializer ser = Serializer.new();
         IO:File:Path storageDir = _storageDir;
         any keyEncoder = null;
      }
   }
   
   getStoreId(String id) {
      //id = id.lower();//why?  no thanks
      if (def(keyEncoder)) {
         String storeId = keyEncoder.encode(id);
      } else {
         storeId = id;
      }
      return(storeId);
   }
   
   getPath(String id) IO:File:Path {
      IO:File:Path p;
      if (def(id) && id != "") {
         if (storageDir.file.exists!) {
            storageDir.file.makeDirs();
         }
         String storeId = getStoreId(id);
         p = storageDir.copy().addStep(storeId);
      }
      return(p);
   }
   
   put(String id, object) {
      if (def(id) && id != "") {
         IO:File:Path p = getPath(id);
         if (def(p)) {
            ser.serialize(object, p.file.writer.open());
            p.file.writer.close();
         }
      }
   }
   
   get(String id) {
      if (def(id) && id != "") {
         IO:File:Path p = getPath(id);
         if (def(p) && p.file.exists) {
            any object = ser.deserialize(p.file.reader.open());
            p.file.reader.close();
            return(object);
         }
      }
      return(null);
   }

   has(String id) Bool {
      if (undef(id) || id == "") { return(false); }
      IO:File:Path p = getPath(id);
      if (p.file.exists) {
         return(true);
      }
      return(false);
   }
   
   remove(String id) self {
      IO:File:Path p = getPath(id);
      p.file.delete();
   }

}

use System:NamedPropertiesIterator;

final class NamedPropertiesIterator {
   
   new(any _inst, List _propNames) {
      fields {
         List propNames = _propNames;
         Container:List:Iterator subIter;
         any inst = _inst;
         List setArgs = List.new(1);
         List getArgs = List.new(0);
      }
   }
   
   subIterGet() Container:List:Iterator {
      if (undef(subIter)) {
         subIter = propNames.iterator;
      }
      return(subIter);
   }
   
   hasNextGet() Bool {
      return(self.subIter.hasNext);
   }
      
   nextGet() {
      String name = self.subIter.next + "Get";
      if (inst.can(name, 0)) {
         return(inst.invoke(name, getArgs));
      }
      return(null);
   }
   
   nextSet(value) {
      String name = self.subIter.next + "Set";
      if (inst.can(name, 1)) {
         setArgs[0] = value;
         inst.invoke(name, setArgs);
      }
   }
   
   skip(Int multiNullCount) {
      for (Int mi = 0;mi < multiNullCount;mi++) {
         self.next = null;
      }
   }
   
}

