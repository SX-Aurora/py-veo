import veo
import os
import time

print("\nVEO test:")
print("First function call passes 6 arguments of various types to VE, VE prints them.")
print("Second function passes 10 int arguments (on the stack), VE prints them.")
print("\n")

p = veo.VeoProc(0)
lib = p.load_library(os.getcwd() + "/libvetest2.so")
c = p.open_context()

args = (-12, 123456, -1234L, 1234567L, 0.12345, 0.12345)
print("sending args: %r" % (args,))
lib.print_args.args_type("int", "unsigned int", "long", "unsigned long", "double", "float")
req = lib.print_args(c, *args)
req.wait_result()

print("\nand now 10 arguments!\n")

fargs = ["int"] * 10
lib.print_args10.args_type(*fargs)
args = (1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
print("sending args: %r" % (args,))
req = lib.print_args10(c, *args)
req.wait_result()

del p
print("finished")
