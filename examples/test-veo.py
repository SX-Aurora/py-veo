import veo
import os

print "\nVEO example:\nOpen a context and sleep 5s on the VE\n"

p = veo.VeoProc(0)
lib = p.load_library(os.getcwd() + "/libvesleep.so")
print "lib = ", lib

f = lib.find_function("do_sleep")
f.args_type("int")
print "f = ", f

c = p.open_context()

req = f(c, 5)
print "req = ", req
print "result = ", req.wait_result()

print "deleting proc"
del p
print "finished"
