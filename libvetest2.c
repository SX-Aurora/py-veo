//
// /opt/nec/ve/bin/ncc -shared -fpic -pthread -o libvetest2.so libvetest2.c
//
#include <stdio.h>
#include <unistd.h>

void print_args(int a1, unsigned int a2, long a3, unsigned long a4, double a5, float a6)
{
	printf("a1 = %d\n", a1);
	printf("a2 = %u\n", a2);
	printf("a3 = %ld\n", a3);
	printf("a4 = %lu\n", a4);
	printf("a5 = %e\n", a5);
	printf("a6 = %e\n", a6);
}
