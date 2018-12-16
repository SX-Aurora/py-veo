import veo
import os
import numpy as np


print("\nVEO test:")
print("Allocate a buffer on VE, copy a string asynchronously to it.")
print("Display its address as seen on the VE and display the content as string.")
print("Modify buffer on VE and retrieve the buffer asynchronously.")
print("Display the content of modified buffer as a string.\n")

def round(n, r):
    return int(r * ((n + (r - 1)) / r))


p = veo.VeoProc(0)
lib = p.load_library(os.getcwd() + "/libvetest7.so")
f = lib.find_function("print_mod_buff")
c = p.open_context()

buff = np.frombuffer("Hello VE!!!\x00", dtype=np.uint8)

buff_ve = p.alloc_mem( round(buff.size, 8) )
print("allocated buffer on VE: ", buff_ve)

r1 = c.async_write_mem(buff_ve, buff, buff.size)
print("async_write req:", r1)

f.args_type("char *")
r2 = f(c, buff_ve)
print("print_mod_buff req:", r2)

r3 = c.async_read_mem(buff, buff_ve, buff.size)
print("async_read req:", r3)

r = r3.wait_result()
print("VH buffer:", buff.tobytes())

del p
print("finished")
