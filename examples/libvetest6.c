//
// /opt/nec/ve/bin/ncc -shared -fpic -pthread -o libvetest6.so libvetest6.c
//

struct abc {
	int a, b, c;
};

int multeach(struct abc *a, int n)
{
	return n*(a->a + a->b + a->c);
}
