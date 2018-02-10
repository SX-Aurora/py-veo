from libveo cimport *

import os
import numbers
from struct import pack, unpack
import numpy as np
cimport numpy as np

include "conv_i64.pxi"

cdef _proc_init_hook
_proc_init_hook = None

cpdef set_proc_init_hook(v):
    """
    Hook for a function that should be called as last in the
    initialization of a VeoProc.

    Usefull eg. for loading functions from a statically linked library.
    """
    global _proc_init_hook
    _proc_init_hook = v


cdef union U64:
    uint64_t u64
    int64_t i64
    uint32_t u32[2]
    int32_t i32[2]
    uint16_t u16[4]
    int16_t i16[4]
    uint8_t u8[8]
    int8_t i8[8]
    float f32[2]
    double d64


cdef inline zsign(x):
    return 0 if x >= 0 else -1


cdef class VeoFunction(object):
    """
    VE Offloaded function
    """
    cdef readonly VeoLibrary lib
    cdef uint64_t addr
    cdef readonly name
    cdef readonly _args_type
    cdef readonly _ret_type
    cdef args_conv
    cdef ret_conv
    
    def __init__(self, lib, uint64_t addr, name):
        self.lib = lib
        self.addr = addr
        self.name = name
        self.args_conv = None
        self.ret_conv = conv_from_i64_func("int")

    def __repr__(self):
        out = "<%s object VE function %s%r at %s>" % \
              (self.__class__.__name__, self.name, self._args_type, hex(id(self)))
        return out

    def args_type(self, *args):
        self._args_type = args
        self.args_conv = list()
        for t in args:
            self.args_conv.append(conv_to_i64_func(t))

    def ret_type(self, rettype):
        self._ret_type = rettype
        self.ret_conv = conv_from_i64_func(rettype)

    def __call__(self, VeoCtxt ctx, *args):
        """
        Asynchrounously call a function on VE.

        Returns: VeoRequest instance, None in case of error.
        """
        if self._args_type is None:
            raise RuntimeError("VeoFunction needs arguments format info before call()")
        if len(args) > VEO_MAX_NUM_ARGS:
            raise ValueError("call_async: too many arguments (%d)" % len(args))
        
        cdef veo_call_args a
        
        a.nargs = len(self.args_conv)
        for i in xrange(len(self.args_conv)):
            x = args[i]
            f = self.args_conv[i]
            try:
                a.arguments[i] = f(x)
            except Exception as e:
                raise ValueError("%r : args conversion: f = %r, x = %r" % (e, f, x))

        cdef uint64_t res = veo_call_async(ctx.thr_ctxt, self.addr, &a)
        if res == VEO_REQUEST_ID_INVALID:
            return None
            #raise RuntimeError("veo_call_async failed")
        return VeoRequest(ctx, res, self.ret_conv)


cdef class VeoRequest(object):
    """
    VE offload call request
    """
    cdef uint64_t req
    cdef VeoCtxt ctx
    cdef ret_conv

    def __init__(self, ctx, req, ret_conv):
        self.ctx = ctx
        self.req = req
        self.ret_conv = ret_conv

    def __repr__(self):
        out = "<%s object req %d in context %r>" % \
              (self.__class__.__name__, self.req, self.ctx)
        return out

    def wait_result(self):
        cdef uint64_t res
        cdef int rc = veo_call_wait_result(self.ctx.thr_ctxt, self.req, &res)
        if rc == -1:
            raise Exception("wait_result command exception")
        elif rc < 0:
            raise RuntimeError("wait_result command error on VE")
        # TODO: cast result
        return self.ret_conv(res)

    def peek_result(self):
        cdef uint64_t res
        cdef int rc = veo_call_peek_result(self.ctx.thr_ctxt, self.req, &res)
        if rc == VEO_COMMAND_EXCEPTION:
            raise Exception("peek_result command exception")
        elif rc == VEO_COMMAND_ERROR:
            raise RuntimeError("peek_result command error on VE")
        elif rc == VEO_COMMAND_UNFINISHED:
            raise NameError("peek_result command unfinished")
        # TODO: cast result
        return self.ret_conv(res)


cdef class VeoLibrary(object):
    """
    Library loaded in a VE Proc.

    The library object can be one loaded with dlopen
    or correspond to the static symbols in the veorun VE binary.
    """
    cdef VeoProc proc
    cdef name
    cdef uint64_t lib_handle
    cdef readonly dict func
    cdef readonly dict symbol

    def __init__(self, veo_proc, name, uint64_t handle):
        self.proc = veo_proc
        self.name = name
        self.lib_handle = handle
        self.func = dict()
        self.symbol = dict()

    def get_symbol(self, char *symname):
        cdef uint64_t res
        res = veo_get_sym(self.proc.proc_handle, self.lib_handle, symname)
        if res == 0UL:
            raise RuntimeError("veo_get_sym '%s' failed" % symname)
        self.symbol[<bytes>symname] = res
        return res

    def find_function(self, char *symname):
        cdef uint64_t res
        res = veo_get_sym(self.proc.proc_handle, self.lib_handle, symname)
        if res == 0UL:
            raise RuntimeError("veo_get_sym '%s' failed" % symname)
        func = VeoFunction(self, res, <bytes>symname)
        self.func[<bytes>symname] = func
        return func


cdef class VeoCtxt(object):
    """
    VE Offloading thread context.

    This is corresponding to one VE worker thread. Technically
    it is cloned from the control thread started by the VeoProc
    therefore all VeoCtxt instances share the same memory and
    are controlled by their parent VeoProc.
    """
    cdef veo_thr_ctxt *thr_ctxt
    cdef VeoProc proc

    def __init__(self, VeoProc proc):
        self.proc = proc
        self.thr_ctxt = veo_context_open(proc.proc_handle)
        if self.thr_ctxt == NULL:
            raise RuntimeError("veo_context_open failed")

    def __dealloc__(self):
        veo_context_close(self.thr_ctxt)


cdef class VeoProc(object):
    cdef veo_proc_handle *proc_handle
    cdef readonly int nodeid
    cdef readonly list context
    cdef readonly dict lib

    def __init__(self, int nodeid):
        global _proc_init_hook
        self.nodeid = nodeid
        self.context = list()
        self.lib = dict()
        self.proc_handle = veo_proc_create(nodeid)
        if self.proc_handle == NULL:
            raise RuntimeError("veo_proc_create(%d) failed" % nodeid)
        if _proc_init_hook != None:
            _proc_init_hook(self)

    def __dealloc__(self):
        while len(self.context) > 0:
            c = self.context.pop(0)
            del c
        if veo_proc_destroy(self.proc_handle):
            raise RuntimeError("veo_proc_destroy failed")

    def get_function(self, name):
        """
        Return a VeoFunction for function 'name' which
        has been previously found in one of the loaded libraries.
        Ruturn None if the function wasn't found.
        """
        for lib in self.lib:
            if name in lib.func.keys():
                return lib.func[name]
        return None

    def load_library(self, char *libname):
        cdef uint64_t res = veo_load_library(self.proc_handle, libname)
        if res == 0UL:
            raise RuntimeError("veo_load_library '%s' failed" % libname)
        lib = VeoLibrary(self, <bytes> libname, res)
        self.lib[<bytes>libname] = lib
        return lib

    def static_library(self):
        lib = VeoLibrary(self, "__static__", 0UL)
        self.lib["__static__"] = lib
        return lib

    def alloc_mem(self, size_t size):
        cdef uint64_t addr
        if veo_alloc_mem(self.proc_handle, &addr, size):
            raise RuntimeError("veo_alloc_mem failed")
        return addr

    def free_mem(self, uint64_t addr):
        if veo_free_mem(self.proc_handle, addr):
            raise RuntimeError("veo_free_mem failed")

    def read_mem(self, np.ndarray dst, uint64_t src, size_t size):
        if dst.nbytes < size:
            raise ValueError("read_mem dst array is smaller than required size")
        if veo_read_mem(self.proc_handle, dst.data, src, size):
            raise RuntimeError("veo_read_mem failed")

    def write_mem(self, uint64_t dst, np.ndarray src, size_t size):
        if src.nbytes < size:
            raise ValueError("write_mem src array is smaller than transfer size")
        if veo_write_mem(self.proc_handle, dst, src.data, size):
            raise RuntimeError("veo_write_mem failed")

    def open_context(self):
        cdef VeoCtxt c
        c = VeoCtxt(self)
        self.context.append(c)
        return c

    def close_context(self, VeoCtxt c):
        self.context.remove(c)
        del c


cdef class VEMemPtr(object):
    cdef readonly uint64_t addr
    cdef readonly size_t size

    def __init__(self, uint64_t addr, size_t size):
        self.addr = addr
        self.size = size

    
