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

#include <BER_Base.h>
#include <Base.h>
#include <Base/Text/BEK_String.h>
#include <Base/Math/BEK_Int.h>
#include <Base/Math/BEK_Float.h>
#include <Base/Logic/BEK_Bool.h>
#include <Base/Logic/BEK_Bools.h>
#include <Base/Container/BEK_Array.h>
#include <Base/Container/BEK_Vector.h>
#include <Base/System/BEK_Exception.h>
#include <Base/System/BEK_MethodNotDefined.h>
#include <Base/System/BEK_CallOnNull.h>
#include <Base/System/BEK_IncorrectType.h>
#include <Base/System/BEK_ExceptionBuilder.h>
#include <Base/System/BEK_Thing.h>
#include <Base/System/BEK_Process.h>

/* There are two ways of initializing the dmlist, only one of which is
 * in use at any given time.  I've left them both in and there performance
 * is basically a wash
 * little performance compare of the options for building dmlist
 * inline consists of an initialize call, followed by calls to insert with retry
 * (possibly including rehash) and finally with fillempty
 * the other (in use as of this writing) is the Dmlist_Setup option
 * which does it all based on the mlist
 * these calls will be in the builddef constructed in CEmitVisit
 * a quick perf compare
 * inline in cldef
 * 7 325
 * 22 278
 * 2 906
 * 10 366
 * mlist based
 * 7 185
 * 22 272
 * 2 836
 * 10 324
 * basically, it's a wash
 */
 
/*
 * Initialize the dmlist, for no superclass sets up initial 
 * list, with superclass copies super list and list len
 */
void BERF_Dmlist_Initialize(BERT_ClassDef* twst_shared_cd) {
	size_t dmlistlen = 0;
	size_t i = 0;
	if (twst_shared_cd->twst_supercd == NULL) {
		dmlistlen = (twst_shared_cd->mtdArLen * 2) + 3;
	} else {
		dmlistlen = twst_shared_cd->twst_supercd->dmlistlen;
	}
	twst_shared_cd->dmlistlen = dmlistlen;
	twst_shared_cd->dmlist = (BERT_MtdDef**) BEMalloc(twst_shared_cd->dmlistlen * sizeof(BERT_MtdDef*));
	if (twst_shared_cd->twst_supercd != NULL) {
		/* should do memcpy here */
		for (i = 0;i < twst_shared_cd->dmlistlen;i++) {
			twst_shared_cd->dmlist[i] = twst_shared_cd->twst_supercd->dmlist[i];
		}
	}
}

/*
 * Fill in null slots with empty ref, so users of the list don't have to do
 * an extra check for null array entries
 */
void BERF_Dmlist_FillEmpty(BERT_ClassDef* twst_shared_cd) {
	size_t i = 0;
	static BERT_MtdDef empty = { NULL, 0, -1 };
	for (i = 0;i < twst_shared_cd->dmlistlen;i++) {
		if (twst_shared_cd->dmlist[i] == NULL) {
			twst_shared_cd->dmlist[i] = &empty;
		}
	}
}

/*
 * Insert a method definition into the mlist
 * will initialize mlist if it isn't
 * will rehash mlist if necessary
 * pass in the cldef which contains
 * the mlist and the method
 */
void BERF_Dmlist_Insert_With_Retry(BERT_ClassDef* twst_shared_cd, BERT_MtdDef* mtd) {
	while (BERF_Dmlist_Insert(twst_shared_cd, mtd) == 0) {
	   BERF_Dmlist_ReHash(twst_shared_cd, 2, 1);
	}
}

/*
 * Insert a method definition into the mlist, pass in the cldef which contains
 * the mlist and the method
 * returns 0 on fail, 1 on success
 */
size_t BERF_Dmlist_Insert(BERT_ClassDef* twst_shared_cd, BERT_MtdDef* mtd) {
	
	BEINT idx = 0;
	
	idx = mtd->twnn % twst_shared_cd->dmlistlen;
	
	BERT_MtdDef* omtd = twst_shared_cd->dmlist[idx];
	if (omtd == NULL || omtd->twnn == -1 || omtd->twnn == mtd->twnn) {
		/*The existing entry is either an empty entry (NULL) or this is an
		 * override case (replacing parent mtd with our own)
		 */
		
		twst_shared_cd->dmlist[idx] = mtd;
		return 1;
	}
	
	return 0;
	
}

/*
 * Rehash the dmlist 
 * pass the multiplier and adder (new size = (multiplier * current) + adder
 */
void BERF_Dmlist_ReHash(BERT_ClassDef* twst_shared_cd, size_t multiplier, size_t adder) {
	
	size_t i = 0;
	size_t dmlistlen = twst_shared_cd->dmlistlen;
	BERT_MtdDef** dmlist = twst_shared_cd->dmlist;
	/*printf("Starting a rehash\n");*/
	twst_shared_cd->dmlistlen = (twst_shared_cd->dmlistlen * multiplier) + adder;
	twst_shared_cd->dmlist = (BERT_MtdDef**) BEMalloc(twst_shared_cd->dmlistlen * sizeof(BERT_MtdDef*));
	for (i = 0;i < dmlistlen;i++) {
		BERT_MtdDef* mtddef = dmlist[i];
		if (mtddef != NULL && mtddef->twnn != -1) {  /*not an empty*/
			if (BERF_Dmlist_Insert(twst_shared_cd, mtddef) == 0) {
				/*Rehash failed*/
				BEFree(twst_shared_cd->dmlist);
				twst_shared_cd->dmlistlen = dmlistlen;
				twst_shared_cd->dmlist = dmlist;
				/*try again*/
				adder++;
				BERF_Dmlist_ReHash(twst_shared_cd, multiplier, adder);
				return;
			}
		}
	}
	/*printf("Ending a rehash\n");*/
}

void BERF_Dmlist_Setup_Test(BERT_ClassDef* twst_shared_cd, size_t multiplier, size_t adder) {
	/*A way of verifying Setup works, possibly even comparing results*/
	size_t dmlistlen = 0;
	BERT_MtdDef** dmlist = NULL;
	
	dmlistlen = twst_shared_cd->dmlistlen;
	dmlist = twst_shared_cd->dmlist;
	
	BERF_Dmlist_Setup(twst_shared_cd, multiplier, adder);
	
	BEFree(twst_shared_cd->dmlist);
	
	twst_shared_cd->dmlistlen = dmlistlen;
	twst_shared_cd->dmlist = dmlist;
}

/*
 * Setup the dmlist this is one of two versions, the other being inline to the cldef 
 * pass the multiplier and adder (new size = (multiplier * current) + adder
 */
void BERF_Dmlist_Setup(BERT_ClassDef* twst_shared_cd, size_t multiplier, size_t adder) {
	
	size_t i = 0;
	size_t mtdArLen = twst_shared_cd->mtdArLen;
	twst_shared_cd->dmlistlen = (mtdArLen * multiplier) + adder;
	twst_shared_cd->dmlist = (BERT_MtdDef**) BEMalloc(twst_shared_cd->dmlistlen * sizeof(BERT_MtdDef*));
	for (i = 0;i < mtdArLen;i++) {
		BERT_MtdDef* mtddef = twst_shared_cd->mlist[i];
		if (BERF_Dmlist_Insert(twst_shared_cd, mtddef) == 0) {
			/*failed*/
			BEFree(twst_shared_cd->dmlist);
			/*try again*/
			adder++;
			BERF_Dmlist_Setup(twst_shared_cd, multiplier, adder);
			return;
		}
	}
	BERF_Dmlist_FillEmpty(twst_shared_cd);
}

BEINT BERF_GetCallIdForName(BERT_Glob* blah, char* key, BEINT keyHash) {
   void* value;
   void* rvalue;
   BEINT cid;
   BEINT rcid;
   
   value = (void*) BERV_proc_glob->nextCallId;
   
   cid = (BEINT) value;
   
   rvalue = BERF_Hash_PutOnce(BERV_proc_glob->nameHash, keyHash, key, value);
   
   rcid = (BEINT) rvalue;
   /*printf("Send cid %d, got rcid %d for %s\n", cid, rcid, key);*/
   if (cid == rcid) {
      BERV_proc_glob->nextCallId++;
   }
   return rcid;
}

void* BERF_Hash_PutOnce(BERT_Hash* hash, BEINT keyHash, char* key, void* value) {
   BERT_HashEntry* entry = NULL;
   
   entry = (BERT_HashEntry*) BEMalloc(sizeof(BERT_HashEntry));
   entry->keyHash = keyHash;
   entry->key = key;
   entry->value = value;
   
   return BERF_Hash_PutEntryOnce(hash, entry);
}

void* BERF_Hash_PutEntryOnce(BERT_Hash* hash, BERT_HashEntry* entry) {
   
   BEINT orgNum = 0;
   BEINT num = 0;
   
   
   orgNum = entry->keyHash % hash->mod;
   num = orgNum;
   
   while (1) {
      if (hash->entries[num] == NULL) {
         entry->num = orgNum;
         hash->entries[num] = entry;
         return entry->value;
      } else if (strcmp(hash->entries[num]->key, entry->key) == 0) {
         return hash->entries[num]->value;
      } else if (hash->entries[num]->num != orgNum || ++num >= hash->mod) {
         BERF_Hash_ReHash(hash);
         orgNum = entry->keyHash % hash->mod;
         num = orgNum;
      }
   }
   
}

void* BERF_Hash_Get(BERT_Hash* hash, BEINT keyHash, char* key) {
   
   BEINT orgNum = 0;
   BEINT num = 0;
   
   orgNum = keyHash % hash->mod;
   num = orgNum;
   
   while (1) {
      if (hash->entries[num] == NULL) {
         return NULL;
      } else if (strcmp(hash->entries[num]->key, key) == 0) {
         return hash->entries[num]->value;
      } else if (hash->entries[num]->num != orgNum) {
         return NULL;
      } else {
         num++;
      }
   }
  
}

BERT_ClassDef* BERF_ClassDef_Get(BEINT keyHash, char* key) {
   BERT_ClassDef* bevl_cldef;
   bevl_cldef = (BERT_ClassDef*) BERF_Hash_Get(BERV_proc_glob->classHash, keyHash, key);
   if (bevl_cldef == NULL) {
      printf("Did not find class definition for %s, exiting\n", key);
      exit(1);
   }
   return bevl_cldef;
}

void BERF_Hash_ReHash(BERT_Hash* hash) {
   BERT_HashEntry** oentries;
   BEINT omod = 0;
   BEINT nmod = 0;
   BEINT i = 0;
   oentries = hash->entries;
   omod = hash->mod;
   
   nmod = (omod * 2 + 7);
   BERF_Hash_InitHash(hash, nmod);
   /*do the copy*/
   for (i = 0;i < omod;i++) {
      BERT_HashEntry* he = oentries[i];
      if (he != NULL) {
         BERF_Hash_PutEntryOnce(hash, oentries[i]);
      }
   }
   BEFree(oentries);
   return;
}

BERT_Hash* BERF_Hash_InitHash(BERT_Hash* hash, BEINT value) {
   if (hash == NULL) {
      hash = (BERT_Hash*) BEMalloc(sizeof(BERT_Hash));
   }
   hash->entries = (BERT_HashEntry**) BEMalloc(value * sizeof(BERT_HashEntry*));
   hash->mod = value;
   return hash;
}

void BERF_Init(BERT_Stacks* berv_sts) {
   
   /*subtlety, this is the first thing constructed and xxxTrue == NULL so it will be constructed STATIC*/
   /*passBack set not needed, gc looks at these refs*/
   berv_sts->passedClassDef = BEUV_5_4_LogicBool_clDef;
   berv_sts->bool_True = BEKF_5_4_LogicBool_new_0( 0, berv_sts, NULL);
   
   berv_sts->passedClassDef = BEUV_5_4_LogicBool_clDef;
   berv_sts->bool_False = BEKF_5_4_LogicBool_new_0( 0, berv_sts, NULL);
   
   berv_sts->passedClassDef = BEUV_5_5_LogicBools_clDef;
   berv_sts->bools_singleton = BEKF_5_5_LogicBools_new_0( 0, berv_sts, NULL);
   
   berv_sts->passedClassDef = BEUV_6_3_EncodeUrl_clDef;
   berv_sts->url_singleton = BEKF_6_3_EncodeUrl_new_0( 0, berv_sts, NULL);
   
   berv_sts->passedClassDef = BEUV_6_16_SystemExceptionBuilder_clDef;
   berv_sts->exceptionBuilder_singleton = BEKF_6_16_SystemExceptionBuilder_new_0( 0, berv_sts, NULL);
}

BEINT BERF_HashForString(char* str) {
   BEINT i = 0;
   BEINT h = 0;
   BEINT len = 0;
   if (str != NULL) {
      len = strlen(str);/*utf8 ok, seems to be unused*/
      for (i = 0; i < len;i++) {
         h = h * 31 + (BEINT) str[i];
      }
      h = abs(h);
   } else {
      h = -1;
   }
   return h;
}

void BERF_PrepareClassData(BERT_Stacks* berv_sts, BERT_ClassDef* twrv_cldef) {
   
   if (berv_sts->onceInstances == NULL) {
      berv_sts->onceInstances = (void**) BEMalloc(BERV_proc_glob->nextClassId * sizeof(void*));
   }
   if (berv_sts->onceEvalVars == NULL) {
      berv_sts->onceEvalVars = (void**) BEMalloc(BERV_proc_glob->nextClassId * sizeof(void*));
   }
   if (berv_sts->onceEvalFlags == NULL) {
      berv_sts->onceEvalFlags = (BEINT**) BEMalloc(BERV_proc_glob->nextClassId * sizeof(BEINT*));
   }
   berv_sts->onceEvalVars[twrv_cldef->classId] = (void**) BEMalloc(twrv_cldef->onceEvalCount * sizeof(void**));
   berv_sts->onceEvalFlags[twrv_cldef->classId] = (BEINT*) BEMalloc(twrv_cldef->onceEvalCount * sizeof(BEINT));
}

BERT_Slab* BERF_AddSlab(BERT_Stacks* berv_sts, size_t allocBucket) {
   size_t slabSize;
   BERT_Slab* twrv_slab;
   size_t allocSize;
   
   berv_sts->debugPos = 400;
   
   allocSize = (allocBucket + 1) * BERV_proc_glob->twrbsz;
   
   twrv_slab = berv_sts->allocSlabs[allocBucket];
   
   while (twrv_slab != NULL && twrv_slab->next != NULL) {
      twrv_slab = twrv_slab->next;
   }
   berv_sts->allocSlabs[allocBucket] = twrv_slab;
   
   twrv_slab = (BERT_Slab*) BEMalloc(sizeof(BERT_Slab));
   slabSize = (berv_sts->slabSize / allocSize) * allocSize;
   twrv_slab->slab = (char*) BEMalloc(slabSize);
   twrv_slab->slabSize = slabSize;
   twrv_slab->slabEnd = ((size_t) twrv_slab->slab) + slabSize;
   twrv_slab->slabAt = twrv_slab->slab;
   berv_sts->allocsTotal = berv_sts->allocsTotal + twrv_slab->slabSize;
   if (berv_sts->allocSlabs[allocBucket] != NULL) {
      berv_sts->allocSlabs[allocBucket]->next = twrv_slab;
      twrv_slab->prior = berv_sts->allocSlabs[allocBucket];
   }
   berv_sts->allocSlabs[allocBucket] = twrv_slab;
   berv_sts->slabsOutThere++;
   berv_sts->debugPos = 0;
   return twrv_slab;
}

void** BERF_Create_Instance(BERT_Stacks* berv_sts, BERT_ClassDef* bevl_scldef, BEINT attempt) {
   void** twvg = NULL;
   void** twvn = NULL;
   BEUINT* bevl_gen;
   BERT_Slab* twrv_slab;
   BERT_Slab* twrv_scount;
   size_t isize;
   char* slab;
   void** cursor;
   BEUINT vmark;
   BEUINT maxVmark;
   
   berv_sts->allocsSinceCollect = berv_sts->allocsSinceCollect + bevl_scldef->allocSize;
   vmark = berv_sts->vmark;
   maxVmark = berv_sts->maxVmark;
   if (bevl_scldef->allocBucket < berbmax && bevl_scldef->freeFirstSlot != 1) {
      twrv_slab = berv_sts->allocSlabs[bevl_scldef->allocBucket];
      isize = bevl_scldef->allocSize;
      while (twrv_slab != NULL && twvg == NULL) {
         slab = twrv_slab->slabAt;
         while (slab != NULL) {
            cursor = (void**) slab;
            bevl_gen = (BEUINT*) (cursor + bergen);
            if (((size_t) slab) + isize < twrv_slab->slabEnd) {
               slab = slab + isize;
            } else {
               slab = NULL;
            }
            if ((*bevl_gen & maxVmark) != vmark) {
#ifdef BED_GCSTATS
               berv_sts->instancesReused++;
#endif
               twvg = cursor;
               if (slab == NULL) {
                  if (twrv_slab->next == NULL) {
                     twrv_slab->slabAt = (char*) cursor;
                     berv_sts->allocSlabs[bevl_scldef->allocBucket] = twrv_slab;
                  } else {
                     twrv_slab->slabAt = twrv_slab->slab;
                     berv_sts->allocSlabs[bevl_scldef->allocBucket] = twrv_slab->next;
                  }
               } else {
                  twrv_slab->slabAt = slab;
                  berv_sts->allocSlabs[bevl_scldef->allocBucket] = twrv_slab;
               }
               slab = NULL;
            }
         }
         if (twvg == NULL) {
            twrv_slab->slabAt = twrv_slab->slab;
         }
         twrv_slab = twrv_slab->next;
      }
      if (twvg == NULL) {
         if (attempt == 0 && berv_sts->allocsSinceCollect > berv_sts->allocsBeforeCollect) {
            BERF_Collect(berv_sts);
            return BERF_Create_Instance(berv_sts, bevl_scldef, 1);
         }
         twrv_slab = BERF_AddSlab(berv_sts, bevl_scldef->allocBucket);
         twvg = (void**) twrv_slab->slabAt;
         twrv_slab->slabAt = twrv_slab->slabAt + isize;
      }
      twvg = (void**) memset((void*) twvg, 0, bevl_scldef->allocSize);
   } else {
      if (attempt == 0 && berv_sts->allocsSinceCollect > berv_sts->allocsBeforeCollect) {
         BERF_Collect(berv_sts);
         return BERF_Create_Instance(berv_sts, bevl_scldef, 1);
      }
#ifdef BED_GCSTATS
      berv_sts->instancesNonSlab++;
#endif
      twvn = (void**) BEOMalloc(bevl_scldef->loneAlloc);
      berv_sts->allocsTotal = berv_sts->allocsTotal + bevl_scldef->allocSize;
      berv_sts->lastAlloc[bernal] = twvn;
      berv_sts->lastAlloc = twvn;
      twvg = twvn + berato;
   }
   bevl_gen = (BEUINT*) (twvg + bergen);
   *bevl_gen = vmark;
   twvg[berdef] = (void*) bevl_scldef;
#ifdef BED_GCSTATS
      berv_sts->instancesCreated++;
#endif
   return twvg;
}

void BERF_Add_Once(BERT_Stacks* berv_sts, void** bevs) {
   BERT_Once* twrv_once;
   
   if (bevs != NULL) {
      twrv_once = (BERT_Once*) BEMalloc(sizeof(BERT_Once));
      twrv_once->bevo = bevs;
      twrv_once->prior = berv_sts->lastOnce;
      berv_sts->lastOnce = twrv_once;
   }
}

void** BERF_String_For_Chars(BERT_Stacks* berv_sts, char* cstr) {
   
   BEINT nchars;
   void** bevs;
   
   nchars = strlen(cstr);/*could be uf8 issue...*/
   
   bevs = BERF_Create_Instance(berv_sts, BEUV_4_6_TextString_clDef, 0);
   berv_sts->passBack = bevs;
   bevs[bercps + 1] = BERF_Create_Instance(berv_sts, BEUV_4_3_MathInt_clDef, 0);
   berv_sts->passBack = bevs;
   *((BEINT*) (((void**)(bevs[bercps + 1])) + bercps)) = nchars;
   
   bevs[bercps] = BENoMalloc((nchars + 1) * sizeof(char));
   memcpy(((char*) bevs[bercps]), cstr, nchars * sizeof(char));
   
   return bevs;
   
}

char* BERF_Copy_Chars(char* cstr) {
   
   BEINT nchars;
   char* cstrcp;
   
   nchars = strlen(cstr);/*utf8 ok, only used on cmd line args*/
   
   cstrcp = (char*) BENoMalloc((nchars + 1) * sizeof(char));
   memcpy(cstrcp, cstr, nchars * sizeof(char));
   
   return cstrcp;
}

void** BERF_String_For_Chars_No_Realloc(BERT_Stacks* berv_sts, char* cstr) {
   
   BEINT nchars;
   void** bevs;
   
   nchars = strlen(cstr);/*could be uf8 issue...*/
   
   bevs = BERF_Create_Instance(berv_sts, BEUV_4_6_TextString_clDef, 0);
   berv_sts->passBack = bevs;
   bevs[bercps + 1] = BERF_Create_Instance(berv_sts, BEUV_4_3_MathInt_clDef, 0);
   berv_sts->passBack = bevs;
   *((BEINT*) (((void**)(bevs[bercps + 1])) + bercps)) = nchars;
   
   bevs[bercps] = (void*) cstr;
   
   return bevs;
   
}

void** BERF_String_For_Wide_Chars(BERT_Stacks* berv_sts, wchar_t* wstr) {
   
   BEINT nchars;
   mbstate_t mbstate;
   char* cstr;
   void** bevs;
   
   memset((void*)&mbstate, 0, sizeof(mbstate));
   nchars = wcsrtombs(NULL, (const wchar_t**) &wstr, 0, &mbstate);
   memset((void*)&mbstate, 0, sizeof(mbstate));
   
   cstr = (char*) BENoMalloc((nchars + 1) * sizeof(char));
   wcsrtombs(cstr, (const wchar_t**) &wstr, nchars, &mbstate);
   
   bevs = BERF_Create_Instance(berv_sts, BEUV_4_6_TextString_clDef, 0);
   berv_sts->passBack = bevs;
   bevs[bercps + 1] = BERF_Create_Instance(berv_sts, BEUV_4_3_MathInt_clDef, 0);
   berv_sts->passBack = bevs;
   
   *((BEINT*) (((void**)(bevs[bercps + 1])) + bercps)) = nchars;
   
   bevs[bercps] = (void*) cstr;
   
   return bevs;
}

void BERF_Url_Decode_Swap_String(BERT_Stacks* berv_sts, void** bevs) {
   void* tmpcp;
   void* tmpcp1;
   void** decstr;
   
   decstr = BEKF_6_3_EncodeUrl_decodeString_1(0, berv_sts, berv_sts->url_singleton, bevs);
   /*no passBack here, no opportunity for gc in the upcoming series of events
    (could be an issue if we ever have parallel gc dependent on stackf)*/
   tmpcp = decstr[bercps];
   tmpcp1 = decstr[bercps + 1];
   decstr[bercps] = bevs[bercps];
   decstr[bercps + 1] = bevs[bercps + 1];
   bevs[bercps] = tmpcp;
   bevs[bercps + 1] = tmpcp1;
   berv_sts->passBack = bevs;
   /*no return because the holder of the value was passed in*/
}

void BERF_OutputCrashInfo(int sig) {

   BERT_Stacks* berv_sts;

   /*
   printf("\nIn OutputCrashInfo\n");
   printf("sig is %d\n", sig);
   printf("debugPos is %f\n", BERV_proc_glob->firstStacks->debugPos);
   printf("OutputCrashInfo Done\n\n");
   */

   berv_sts = BERV_proc_glob->lastStacks;
   BERF_Throw_CallOnNull(berv_sts, berv_sts->stackf->stackDef->cname, berv_sts->stackf->stackDef->sname, (char*) "", berv_sts->stackf->twvmp );
}

void BERF_Crash(int sig) {
   BERF_OutputCrashInfo(sig);
}

void BERF_Signal_CRASH(int sig) {
   BERF_Crash(sig);
}

#ifdef BENM_ISWIN

void BERF_Install_Signal_Handlers() {
   signal(SIGSEGV, BERF_Signal_CRASH);
   signal(SIGTERM, BERF_Signal_CRASH);
   signal(SIGABRT, BERF_Signal_CRASH);
   signal(SIGILL, BERF_Signal_CRASH);
   /* SIGINT */
}

#endif

#ifdef BENM_ISNIX

void BERF_Install_Signal_Handlers() {
    struct sigaction sigcrash;
    int rc;
    sigcrash.sa_flags = SA_RESTART;
    sigcrash.sa_handler = BERF_Signal_CRASH;
    sigfillset (&sigcrash.sa_mask);
    /* printf("Install SIG HANS\n"); */
    rc = sigaction (SIGINT, &sigcrash, NULL);
    if (rc == -1)
        printf ("Failed Installing SIGINT\n");
    rc = sigaction (SIGTERM, &sigcrash, NULL);
    if (rc == -1)
        printf ("Failed Installing SIGTERM\n");
    rc = sigaction (SIGSEGV, &sigcrash, NULL);
    if (rc == -1)
        printf ("Failed Installing SIGSEGV\n");
    rc = sigaction (SIGBUS, &sigcrash, NULL);
    if (rc == -1)
        printf ("Failed Installing SIGBUS\n");
    /*SA_RESTART EINTR*/
    return;
}

#endif

/*All the throws except throw itself need to be refactored so that the exeption is on the stack, so they need to be "actual calls" into the build exception singleton, they could otherwise not be reachable during a gc*/

void BERF_Throw_CallOnNull(BERT_Stacks* berv_sts, char* clname, char* subname, char* fname, int line) {
   void** bevl_msg;
   void** bevl_ex;
   
   bevl_msg = (void**) BERF_String_For_Chars(berv_sts, (char*) "Exception, call on null");
   berv_sts->passBack = bevl_msg;
   
   berv_sts->passedClassDef = BEUV_6_10_SystemCallOnNull_clDef;
   bevl_ex = BEKF_6_10_SystemCallOnNull_new_1(0, berv_sts, NULL, bevl_msg);
   berv_sts->passBack = bevl_ex;
   BERF_Throw(berv_sts, bevl_ex, clname, subname, fname, line);
}

void BERF_Throw_IncorrectType(BERT_Stacks* berv_sts, char* clname, char* subname, char* fname, int line) {
   void** bevl_msg;
   void** bevl_ex;
   
   bevl_msg = (void**) BERF_String_For_Chars(berv_sts, (char*) "Exception, incorrect type");
   berv_sts->passBack = bevl_msg;
   
   berv_sts->passedClassDef = BEUV_6_13_SystemIncorrectType_clDef;
   bevl_ex = BEKF_6_13_SystemIncorrectType_new_1(0, berv_sts, NULL, bevl_msg);
   berv_sts->passBack = bevl_ex;
   BERF_Throw(berv_sts, bevl_ex, clname, subname, fname, line);
}

void BERF_Throw(BERT_Stacks* berv_sts, void** _passBack, char* clname, char* subname, char* fname, int line) {
   void** bevl_clname;
   void** bevl_subname;
   void** bevl_fname;
   void** bevl_line;
   size_t bevl_stm;
   size_t bevl_stb;
   char* bevl_buf;
   BERT_Stackf* twrv_sfc;
   void** bevl_sftext;
   twrv_sfc = berv_sts->stackf;
   bevl_stm = 0;
   bevl_stb = 70 * sizeof(char);
   /* TODO it looks to me like there are a bunch of places here where there are allocs no where the gc would see them
    * and it would potentially collect them, fix it */
   bevl_buf = (char*) BENoMalloc(bevl_stb);
   bevl_clname = BERF_String_For_Chars(berv_sts, clname);
   berv_sts->passBack = bevl_clname;
   bevl_subname = BERF_String_For_Chars(berv_sts, subname);
   berv_sts->passBack = bevl_subname;
   bevl_fname = BERF_String_For_Chars(berv_sts, fname);
   berv_sts->passBack = bevl_fname;
   berv_sts->passedClassDef = BEUV_4_3_MathInt_clDef;
   bevl_line = BEKF_4_3_MathInt_new_0(0, berv_sts, NULL);
   berv_sts->passBack = bevl_line;
   *((BEINT*) bevl_line + bercps) = (BEINT) line;
   BEKF_6_16_SystemExceptionBuilder_buildException_6(0, berv_sts, berv_sts->exceptionBuilder_singleton, _passBack, NULL, bevl_clname, bevl_subname, bevl_fname, bevl_line);
   while ((twrv_sfc != NULL) && (twrv_sfc->except == NULL)) {
      bevl_stm = 0;
      bevl_stm = strlen(twrv_sfc->stackDef->cname) * sizeof(char);/*utf8 should be ok, from code, no embeded nulls (need to make sure not possible to have embedded nulls in code!)*/
      bevl_stm = bevl_stm + strlen(twrv_sfc->stackDef->sname) * sizeof(char);/*utf8 should be ok, from code*/
      bevl_stm = bevl_stm + 55 * sizeof(char);
      if (bevl_stm > bevl_stb) {
         bevl_stb = bevl_stm;
         bevl_buf = (char*) BENoRealloc(bevl_buf, bevl_stb);
      }
      sprintf(bevl_buf, "STACK UNWIND: Class: %s, Method: %s, Line: %ld\n", twrv_sfc->stackDef->cname, twrv_sfc->stackDef->sname, twrv_sfc->twvmp);
      
      bevl_sftext = BERF_String_For_Chars(berv_sts, bevl_buf);
      berv_sts->passBack = bevl_sftext;
      
      BEKF_6_16_SystemExceptionBuilder_addStackFrameText_2(0, berv_sts, berv_sts->exceptionBuilder_singleton, _passBack, bevl_sftext);
      twrv_sfc = twrv_sfc->prior;
   }
   /* printf("Unwind Buf %s\n", bevl_buf); */
   BENoFree(bevl_buf);
   BEKF_6_16_SystemExceptionBuilder_sendToConsole_1(0, berv_sts, berv_sts->exceptionBuilder_singleton, _passBack);
   if (twrv_sfc == NULL) {
      printf("STACKFP IS NULL\n");
      exit(1);
   } else {
      /*printf("Jumping to catch position\n");*/
      berv_sts->passBack = _passBack;
      longjmp(twrv_sfc->except->env, 1);
      printf("POST JUMP IN THROW!!!\n");
      exit(1);
   }
}

void** BERF_MethodNotDefined(int berv_chkt, BERT_Stacks* berv_sts, void** bevl_bevs, void** bevl_forwardArgs, BEINT bevl_forwardNumargs, char* bevl_forwardName) {
   
   berv_sts->forwardArgs = bevl_forwardArgs;
   berv_sts->forwardNumargs = bevl_forwardNumargs;
   berv_sts->forwardName = bevl_forwardName;
   
   return BEKF_6_6_SystemObject_methodNotDefined_0( berv_chkt, berv_sts, bevl_bevs );
}

void** BERF_MethodNotDefined0(int berv_chkt, BERT_Stacks* berv_sts, void** bevl_bevs, BEINT bevl_forwardNumargs, char* bevl_forwardName) {
   
   void* bevl_forwardArgs[1];
   
   berv_sts->forwardArgs = bevl_forwardArgs;
   berv_sts->forwardNumargs = bevl_forwardNumargs;
   berv_sts->forwardName = bevl_forwardName;
   
   return BEKF_6_6_SystemObject_methodNotDefined_0( berv_chkt, berv_sts, bevl_bevs );
}

void** BERF_MethodNotDefined1(int berv_chkt, BERT_Stacks* berv_sts, void** bevl_bevs, BEINT bevl_forwardNumargs, char* bevl_forwardName, void** beav0) {
   
   void* bevl_forwardArgs[1];
   
   bevl_forwardArgs[0] = beav0;
   
   berv_sts->forwardArgs = bevl_forwardArgs;
   berv_sts->forwardNumargs = bevl_forwardNumargs;
   berv_sts->forwardName = bevl_forwardName;
   
   return BEKF_6_6_SystemObject_methodNotDefined_0( berv_chkt, berv_sts, bevl_bevs );
}

void** BERF_MethodNotDefined2(int berv_chkt, BERT_Stacks* berv_sts, void** bevl_bevs, BEINT bevl_forwardNumargs, char* bevl_forwardName, void** beav0, void** beav1) {
   
   void* bevl_forwardArgs[2];
   
   bevl_forwardArgs[0] = beav0;
   bevl_forwardArgs[1] = beav1;
   
   berv_sts->forwardArgs = bevl_forwardArgs;
   berv_sts->forwardNumargs = bevl_forwardNumargs;
   berv_sts->forwardName = bevl_forwardName;
   
   return BEKF_6_6_SystemObject_methodNotDefined_0( berv_chkt, berv_sts, bevl_bevs );
}

void** BERF_MethodNotDefined3(int berv_chkt, BERT_Stacks* berv_sts, void** bevl_bevs, BEINT bevl_forwardNumargs, char* bevl_forwardName, void** beav0, void** beav1, void** beav2) {
   
   void* bevl_forwardArgs[3];
   
   bevl_forwardArgs[0] = beav0;
   bevl_forwardArgs[1] = beav1;
   bevl_forwardArgs[2] = beav2;
   
   berv_sts->forwardArgs = bevl_forwardArgs;
   berv_sts->forwardNumargs = bevl_forwardNumargs;
   berv_sts->forwardName = bevl_forwardName;
   
   return BEKF_6_6_SystemObject_methodNotDefined_0( berv_chkt, berv_sts, bevl_bevs );
}

void** BERF_MethodNotDefined4(int berv_chkt, BERT_Stacks* berv_sts, void** bevl_bevs, BEINT bevl_forwardNumargs, char* bevl_forwardName, void** beav0, void** beav1, void** beav2, void** beav3) {
   
   void* bevl_forwardArgs[4];
   
   bevl_forwardArgs[0] = beav0;
   bevl_forwardArgs[1] = beav1;
   bevl_forwardArgs[2] = beav2;
   bevl_forwardArgs[3] = beav3;
   
   berv_sts->forwardArgs = bevl_forwardArgs;
   berv_sts->forwardNumargs = bevl_forwardNumargs;
   berv_sts->forwardName = bevl_forwardName;
   
   return BEKF_6_6_SystemObject_methodNotDefined_0( berv_chkt, berv_sts, bevl_bevs );
}

void** BERF_MethodNotDefined5(int berv_chkt, BERT_Stacks* berv_sts, void** bevl_bevs, BEINT bevl_forwardNumargs, char* bevl_forwardName, void** beav0, void** beav1, void** beav2, void** beav3, void** beav4) {
   
   void* bevl_forwardArgs[5];
   
   bevl_forwardArgs[0] = beav0;
   bevl_forwardArgs[1] = beav1;
   bevl_forwardArgs[2] = beav2;
   bevl_forwardArgs[3] = beav3;
   bevl_forwardArgs[4] = beav4;
   
   berv_sts->forwardArgs = bevl_forwardArgs;
   berv_sts->forwardNumargs = bevl_forwardNumargs;
   berv_sts->forwardName = bevl_forwardName;
   
   return BEKF_6_6_SystemObject_methodNotDefined_0( berv_chkt, berv_sts, bevl_bevs );
}

void** BERF_MethodNotDefined6(int berv_chkt, BERT_Stacks* berv_sts, void** bevl_bevs, BEINT bevl_forwardNumargs, char* bevl_forwardName, void** beav0, void** beav1, void** beav2, void** beav3, void** beav4, void** beav5) {
   
   void* bevl_forwardArgs[6];
   
   bevl_forwardArgs[0] = beav0;
   bevl_forwardArgs[1] = beav1;
   bevl_forwardArgs[2] = beav2;
   bevl_forwardArgs[3] = beav3;
   bevl_forwardArgs[4] = beav4;
   bevl_forwardArgs[5] = beav5;
   
   berv_sts->forwardArgs = bevl_forwardArgs;
   berv_sts->forwardNumargs = bevl_forwardNumargs;
   berv_sts->forwardName = bevl_forwardName;
   
   return BEKF_6_6_SystemObject_methodNotDefined_0( berv_chkt, berv_sts, bevl_bevs );
}


void** BERF_MethodNotDefined7(int berv_chkt, BERT_Stacks* berv_sts, void** bevl_bevs, BEINT bevl_forwardNumargs, char* bevl_forwardName, void** beav0, void** beav1, void** beav2, void** beav3, void** beav4, void** beav5, void** beav6) {
   
   void* bevl_forwardArgs[7];
   
   bevl_forwardArgs[0] = beav0;
   bevl_forwardArgs[1] = beav1;
   bevl_forwardArgs[2] = beav2;
   bevl_forwardArgs[3] = beav3;
   bevl_forwardArgs[4] = beav4;
   bevl_forwardArgs[5] = beav5;
   bevl_forwardArgs[6] = beav6;
   
   berv_sts->forwardArgs = bevl_forwardArgs;
   berv_sts->forwardNumargs = bevl_forwardNumargs;
   berv_sts->forwardName = bevl_forwardName;
   
   return BEKF_6_6_SystemObject_methodNotDefined_0( berv_chkt, berv_sts, bevl_bevs );
}

void** BERF_MethodNotDefined8(int berv_chkt, BERT_Stacks* berv_sts, void** bevl_bevs, BEINT bevl_forwardNumargs, char* bevl_forwardName, void** beav0, void** beav1, void** beav2, void** beav3, void** beav4, void** beav5, void** beav6, void** beav7) {
   
   void* bevl_forwardArgs[8];
   
   bevl_forwardArgs[0] = beav0;
   bevl_forwardArgs[1] = beav1;
   bevl_forwardArgs[2] = beav2;
   bevl_forwardArgs[3] = beav3;
   bevl_forwardArgs[4] = beav4;
   bevl_forwardArgs[5] = beav5;
   bevl_forwardArgs[6] = beav6;
   bevl_forwardArgs[7] = beav7;
   
   berv_sts->forwardArgs = bevl_forwardArgs;
   berv_sts->forwardNumargs = bevl_forwardNumargs;
   berv_sts->forwardName = bevl_forwardName;
   
   return BEKF_6_6_SystemObject_methodNotDefined_0( berv_chkt, berv_sts, bevl_bevs );
}

void** BERF_MethodNotDefined9(int berv_chkt, BERT_Stacks* berv_sts, void** bevl_bevs, BEINT bevl_forwardNumargs, char* bevl_forwardName, void** beav0, void** beav1, void** beav2, void** beav3, void** beav4, void** beav5, void** beav6, void** beav7, void** beav8) {
   
   void* bevl_forwardArgs[9];
   
   bevl_forwardArgs[0] = beav0;
   bevl_forwardArgs[1] = beav1;
   bevl_forwardArgs[2] = beav2;
   bevl_forwardArgs[3] = beav3;
   bevl_forwardArgs[4] = beav4;
   bevl_forwardArgs[5] = beav5;
   bevl_forwardArgs[6] = beav6;
   bevl_forwardArgs[7] = beav7;
   bevl_forwardArgs[8] = beav8;
   
   berv_sts->forwardArgs = bevl_forwardArgs;
   berv_sts->forwardNumargs = bevl_forwardNumargs;
   berv_sts->forwardName = bevl_forwardName;
   
   return BEKF_6_6_SystemObject_methodNotDefined_0( berv_chkt, berv_sts, bevl_bevs );
}

void** BERF_MethodNotDefined10(int berv_chkt, BERT_Stacks* berv_sts, void** bevl_bevs, BEINT bevl_forwardNumargs, char* bevl_forwardName, void** beav0, void** beav1, void** beav2, void** beav3, void** beav4, void** beav5, void** beav6, void** beav7, void** beav8, void** beav9) {
   
   void* bevl_forwardArgs[10];
   
   bevl_forwardArgs[0] = beav0;
   bevl_forwardArgs[1] = beav1;
   bevl_forwardArgs[2] = beav2;
   bevl_forwardArgs[3] = beav3;
   bevl_forwardArgs[4] = beav4;
   bevl_forwardArgs[5] = beav5;
   bevl_forwardArgs[6] = beav6;
   bevl_forwardArgs[7] = beav7;
   bevl_forwardArgs[8] = beav8;
   bevl_forwardArgs[9] = beav9;
   
   berv_sts->forwardArgs = bevl_forwardArgs;
   berv_sts->forwardNumargs = bevl_forwardNumargs;
   berv_sts->forwardName = bevl_forwardName;
   
   return BEKF_6_6_SystemObject_methodNotDefined_0( berv_chkt, berv_sts, bevl_bevs );
}

void** BERF_MethodNotDefined11(int berv_chkt, BERT_Stacks* berv_sts, void** bevl_bevs, BEINT bevl_forwardNumargs, char* bevl_forwardName, void** beav0, void** beav1, void** beav2, void** beav3, void** beav4, void** beav5, void** beav6, void** beav7, void** beav8, void** beav9, void** beav10) {
   
   void* bevl_forwardArgs[11];
   
   bevl_forwardArgs[0] = beav0;
   bevl_forwardArgs[1] = beav1;
   bevl_forwardArgs[2] = beav2;
   bevl_forwardArgs[3] = beav3;
   bevl_forwardArgs[4] = beav4;
   bevl_forwardArgs[5] = beav5;
   bevl_forwardArgs[6] = beav6;
   bevl_forwardArgs[7] = beav7;
   bevl_forwardArgs[8] = beav8;
   bevl_forwardArgs[9] = beav9;
   bevl_forwardArgs[10] = beav10;
   
   berv_sts->forwardArgs = bevl_forwardArgs;
   berv_sts->forwardNumargs = bevl_forwardNumargs;
   berv_sts->forwardName = bevl_forwardName;
   
   return BEKF_6_6_SystemObject_methodNotDefined_0( berv_chkt, berv_sts, bevl_bevs );
}

void** BERF_MethodNotDefined12(int berv_chkt, BERT_Stacks* berv_sts, void** bevl_bevs, BEINT bevl_forwardNumargs, char* bevl_forwardName, void** beav0, void** beav1, void** beav2, void** beav3, void** beav4, void** beav5, void** beav6, void** beav7, void** beav8, void** beav9, void** beav10, void** beav11) {
   
   void* bevl_forwardArgs[12];
   
   bevl_forwardArgs[0] = beav0;
   bevl_forwardArgs[1] = beav1;
   bevl_forwardArgs[2] = beav2;
   bevl_forwardArgs[3] = beav3;
   bevl_forwardArgs[4] = beav4;
   bevl_forwardArgs[5] = beav5;
   bevl_forwardArgs[6] = beav6;
   bevl_forwardArgs[7] = beav7;
   bevl_forwardArgs[8] = beav8;
   bevl_forwardArgs[9] = beav9;
   bevl_forwardArgs[10] = beav10;
   bevl_forwardArgs[11] = beav11;
   
   berv_sts->forwardArgs = bevl_forwardArgs;
   berv_sts->forwardNumargs = bevl_forwardNumargs;
   berv_sts->forwardName = bevl_forwardName;
   
   return BEKF_6_6_SystemObject_methodNotDefined_0( berv_chkt, berv_sts, bevl_bevs );
}

void** BERF_MethodNotDefined13(int berv_chkt, BERT_Stacks* berv_sts, void** bevl_bevs, BEINT bevl_forwardNumargs, char* bevl_forwardName, void** beav0, void** beav1, void** beav2, void** beav3, void** beav4, void** beav5, void** beav6, void** beav7, void** beav8, void** beav9, void** beav10, void** beav11, void** beav12) {
   
   void* bevl_forwardArgs[13];
   
   bevl_forwardArgs[0] = beav0;
   bevl_forwardArgs[1] = beav1;
   bevl_forwardArgs[2] = beav2;
   bevl_forwardArgs[3] = beav3;
   bevl_forwardArgs[4] = beav4;
   bevl_forwardArgs[5] = beav5;
   bevl_forwardArgs[6] = beav6;
   bevl_forwardArgs[7] = beav7;
   bevl_forwardArgs[8] = beav8;
   bevl_forwardArgs[9] = beav9;
   bevl_forwardArgs[10] = beav10;
   bevl_forwardArgs[11] = beav11;
   bevl_forwardArgs[12] = beav12;
   
   berv_sts->forwardArgs = bevl_forwardArgs;
   berv_sts->forwardNumargs = bevl_forwardNumargs;
   berv_sts->forwardName = bevl_forwardName;
   
   return BEKF_6_6_SystemObject_methodNotDefined_0( berv_chkt, berv_sts, bevl_bevs );
}

void** BERF_MethodNotDefined14(int berv_chkt, BERT_Stacks* berv_sts, void** bevl_bevs, BEINT bevl_forwardNumargs, char* bevl_forwardName, void** beav0, void** beav1, void** beav2, void** beav3, void** beav4, void** beav5, void** beav6, void** beav7, void** beav8, void** beav9, void** beav10, void** beav11, void** beav12, void** beav13) {
   
   void* bevl_forwardArgs[14];
   
   bevl_forwardArgs[0] = beav0;
   bevl_forwardArgs[1] = beav1;
   bevl_forwardArgs[2] = beav2;
   bevl_forwardArgs[3] = beav3;
   bevl_forwardArgs[4] = beav4;
   bevl_forwardArgs[5] = beav5;
   bevl_forwardArgs[6] = beav6;
   bevl_forwardArgs[7] = beav7;
   bevl_forwardArgs[8] = beav8;
   bevl_forwardArgs[9] = beav9;
   bevl_forwardArgs[10] = beav10;
   bevl_forwardArgs[11] = beav11;
   bevl_forwardArgs[12] = beav12;
   bevl_forwardArgs[13] = beav13;
   
   berv_sts->forwardArgs = bevl_forwardArgs;
   berv_sts->forwardNumargs = bevl_forwardNumargs;
   berv_sts->forwardName = bevl_forwardName;
   
   return BEKF_6_6_SystemObject_methodNotDefined_0( berv_chkt, berv_sts, bevl_bevs );
}

void** BERF_MethodNotDefined15(int berv_chkt, BERT_Stacks* berv_sts, void** bevl_bevs, BEINT bevl_forwardNumargs, char* bevl_forwardName, void** beav0, void** beav1, void** beav2, void** beav3, void** beav4, void** beav5, void** beav6, void** beav7, void** beav8, void** beav9, void** beav10, void** beav11, void** beav12, void** beav13, void** beav14) {
   
   void* bevl_forwardArgs[15];
   
   bevl_forwardArgs[0] = beav0;
   bevl_forwardArgs[1] = beav1;
   bevl_forwardArgs[2] = beav2;
   bevl_forwardArgs[3] = beav3;
   bevl_forwardArgs[4] = beav4;
   bevl_forwardArgs[5] = beav5;
   bevl_forwardArgs[6] = beav6;
   bevl_forwardArgs[7] = beav7;
   bevl_forwardArgs[8] = beav8;
   bevl_forwardArgs[9] = beav9;
   bevl_forwardArgs[10] = beav10;
   bevl_forwardArgs[11] = beav11;
   bevl_forwardArgs[12] = beav12;
   bevl_forwardArgs[13] = beav13;
   bevl_forwardArgs[14] = beav14;
   
   berv_sts->forwardArgs = bevl_forwardArgs;
   berv_sts->forwardNumargs = bevl_forwardNumargs;
   berv_sts->forwardName = bevl_forwardName;
   
   return BEKF_6_6_SystemObject_methodNotDefined_0( berv_chkt, berv_sts, bevl_bevs );
}

void** BERF_MethodNotDefined16(int berv_chkt, BERT_Stacks* berv_sts, void** bevl_bevs, BEINT bevl_forwardNumargs, char* bevl_forwardName, void** beav0, void** beav1, void** beav2, void** beav3, void** beav4, void** beav5, void** beav6, void** beav7, void** beav8, void** beav9, void** beav10, void** beav11, void** beav12, void** beav13, void** beav14, void** beav15) {
   
   void* bevl_forwardArgs[16];
   
   bevl_forwardArgs[0] = beav0;
   bevl_forwardArgs[1] = beav1;
   bevl_forwardArgs[2] = beav2;
   bevl_forwardArgs[3] = beav3;
   bevl_forwardArgs[4] = beav4;
   bevl_forwardArgs[5] = beav5;
   bevl_forwardArgs[6] = beav6;
   bevl_forwardArgs[7] = beav7;
   bevl_forwardArgs[8] = beav8;
   bevl_forwardArgs[9] = beav9;
   bevl_forwardArgs[10] = beav10;
   bevl_forwardArgs[11] = beav11;
   bevl_forwardArgs[12] = beav12;
   bevl_forwardArgs[13] = beav13;
   bevl_forwardArgs[14] = beav14;
   bevl_forwardArgs[15] = beav15;
   
   berv_sts->forwardArgs = bevl_forwardArgs;
   berv_sts->forwardNumargs = bevl_forwardNumargs;
   berv_sts->forwardName = bevl_forwardName;
   
   return BEKF_6_6_SystemObject_methodNotDefined_0( berv_chkt, berv_sts, bevl_bevs );
}

void** BERF_MethodNotDefinedx16(int berv_chkt, BERT_Stacks* berv_sts, void** bevl_bevs, BEINT bevl_forwardNumargs, char* bevl_forwardName, void** beav0, void** beav1, void** beav2, void** beav3, void** beav4, void** beav5, void** beav6, void** beav7, void** beav8, void** beav9, void** beav10, void** beav11, void** beav12, void** beav13, void** beav14, void** beav15, void** beax) {
   int i = beramax;
   
   void** bevl_forwardArgs = (void**) BENoMalloc(bevl_forwardNumargs * sizeof(void*));
   
   bevl_forwardArgs[0] = beav0;
   bevl_forwardArgs[1] = beav1;
   bevl_forwardArgs[2] = beav2;
   bevl_forwardArgs[3] = beav3;
   bevl_forwardArgs[4] = beav4;
   bevl_forwardArgs[5] = beav5;
   bevl_forwardArgs[6] = beav6;
   bevl_forwardArgs[7] = beav7;
   bevl_forwardArgs[8] = beav8;
   bevl_forwardArgs[9] = beav9;
   bevl_forwardArgs[10] = beav10;
   bevl_forwardArgs[11] = beav11;
   bevl_forwardArgs[12] = beav12;
   bevl_forwardArgs[13] = beav13;
   bevl_forwardArgs[14] = beav14;
   bevl_forwardArgs[15] = beav15;
   
   while (i < bevl_forwardNumargs) {
       bevl_forwardArgs[i] = beax[i - beramax];
       i++;
   }
   
   berv_sts->forwardArgs = bevl_forwardArgs;
   berv_sts->forwardNumargs = bevl_forwardNumargs;
   berv_sts->forwardName = bevl_forwardName;
   
   return BEKF_6_6_SystemObject_methodNotDefined_0( berv_chkt, berv_sts, bevl_bevs );
}

void BERF_Collect(BERT_Stacks* berv_sts) {
   BERT_Stacks* twrv_fss;
   BERT_Glob* berv_glob;
   void** eb;
   void** twrgcv;
   void** freeFirst;
   void** freeLast;
   BEINT twrgcvfpos;
   BEINT twrgcvrpos;
   BEINT twrgcvlpos;
   float* debugPos;
#ifdef BED_GCSTATS
   size_t avgCalc;
#endif
   
   void** last = NULL;
   void** current = NULL;
   BERT_Once* current_once = NULL;
   void** cursor;
   void** toFree;
   BEUINT vmark;
   BEUINT maxVmark;
   BEUINT vmarkMask;
   long freed;
   BERT_Stackf* sf;
   BERT_ClassDef* cldef;
   BERT_ClassDef* cldef2;
   BEINT min;
   BEINT max;
   BEUINT* vs_gen;
   void** vs;
   void** vt;
   void** vsm;
   void** va;
   
   BERT_Slab* twrv_slab;
   BERT_Slab* twrv_pivslab;
   BERT_Slab* twrv_endslab;
   char* slab;
   size_t isize;
   size_t si;
   size_t slabsVisited = 0;
   size_t decB = 0;
   size_t decA = 0;
   size_t foundOne = 0;
   BERT_Slab* release_slab;
   
   BEINT i = 0;
   BEINT val = 0;
   
   berv_glob = BERV_proc_glob;
   freeFirst = NULL;
   freeLast = NULL;

   debugPos = &berv_sts->debugPos;
   *debugPos = 300;
   release_slab = NULL;

#ifdef BED_GCSTATS
   if (berv_sts->collects > 0) {
      avgCalc = berv_sts->collects * berv_sts->avgGcAllocs + berv_sts->allocsSinceCollect;
      berv_sts->collects++;
      avgCalc = avgCalc / berv_sts->collects;
      berv_sts->avgGcAllocs = avgCalc;
   } else {
      berv_sts->collects++;
      berv_sts->avgGcAllocs = berv_sts->allocsSinceCollect;
   }
#endif
   *debugPos = 301;
   
   /* Decide when to collect next */
   berv_sts->allocsSinceCollect = 0;
   berv_sts->allocsBeforeCollect = berv_sts->allocsTotal / berv_sts->beforeCollectDivisor;
   berv_sts->allocsBeforeCollect = berv_sts->allocsBeforeCollect * berv_sts->beforeCollectMultiplier;
   
   twrv_fss = berv_sts;
   if (twrv_fss->gcv == NULL) {
      twrv_fss->gcvfpos = twrv_fss->initGcvlen;
      twrv_fss->gcv = (void**) BEMalloc((twrv_fss->gcvfpos + 1) * sizeof(void*));
   }
   twrgcv = twrv_fss->gcv;
   twrgcvfpos = twrv_fss->gcvfpos;
   twrgcvrpos = 0;
   twrgcvlpos = 0;
   maxVmark = berv_sts->maxVmark;
   vmarkMask = berv_sts->vmarkMask;
   vmark = berv_sts->vmark;
   vmark++;
   if (vmark > maxVmark) {
      vmark = 1;
   }
   berv_sts->vmark = vmark;
   *debugPos = 302;
   freed = 0;
   sf = berv_sts->stackf;
   while (sf != NULL) {
      vs = (void**) *(sf->bevs);
      if (vs != NULL) {
         vs_gen = (BEUINT*) (vs + bergen);
         if ((*vs_gen & maxVmark) != vmark) {
            *vs_gen &= vmarkMask; *vs_gen |= vmark; /* *vs_gen = vmark; */
            cldef2 = (BERT_ClassDef*) vs[berdef];
            if (cldef2->maxProperty != cldef2->minProperty) {
               twrgcv[twrgcvrpos] = (void*) vs;
               twrgcvrpos++;
               if (twrgcvrpos > twrgcvfpos) {
                  twrgcvfpos = twrgcvfpos + bergcvgrow;
                  twrgcv = (void**) BENoRealloc(twrgcv, (twrgcvfpos + 1) * sizeof(void*));
               }
            }
         }
      }
      va = sf->twvp;
      val = sf->stackDef->twvhl;
      if (va != NULL) {
         for (i = 0;i < val;i++) {
            vs = (void**) va[i];
            if (vs != NULL) {
				/*need to deref*/
				vs = (void**) *vs;
			}
            if (vs != NULL) {
               vs_gen = (BEUINT*) (vs + bergen);
               if ((*vs_gen & maxVmark) != vmark) {
                  *vs_gen &= vmarkMask; *vs_gen |= vmark; /* *vs_gen = vmark; */
                  cldef2 = (BERT_ClassDef*) vs[berdef];
                  if (cldef2->maxProperty != cldef2->minProperty) {
                     twrgcv[twrgcvrpos] = (void*) vs;
                     twrgcvrpos++;
                     if (twrgcvrpos > twrgcvfpos) {
                        twrgcvfpos = twrgcvfpos + bergcvgrow;
                        twrgcv = (void**) BENoRealloc(twrgcv, (twrgcvfpos + 1) * sizeof(void*));
                     }
                  }
               }
            }
         }
      }
      sf = sf->prior;
   }
   *debugPos = 303;
   vs = berv_sts->passBack; /*passBack ok*/
   if (vs != NULL && vs[berdef] != NULL) {
      vs_gen = (BEUINT*) (vs + bergen);
      if ((*vs_gen & maxVmark) != vmark) {
         *vs_gen &= vmarkMask; *vs_gen |= vmark; /* *vs_gen = vmark; */
         cldef2 = (BERT_ClassDef*) vs[berdef];
         if (cldef2->maxProperty != cldef2->minProperty) {
            twrgcv[twrgcvrpos] = (void*) vs;
            twrgcvrpos++;
            if (twrgcvrpos > twrgcvfpos) {
               twrgcvfpos = twrgcvfpos + bergcvgrow;
               twrgcv = (void**) BENoRealloc(twrgcv, (twrgcvfpos + 1) * sizeof(void*));
            }
         }
      }
   }
   *debugPos = 303.1;
   for (i = 0;i < berv_sts->forwardNumargs;i++) {
      vs = (void**) berv_sts->forwardArgs[i];
      if (vs != NULL && vs[berdef] != NULL) {
         vs_gen = (BEUINT*) (vs + bergen);
         if ((*vs_gen & maxVmark) != vmark) {
            *vs_gen &= vmarkMask; *vs_gen |= vmark; /* *vs_gen = vmark; */
            cldef2 = (BERT_ClassDef*) vs[berdef];
            if (cldef2->maxProperty != cldef2->minProperty) {
               twrgcv[twrgcvrpos] = (void*) vs;
               twrgcvrpos++;
               if (twrgcvrpos > twrgcvfpos) {
                  twrgcvfpos = twrgcvfpos + bergcvgrow;
                  twrgcv = (void**) BENoRealloc(twrgcv, (twrgcvfpos + 1) * sizeof(void*));
               }
            }
         }
      }
   }
   *debugPos = 303.2;
   vs = berv_sts->bool_True;
   if (vs != NULL && vs[berdef] != NULL) {
      vs_gen = (BEUINT*) (vs + bergen);
      if ((*vs_gen & maxVmark) != vmark) {
         *vs_gen &= vmarkMask; *vs_gen |= vmark; /* *vs_gen = vmark; */
      }
   }
   *debugPos = 303.3;
   vs = berv_sts->bool_False;
   if (vs != NULL && vs[berdef] != NULL) {
      vs_gen = (BEUINT*) (vs + bergen);
      if ((*vs_gen & maxVmark) != vmark) {
         *vs_gen &= vmarkMask; *vs_gen |= vmark; /* *vs_gen = vmark; */
      }
   }
   *debugPos = 304;
   current_once = berv_sts->lastOnce;
   while (current_once != NULL) {
      vs = current_once->bevo;
      vs_gen = (BEUINT*) (vs + bergen);
      if ((*vs_gen & maxVmark) != vmark) {
         *vs_gen &= vmarkMask; *vs_gen |= vmark; /* *vs_gen = vmark; */
         cldef2 = (BERT_ClassDef*) vs[berdef];
         if (cldef2->maxProperty != cldef2->minProperty) {
            twrgcv[twrgcvrpos] = (void*) vs;
            twrgcvrpos++;
            if (twrgcvrpos > twrgcvfpos) {
               twrgcvfpos = twrgcvfpos + bergcvgrow;
               twrgcv = (void**) BENoRealloc(twrgcv, (twrgcvfpos + 1) * sizeof(void*));
            }
         }
      }
      current_once = current_once->prior;
   }
   
   *debugPos = 305;
   cursor = (void**) twrgcv[twrgcvlpos];
   twrgcvlpos++;
   while (twrgcvlpos <= twrgcvrpos) {
      cldef = (BERT_ClassDef*) cursor[berdef];
      /*if (cldef != NULL) {*/
         min = cldef->minProperty;
         max = cldef->maxProperty;
         for (i = min;i < max;i++) {
            vs = (void**) cursor[i];
            if (vs != NULL) {
               vs_gen = (BEUINT*) (vs + bergen);
               if ((*vs_gen & maxVmark) != vmark) {
                  *vs_gen &= vmarkMask; *vs_gen |= vmark; /* *vs_gen = vmark; */
                  cldef2 = (BERT_ClassDef*) vs[berdef];
                  if (cldef2->maxProperty != cldef2->minProperty) {
                     if (twrgcvrpos >= twrgcvfpos && twrgcvlpos > 0) {
                        twrgcvlpos--;
                        twrgcv[twrgcvlpos] = (void*) vs;
                     } else {
                        twrgcv[twrgcvrpos] = (void*) vs;
                        twrgcvrpos++;
                        if (twrgcvrpos > twrgcvfpos) {
                           twrgcvfpos = twrgcvfpos + bergcvgrow;
                           twrgcv = (void**) BENoRealloc(twrgcv, (twrgcvfpos + 1) * sizeof(void*));
                        }
                     }
                  }
               }
            }
         }
         if (cldef->isArray == 1) {
            /*printf("Doing array\n");*/
            va = (void**) cursor[bercps + 1]; /*get length Int*/
            vsm = (void**) cursor[bercps];
            min = 0;
            if (va != NULL && vsm != NULL) {
               max = *((int*) (va + bercps)); /*get length as int*/
               /*printf("Array length %d\n", max);*/
               for (i = min;i < max;i++) {
                  vs = (void**) vsm[i];
                  if (vs != NULL) {
                     vs_gen = (BEUINT*) (vs + bergen);
                     if ((*vs_gen & maxVmark) != vmark) {
                        *vs_gen &= vmarkMask; *vs_gen |= vmark; /* *vs_gen = vmark; */
                        cldef2 = (BERT_ClassDef*) vs[berdef];
                        
                        if (cldef2->maxProperty != cldef2->minProperty) {
                           if (twrgcvrpos >= twrgcvfpos && twrgcvlpos > 0) {
                              twrgcvlpos--;
                              twrgcv[twrgcvlpos] = (void*) vs;
                           } else {
                              twrgcv[twrgcvrpos] = (void*) vs;
                              twrgcvrpos++;
                              if (twrgcvrpos > twrgcvfpos) {
                                 twrgcvfpos = twrgcvfpos + bergcvgrow;
                                 twrgcv = (void**) BENoRealloc(twrgcv, (twrgcvfpos + 1) * sizeof(void*));
                              }
                           }
                        }
                     }
                  }
               }
            }
         }
      /*}*/
      cursor = (void**) twrgcv[twrgcvlpos];
      twrgcvlpos++;
   }
   *debugPos = 306;
   berv_sts = twrv_fss;
   
   current = (void**) berv_sts->firstAlloc[bernal];
   last = berv_sts->firstAlloc;
   *debugPos = 307;
   while (current != NULL) {
      vs = current + berato;
      vs_gen = (BEUINT*) (vs + bergen);
      if ((*vs_gen & maxVmark) == vmark) {
         cldef = (BERT_ClassDef*) vs[berdef];
         last[bernal] = (void*) current;
         last = current;
         current = (void**) current[bernal];
      } else {
         cldef = (BERT_ClassDef*) vs[berdef];
         *vs_gen = 0;
         if (cldef != NULL) {
            berv_sts->allocsTotal = berv_sts->allocsTotal - cldef->allocSize;
            if (cldef->freeFirstSlot == 1) {
               if (vs[bercps] != NULL) {
                  BENoFree(vs[bercps]);
                  vs[bercps] = NULL;
               }
            }
         }
         toFree = current;
         current = (void**) current[bernal];
         *debugPos = 308;
         if (freeFirst == NULL) {
            freeFirst = toFree;
            freeLast = toFree;
         } else {
            freeLast[bernal] = (void*) toFree;
            freeLast = toFree;
         }
         freeLast[bernal] = NULL;
      }
   }
   berv_sts->lastAlloc = last;
   last[bernal] = NULL;
   
   /*
    * Reset all slabs to the beginning and reset the current slab
    * for each bucket to the first one for reuse
    */
   for (si = 0;si < berbmax;si++) {
      twrv_slab = berv_sts->allocSlabs[si];
      twrv_pivslab = twrv_slab;
      while (twrv_slab != NULL && twrv_slab->next != NULL) {
         twrv_slab = twrv_slab->next;
         twrv_slab->slabAt = twrv_slab->slab;
      }
      if (twrv_pivslab != NULL) {
         twrv_pivslab->slabAt = twrv_pivslab->slab;
      }
      twrv_slab = twrv_pivslab;
      while (twrv_slab != NULL && twrv_slab->prior != NULL) {
         twrv_slab = twrv_slab->prior;
         twrv_slab->slabAt = twrv_slab->slab;
      }
      berv_sts->allocSlabs[si] = twrv_slab;
   }
   
   *debugPos = 309;
   /*
    * If this is the last allowed generation, cycle through all instances
    * and set unused instances to 0 gen to avoid false positives, recover
    * an unused slab if one exists
    */
   if (vmark == maxVmark) {
      for (si = 0;si < berbmax;si++) {
         twrv_slab = berv_sts->allocSlabs[si];
         isize = (si + 1) * BERV_proc_glob->twrbsz;
         while (twrv_slab != NULL) {
            slabsVisited++;
            foundOne = 0;
            slab = twrv_slab->slab;
            while (slab != NULL) {
               cursor = (void**) slab;
               vs_gen = (BEUINT*) (cursor + bergen);
               if ((*vs_gen & maxVmark) == vmark) {
                  foundOne = 1;
               } else {
                  *vs_gen &= vmarkMask; /* *vs_gen = 0; */
               }
               if (((size_t) slab) + isize < twrv_slab->slabEnd) {
                  slab = slab + isize;
               } else {
                  slab = NULL;
               }
            }
            /* Recover unused slab, must not be at beginning or end, one per max vmark gc */
            twrv_slab = twrv_slab->next;
            if (release_slab == NULL && foundOne == 0 && twrv_slab != NULL && twrv_slab->prior->prior != NULL) {
               release_slab = twrv_slab->prior;
               twrv_slab->prior->prior->next = twrv_slab;
               twrv_slab->prior = twrv_slab->prior->prior;
            }
         }
      }
      /* sanity check slabs */
      if (berv_sts->slabsOutThere != slabsVisited) {
         printf("ERROR Slabs OutThere and Visited unequal %lu %lu\n", (unsigned long) berv_sts->slabsOutThere, (unsigned long) slabsVisited);
         exit(1);
      }
   
   }
   
   *debugPos = 310;
   current = freeFirst;
   while (current != NULL) {
      toFree = current;
      current = (void**) toFree[bernal];
      BEOFree(toFree);
      freed++;
   }
   
   if (release_slab != NULL) {
      berv_sts->allocsTotal = berv_sts->allocsTotal - release_slab->slabSize;
      BEFree(release_slab->slab);
      BEFree(release_slab);
      release_slab = NULL;
      berv_sts->slabsOutThere--;
#ifdef BED_GCSTATS
      berv_sts->slabsReleased++;
#endif
   }
   
   twrv_fss->gcv = twrgcv;
   twrv_fss->gcvfpos = twrgcvfpos;
#ifdef BED_GCSTATS
   berv_sts->collects++;
#endif

   *debugPos = 0;
}

BERT_Stacks* BERF_New_Stacks() {
   
BERT_Stacks* berv_sts;
void** rgch;
BEUINT maxBEUINT;
BEUINT vmarkMask;

berv_sts = (BERT_Stacks*) BEMalloc(sizeof(BERT_Stacks));

berv_sts->berv_glob = BERV_proc_glob;
berv_sts->initGcvlen = 51200;
berv_sts->vmark = 1;
berv_sts->maxVmark = BERD_MAXVMARK;
/*262144, 524288*/

/* Setup maxtwuint and the mask for gc marks */
maxBEUINT = BERD_MAXBEINT;
maxBEUINT <<= 1;
maxBEUINT++;
berv_sts->maxBEUINT = maxBEUINT;
vmarkMask = maxBEUINT;
/* vmarkMask = maxBEUINT XOR maxVmark; not with genshift and remoom for gc gen labeling */
vmarkMask <<= BERD_MASKSHIFT;
berv_sts->vmarkMask = vmarkMask;
/* Setup done */

berv_sts->slabSize = 524288;
/*Size of gc tovisit buffer, requirements vary with above values, now 800000*/
berv_sts->slabsOutThere = 0;
berv_sts->allocsTotal = 0;
berv_sts->allocsSinceCollect = 0;
berv_sts->allocsBeforeCollect = 8388608;
berv_sts->beforeCollectDivisor = 3;
berv_sts->beforeCollectMultiplier = 1;
berv_sts->debugPos = 0;
berv_sts->forwardNumargs = 0;

rgch = (void**) BEMalloc((bernal + 1) * sizeof(void*));
rgch[bernal] = NULL;
berv_sts->firstAlloc = rgch;
berv_sts->lastAlloc = rgch;
return(berv_sts);
}

int BERF_Run_Main(int argc, char **argv, char* klasschar, bemcuinit cuinit, char* platchar) {
BERT_Glob* berv_glob;

berv_glob = (BERT_Glob*) BEMalloc(sizeof(BERT_Glob));
berv_glob->nameHash = BERF_Hash_InitHash(NULL, 1000);
berv_glob->classHash = BERF_Hash_InitHash(NULL, 500);
berv_glob->nextCallId = 1;
berv_glob->nextClassId = 0;
berv_glob->firstStacks = NULL;
berv_glob->lastStacks = NULL;
berv_glob->twrbsz = sizeof(void*) * berbmod;

BERV_proc_glob = berv_glob;
(cuinit)( );

   BERF_Install_Signal_Handlers();

return BERF_Start_Process(argc, argv, klasschar, platchar);

}

int BERF_Start_Process(int argc, char **argv, char* klasschar, char* platchar) {
BERT_Glob* berv_glob;
BERT_Stacks* berv_sts;
BERT_Stacks* twrv_fss;
BERT_Stackf* twrv_sfc;
BERT_StackDef* twrv_sfd;
void* twvp[3] = { NULL, NULL, NULL };
BERT_StackDef twrv_stackdn;
BERT_Stackf twrv_stackfn;
BERT_Except twrv_stackex;
void** eb;
void** ac;
void** av;
void** ei;
void** plat;
void** klass;
void** x;
void** bevs;
void** msg;

bevs = NULL;
berv_glob = BERV_proc_glob;

berv_sts = BERF_New_Stacks();
berv_sts->execState = 1;
if (berv_glob->lastStacks == NULL) {
   berv_glob->firstStacks = berv_sts;
} else {
   berv_glob->lastStacks->nextStacks = berv_sts;
}
berv_glob->lastStacks = berv_sts;
twrv_fss = berv_sts;

berv_sts = twrv_fss;

berv_glob->mainCuClear();
berv_glob->mainCuData(berv_sts);

berv_sts->allocSlabs = (BERT_Slab**) BEMalloc(berbmax * sizeof(BERT_Slab*));

twrv_sfd = &twrv_stackdn;
twrv_sfd->cname = (char*) "main";
twrv_sfd->sname = (char*) "main";
twrv_sfd->twvhl = 3;

twrv_sfc = &twrv_stackfn;
twrv_sfc->stackDef = twrv_sfd;
twrv_sfc->prior = NULL;
twrv_sfc->bevs = (void**) &bevs;
twrv_sfc->twvp = twvp;
berv_sts->stackf = twrv_sfc;
BERF_Init(berv_sts);
berv_sts->passedClassDef = BEUV_6_16_SystemExceptionBuilder_clDef;
eb = BEKF_6_16_SystemExceptionBuilder_new_0(0, berv_sts, NULL);
berv_sts->passBack = eb;
if (setjmp(twrv_stackex.env) == 0) {
twrv_sfc->except = &twrv_stackex;
berv_sts->passedClassDef = BEUV_4_3_MathInt_clDef;
ac = BEKF_4_3_MathInt_new_0(0, berv_sts, NULL);
berv_sts->passBack = ac;
*((int*) ac + bercps) = argc;
berv_sts->passedClassDef = BEUV_6_5_SystemThing_clDef;
av = BEKF_6_5_SystemThing_new_0(0, berv_sts, NULL);
berv_sts->passBack = av;
av[bercps] = (void*) argv;
berv_sts->passedClassDef = BEUV_6_7_SystemProcess_clDef;
ei = BEKF_6_7_SystemProcess_new_0(0, berv_sts, NULL);
berv_sts->passBack = ei;

plat = BERF_String_For_Chars(berv_sts, platchar);
berv_sts->passBack = plat;

klass = BERF_String_For_Chars(berv_sts, klasschar);
berv_sts->passBack = klass;

twvp[0] = &(ac);
twvp[1] = &(av);
twvp[2] = &(plat);
BEKF_6_7_SystemProcess_setup_3(0, berv_sts, ei, ac, av, plat);

twvp[0] = &(klass);
BEKF_6_7_SystemProcess_startByName_1(0, berv_sts, ei, klass);
} else {
msg = berv_sts->passBack; /*passBack ok*/
twvp[0] = &(msg);
BEKF_6_16_SystemExceptionBuilder_printException_1(0, berv_sts, eb, msg);
}
berv_sts->execState = 2;
#ifdef BED_GCSTATS
   printf("Ending process, gc stats: collects %d, slabsReleased %d, allocsSinceCollect %d, avgGcAllocs %d, gcvfpos %d, initGcvlen %d, instancesCreated %d, instancesReused %d, instancesNonSlab %d\n", berv_sts->collects, berv_sts->slabsReleased, berv_sts->allocsSinceCollect, berv_sts->avgGcAllocs, berv_sts->gcvfpos, berv_sts->initGcvlen, berv_sts->instancesCreated, berv_sts->instancesReused, berv_sts->instancesNonSlab);
#endif
return 0;
}

int BERF_Start_Process_Free_Args(int argc, char **argv, char* klasschar, char* platchar) {
   char* c_arg;
   int i;
   
   BERF_Start_Process(argc, argv, klasschar, platchar);
   for (i = 0;i < argc;i++) {
      c_arg = argv[i];
      BENoFree(c_arg);
   }
   BENoFree(klasschar);
   BENoFree(platchar);
   /*return is ignored, why is it here?*/
   return 0;
   
}

void BERF_WaitLoop() {
   BERT_Stacks* berv_sts;
   BERT_Glob* berv_glob;
   int allDone = 1;
   
   berv_glob = BERV_proc_glob;
   
   while (1) {
      /*while (sem down) {*/
         berv_sts = berv_glob->firstStacks;
         allDone = 1;
         while (berv_sts != NULL) {
            if (berv_sts->execState == 1) {
               allDone = 0;
            }
            berv_sts = berv_sts->nextStacks;
         }
         if (allDone) {
            exit(0);
         }
      /*}*/
   }
}

BERT_Glob* BERV_proc_glob = NULL;

