//allocsPerGc 0-4,294,967,295 :: 10000000 >>6000000<< OKish bld, 1000000 extec, diff is 1 0
//#define BEDCC_GCAPERGC 1000000
//#define BEDCC_GCAPERGC 10000000
#define BEDCC_GCAPERGC 1111
//how many marks before a sweep
#define BEDCC_GCMPERS 1
//sync count sometimes
//#define BEDCC_GCSHASYNC 8192
#define BEDCC_GCSHASYNC 1000
//#define BEDCC_GCSHASYNC 500
//sync do gc moretimes 2 4 8 16 32 64 128
#define BEDCC_GCSSCHECK 8
#define BEDCC_GCRWM 60000
//#define BED_GCSTATS
