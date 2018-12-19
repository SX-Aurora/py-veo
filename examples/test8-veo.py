import veo
import os
import numpy as np


print("""
VEO test:
Pass an IN array and an INOUT array, the VE side sums up elements of IN array
and copies its values incremented by 2 into the second array.

Arguments are all passed by reference and their values are passed on the stack.
""")


def round(n, r):
    return int(r * ((n + (r - 1)) / r))

p = veo.VeoProc(0)
lib = p.load_library(os.getcwd() + "/libvetest8.so")
c = p.open_context()

buff = np.array([1,2,3,4,5], dtype=np.int32 )
buff2 = np.array([0,0,0,0,0], dtype=np.int32 )
nbuff = np.array([buff.size], dtype=np.int32 )
# this does not work
#nbuff = np.int32(buff.size)

lib.mod_buff.args_type("int *", "int *", "int *")
lib.mod_buff.ret_type("int")

req = lib.mod_buff(c, veo.OnStack(buff, inout=veo.INTENT_IN),
                   veo.OnStack(buff2, inout=veo.INTENT_INOUT),
                   veo.OnStack(nbuff))

res = req.wait_result()
print("request returns res = %r" % res)

print("buff2 after VEO call: %r" % buff2)

del p
print("finished")
