import veo
import os
import numpy as np


print """
VEO test:

Call a fortran subroutine and pass in a numpy integer array, the address
of a second array and the number of elements of the arrays.

Return the sum of the elements of the first array.

Increment each input array element by 2 and store the value into the
second array.

Retrieve the second array after the VEO Fortran function was called. Display it.

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

buff_ve = p.alloc_mem( round(buff2.size * 4, 8) )
print "allocated buffer on VE: ", buff_ve

p.write_mem(buff_ve, buff2, buff2.size * 4)
print "wrote buff2 to VE (zeros)."


f.args_type("int *", "int *", "int *")
f.ret_type("int")

req = f(c, veo.OnStack(buff, inout=veo.INTENT_IN),
        buff_ve,
        veo.OnStack(nbuff))

res = req.wait_result()

print "res = ", res

p.read_mem(buff2, buff_ve, buff2.size * 4)
print "read buff2 from VE."

print "buff2 after VEO call:", buff2

del p
print "finished"
