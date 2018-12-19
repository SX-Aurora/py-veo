import collections
import subprocess
import os
from shutil import rmtree


GLOBAL_SO_FLAGS = "-shared -pthread"
MK_VEORUN_STATIC = "/opt/nec/ve/libexec/mk_veorun_static"

SUFFIX = { "C": ".c", "C++": ".cpp", "F": ".f90"}
COMPILER = { "C": "/opt/nec/ve/bin/ncc",
             "C++": "/opt/nec/ve/bin/nc++",
             "F": "/opt/nec/ve/bin/nfort" }
FLAGS = { "C": "-O2 -fpic -pthread",
          "C++": "-O2 -fpic -pthread -finline -finline-functions",
          "F": "-O2 -fpic -pthread" }


def _shell_cmd(cmd, verbose=False):
    if verbose: print(cmd)
    try:
        out = subprocess.check_output(cmd, stderr=subprocess.STDOUT, shell=True)
        if verbose: print(out)
    except Exception as e:
        print("%r" % e)
        print("Command failed: %s" % e.cmd)
        print("Output:\n%s" % e.output)
        return False
    return True


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
        return _shell_cmd(cmd, verbose=verbose)

    def clean(self, oname):
        sname = oname + SUFFIX[self._type]
        try:
            os.unlink(sname)
            os.unlink(oname + ".o")
        except:
            pass

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
    _built = [] # built files, to be deleted by realclean()
    _bdirs = [] # build dirs that were created

    def __init__(self):
        self._obj = collections.OrderedDict()
        self._blddir = "./"

    def set_c_src(self, label, content, flags=None, compiler=None):
        self._obj[label] = VeCObj(content, flags=flags, compiler=compiler)

    def set_cpp_src(self, label, content, flags=None, compiler=None):
        self._obj[label] = VeCppObj(content, flags=flags, compiler=compiler)
    
    def set_ftn_src(self, label, content, flags=None, compiler=None):
        self._obj[label] = VeFtnObj(content, flags=flags, compiler=compiler)

    def set_build_dir(self, dirname):
        if not dirname.endswith("/"):
            dirname = dirname + "/"
        self._blddir = dirname

    def build_so(self, label=None, flags=None, libs=[], linker=None, verbose=False):
        if label is None and self._obj.keys():
            label = self._first_label()
        if label is None:
            raise ValueError("No label. Did you define any sources?")
        self._check_create_blddir()
        soname = self._blddir + label + ".so"
        for src, obj in self._obj.items():
            if obj.build(self._blddir + src, verbose=verbose):
                print("compile %s -> ok" % src)
            else:
                print("compile %s -> failed" % src)
                return

        if linker is None:
            linker = self._find_linker()
        if flags:
            cmd = linker + " " + flags
        else:
            cmd = linker + " " + GLOBAL_SO_FLAGS
        cmd += " -o " + soname
        cmd += " " + " ".join(["%s%s.o" % (self._blddir, src) for src in self._obj.keys()])
        if libs:
            cmd += " " + " ".join(libs)
        if _shell_cmd(cmd, verbose=verbose):
            if soname not in self._built:
                self._built.append(soname)
            return soname
        return None

    def build_veorun(self, label=None, flags=None, libs=[], verbose=False):
        if label is None and self._obj.keys():
            label = self._first_label()
        if label is None:
            raise ValueError("No label. Did you define any sources?")
        self._check_create_blddir()
        oname = label + ".veorun"
        for src, obj in self._obj.items():
            if obj.build(src, verbose=verbose):
                print("compile %s -> ok" % src)
            else:
                print("compile %s -> failed" % src)
                return

        cmd = MK_VEORUN_STATIC + " " + oname
        if flags:
            cmd = "env CFLAGS=\"%s\" " % flags + cmd
        cmd += " " + " ".join(["%s%s.o" % (self._blddir, src) for src in self._obj.keys()])
        if libs:
            cmd += " " + " ".join(libs)
        if _shell_cmd(cmd, verbose=verbose):
            if oname not in self._built:
                self._built.append(oname)
            return oname
        return None

    def clean(self):
        for src, obj in self._obj.items():
            obj.clean(src)

    def clear(self):
        self.clean()
        self._obj = OrderedDict()
        self._blddir = "./"

    def realclean(self):
        self.clean()
        for file in self._built:
            try:
                os.unlink(file)
                self._built.remove(file)
            except:
                pass
        for dir in self._bdirs:
            rmtree(dir)
        self._bdirs = []

    def _check_create_blddir(self):
        if os.path.isdir(self._blddir):
            if not os.access(self._blddir, os.W_OK | os.R_OK):
                raise OSError("Directory %s exists but is not readable or writable!" % self._blddir)
        else:
            os.mkdir(self._blddir)
            self._bdirs.append(self._blddir)

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

