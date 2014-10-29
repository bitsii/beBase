#include "first.h"


x* makex() {
   x *s = malloc(sizeof(x));
   return s;
}

int main() { 
    x *s = makex();
    char *base;
    int offset;
    int *b;

    // initialize both members to known values
    s->member_a = 1;
    s->member_b = 2;

    // get base address
    base = (char *)s;

    // and the offset to member_b
    offset = offsetof(x, member_b);

    // Compute address of member_b
    b = (int *)(base+offset);

    // write to member_b via our pointer
    *b = 10;

    // print out via name, to show it was changed to new value.
    printf("%d\n", s->member_b);
    return 0;
}

