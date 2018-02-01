from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize
import numpy

ext_modules=[
    Extension("veo",
              sources=["veo.pyx"],
              libraries=["veo"], # Unix-like specific
              include_dirs=[numpy.get_include()]
    )
]

setup(
  name = "Veo",
  ext_modules = cythonize(ext_modules)
)
