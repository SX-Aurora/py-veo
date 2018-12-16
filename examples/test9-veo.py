import veo
import os
import numpy as np


print """
VEO test:

Call a fortran function and pass in numpy arrays and parameters, by reference.

function test9(a, b, c, n, m)
    integer, dimension(n), intent(in) :: a
    integer, dimension(n) :: b
    double precision, intent(out) :: c(n,m)
    integer i, j, test9
    test9 = 0
    do i = 1, n
       test9 = test9 + a(i)
       b(i) = a(i) + 2
       do j = 1, m
          c(i,j) = dble(a(i)) * dble(j)
       end do
    end do
    return
end

a, b, c are numpy arrays, a, c are passed by reference, on the stack,
b is a buffer which was allocated separately on the VE and it's address
is passed as an argument. b and c are returned and printed.

"""


def round(n, r):
    return int(r * ((n + (r - 1)) / r))


p = veo.VeoProc(0)
lib = p.load_library(os.getcwd() + "/libvetest9.so")
f = lib.find_function("test9")
ctx = p.open_context()

n = 5; m = 3
a = np.array([1,2,3,4,5], dtype=np.int32)
b = np.array([0,0,0,0,0], dtype=np.int32)
c = np.zeros((n,m), dtype=np.float64, order="F")
nsz = np.array([a.size], dtype=np.int32)
msz = np.array([m], dtype=np.int32)
# this does not work
#nsz = np.int32(buff.size)

b_ve = p.alloc_mem( round(b.size * 4, 8) )
print("allocated b on VE: ", b_ve)

p.write_mem(b_ve, b, b.size * 4)
print("wrote b to VE (zeros).")

f.args_type("int *", "int *", "double *", "int *", "int *")
f.ret_type("int")

req = f(ctx, veo.OnStack(a, inout=veo.INTENT_IN),
        b_ve, veo.OnStack(c, inout=veo.INTENT_OUT),
        veo.OnStack(nsz), veo.OnStack(msz))

res = req.wait_result()

print("Request returns sum = ", res)

p.read_mem(b, b_ve, b.size * 4)
print("read b from VE.")

print("b after VEO call:", b)
print("c after VEO call:", c)

del p
print("finished")
