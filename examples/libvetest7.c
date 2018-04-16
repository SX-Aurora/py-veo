//
// /opt/nec/ve/bin/ncc -shared -fpic -pthread -o libvetest7.so libvetest7.c
//
#include <stdio.h>
#include <unistd.h>

void print_mod_buff(char *buff)
{
	printf("[VE] buff at address %p\n", (void *)buff);
        printf("[VE] buff content: %s\n", buff);
	sprintf(buff, "%s", "Hola VH!!!");
}

