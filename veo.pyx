from libveo cimport *

import os
import numbers
from struct import pack, unpack
import numpy as np
cimport numpy as np

cdef zsign(x):
    return 0 if x >= 0 else -1

cdef class VeoFunction(object):
    """
    VE Offloaded function
    """
    cdef uint64_t addr
    cdef args_fmt
    cdef ret_type
    
    def __init__(self, uint64_t addr):
        self.addr = addr
        self.args_fmt = None
        self.ret_type = None

    def set_argsfmt(self, *args):
        self.args_fmt = args

    def set_rettype(self, rettype):
        self.ret_type = rettype

    def call(self, VeoCtxt ctx, *args):
        """
        Asynchrounously call a function on VE.

        Returns: VeoRequest instance, None in case of error.
        """
        if self.args_fmt is None:
            raise RuntimeError("VeoFunction needs arguments format info before call()")
        if len(args) > VEO_MAX_NUM_ARGS:
            raise ValueError("call_async: too many arguments (%d)" % len(args))
        
        cdef veo_call_args a
        
        a.nargs = len(self.args_fmt)
        for i in xrange(len(self.args_fmt)):
            x = args[i]
            s = zsign(x)
            f = self.args_fmt[i]
            if f in ("char", "unsigned char"):
                a.arguments[i] = unpack("Q", pack("cchi", x, s, s, s))[0]
            elif f in ("short", "unsigned short"):
                a.arguments[i] = unpack("Q", pack("hhi", x, s, s))[0]
            elif f in ("int", "unsigned int"):
                a.arguments[i] = unpack("Q", pack("ii", x, s))[0]
            elif f in ("long", "unsigned long"):
                a.arguments[i] = <int64_t>x
            elif f == "float":
                a.arguments[i] = unpack("Q", pack("if", 0, x))[0]
            elif f == "double":
                a.arguments[i] = unpack("Q", pack("d", x))[0]
            elif f.endswith("*"):
                a.arguments[i] = <int64_t>x
            else:
                raise ValueError("cannot convert arg %d to call_async" % i)

        cdef uint64_t res = veo_call_async(ctx.thr_ctxt, self.addr, &a)
        if res == VEO_REQUEST_ID_INVALID:
            return None
            #raise RuntimeError("veo_call_async failed")
        return VeoRequest(ctx, res)


cdef class VeoRequest(object):
    """
    VE offload call request
    """
    cdef uint64_t req
    cdef VeoCtxt ctx

    def __init__(self, ctx, req):
        self.ctx = ctx
        self.req = req

    def wait_result(self):
        cdef uint64_t res
        cdef int rc = veo_call_wait_result(self.ctx.thr_ctxt, self.req, &res)
        if rc == -1:
            raise Exception("wait_result command exception")
        elif rc < 0:
            raise RuntimeError("wait_result command error on VE")
        # TODO: cast result
        return res

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
        return res


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

    def __cinit__(self, VeoProc proc):
        self.proc = proc
        self.thr_ctxt = veo_context_open(proc.proc_handle)
        if self.thr_ctxt == NULL:
            raise RuntimeError("veo_context_open failed")

    def __dealloc__(self):
        veo_context_close(self.thr_ctxt)

    def call_async(self, uint64_t sym, *args, **kwds):
        """
        Asynchrounously call a function on VE.

        A maximum of 8 arguments are allowed and passed in
        registers.
        Returns: the request ID of type uint64_t,
        -1L in case of error.
        """
        #cdef uint64_t sym = <uint64_t>args[0]
        if len(args) > VEO_MAX_NUM_ARGS:
            raise ValueError("call_async: too many arguments (%d)" % len(args))
        cdef veo_call_args a
        cdef int i
        a.nargs = len(args)
        for i in xrange(len(args)):
            if isinstance(args[i], int):
                a.arguments[i] = <int64_t>args[i]
            elif isinstance(args[i], numbers.Integral):
                a.arguments[i] = <int64_t>args[i]
            elif isinstance(args[i], float):
                a.arguments[i] = unpack("Q", pack("d", args[i]))[0]
            else:
                raise ValueError("cannot convert arg %d to call_async" % i)

        cdef uint64_t res = veo_call_async(self.thr_ctxt, sym, &a)
        if res == VEO_REQUEST_ID_INVALID:
            raise RuntimeError("veo_call_async failed")
        return res

    def wait_result(self, uint64_t req):
        cdef uint64_t res
        cdef int rc = veo_call_wait_result(self.thr_ctxt, req, &res)
        if rc == -1:
            raise Exception("wait_result command exception")
        elif rc < 0:
            raise RuntimeError("wait_result command error on VE")
        return res

    def peek_result(self, uint64_t req):
        cdef uint64_t res
        cdef int rc = veo_call_peek_result(self.thr_ctxt, req, &res)
        if rc == VEO_COMMAND_EXCEPTION:
            raise Exception("peek_result command exception")
        elif rc == VEO_COMMAND_ERROR:
            raise RuntimeError("peek_result command error on VE")
        elif rc == VEO_COMMAND_UNFINISHED:
            raise NameError("peek_result command unfinished")
        return res


cdef class VeoProc(object):
    cdef veo_proc_handle *proc_handle
    cdef int nodeid
    cdef list context

    def __cinit__(self, int nodeid):
        self.nodeid = nodeid
        self.proc_handle = veo_proc_create(nodeid)
        if self.proc_handle == NULL:
            raise RuntimeError("veo_proc_create(%d) failed" % nodeid)
        self.context = list()

    def __dealloc__(self):
        while len(self.context) > 0:
            c = self.context.pop(0)
            del c
        if veo_proc_destroy(self.proc_handle):
            raise RuntimeError("veo_proc_destroy failed")

    def load_library(self, char *libname):
        cdef uint64_t res = veo_load_library(self.proc_handle, libname)
        if res == 0UL:
            raise RuntimeError("veo_load_library '%s' failed" % libname)
        return res

    def get_sym(self, uint64_t lib_handle, char *symname):
        cdef uint64_t res
        res = veo_get_sym(self.proc_handle, lib_handle, symname)
        if res == 0UL:
            raise RuntimeError("veo_get_sym '%s' failed" % symname)
        return res

    def find_function(self, uint64_t lib_handle, char *symname):
        cdef uint64_t res
        res = veo_get_sym(self.proc_handle, lib_handle, symname)
        if res == 0UL:
            raise RuntimeError("veo_get_sym '%s' failed" % symname)
        return VeoFunction(res)

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

    
