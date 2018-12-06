import veo
import os
import numpy as np


print """
VEO test:
Call a fortran subroutine and pass in a numpy integer array and its length.

"""


def round(n, r):
    return int(r * ((n + (r - 1)) / r))


p = veo.VeoProc(0)
lib = p.load_library(os.getcwd() + "/libvetest8.so")
f = lib.find_function("mod_buff_")
c = p.open_context()

buff = np.array([1,2,3,4,5], dtype=np.int32 )
buff2 = np.array([0,0,0,0,0], dtype=np.int32 )
nbuff = np.int32(buff.size)
# this works as well
#nbuff = np.array([buff.size], dtype=np.int32 )

f.args_type("int *", "int *", "int *")
f.ret_type("int")

req = f(c, veo.OnStack(buff, inout=veo.INTENT_IN),
        veo.OnStack(buff2, inout=veo.INTENT_INOUT),
        veo.OnStack(nbuff))

res = req.wait_result()

print "res = ", res

print "buff2 after VEO call:", buff2

del p
print "finished"
