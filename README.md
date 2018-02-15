# PyVEO: Python bindings to VEO

This package provides python bindings to VEO: Vector Engine Offloading.

## Introduction

The NEC Aurora Tsubasa Vector Engine (VE) is a very high memory
bandwidth vector processor with HBM2 memory in the form-factor of a
PCIe card. Currently up to eight VE cards can be inserted into a
vector host (VH) which is typically a x86_64 server.

The primary usage model of the VE is as a standalone computer which
uses the VH for offloading its operating system functionality. Each VE
card behaves like a separate computer with its own instance of
operating system (VEOS), it runs native VE programs compiled for the
vector CPU that are able to communicate with other VEs through MPI.

A second usage model of VEs lets native VE programs offload
functionality to the VH with the help of the VHcall mechanisms. The VH
is used by the VE as an accelerator for functions it is better suited
for, like unvectorizable code.

The third usage model is the classical accelerator model with a main
program compiled for the VH running high speed program kernels on the
VE. A mechanism for this usage model is the VE Offloading (VEO)
library provided by the veofload and veoffload-veorun RPMs.

This Python module is an implementation of the VEO API for Python
programs. It is an extension to the C API and exposes the mechanisms
through Python objects.


## Python VEO API

![PyVEO components](https://192.168.50.140/gogs/focht/py-veo/src/master/doc/pyveo_components.jpg)

### VeoProc

A `VeoProc` object corresponds to one running instance of the `veorun`
VE program that controls one address space on the VE. The command
```python
from veo import *

proc = VeoProc(nodeid)
```
creates a VEO process instance on the VE node `nodeid`. By default `VeoProc()`
starts `/opt/nec/ve/libexec/veorun`. It can be replaced by an own version with
statically linked libraries by pointing the environment variable **VEORUN_BIN**
to it.

**Methods:**
- `load_library(libname)` loads a `.so` dynamically linked shared object
fileinto the VEOProc address space. It returns a `VeoLibrary` object.
- `static_library()` returns a `VeoLibrary` object exposing the symbols
and functions statically linked with the running `veorun`-instance of
this `VeoProc`.
- `alloc_mem(size_t size)` allocates a memory buffer of size *size* on
the VE and returns a `VEMemPtr` object that points to it.
- `free_mem(VEMemPtr memptr)` frees the VE memory pointed to by the
`VEMemPtr` argument.
- `read_mem(np.ndarray dst, VEMemPtr src, size_t size)` read memory from
the VE memory buffer that *src* points to into a *numpy* array transfering
*size* bytes.
- `write_mem(VEMemPtr dst, np.ndarray src, size_t size)` write *size* bytes
from the *src* numpy array to the VE memory buffer pointed to by the *dst*
VEMemPtr.
- `open_context()` opens a worker thread context on the VE.
- `close_context(VeoContext ctx)` closes a context on the VE.
- `get_function(name)` searches for the function *name* in the `VeoFunction`
cache of each `VeoLibrary` object of the current `VeoProc` and returns the
`VeoFunction` object. A VE function appears in a library's cache only if it
was looked up before with the `find_library()` method of the `VeoLibrary` object.

**Attributes:**
- `nodeid` is the VE node ID on which the `VeoProc` is running.
- `context` is a list with the contexts active in the current `VeoProc` instance.
- `lib` is a dict of the `VeoLibrary` objects loaded into the `VeoProc`.



### VeoLibrary

Functions that need to be called on the VE must be loaded into the
*VeoProc* by loading a shared library .so file into the process
running on the VE. This is done by calling the `load_library()` method
of the *VeoProc* instance. The result is an instance of the
*VeoLibrary* class.

Example:
```python
import os

lib = proc.load_library(os.getcwd() + "/libvetest.so")
```

A special instance of *VeoLibrary* is the "static" library, that
represents the functions and symbols statically linked with the
*veorun* VE program that has been started by the *VeoProc*
instance. It does not need to be loaded but can be accessed by the
method `static_library()`.
```python
slib = proc.static_library()
```

The static library feature only needs to be used when the offloaded
functions can not be linked dynamically or cannot be compiled with
`-fpic`, for example because some of the libraries it uses is not
available as dynamic library.

**Methods:**
- `get_symbol(name)`: find a symbol's address in the *VeoLibrary* and return it as a *VEMemPtr*.
- `find_function(name)`: find a function in the current library and return it as an instance of *VeoFunction*.

**Attributes:**
- `name`: the name of the library, actually the full path from which it was loaded. The "static" library has the name `__static__`.
- `proc`: the *VeoProc* instance to which the library belongs.
- `func`: a `dict` containing all functions that were 'found' in the current library. The values are the corresponding *VeoFunction* instances.
- `symbol`: a `dict` containing all symbols and their *VEMemPtr* that were searched and found in the current library.


### VeoFunction

### VeoContext

### VeoRequest

### VEMemPtr

### Hooks

Whenever a *VeoProc* object is created it will check for the existence
of init hooks and call them at the end of the initialisation of the
*VeoProc* object. Functions that are registered and called as an init
hook must take one single argument: the *VeoProc* object. The are
registered by calling *set_proc_init_hook()*:
```python
from veo import set_proc_init_hook

def init_function(proc):
    # do something that needs to be done automatically
    # for each proc instance
    #...

set_proc_init_hook(init_function)
```

A practical use for the init hooks is the registration of the VE BLAS functions in *py-vecblas*:
```python
from veo import set_proc_init_hook

def _init_cblas_funcs(p):
    lib = p.static_library()
    for k, v in _cblas_proto.items():
        f = lib.find_function(k)
        if f is not None:
            fargs = v["args"]
            f.args_type(*fargs)
            f.ret_type(v["ret"])

set_proc_init_hook(_init_cblas_funcs)
```

The registration of the VE BLAS functions needs to be done for every
instance of *VeoProc* because each of the instances must find and
register its own set of *VeoFunction*s. By registering the init hook
the user will not need to load a library and find a function for each
of the started *VeoProc* processes, i.e. for each of the VE cards in
the system.

## Build & Install

