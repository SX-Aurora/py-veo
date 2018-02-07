import veo
import os
import time

p=veo.VeoProc(0)
ld=p.load_library("/home/focht/Tests/py-veo/libvetest2.so")
f=p.find_function(ld, "print_args")
c=p.open_context()

f.set_argsfmt("int", "unsigned int", "long", "unsigned long", "double", "float")
print f
args = (-12, 123456, -1234L, 1234567L, 0.12345, 0.12345)
print "sending args: %r" % (args,)
req=f.call(c, *args)
print req
r=req.wait_result()

del p
print "finished"
