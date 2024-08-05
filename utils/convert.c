#include <stdio.h>

// Test converting hex to epoc sec to timestamp converter
int main(void)
{

#define __VAL   0x00d422ee

    const float f = (float)(__VAL);
    const unsigned int i = (int)(__VAL);
    printf("value as float = %f\nvalue as int = %d\n\n",f,i);
    return(0);
}

