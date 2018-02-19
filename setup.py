from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize
import numpy

ext_modules=[
    Extension("veo",
              sources=["src/veo.pyx"],
              libraries=["veo"], # Unix-like specific
              include_dirs=[numpy.get_include()]
    ),
]

setup(
    name = "pyVeo",
    version = "0.1",
    ext_modules = cythonize(ext_modules),
    packages = ["veo"],
    author = "Erich Focht",
    author_email = "efocht@gmail.com",
    license = "GPLv2",
    description = "Python bindings for the VE Offloading API",
    url = "https://github.com/aurora-ve/py-veo"
)
