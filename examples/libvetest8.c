#include <stdio.h>

int mod_buff(int *a, int *b, int *c)
{
	int i, sum = 0, n = *c;

	printf("VE: &a=%x &b=%x n=%d\n", (void *)a, (void *)b, n);
        for (i = 0; i < n; i++) {
		printf("VE:(%d) a[%d]=%d\n", i, i, a[i]);
		sum += a[i];
		b[i] = a[i] + 2;
	}
	return sum;
}

