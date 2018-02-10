from libc.stdint cimport *


cdef union U64:
    uint64_t u64
    int64_t i64
    float f32[2]
    double d64


cdef class ConvToI64(object):
    @staticmethod
    def from_char(x):
        return <int64_t><char>x

    @staticmethod
    def from_uchar(x):
        return <int64_t><unsigned char>x

    @staticmethod
    def from_short(x):
        return <int64_t><short>x

    @staticmethod
    def from_ushort(x):
        return <int64_t><unsigned short>x

    @staticmethod
    def from_int(x):
        return <int64_t><int>x

    @staticmethod
    def from_uint(x):
        return <int64_t><unsigned int>x

    @staticmethod
    def from_long(x):
        return <long>x

    @staticmethod
    def from_ulong(x):
        cdef U64 u
        u.u64 = <unsigned long>x
        return u.i64

    @staticmethod
    def from_float(x):
        cdef U64 u
        u.f32[1] = <float>x
        u.f32[0] = <float>0
        return u.i64

    @staticmethod
    def from_double(x):
        cdef U64 u
        u.d64 = <double>x
        return u.i64

cdef class ConvFromI64(object):
    @staticmethod
    def to_char(int64_t x):
        return <char>(x & 0xff)

    @staticmethod
    def to_uchar(int64_t x):
        return <unsigned char>(x & 0xff)

    @staticmethod
    def to_short(int64_t x):
        return <short>(x & 0xffff)

    @staticmethod
    def to_ushort(int64_t x):
        return <unsigned short>(x & 0xffff)

    @staticmethod
    def to_int(int64_t x):
        return <int>(x & 0xffffffff)

    @staticmethod
    def to_uint(int64_t x):
        return <unsigned int>(x & 0xffffffff)

    @staticmethod
    def to_long(int64_t x):
        return x

    @staticmethod
    def to_ulong(int64_t x):
        cdef U64 u
        u.i64 = x
        return u.u64

    @staticmethod
    def to_float(int64_t x):
        cdef U64 u
        u.i64 = x
        return u.f32[1]

    @staticmethod
    def to_double(int64_t x):
        cdef U64 u
        u.i64 = x
        return u.d64

cdef conv_to_i64_func(t):
    if t == "char":
        return ConvToI64.from_char
    elif t == "short":
        return ConvToI64.from_short
    elif t == "int":
        return ConvToI64.from_int
    elif t == "long":
        return ConvToI64.from_long
    elif t == "unsigned char":
        return ConvToI64.from_uchar
    elif t == "unsigned short":
        return ConvToI64.from_ushort
    elif t == "unsigned int":
        return ConvToI64.from_uint
    elif t == "unsigned long":
        return ConvToI64.from_ulong
    elif t == "float":
        return ConvToI64.from_float
    elif t == "double":
        return ConvToI64.from_double
    elif t.endswith("*"):
        return ConvToI64.from_ulong
    else:
        raise TypeError("Don't know how to convert '%s' to I64" % t)

cdef conv_from_i64_func(t):
    if t == "char":
        return ConvFromI64.to_char
    elif t == "short":
        return ConvFromI64.to_short
    elif t == "int":
        return ConvFromI64.to_int
    elif t == "long":
        return ConvFromI64.to_long
    elif t == "unsigned char":
        return ConvFromI64.to_uchar
    elif t == "unsigned short":
        return ConvFromI64.to_ushort
    elif t == "unsigned int":
        return ConvFromI64.to_uint
    elif t == "unsigned long":
        return ConvFromI64.to_ulong
    elif t == "float":
        return ConvFromI64.to_float
    elif t == "double":
        return ConvFromI64.to_double
    elif t.endswith("*"):
        return ConvFromI64.to_ulong
    else:
        raise TypeError("Don't know how to convert from I64 to '%s'" % t)

    
