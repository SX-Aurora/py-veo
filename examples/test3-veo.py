import veo
import os
import time

def proc_hook(x):
    print("hello %r, this is the proc_init_hook!" % x)


print("\nVEO test:")
print("Call a trivial function as proc init_hook, call some trivial function to check that VEO works.")
print("Not opening a second VeoProc instance after the deletion of the first one due to a bug.")
print("\n")

veo.set_proc_init_hook(proc_hook)

p=veo.VeoProc(0)
lib=p.load_library(os.getcwd() + "/libvetest2.so")
f=lib.find_function("print_args")
c=p.open_context()

f.args_type("int", "unsigned int", "long", "unsigned long", "double", "float")
print(f)
args = (-12, 123456, -1234L, 1234567L, 0.12345, 0.12345)
print("sending args: %r" % (args,))
req=f(c, *args)
print(req)
r=req.wait_result()

del p
print("finished")
