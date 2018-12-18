import collections
import subprocess
import os


GLOBAL_SO_FLAGS = "-shared"
MK_VEORUN_STATIC = "/opt/nec/ve/libexec/mk_veorun_static"

SUFFIX = { "C": ".c", "C++": ".cpp", "F": ".f90"}
COMPILER = { "C": "/opt/nec/ve/bin/ncc",
             "C++": "/opt/nec/ve/bin/nc++",
             "F": "/opt/nec/ve/bin/nfort" }
FLAGS = { "C": "-O2 -fpic",
          "C++": "-O2 -fpic -finline -finline-functions",
          "F": "-O2 -fpic" }


class VeObj(object):
    def __init__(self, content, flags=None, compiler=None):
        self._src = content
        # _type must be set here
        if flags is None:
            self._flags = FLAGS[self._type]
        else:
            self._flags = flags
        if compiler is None:
            self._compiler = COMPILER[self._type]
        else:
            self._compiler = compiler

    def build(self, oname, verbose=False):
        sname = oname + SUFFIX[self._type]
        with open(sname, "w") as f:
            f.write(self._src)

        cmd = self._compiler + " " + self._flags + " -c " + sname + " -o " + oname + ".o"
        if verbose: print(cmd)
        out = subprocess.check_output(cmd, stderr=subprocess.STDOUT, shell=True)
        return out

    def clean(self, oname):
        sname = oname + SUFFIX[self._type]
        os.unlink(sname)
        os.unlink(oname + ".o")

    def get_compiler(self):
        return self._compiler

    def set_compiler(self, compiler):
        self._compiler = compiler

    def set_flags(self, flags):
        self._flags = flags

    def get_type(self):
        return self._type


class VeCObj(VeObj):
    def __init__(self, content, flags=None, compiler=None):
        self._type = "C"
        super(VeCObj, self).__init__(content, flags=flags, compiler=compiler)


class VeCppObj(VeObj):
    def __init__(self, content, flags=None, compiler=None):
        self._type = "C++"
        super(VeCppObj, self).__init__(content, flags=flags, compiler=compiler)


class VeFtnObj(VeObj):
    def __init__(self, content, flags=None, compiler=None):
        self._type = "F"
        super(VeFtnObj, self).__init__(content, flags=flags, compiler=compiler)


class VeBuild(object):
    def __init__(self):
        self._obj = collections.OrderedDict()
        self._builddir = "."

    def set_c_src(self, label, content, flags=None, compiler=None):
        self._obj[label] = VeCObj(content, flags=flags, compiler=compiler)

    def set_cpp_src(self, label, content, flags=None, compiler=None):
        self._obj[label] = VeCppObj(content, flags=flags, compiler=compiler)
    
    def set_ftn_src(self, label, content, flags=None, compiler=None):
        self._obj[label] = VeFtnObj(content, flags=flags, compiler=compiler)

    def build_dir(self, dirname):
        self._builddir = dirname

    def build_so(self, label=None, flags=None, libs=[], linker=None, verbose=False):
        if label is None and self._obj.keys():
            label = self._first_label()
        if label is None:
            raise ValueError("No label. Did you define any sources?")
        soname = label + ".so"
        for src, obj in self._obj.items():
            try:
                out = obj.build(src, verbose=verbose)
                print("%s -> ok" % src)
                if verbose: print(out)
            except Exception as e:
                print("%s -> failed (%r)" % (src, e))
                return
        if linker is None:
            linker = self._find_linker()
        if flags:
            cmd = linker + " " + flags
        else:
            cmd = linker + " " + GLOBAL_SO_FLAGS
        cmd = cmd + " -o " + soname
        cmd = cmd + " " + " ".join(["%s.o" % src for src in self._obj.keys()]) + \
              " " + " ".join(libs)
        if verbose: print(cmd)
        try:
            out = subprocess.check_output(cmd, stderr=subprocess.STDOUT, shell=True)
            if verbose: print(out)
        except Exception as e:
            print("build_so(%s) -> failed (%r)" % (soname, e))
            return None
        return soname

    def build_veorun(self, label=None, flags=None, libs=[], verbose=False):
        if label is None and self._obj.keys():
            label = self._first_label()
        if label is None:
            raise ValueError("No label. Did you define any sources?")
        oname = label + ".veorun"
        for src, obj in self._obj.items():
            try:
                out = obj.build(src, verbose=verbose)
                print("%s -> ok" % src)
                if verbose: print(out)
            except Exception as e:
                print("%s -> failed (%r)" % (src, e))
                return

        cmd = MK_VEORUN_STATIC + " " + oname
        if flags:
            cmd = "env CFLAGS=\"%s\" " % flags + cmd
        cmd = cmd + " " + " ".join(["%s.o" % src for src in self._obj.keys()])
        if libs:
            cmd = cmd + " " + " ".join(libs)
        if verbose: print(cmd)
        try:
            out = subprocess.check_output(cmd, stderr=subprocess.STDOUT, shell=True)
            if verbose: print(out)
        except Exception as e:
            print("build_veorun(%s) -> failed (%r)" % (oname, e))
            return None
        return oname

    def clean(self):
        for src, obj in self._obj.items():
            obj.clean(src)
    
    def _first_label(self):
        if self._obj.keys():
            return self._obj.keys()[0]
        return None

    def _find_linker(self):
        _type = None
        for src, obj in self._obj.items():
            otype = obj.get_type()
            if _type is None:
                _type = otype
                continue
            if otype == "C++":
                _type = "C++"
            elif otype == "F":
                if _type == "C": _type = "F"
        if _type is not None:
            return COMPILER[_type]
        raise ValueError("No linker. Did you define any sources?")

