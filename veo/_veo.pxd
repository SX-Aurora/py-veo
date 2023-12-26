# Copyright (c) 2018 - 2023 Erich Focht, NEC HPCE.
#
# Re-integrated and adapted code that has been derived from PyVEO and
# used in NLCPY, therefore:
#
# # NLCPy License #
#     Copyright (c) 2020 NEC Corporation
#
# See LICENSE file for details.
#
from veo.libveo cimport *

cdef _proc_init_hook

cpdef set_proc_init_hook(v)
cpdef del_proc_init_hook(v)

#
# Re-declaring the enums here because they're otherwise not visible in Python
#
cpdef enum _veo_args_intent:
    INTENT_IN = VEO_INTENT_IN
    INTENT_INOUT = VEO_INTENT_INOUT
    INTENT_OUT = VEO_INTENT_OUT

cpdef enum _veo_context_state:
    STATE_UNKNOWN = VEO_STATE_UNKNOWN
    STATE_RUNNING = VEO_STATE_RUNNING
    STATE_SYSCALL = VEO_STATE_SYSCALL
    STATE_BLOCKED = VEO_STATE_BLOCKED
    STATE_EXIT = VEO_STATE_EXIT

cpdef enum _veo_command_state:
    COMMAND_OK = VEO_COMMAND_OK
    COMMAND_EXCEPTION = VEO_COMMAND_EXCEPTION
    COMMAND_ERROR = VEO_COMMAND_ERROR
    COMMAND_UNFINISHED = VEO_COMMAND_UNFINISHED


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


cdef class VeoProc(object):
    cdef veo_proc_handle *proc_handle
    cdef readonly int nodeid
    cdef readonly list context
    cdef readonly dict lib
    cdef readonly int tid


cdef class VeoLibrary(object):
    cdef readonly VeoProc proc
    cdef name
    cdef uint64_t lib_handle
    cdef readonly dict func
    cdef readonly dict symbol


cdef class VeoFunction(object):
    cdef readonly VeoLibrary lib
    cdef uint64_t addr
    cdef readonly name
    cdef readonly _args_type
    cdef readonly _ret_type
    cdef args_conv
    cdef ret_conv


cdef class VeoRequest(object):
    cdef readonly uint64_t req
    cdef readonly VeoCtxt ctx
    cdef ret_conv
    cdef VeoArgs args


cdef class VeoMemRequest(VeoRequest):
    cdef Py_buffer data

    @staticmethod
    cdef create(VeoCtxt ctx, req, Py_buffer data)


cdef class OnStack(object):
    cdef Py_buffer data
    cdef uint64_t _c_pointer
    cdef _size
    cdef veo_args_intent _inout


cdef class VeoArgs(object):
    cdef veo_args *args
    cdef readonly list stacks


cdef class VeoCtxt(object):
    cdef veo_thr_ctxt *thr_ctxt
    cdef VeoProc proc
    cdef readonly int tid

cdef class VEO_HMEM(object):
    pass
