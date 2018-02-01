from libveo cimport *

import os
import numbers
from struct import pack, unpack
import numpy as np
cimport numpy as np


cdef class VeoCtxt(object):
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

        
        """
        #cdef uint64_t sym = <uint64_t>args[0]
        if len(args) > 8:
            raise ValueError("call_async: too many arguments (%d)" % len(args))
        cdef veo_call_args a
        cdef int i
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

    def context_open(self):
        cdef VeoCtxt c
        c = VeoCtxt(self)
        self.context.append(c)
        return c

    def context_close(self, VeoCtxt c):
        self.context.remove(c)
        del c



