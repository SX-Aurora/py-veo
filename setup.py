import os, sys, glob
from setuptools import setup
from distutils.extension import Extension
import numpy

USE_CYTHON = False
ext = ".c"
if "--use-cython" in sys.argv:
    from Cython.Build import cythonize
    sys.argv.remove("--use-cython")
    USE_CYTHON = True
    ext = ".pyx"

VEO_LIB_DIR = os.getenv("VEO_LIB_DIR")
if not VEO_LIB_DIR:
    VEO_LIB_DIR = "/opt/nec/ve/veos/lib64"
VEO_INC_DIR = os.getenv("VEO_INC_DIR")
if not VEO_INC_DIR:
    VEO_INC_DIR = "/opt/nec/ve/veos/include"


_ext_mods=[
    Extension("veo._veo",
              sources=["veo/_veo" + ext],
              libraries=["veo"], # Unix-like specific
              library_dirs=["veo", VEO_LIB_DIR],
              include_dirs=["veo", VEO_INC_DIR, numpy.get_include()],
              extra_link_args=["-Wl,-rpath=%s" % VEO_LIB_DIR]
    ),
]

_example_files = glob.glob("./examples/*.py")
_example_files.extend(glob.glob("./examples/*.c"))
_example_files.extend(glob.glob("./examples/*.f90"))
_example_files.append("examples/Makefile")

if USE_CYTHON:
    ext_mods = cythonize(_ext_mods)
else:
    ext_mods = _ext_mods

# read the contents of your README file
from os import path
this_directory = path.abspath(path.dirname(__file__))
with open(path.join(this_directory, 'README.md')) as f:
    long_description = f.read()

setup(
    name = "py-veo",
    version = "1.5.0",
    ext_modules = ext_mods,
    data_files = [("share/py-veo/examples", _example_files), ("share/py-veo", ["README.md"])],
    packages = [ "veo", "veo.logging" ],
    author = "Erich Focht",
    author_email = "efocht@gmail.com",
    license = "GPLv2",
    requires = ["future","numpy", "psutil"],
    description = "Python bindings for the VE Offloading API",
    url = "https://github.com/sx-aurora/py-veo",
    long_description=long_description,
    long_description_content_type='text/markdown',
    classifiers=[
      'Development Status :: 4 - Beta',
      'Environment :: Console',
      'Intended Audience :: Education',
      'Intended Audience :: Developers',
      'Intended Audience :: Science/Research',
      'License :: OSI Approved :: GNU General Public License (GPL)',
      'Operating System :: POSIX :: Linux',
      'Programming Language :: Python',
      'Topic :: Software Development :: Libraries :: Python Modules'
      ]
)
