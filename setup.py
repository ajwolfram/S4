from distutils.core import setup, Extension

# import os
# os.environ["CC"] = "g++"
# os.environ["CXX"] = "g++"

libs = ['S4', 'stdc++']
lib_dirs = ['./build', 'S4/lib']
libs.extend([lib[2::] for lib in
             '-lblas -llapack -lfftw3 -lpthread -lcholmod -lamd -lcolamd -lcamd -lccolamd  -L./S4/lib/ -lboost_serialization'.split()])
include_dirs = ['S4/include']
extra_link_args = ['./build/libS4.a']

S4module = Extension('S4',
                     sources=['S4/main_python.c'],
                     libraries=libs,
                     library_dirs=lib_dirs,
                     include_dirs=include_dirs,
                     extra_link_args=extra_link_args,
                     extra_compile_args=['-std=gnu99']
                     )

setup(name='S4',
      version='1.1',
      description='Stanford Stratified Structure Solver (S4): Fourier Modal Method',
      ext_modules=[S4module]
      )
