#include "hash-ops.h"
#include <stdio.h>

int main() {
    int len = 0;
    char inputChar[len];

    char h[32];

    cn_slow_hash(&inputChar, len, &h[0]);

    for (int i = 0; i < sizeof(h); i++) {
        printf("%02x", (unsigned char)h[i]);
    }

    printf("\n%s", h);
    printf("unko\n");
return 0;
}
