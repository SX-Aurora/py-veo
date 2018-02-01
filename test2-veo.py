import veo
import os
import time

p=veo.VeoProc(0)
ld=p.load_library("/home/focht/Tests/py-veo/libvetest2.so")
sym=p.get_sym(ld, "print_args")
#print "sym=", sym
c=p.context_open()

args = (-12, 123456, -1234L, 1234567L, 0.12345, 0.12345)
print "sending args: %r" % (args,)
req=c.call_async(sym, *args)
c.wait_result(req)
del p
print "finished"
