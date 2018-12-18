import veo
import os

print("\nVEO example:\nOpen a context and sleep 5s on the VE\n")

b = veo.VeBuild()

b.set_c_src("_test", r"""
#include <stdio.h>
#include <unistd.h>

int flag = 0;
int do_sleep(int secs)
{
	
	printf("VE: flag value %d\n", flag);
        flag++;
	printf("VE: increased flag %d\n", flag);
	
	printf("VE: sleeping %d seconds\n", secs);
	sleep(secs);
	printf("VE: finished sleeping.\n");
	printf("VE: flag value %d\n", flag);
	return secs;
}
""")
kernel = b.build_so(verbose=False)
b.clean()

p = veo.VeoProc(0)
lib = p.load_library(os.getcwd() + "/" + kernel)
print("lib = %r" % lib)

lib.do_sleep.args_type("int")
print("lib.do_sleep = %r" % lib.do_sleep)

c = p.open_context()

req = lib.do_sleep(c, 5)
print("req = %r" % req)
print("result = %r" % req.wait_result())

print("deleting proc")
del p
print("finished")
