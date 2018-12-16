import veo
import os
from cffi import FFI

print("\nVEO test:")
print("Pass a cffi built structure to the VE as argument on the stack.")
print("Sum the elements and multiply with a factor. Correct result is 30.")
print("\n")

p = veo.VeoProc(0)
lib = p.load_library(os.getcwd() + "/libvetest6.so")
c = p.open_context()

ffi = FFI()
ffi.cdef("""
    struct abc {
        int a, b, c;
    };
    """)

abc = ffi.new("struct abc *")
abc.a = 1
abc.b = 2
abc.c = 3

# we'll pass the struct * as a void *
lib.multeach.args_type("void *", "int")
lib.multeach.ret_type("int")

req = lib.multeach(c, veo.OnStack(ffi.buffer(abc)), 5)
r = req.wait_result()
print("result = %r" % r)

del p
print("finished")
