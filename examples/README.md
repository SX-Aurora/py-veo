# Examples

The examples in this directory also serve as tests for features.

Build *py-veo* in the directory above, then:
```
cd examples
make test
make test1
make test2
...
```

### test-veo.py

Basic test. Open a context and call a function on the VE that sleeps for 10s.

### test2-veo.py

Call two VE functions and demonstrate passing arguments of various
types. The first function call passes 6 arguments of various types to
VE, VE prints them.  The second function passes 10 int arguments (when
using more than 8 arguments, they are passed on the stack), VE prints
them.

### test3-veo.py

Test for init_hook() called when a VeoProc is instantiated. Call a
trivial function as proc init_hook, call some trivial function to
check that VEO works.

We are not opening a second VeoProc instance after the deletion of the
first one due to a bug.

### test4-veo.py

Test VeoProc.write_mem(). Allocate a buffer on VE, copy a string to
it. Display its address as seen on the VE and display the content as
string.

### test5-veo.py

Test passing args on stack with OnStack(). Pass a string on stack to
VE function. Function mallocs a buffer and copies the string into the
buffer. The VH program copies the buffer content back and prints it.

### test6-veo.py

Example for using *cffi*. Pass a cffi built structure to the VE as
argument on the stack.  Sum the elements and multiply with a
factor. Correct result that should be printed is 30.

### test7-veo.py

Test for VeoCtxt.async_write_mem() and
VeoCtxt.async_read_mem(). Allocate a buffer on VE, copy a string
asynchronously to it. Display its address as seen on the VE and
display the content on VE.  Modify buffer on VE and retrieve the
buffer asynchronously. Display the content of the modified buffer as a
string.

