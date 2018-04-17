import veo
import os


print "\nVEO test:"
print "Pass a string on stack to VE function. Function mallocs a buffer"
print "and copies the string into the buffer. The VH program copies the"
print "buffer content back and prints it."
print "\n"

p = veo.VeoProc(0)
lib = p.load_library(os.getcwd() + "/libvetest5.so")
f = lib.find_function("malloc_buff")
c = p.open_context()

f.args_type("char *")
f.ret_type("void *")

req = f(c, veo.OnStack(b'Hello from VH!\0', 15))
print req
r = req.wait_result()
print "received address from VE: %r" % r

buff = b'                                                       '
p.read_mem(buff, r, 15)

print buff

del p
print "finished"
