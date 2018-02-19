//
// /opt/nec/ve/bin/ncc -shared -fpic -pthread -o libvetest4.so libvetest4.c
//
#include <stdio.h>
#include <unistd.h>

void print_buff(char *buff)
{
	printf("[VE] buff at address %p\n", (void *)buff);
        printf("[VE] buff content: %s\n", buff);
}

