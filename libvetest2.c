//
// /opt/nec/ve/bin/ncc -shared -fpic -pthread -o libvetest2.so libvetest2.c
//
#include <stdio.h>
#include <unistd.h>

void print_args(int a1, unsigned int a2, long a3, unsigned long a4, double a5, float a6)
{
	int a = a6;
	printf("stack pointer: %p\n", (void *)&a);
	printf("print_args: ");
	printf("a1 = %d, ", a1);
	printf("a2 = %u, ", a2);
	printf("a3 = %ld, ", a3);
	printf("a4 = %lu, ", a4);
	printf("a5 = %e, ", a5);
	printf("a6 = %e\n", a6);
}

void print_args10(int a1, int a2, int a3, int a4, int a5, int a6, int a7,
		  int a8, int a9, int a10)
{
	int a = a6;
	printf("stack pointer: %p\n", (void *)&a);
	printf("print_args10: ");
	printf("a1 = %d, ", a1);
	printf("a2 = %d, ", a2);
	printf("a3 = %d, ", a3);
	printf("a4 = %d, ", a4);
	printf("a5 = %d, ", a5);
	printf("a6 = %d, ", a6);
	printf("a7 = %d, ", a7);
	printf("a8 = %d, ", a8);
	printf("a9 = %d, ", a9);
	printf("a10= %d\n", a10);
}
