// Copyright 2006 Craig Welch
//
// Licensed under the MIT license. See LICENSE.txt file in the project root 
// for full license information.
#ifndef BERH_Base
#define BERH_Base

#include <stdlib.h>
#include <stdint.h>
#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <setjmp.h>
#include <limits.h>
#include <wchar.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <signal.h>
#include <time.h>
#ifdef BENM_ISWIN
#include <process.h>
#include <windows.h>
#include <winbase.h>
#endif

/*   calloc(m, n) is equivalent to   */
/*   p = malloc(m * n);   */
/*   memset(p, 0, m * n);   */
/*
export MALLOC_CHECK_=1 # Report error and continue

OR

export MALLOC_CHECK_=0 # Ignore error
*/

/* 
for individual (nonbucket) allocs, freefirstslot==1 (for later freeing using llist) or
bc is oversize for buckets
*/ 
/*what to add to alloced mem to get to "object" mem*/
#define berato 1
/*the position in the alloced mem which points to the next link of alloced mem in llists of them*/
#define bernal 0

/*obj index for the gen mark*/
#define bergen 0
/*obj index for the classdef*/
#define berdef 1
/*obj index for the first member, sometimes a native type*/
#define bercps 2
/*the max number of "directly handled" arguments (with variable definitions in C call signature)*/
#define beramax 16

/*the slot width (range) of alloc buckets, was 3*/
#define berbmod 1
/*the max number of buckets (max slot instance which can be allocated from slabs is berbmod * berbmax), was 5*/
#define berbmax 16
/*size slabs should be allocated at, was 524288 - 262144 - 174762*/
#define berbssz 262144

/*Define BED_GCSTATS to get gc statistics*/
/*#define BED_GCSTATS*/

#define bergcvgrow 10000

#define BEOMalloc(size) memset(malloc(size), 0, size);
#define BEOFree(ptr) free(ptr);
#define BEOSMalloc(size) memset(malloc(size), 0, size);
#define BENoMalloc(size) memset(malloc(size), 0, size);
#define BENoRealloc(ptr, size) realloc(ptr, size);
#define BENoFree(ptr) free(ptr);
#define BEMalloc(size) memset(malloc(size), 0, size);
#define BEFree(ptr) free(ptr);

#define BEVReturn(val) berv_sts->stackf = berv_stackfs.prior; return val;
#define BEVReturnCast(val) berv_sts->stackf = berv_stackfs.prior; return (void**) val;

/*SIZES NUMBERS*/
#define BERD_MAXBEINT INT_MAX
#define BERD_MAXSIZET (size_t)-1;
#define BERD_PIDX_UNDEF 0
/* maxvmark was 512.*/
/* the below are inter related, and are in turn related to the range of size_t */
/* M 63 G 6(8), M 127 G 7(9), M 255 G 8(10)*/
/* 2 4 8 16 32 64 128 256 512 1024 2048 4096 8192 16384 32768 65536 131072 262144 524288 1048576 2097152 4194304 8388608 16777216 33554432 67108864 134217728 268435456 536870912 1073741824 2147483648 4294967296 */
#define BERD_MAXVMARK 127
#define BERD_MASKSHIFT 7
#define BERD_GENSHIFT 9

/*NOTICE BEINT must be signed and the size of size_t (range of sizeof(void*), BEUINT needs to be unsigned 
and size of size_t*/
/*BEFLOAT is size of BEINT presently*/
/*BEBYTE is for bytes*/
typedef int BEINT;
typedef unsigned int BEUINT;
typedef float BEFLOAT;

typedef struct BERS_Slab BERT_Slab;
typedef struct BERS_Hash BERT_Hash;
typedef struct BERS_HashEntry BERT_HashEntry;
typedef struct BERS_MtdDef BERT_MtdDef;
typedef struct BERS_Stacks BERT_Stacks;
typedef struct BERS_StackDef BERT_StackDef;
typedef struct BERS_Once BERT_Once;
typedef struct BERS_Except BERT_Except;
typedef struct BERS_Stackf BERT_Stackf;
typedef struct BERS_ClassDef BERT_ClassDef;
typedef struct BERS_Glob BERT_Glob;

typedef void (*bemcuinit)( );
typedef void (*bemcusinit)(BERT_Stacks* berv_sts);

typedef void** (*becd0)( int berv_chkt, BERT_Stacks* berv_sts, void** bevs);
typedef void** (*becd1)( int berv_chkt, BERT_Stacks* berv_sts, void** bevs, void** beav0);
typedef void** (*becd2)( int berv_chkt, BERT_Stacks* berv_sts, void** bevs, void** beav0, void** beav1);
typedef void** (*becd3)( int berv_chkt, BERT_Stacks* berv_sts, void** bevs, void** beav0, void** beav1, void** beav2);
typedef void** (*becd4)( int berv_chkt, BERT_Stacks* berv_sts, void** bevs, void** beav0, void** beav1, void** beav2, void** beav3);
typedef void** (*becd5)( int berv_chkt, BERT_Stacks* berv_sts, void** bevs, void** beav0, void** beav1, void** beav2, void** beav3, void** beav4);
typedef void** (*becd6)( int berv_chkt, BERT_Stacks* berv_sts, void** bevs, void** beav0, void** beav1, void** beav2, void** beav3, void** beav4, void** beav5);
typedef void** (*becd7)( int berv_chkt, BERT_Stacks* berv_sts, void** bevs, void** beav0, void** beav1, void** beav2, void** beav3, void** beav4, void** beav5, void** beav6);
typedef void** (*becd8)( int berv_chkt, BERT_Stacks* berv_sts, void** bevs, void** beav0, void** beav1, void** beav2, void** beav3, void** beav4, void** beav5, void** beav6, void** beav7);
typedef void** (*becd8)( int berv_chkt, BERT_Stacks* berv_sts, void** bevs, void** beav0, void** beav1, void** beav2, void** beav3, void** beav4, void** beav5, void** beav6, void** beav7);
typedef void** (*becd9)( int berv_chkt, BERT_Stacks* berv_sts, void** bevs, void** beav0, void** beav1, void** beav2, void** beav3, void** beav4, void** beav5, void** beav6, void** beav7, void** beav8);
typedef void** (*becd10)( int berv_chkt, BERT_Stacks* berv_sts, void** bevs, void** beav0, void** beav1, void** beav2, void** beav3, void** beav4, void** beav5, void** beav6, void** beav7, void** beav8, void** beav9);
typedef void** (*becd11)( int berv_chkt, BERT_Stacks* berv_sts, void** bevs, void** beav0, void** beav1, void** beav2, void** beav3, void** beav4, void** beav5, void** beav6, void** beav7, void** beav8, void** beav9, void** beav10);
typedef void** (*becd12)( int berv_chkt, BERT_Stacks* berv_sts, void** bevs, void** beav0, void** beav1, void** beav2, void** beav3, void** beav4, void** beav5, void** beav6, void** beav7, void** beav8, void** beav9, void** beav10, void** beav11);
typedef void** (*becd13)( int berv_chkt, BERT_Stacks* berv_sts, void** bevs, void** beav0, void** beav1, void** beav2, void** beav3, void** beav4, void** beav5, void** beav6, void** beav7, void** beav8, void** beav9, void** beav10, void** beav11, void** beav12);
typedef void** (*becd14)( int berv_chkt, BERT_Stacks* berv_sts, void** bevs, void** beav0, void** beav1, void** beav2, void** beav3, void** beav4, void** beav5, void** beav6, void** beav7, void** beav8, void** beav9, void** beav10, void** beav11, void** beav12, void** beav13);
typedef void** (*becd15)( int berv_chkt, BERT_Stacks* berv_sts, void** bevs, void** beav0, void** beav1, void** beav2, void** beav3, void** beav4, void** beav5, void** beav6, void** beav7, void** beav8, void** beav9, void** beav10, void** beav11, void** beav12, void** beav13, void** beav14);
typedef void** (*becd16)( int berv_chkt, BERT_Stacks* berv_sts, void** bevs, void** beav0, void** beav1, void** beav2, void** beav3, void** beav4, void** beav5, void** beav6, void** beav7, void** beav8, void** beav9, void** beav10, void** beav11, void** beav12, void** beav13, void** beav14, void** beav15);

typedef void** (*becdx16)( int berv_chkt, BERT_Stacks* berv_sts, void** bevs, void** beav0, void** beav1, void** beav2, void** beav3, void** beav4, void** beav5, void** beav6, void** beav7, void** beav8, void** beav9, void** beav10, void** beav11, void** beav12, void** beav13, void** beav14, void** beav15, void** beax);

struct BERS_Slab {
    BERT_Slab* prior;
    BERT_Slab* next;
    char* slab;
    char* slabAt;
    size_t slabEnd;
    size_t slabSize;
};

struct BERS_Hash {
   BERT_HashEntry** entries;
   BEINT mod;
};

struct BERS_HashEntry {
   BEINT keyHash;
   char* key;
   void* value;
   BEINT num;
};

/* used for accessor optimizations (call avoidance) and dynamic calls */
/* usage assumes pidx can never be 0 (at least a cldef slot for all objs) */
struct BERS_MtdDef {
   /* pointer to the call */
   void** mcall; 
   
   /* if this is a generated accessor, this will be the index of the property
    * in the object used to avoid calls where possible (twpi_) */ 
   size_t pidx; 
   
   /*
    * the twnn value, unique per-name serial used to confirm a method's identity
    */
    BEINT twnn;

};

struct BERS_Stacks {
   void** passBack;
   size_t allocsTotal;
   size_t allocsSinceCollect;
   size_t allocsBeforeCollect;
   size_t beforeCollectDivisor;
   size_t beforeCollectMultiplier;
   void** firstAlloc;
   void** lastAlloc;
   BERT_Once* lastOnce;
   BERT_Glob* berv_glob;
   BERT_Stacks* nextStacks;
   BERT_ClassDef* passedClassDef;
   void*  pthr;
   void** instBuild;
   void** bool_True;
   void** bool_False;
   void** bools_singleton;
   void** url_singleton;
   void** exceptionBuilder_singleton;
   void** gcv; /*gc visit array*/
   BEINT gcvfpos; /*length of visit array*/
   BEINT initGcvlen; /*Starting size of visit array*/
   BEUINT vmark;
   BEUINT maxVmark;
   BEUINT maxBEUINT;
   BEUINT vmarkMask;
   volatile int execState; /* 0 - not yet started, 1 - started, 2 - started and finished, 3 - will never start, never reclaim, 5 - suspended */
   BERT_Slab** allocSlabs;
   BERT_Slab** freeFirstAllocSlabs;
   size_t slabSize;
   size_t slabsOutThere;
   float debugPos;
   BERT_Stackf* stackf;
   void** forwardArgs;
   BEINT forwardNumargs;
   char* forwardName;
   void** onceInstances; /*class instances*/
   void** onceEvalVars; /*once variables, assigned with =@ or literals (String, Int)*/
   BEINT** onceEvalFlags; /*flag to foce once assign, only matters in null return cases*/
#ifdef BED_GCSTATS
   size_t collects;
   size_t slabsReleased;
   size_t avgGcAllocs;
   size_t instancesCreated;
   size_t instancesReused;
   size_t instancesNonSlab;
#endif
};

struct BERS_StackDef {
   char* cname;
   char* sname;
   BEINT twvhl;
};

struct BERS_Stackf {
   BERT_StackDef* stackDef;
   BERT_Stackf* prior;
   void** bevs;
   /* array of pointers to pointers of local references, used for gc stack mark (at least) */
   void** twvp;
   BEINT twvmp;
   BERT_Except* except;
};

struct BERS_Once {
   BERT_Once* prior;
   void** bevo;
};

struct BERS_Except {
   jmp_buf env;
};

/*
 * Every entry in the BERS_ClassDef struct should be == sizeof(void*)
 * this is because we abuse the memory buffer to also be used as an 
 * extended structure accessed via aray subscripts
 * for things like typed method calls (vtable) and typed property 
 * accessors by making it bigger than it needs to be
 * The build code knows the "size" of this too, so if you add something
 * you need to arrange to simulataneously change that value too
 * Currently, 25 pointer slots, mtdxPad in Constants (build.constants)
 * needs to be set to at least this value
 */
struct BERS_ClassDef {
   char* className;
   BERT_ClassDef* twst_supercd;
   BEINT minProperty;
   BEINT maxProperty;
   size_t loneAlloc;
   size_t allocSize;
   size_t allocBucket;
   BEINT freeFirstSlot;
   BEINT firstSlotNative; /*I think we can get rid of this, now minProperty*/
   BEINT isFinal;
   BEINT isLocal;
   BEINT isArray;
   BEINT classId;
   BEINT onceEvalCount;
   /* len of mtdarray (off the end of the class, for mtd vtable) */
   size_t mtdArLen; 
   /* the mlist, used for building dmlist as needed and for accessor call avoidance 
    * is a list mirroring the order of the mtdAr (off the end of class, mtd vtable) */
   BERT_MtdDef** mlist;
   /* len of the dmlist */ 
   size_t dmlistlen; 
   /* the dmlist, is a hash bucket list used for dynamic calls */
   BERT_MtdDef** dmlist;
};

struct BERS_Glob {
   BERT_Stacks* firstStacks;
   BERT_Stacks* lastStacks;
   BERT_Hash* nameHash;
   BERT_Hash* classHash;
   BEINT nextCallId;
   BEINT nextClassId;
   bemcusinit mainCuData;
   bemcuinit mainCuClear;
   size_t twrbsz;
   bemcusinit mainNotNullInit;
};

#ifdef BENM_ISNIX
                                            
void BERF_OutputCrashInfo(int sig);

void BERF_Crash(int sig);

void BERF_Signal_CRASH(int sig);

#endif


#ifdef BENM_DLLEXPORT
#ifdef BENC_Base
__declspec(dllexport)
#endif
#ifndef BENC_Base
__declspec(dllimport)
#endif
#endif
BEINT BERF_GetCallIdForName(BERT_Glob* blah, char* key, BEINT keyHash);

#ifdef BENM_DLLEXPORT
#ifdef BENC_Base
__declspec(dllexport)
#endif
#ifndef BENC_Base
__declspec(dllimport)
#endif
#endif
void BERF_Dmlist_Initialize(BERT_ClassDef* twst_shared_cd);

#ifdef BENM_DLLEXPORT
#ifdef BENC_Base
__declspec(dllexport)
#endif
#ifndef BENC_Base
__declspec(dllimport)
#endif
#endif
void BERF_Dmlist_FillEmpty(BERT_ClassDef* twst_shared_cd);

#ifdef BENM_DLLEXPORT
#ifdef BENC_Base
__declspec(dllexport)
#endif
#ifndef BENC_Base
__declspec(dllimport)
#endif
#endif
void BERF_Dmlist_Insert_With_Retry(BERT_ClassDef* twst_shared_cd, BERT_MtdDef* mtd);

#ifdef BENM_DLLEXPORT
#ifdef BENC_Base
__declspec(dllexport)
#endif
#ifndef BENC_Base
__declspec(dllimport)
#endif
#endif
size_t BERF_Dmlist_Insert(BERT_ClassDef* twst_shared_cd, BERT_MtdDef* mtd);

#ifdef BENM_DLLEXPORT
#ifdef BENC_Base
__declspec(dllexport)
#endif
#ifndef BENC_Base
__declspec(dllimport)
#endif
#endif
void BERF_Dmlist_ReHash(BERT_ClassDef* twst_shared_cd, size_t multiplier, size_t adder);

#ifdef BENM_DLLEXPORT
#ifdef BENC_Base
__declspec(dllexport)
#endif
#ifndef BENC_Base
__declspec(dllimport)
#endif
#endif
void BERF_Dmlist_Setup_Test(BERT_ClassDef* twst_shared_cd, size_t multiplier, size_t adder);

#ifdef BENM_DLLEXPORT
#ifdef BENC_Base
__declspec(dllexport)
#endif
#ifndef BENC_Base
__declspec(dllimport)
#endif
#endif
void BERF_Dmlist_Setup(BERT_ClassDef* twst_shared_cd, size_t multiplier, size_t adder);

#ifdef BENM_DLLEXPORT
#ifdef BENC_Base
__declspec(dllexport)
#endif
#ifndef BENC_Base
__declspec(dllimport)
#endif
#endif
void* BERF_Hash_PutOnce(BERT_Hash* hash, BEINT keyHash, char* key, void* value);

#ifdef BENM_DLLEXPORT
#ifdef BENC_Base
__declspec(dllexport)
#endif
#ifndef BENC_Base
__declspec(dllimport)
#endif
#endif
void* BERF_Hash_PutEntryOnce(BERT_Hash* hash, BERT_HashEntry* entry);

#ifdef BENM_DLLEXPORT
#ifdef BENC_Base
__declspec(dllexport)
#endif
#ifndef BENC_Base
__declspec(dllimport)
#endif
#endif
void* BERF_Hash_Get(BERT_Hash* hash, BEINT keyHash, char* key);

#ifdef BENM_DLLEXPORT
#ifdef BENC_Base
__declspec(dllexport)
#endif
#ifndef BENC_Base
__declspec(dllimport)
#endif
#endif
BERT_ClassDef* BERF_ClassDef_Get(BEINT keyHash, char* key);

#ifdef BENM_DLLEXPORT
#ifdef BENC_Base
__declspec(dllexport)
#endif
#ifndef BENC_Base
__declspec(dllimport)
#endif
#endif
void BERF_Hash_ReHash(BERT_Hash* hash);

#ifdef BENM_DLLEXPORT
#ifdef BENC_Base
__declspec(dllexport)
#endif
#ifndef BENC_Base
__declspec(dllimport)
#endif
#endif
BERT_Hash* BERF_Hash_InitHash(BERT_Hash* hash, BEINT value);

#ifdef BENM_DLLEXPORT
#ifdef BENC_Base
__declspec(dllexport)
#endif
#ifndef BENC_Base
__declspec(dllimport)
#endif
#endif
void BERF_Init(BERT_Stacks* berv_sts);

#ifdef BENM_DLLEXPORT
#ifdef BENC_Base
__declspec(dllexport)
#endif
#ifndef BENC_Base
__declspec(dllimport)
#endif
#endif
BEINT BERF_HashForString(char* string);

#ifdef BENM_DLLEXPORT
#ifdef BENC_Base
__declspec(dllexport)
#endif
#ifndef BENC_Base
__declspec(dllimport)
#endif
#endif
void BERF_PrepareClassData(BERT_Stacks* berv_sts, BERT_ClassDef* twrv_cldef);

#ifdef BENM_DLLEXPORT
#ifdef BENC_Base
__declspec(dllexport)
#endif
#ifndef BENC_Base
__declspec(dllimport)
#endif
#endif
void** BERF_Create_Instance(BERT_Stacks* berv_sts, BERT_ClassDef* bevl_scldef, BEINT attempt);

#ifdef BENM_DLLEXPORT
#ifdef BENC_Base
__declspec(dllexport)
#endif
#ifndef BENC_Base
__declspec(dllimport)
#endif
#endif
void BERF_Add_Once(BERT_Stacks* berv_sts, void** bevs);

#ifdef BENM_DLLEXPORT
#ifdef BENC_Base
__declspec(dllexport)
#endif
#ifndef BENC_Base
__declspec(dllimport)
#endif
#endif
void** BERF_String_For_Chars(BERT_Stacks* berv_sts, char* cstr);

#ifdef BENM_DLLEXPORT
#ifdef BENC_Base
__declspec(dllexport)
#endif
#ifndef BENC_Base
__declspec(dllimport)
#endif
#endif
void** BERF_String_For_Chars_Size(BERT_Stacks* berv_sts, char* cstr, BEINT nchars);

#ifdef BENM_DLLEXPORT
#ifdef BENC_Base
__declspec(dllexport)
#endif
#ifndef BENC_Base
__declspec(dllimport)
#endif
#endif
char* BERF_Copy_Chars(char* cstr);

#ifdef BENM_DLLEXPORT
#ifdef BENC_Base
__declspec(dllexport)
#endif
#ifndef BENC_Base
__declspec(dllimport)
#endif
#endif
void BERF_Collect(BERT_Stacks* berv_sts);

#ifdef BENM_DLLEXPORT
#ifdef BENC_Base
__declspec(dllexport)
#endif
#ifndef BENC_Base
__declspec(dllimport)
#endif
#endif
void BERF_Throw(BERT_Stacks* berv_sts, void** _passBack, char* inClassNamed, char* inMtdNamed, char* filename, int line);

#ifdef BENM_DLLEXPORT
#ifdef BENC_Base
__declspec(dllexport)
#endif
#ifndef BENC_Base
__declspec(dllimport)
#endif
#endif
void** BERF_MethodNotDefined(int berv_chkt, BERT_Stacks* berv_sts, void** bevl_bevs, void** bevl_forwardArgs, BEINT bevl_forwardNumargs, char* bevl_forwardName);

#ifdef BENM_DLLEXPORT
#ifdef BENC_Base
__declspec(dllexport)
#endif
#ifndef BENC_Base
__declspec(dllimport)
#endif
#endif
void** BERF_MethodNotDefined0(int berv_chkt, BERT_Stacks* berv_sts, void** bevl_bevs, BEINT bevl_forwardNumargs, char* bevl_forwardName);

#ifdef BENM_DLLEXPORT
#ifdef BENC_Base
__declspec(dllexport)
#endif
#ifndef BENC_Base
__declspec(dllimport)
#endif
#endif
void** BERF_MethodNotDefined1(int berv_chkt, BERT_Stacks* berv_sts, void** bevl_bevs, BEINT bevl_forwardNumargs, char* bevl_forwardName, void** beav0);

#ifdef BENM_DLLEXPORT
#ifdef BENC_Base
__declspec(dllexport)
#endif
#ifndef BENC_Base
__declspec(dllimport)
#endif
#endif
void** BERF_MethodNotDefined2(int berv_chkt, BERT_Stacks* berv_sts, void** bevl_bevs, BEINT bevl_forwardNumargs, char* bevl_forwardName, void** beav0, void** beav1);

#ifdef BENM_DLLEXPORT
#ifdef BENC_Base
__declspec(dllexport)
#endif
#ifndef BENC_Base
__declspec(dllimport)
#endif
#endif
void** BERF_MethodNotDefined3(int berv_chkt, BERT_Stacks* berv_sts, void** bevl_bevs, BEINT bevl_forwardNumargs, char* bevl_forwardName, void** beav0, void** beav1, void** beav2);

#ifdef BENM_DLLEXPORT
#ifdef BENC_Base
__declspec(dllexport)
#endif
#ifndef BENC_Base
__declspec(dllimport)
#endif
#endif
void** BERF_MethodNotDefined4(int berv_chkt, BERT_Stacks* berv_sts, void** bevl_bevs, BEINT bevl_forwardNumargs, char* bevl_forwardName, void** beav0, void** beav1, void** beav2, void** beav3);

#ifdef BENM_DLLEXPORT
#ifdef BENC_Base
__declspec(dllexport)
#endif
#ifndef BENC_Base
__declspec(dllimport)
#endif
#endif
void** BERF_MethodNotDefined5(int berv_chkt, BERT_Stacks* berv_sts, void** bevl_bevs, BEINT bevl_forwardNumargs, char* bevl_forwardName, void** beav0, void** beav1, void** beav2, void** beav3, void** beav4);

#ifdef BENM_DLLEXPORT
#ifdef BENC_Base
__declspec(dllexport)
#endif
#ifndef BENC_Base
__declspec(dllimport)
#endif
#endif
void** BERF_MethodNotDefined6(int berv_chkt, BERT_Stacks* berv_sts, void** bevl_bevs, BEINT bevl_forwardNumargs, char* bevl_forwardName, void** beav0, void** beav1, void** beav2, void** beav3, void** beav4, void** beav5);

#ifdef BENM_DLLEXPORT
#ifdef BENC_Base
__declspec(dllexport)
#endif
#ifndef BENC_Base
__declspec(dllimport)
#endif
#endif
void** BERF_MethodNotDefined7(int berv_chkt, BERT_Stacks* berv_sts, void** bevl_bevs, BEINT bevl_forwardNumargs, char* bevl_forwardName, void** beav0, void** beav1, void** beav2, void** beav3, void** beav4, void** beav5, void** beav6);

#ifdef BENM_DLLEXPORT
#ifdef BENC_Base
__declspec(dllexport)
#endif
#ifndef BENC_Base
__declspec(dllimport)
#endif
#endif
void** BERF_MethodNotDefined8(int berv_chkt, BERT_Stacks* berv_sts, void** bevl_bevs, BEINT bevl_forwardNumargs, char* bevl_forwardName, void** beav0, void** beav1, void** beav2, void** beav3, void** beav4, void** beav5, void** beav6, void** beav7);

#ifdef BENM_DLLEXPORT
#ifdef BENC_Base
__declspec(dllexport)
#endif
#ifndef BENC_Base
__declspec(dllimport)
#endif
#endif
void** BERF_MethodNotDefined9(int berv_chkt, BERT_Stacks* berv_sts, void** bevl_bevs, BEINT bevl_forwardNumargs, char* bevl_forwardName, void** beav0, void** beav1, void** beav2, void** beav3, void** beav4, void** beav5, void** beav6, void** beav7, void** beav8);

#ifdef BENM_DLLEXPORT
#ifdef BENC_Base
__declspec(dllexport)
#endif
#ifndef BENC_Base
__declspec(dllimport)
#endif
#endif
void** BERF_MethodNotDefined10(int berv_chkt, BERT_Stacks* berv_sts, void** bevl_bevs, BEINT bevl_forwardNumargs, char* bevl_forwardName, void** beav0, void** beav1, void** beav2, void** beav3, void** beav4, void** beav5, void** beav6, void** beav7, void** beav8, void** beav9);

#ifdef BENM_DLLEXPORT
#ifdef BENC_Base
__declspec(dllexport)
#endif
#ifndef BENC_Base
__declspec(dllimport)
#endif
#endif
void** BERF_MethodNotDefined11(int berv_chkt, BERT_Stacks* berv_sts, void** bevl_bevs, BEINT bevl_forwardNumargs, char* bevl_forwardName, void** beav0, void** beav1, void** beav2, void** beav3, void** beav4, void** beav5, void** beav6, void** beav7, void** beav8, void** beav9, void** beav10);

#ifdef BENM_DLLEXPORT
#ifdef BENC_Base
__declspec(dllexport)
#endif
#ifndef BENC_Base
__declspec(dllimport)
#endif
#endif
void** BERF_MethodNotDefined12(int berv_chkt, BERT_Stacks* berv_sts, void** bevl_bevs, BEINT bevl_forwardNumargs, char* bevl_forwardName, void** beav0, void** beav1, void** beav2, void** beav3, void** beav4, void** beav5, void** beav6, void** beav7, void** beav8, void** beav9, void** beav10, void** beav11);

#ifdef BENM_DLLEXPORT
#ifdef BENC_Base
__declspec(dllexport)
#endif
#ifndef BENC_Base
__declspec(dllimport)
#endif
#endif
void** BERF_MethodNotDefined13(int berv_chkt, BERT_Stacks* berv_sts, void** bevl_bevs, BEINT bevl_forwardNumargs, char* bevl_forwardName, void** beav0, void** beav1, void** beav2, void** beav3, void** beav4, void** beav5, void** beav6, void** beav7, void** beav8, void** beav9, void** beav10, void** beav11, void** beav12);

#ifdef BENM_DLLEXPORT
#ifdef BENC_Base
__declspec(dllexport)
#endif
#ifndef BENC_Base
__declspec(dllimport)
#endif
#endif
void** BERF_MethodNotDefined14(int berv_chkt, BERT_Stacks* berv_sts, void** bevl_bevs, BEINT bevl_forwardNumargs, char* bevl_forwardName, void** beav0, void** beav1, void** beav2, void** beav3, void** beav4, void** beav5, void** beav6, void** beav7, void** beav8, void** beav9, void** beav10, void** beav11, void** beav12, void** beav13);

#ifdef BENM_DLLEXPORT
#ifdef BENC_Base
__declspec(dllexport)
#endif
#ifndef BENC_Base
__declspec(dllimport)
#endif
#endif
void** BERF_MethodNotDefined15(int berv_chkt, BERT_Stacks* berv_sts, void** bevl_bevs, BEINT bevl_forwardNumargs, char* bevl_forwardName, void** beav0, void** beav1, void** beav2, void** beav3, void** beav4, void** beav5, void** beav6, void** beav7, void** beav8, void** beav9, void** beav10, void** beav11, void** beav12, void** beav13, void** beav14);

#ifdef BENM_DLLEXPORT
#ifdef BENC_Base
__declspec(dllexport)
#endif
#ifndef BENC_Base
__declspec(dllimport)
#endif
#endif
void** BERF_MethodNotDefined16(int berv_chkt, BERT_Stacks* berv_sts, void** bevl_bevs, BEINT bevl_forwardNumargs, char* bevl_forwardName, void** beav0, void** beav1, void** beav2, void** beav3, void** beav4, void** beav5, void** beav6, void** beav7, void** beav8, void** beav9, void** beav10, void** beav11, void** beav12, void** beav13, void** beav14, void** beav15);

#ifdef BENM_DLLEXPORT
#ifdef BENC_Base
__declspec(dllexport)
#endif
#ifndef BENC_Base
__declspec(dllimport)
#endif
#endif
void** BERF_MethodNotDefinedx16(int berv_chkt, BERT_Stacks* berv_sts, void** bevl_bevs, BEINT bevl_forwardNumargs, char* bevl_forwardName, void** beav0, void** beav1, void** beav2, void** beav3, void** beav4, void** beav5, void** beav6, void** beav7, void** beav8, void** beav9, void** beav10, void** beav11, void** beav12, void** beav13, void** beav14, void** beav15, void** beax);

#ifdef BENM_DLLEXPORT
#ifdef BENC_Base
__declspec(dllexport)
#endif
#ifndef BENC_Base
__declspec(dllimport)
#endif
#endif
void BERF_Throw_CallOnNull(BERT_Stacks* berv_sts, char* clname, char* subname, char* fname, int line);

#ifdef BENM_DLLEXPORT
#ifdef BENC_Base
__declspec(dllexport)
#endif
#ifndef BENC_Base
__declspec(dllimport)
#endif
#endif
void BERF_Throw_IncorrectType(BERT_Stacks* berv_sts, char* clname, char* subname, char* fname, int line);

#ifdef BENM_ISNIX

void BERF_Install_Signal_Handlers();

#endif

#ifdef BENM_DLLEXPORT
#ifdef BENC_Base
__declspec(dllexport)
#endif
#ifndef BENC_Base
__declspec(dllimport)
#endif
#endif
int BERF_Run_Main(int argc, char **argv, char* klasschar, bemcuinit cuinit, char* platchar);

#ifdef BENM_DLLEXPORT
#ifdef BENC_Base
__declspec(dllexport)
#endif
#ifndef BENC_Base
__declspec(dllimport)
#endif
#endif
int BERF_Start_Process(int argc, char **argv, char* klasschar, char* platchar);

#ifdef BENM_DLLEXPORT
#ifdef BENC_Base
__declspec(dllexport)
#endif
#ifndef BENC_Base
__declspec(dllimport)
#endif
#endif
int BERF_Start_Process_Free_Args(int argc, char **argv, char* klasschar, char* platchar);

#ifdef BENM_DLLEXPORT
#ifdef BENC_Base
__declspec(dllexport)
#endif
#ifndef BENC_Base
__declspec(dllimport)
#endif
#endif
BERT_Stacks* BERF_New_Stacks();

#ifdef BENM_DLLEXPORT
#ifdef BENC_Base
__declspec(dllexport)
#endif
#ifndef BENC_Base
__declspec(dllimport)
#endif
#endif
void BERF_WaitLoop();

#ifdef BENM_DLLEXPORT
#ifdef BENC_Base
__declspec(dllexport)
#endif
#ifndef BENC_Base
__declspec(dllimport)
#endif
#endif
extern BERT_Glob* BERV_proc_glob;

#ifndef __cplusplus
 extern char **environ;
#endif

#endif
