# To build:
#   make <target>
# Use the 'lib' target first to build the library, then either the Lua
# or Python targets are 'S4lua' and 'python_ext', respectively.

# Set these to the flags needed to link against BLAS and Lapack.
#  If left blank, then performance may be very poor.
#  On Mac OS,
#   BLAS_LIB = -framework vecLib
#   LAPACK_LIB = -framework vecLib
#  On Fedora: dnf install openblas-devel
#  On Debian and Fedora, with reference BLAS and Lapack (slow)
#   BLAS_LIB = -lblas
#   LAPACK_LIB = -llapack
#  NOTE: on Fedora, need to link blas and lapack properly, where X.X.X is some version numbers
#  Linking Command Example: sudo ln -s /usr/lib64/liblapack.so.X.X.X /usr/lib64/liblapack.so
#  blas Example: sudo ln -s /usr/lib64/libopeblas64.so.X.X.X /usr/lib64/libblas.so
#  Can also use -L to link to the explicit libary path 
#BLAS_LIB = -lblas
#LAPACK_LIB = -llapack

# Specify the flags for Lua headers and libraries (only needed for Lua frontend)
# Recommended: build lua in the current directory, and link against this local version
# LUA_INC = -I./lua-5.2.4/install/include
# LUA_LIB = -L./lua-5.2.4/install/lib -llua -ldl -lm
#LUA_INC = -I./lua-5.2.4/install/include
#LUA_LIB = -L./lua-5.2.4/install/lib -llua -ldl -lm

# OPTIONAL
# Typically if installed,
#  FFTW3_INC can be left empty
#  FFTW3_LIB = -lfftw3 
#  or, if Fedora and/or fftw is version 3 but named fftw rather than fftw3
#  FTW3_LIB = -lfftw 
#  May need to link libraries properly as with blas and lapack above
#FFTW3_INC =
#FFTW3_LIB = -lfftw3

# Typically,
#  PTHREAD_INC = -DHAVE_UNISTD_H
#  PTHREAD_LIB = -lpthread
#PTHREAD_INC = -DHAVE_UNISTD_H
#PTHREAD_LIB = -lpthread

# OPTIONAL
# If not installed:
# Fedora: dnf install libsuitsparse-devel
# Typically, if installed:
#CHOLMOD_INC = -I/usr/include/suitesparse
#CHOLMOD_LIB = -lcholmod -lamd -lcolamd -lcamd -lccolamd
#CHOLMOD_INC = -I/usr/include/suitesparse
#CHOLMOD_LIB = -lcholmod -lamd -lcolamd -lcamd -lccolamd

# Specify the MPI library
# For example, on Fedora: dnf  install openmpi-devel
#MPI_INC = -I/usr/include/openmpi-x86_64/openmpi/ompi
#MPI_LIB = -lmpi
# or, explicitly link to the library with -L, example below
#MPI_LIB = -L/usr/lib64/openmpi/lib/libmpi.so
#MPI_INC = -I/usr/include/openmpi-x86_64/openmpi
#MPI_LIB = -L/usr/lib64/openmpi/lib/libmpi.so

# Enable S4_TRACE debugging
# values of 1, 2, 3 enable debugging, with verbosity increasing at 
# value increases. 0 to disable
#S4_DEBUG = 0

# Specify custom compilers if needed
#CXX = g++
#CC  = gcc

#CFLAGS += -O3 -fPIC
#CFLAGS = -O3 -msse3 -msse2 -msse -fPIC

# options for Sampler module
#OPTFLAGS = -O3

#OBJDIR = ./build
#S4_BINNAME = $(OBJDIR)/S4
#S4_LIBNAME = $(OBJDIR)/libS4.a
S4r_LIBNAME = $(OBJDIR)/libS4r.a

##################### DO NOT EDIT BELOW THIS LINE #####################

#### Set the compilation flags

#CPPFLAGS = -I. -IS4 -IS4/RNP -IS4/kiss_fft

#ifeq ($(S4_DEBUG), 1)
#CPPFLAGS += -DENABLE_S4_TRACE
#CPPFLAGS += -ggdb
#endif

#ifeq ($(S4_DEBUG), 2)
#CPPFLAGS += -DENABLE_S4_TRACE
#CPPFLAGS += -DDUMP_MATRICES
#CPPFLAGS += -ggdb
#endif

#ifeq ($(S4_DEBUG), 3)
#CPPFLAGS += -DENABLE_S4_TRACE
#CPPFLAGS += -DDUMP_MATRICES
#CPPFLAGS += -DDUMP_MATRICES_LARGE
#CPPFLAGS += -ggdb

#ifdef FFTW3_LIB
#CPPFLAGS += -DHAVE_FFTW3 $(FFTW3_INC)
#endif

#ifeq ($(S4_DEBUG), 3)
#CPPFLAGS += -DENABLE_S4_TRACE
#CPPFLAGS += -DDUMP_MATRICES
#CPPFLAGS += -DDUMP_MATRICES_LARGE
ifeq ($(OS),Windows_NT)
    include Makefile.Msys2
else
    UNAME_S := $(shell uname -s)
    ifeq ($(UNAME_S),Linux)
        include Makefile.Linux
    endif
    ifeq ($(UNAME_S),Darwin)
        include Makefile.Darwin
    endif
endif

include Makefile.common
