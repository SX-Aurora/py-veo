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

![PyVEO components](https://192.168.50.140/gogs/focht/py-veo/src/master/doc/pyveo_components.gif)

### VeoProc

A `VeoProc` object corresponds to one running instance of the `veorun`
VE program that controls one address space on the VE. The command
```python
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



### VeoFunction

### VeoContext

### VeoRequest

### VEMemPtr



