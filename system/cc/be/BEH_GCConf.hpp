//allocsPerGc 0-4,294,967,295 :: 10000000 >>6000000<< OKish bld, 1000000 extec, diff is 1 0
#define BEDCC_GCAPERGC 666666
//#define BEDCC_GCAPERGC 10000000
//#define BEDCC_GCAPERGC 6666666 //norm
//to really test gc
//#define BEDCC_GCAPERGC 4444
//how many marks before a sweep
#define BEDCC_GCMPERS 16
//#define BEDCC_GCMPERS 1
//#define BED_GCNOREUSE
//#define BEDCC_GCMPERS 4
//sync count sometimes
//#define BEDCC_GCSHASYNC 8192
#define BEDCC_GCSHASYNC 1000
//#define BEDCC_GCSHASYNC 500
//sync do gc moretimes 2 4 8 16 32 64 128
#define BEDCC_GCSSCHECK 16
#define BEDCC_GCRWM 30000
//#define BEDCC_GCRWM 10
//size for heap stack
#define BEDCC_GCHSS 5000
//turn on stats/debug
#define BED_GCSTATS
