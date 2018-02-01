#
# Interface to libveo
#

from libc.stdint cimport *

cdef extern from "<ve_offload.h>":
    # maximum number of arguments to VEO calls (8)
    enum: VEO_MAX_NUM_ARGS

    # invalid request ID
    enum: VEO_REQUEST_ID_INVALID

    enum veo_context_state:
        VEO_STATE_UNKNOWN
        VEO_STATE_RUNNING
        VEO_STATE_SYSCALL
        VEO_STATE_BLOCKED
        VEO_STATE_EXIT

    enum veo_command_state:
        VEO_COMMAND_OK
        VEO_COMMAND_EXCEPTION
        VEO_COMMAND_ERROR
        VEO_COMMAND_UNFINISHED

    cdef struct veo_call_args:
        uint64_t arguments[VEO_MAX_NUM_ARGS]

    cdef struct veo_proc_handle:
        pass

    cdef struct veo_thr_ctxt:
        pass

    veo_proc_handle *veo_proc_create(int)
    uint64_t veo_load_library(veo_proc_handle *, const char *)
    uint64_t veo_get_sym(veo_proc_handle *, uint64_t, const char *)
    veo_thr_ctxt *veo_context_open(veo_proc_handle *)
    int veo_context_close(veo_thr_ctxt *)
    int veo_get_context_state(veo_thr_ctxt *)
    uint64_t veo_call_async(veo_thr_ctxt *, uint64_t, veo_call_args *)
    int veo_call_peek_result(veo_thr_ctxt *, uint64_t, uint64_t *)
    int veo_call_wait_result(veo_thr_ctxt *, uint64_t, uint64_t *)
    int veo_read_mem(veo_proc_handle *, void *, uint64_t, size_t)
    int veo_write_mem(veo_proc_handle *, uint64_t, const void *, size_t)
