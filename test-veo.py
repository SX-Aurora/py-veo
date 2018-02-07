import veo
import os
import time

p=veo.VeoProc(0)
ld=p.load_library("/home/focht/Tests/py-veo/libvesleep.so")
sym=p.get_sym(ld, "do_sleep")
print "sym=", sym
c=p.open_context()
req=c.call_async(sym, 10)
print "req=", req
print "result = ", c.wait_result(req)
print "deleting proc"
del p
print "finished"
