from libc.stdint cimport *

cdef extern from "<sys/ptrace.h>":
    enum __ptrace_request:
        PTRACE_PEEKUSER = 3
        PTRACE_ATTACH = 16
        PTRACE_DETACH = 17
        PTRACE_SEIZE = 0x4206

cdef extern from "ve_hw.h":
    ctypedef uint64_t reg_t
    enum: SR_NUM
    enum: VR_NUM
    enum: AUR_MVL
    cdef struct core_user_reg:
        reg_t USRCC
        reg_t PMC[16]
        uint8_t pad0[0x1000 - 0x88]
        reg_t PSW;                      #/*  0x1000 -  0x1007 */
        reg_t EXS;                      #/*  0x1008 -  0x100F */
        reg_t IC;                       #/*  0x1010 -  0x1017 */
        reg_t ICE;                      #/*  0x1018 -  0x101F */
        reg_t VIXR;                     #/*  0x1020 -  0x1027 */
        reg_t VL;                       #/*  0x1028 -  0x102F */
        reg_t SAR;                      #/*  0x1030 -  0x1047 */
        reg_t PMMR;                     #/*  0x1038 -  0x103F */
        reg_t PMCR[4];                  #/*  0x1040 -  0x105F */
        uint8_t pad1[0x1400 - 0x1060];  #/*  0x1060 -  0x13FF */
        # Scalar Registers
        reg_t SR[SR_NUM];               #/*  0x1400 -  0x15FF */
        uint8_t pad2[0x1800 - 0x1600];  #/*  0x1600 -  0x17FF */
        # Vector Mask Registers
        reg_t VMR[16][4];               #/*  0x1800 -  0x19FF */
        uint8_t pad3[0x40000 - 0x1A00]  #/*  0x1A00 - 0x3FFFF */
        # Vector Registers
        reg_t VR[VR_NUM][AUR_MVL]       #/* 0x40000 - 0x5FFFF */
        uint8_t pad4[0x80000 - 0x60000] #/* 0x60000 - 0x7FFFF */

    ctypedef core_user_reg core_user_reg_t

cdef extern from *:
    cdef int ve_ptrace_getregs(int pid, void *data)

cdef extern from "ve_ptrace.h":
    long ve_ptrace(__ptrace_request request, ...)

def attach(int pid):
    rc = ve_ptrace(PTRACE_ATTACH, pid, 0, 0)
    return rc

def detach(int pid):
    rc = ve_ptrace(PTRACE_DETACH, pid, 0, 0)
    return rc

def peek_user(int pid, uint64_t offset):
    cdef uint64_t data
    if ve_ptrace(PTRACE_PEEKUSER, pid, offset, &data):
        raise RuntimeError("ve_ptrace failed")
    return data

def seize(int pid):
    rc = ve_ptrace(PTRACE_SEIZE, pid, 0, 0)
    return rc

def get_regs(int pid):
    cdef core_user_reg_t data
    if ve_ptrace_getregs(pid, &data):
        raise RuntimeError("ve_ptrace_getregs failed")
    return data


