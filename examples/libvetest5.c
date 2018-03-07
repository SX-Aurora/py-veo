//
// /opt/nec/ve/bin/ncc -shared -fpic -pthread -o libvetest5.so libvetest5.c
//
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void *malloc_buff(char *buff)
{
	printf("[VE] argument on stack: %s\n", buff);
	void *b = malloc(strlen(buff)+1);
	
	printf("[VE] malloced buff at address %p\n", b);
	memcpy(b, buff, strlen(buff) + 1);
	return b;
}

