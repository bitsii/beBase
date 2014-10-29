gcc -c -D TWNM_ISWIN -D TWNM_DLLEXPORT -D TWNC_BaseTests -D TWNP_mswin -I . -o first.o first.c
gcc -D TWNM_ISWIN -shared -o first.dll first.o
