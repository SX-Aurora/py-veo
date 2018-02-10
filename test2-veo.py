import veo
import os
import time

p = veo.VeoProc(0)
lib = p.load_library(os.getcwd() + "/libvetest2.so")
f = lib.find_function("print_args")
c = p.open_context()

args = (-12, 123456, -1234L, 1234567L, 0.12345, 0.12345)
print "sending args: %r" % (args,)
f.args_type("int", "unsigned int", "long", "unsigned long", "double", "float")
req = f(c, *args)
req.wait_result()

print "\nand now 10 arguments!\n"
f2 = lib.find_function("print_args10")

fargs = ["int"] * 10
f2.args_type(*fargs)
args = (1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
print "sending args: %r" % (args,)
req = f2(c, *args)
req.wait_result()

args = (-12, 123456, -1234L, 1234567L, 0.12345, 0.12345)
req = f(c, *args)
req.wait_result()

args = (1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
req = f2(c, *args)
req.wait_result()

args = (-12, 123456, -1234L, 1234567L, 0.12345, 0.12345)
req = f(c, *args)
req.wait_result()

del p
print "finished"
