import veo
import os
import time

p=veo.VeoProc(0)
ld=p.load_library("/home/focht/Tests/py-veo/libvetest2.so")
sym=p.get_sym(ld, "print_args")
print "print_args is at %s" % hex(sym)
c=p.context_open()

args = (-12, 123456, -1234L, 1234567L, 0.12345, 0.12345)
print "sending args: %r" % (args,)
req=c.call_async(sym, *args)
c.wait_result(req)

print "\nand now 10 arguments!\n"
sym2=p.get_sym(ld, "print_args10")

print "print_args10 is at %s" % hex(sym2)
args = (1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
print "sending args: %r" % (args,)
req=c.call_async(sym2, *args)
c.wait_result(req)

args = (-12, 123456, -1234L, 1234567L, 0.12345, 0.12345)
req=c.call_async(sym, *args)
c.wait_result(req)

args = (1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
req=c.call_async(sym2, *args)
c.wait_result(req)

args = (-12, 123456, -1234L, 1234567L, 0.12345, 0.12345)
req=c.call_async(sym, *args)
c.wait_result(req)

del p
print "finished"
