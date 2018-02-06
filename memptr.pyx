from libc.stdint cimport *
from libc.stdlib cimport malloc, calloc, free

cdef class VHMemPtr(object):
    cdef void *data
    cdef size_t size

    def __cinit__(self, object obj not None):
        if isinstance(obj, buffer):
            self.size = len(obj)
            self.data = <void *>obj

    cpdef get(self):
        return <object>self.data



from cpython.mem cimport PyMem_Malloc, PyMem_Realloc, PyMem_Free
    
cdef class SomeMemory:
    cdef double* data
    def __cinit__(self, size_t number):
        # allocate some memory (uninitialised, may contain arbitrary data)
        self.data = <double*> PyMem_Malloc(number)
        if not self.data:
            raise MemoryError()

    def resize(self, size_t new_number):
        # Allocates new_number * sizeof(double) bytes,
        # preserving the current content and making a best-effort to
        # re-use the original data location.
        mem = <double*> PyMem_Realloc(self.data, new_number * sizeof(double))
        if not mem:
            raise MemoryError()
        # Only overwrite the pointer if the memory was really reallocated.
        # On error (mem is NULL), the originally memory has not been freed.
        self.data = mem

    def __dealloc__(self):
        PyMem_Free(self.data)     # no-op if self.data is NULL

