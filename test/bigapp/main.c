#include <stdio.h>
#include "sth.h"

extern void test();
extern void do_neat_stuff();

int main()
{
        printf("SOMETHING=%d\n", SOMETHING);
        test();
        do_neat_stuff();
        return 0;
}
