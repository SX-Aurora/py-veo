import veo
import os

print("\nVEO example:\nOpen a context and sleep 5s on the VE\n")

p = veo.VeoProc(0)
lib = p.load_library(os.getcwd() + "/libvesleep.so")
print("lib = ", lib)

lib.do_sleep.args_type("int")
print("lib.do_sleep = ", lib.do_sleep)

c = p.open_context()

req = lib.do_sleep(c, 5)
print("req = ", req)
print("result = ", req.wait_result())

print("deleting proc")
del p
print("finished")
