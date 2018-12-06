import sys
from distutils.core import setup
from distutils.extension import Extension
import numpy

USE_CYTHON = False
ext = ".c"
if "--use-cython" in sys.argv:
    from Cython.Build import cythonize
    sys.argv.remove("--use-cython")
    USE_CYTHON = True
    ext = ".pyx"


_ext_mods=[
    Extension("veo",
              sources=["src/veo" + ext],
              libraries=["veo"], # Unix-like specific
              include_dirs=[numpy.get_include()]
    ),
]

if USE_CYTHON:
    ext_mods = cythonize(_ext_mods)
else:
    ext_mods = _ext_mods

setup(
    name = "pyVeo",
    version = "1.3.2",
    ext_modules = ext_mods,
    packages = ["veo"],
    author = "Erich Focht",
    author_email = "efocht@gmail.com",
    license = "GPLv2",
    description = "Python bindings for the VE Offloading API",
    url = "https://github.com/aurora-ve/py-veo"
)
