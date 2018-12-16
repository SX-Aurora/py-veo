import veo
import os
import numpy as np


print("\nVEO test:")
print("Allocate a buffer on VE, copy a string to it.")
print("Display its address as seen on the VE and display the content as string.")
print("\n")

def round(n, r):
    return int(r * ((n + (r - 1)) / r))


p = veo.VeoProc(0)
lib = p.load_library(os.getcwd() + "/libvetest4.so")
c = p.open_context()

buff = np.frombuffer("Hello VE!!!\x00", dtype=np.uint8)

buff_ve = p.alloc_mem( round(buff.size, 8) )
print("allocated buffer on VE: ", buff_ve)

p.write_mem(buff_ve, buff, buff.size)
print("wrote buffer to VE.")

lib.print_buff.args_type("char *")
req = lib.print_buff(c, buff_ve)
print(req)
r = req.wait_result()

del p
print("finished")
