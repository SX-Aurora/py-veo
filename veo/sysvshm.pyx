ctypedef int size_t


cdef extern from "errno.h":
    int EEXIST, errno
    int EACCES, errno
    int ENOMEM, errno
 
cdef extern from "string.h":
    void memset(void *addr, int val, size_t len)
    void memcpy(void *trg, void *src, size_t len)

cdef extern from "sys/types.h":
    ctypedef int key_t

cdef extern from "sys/shm.h":

    ctypedef unsigned int shmatt_t

    cdef struct shmid_ds:
        shmatt_t shm_nattch

    int shmget(key_t key, size_t size, int shmflg)
    void *shmat(int shmid, void *shmaddr, int shmflg)
    int shmdt(void *shmaddr)
    int shmctl(int shmid, int cmd, shmid_ds *buf) nogil


cdef extern from "sys/ipc.h":

    key_t ftok(char *path, int id)

    int IPC_STAT, IPC_RMID, IPC_CREAT, IPC_EXCL, IPC_PRIVATE
