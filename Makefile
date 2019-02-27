# To build:
#   make <target>
# Use the 'lib' target first to build the library, then either the Lua
# or Python targets are 'S4lua' and 'python_ext', respectively.
# Set defaults
ALIB_EXT = a
SHLIB_EXT = so
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
# values of 1, 2, 3 enable debugging, with verbosity increasing as 
# value increases. 0 to disable
S4_DEBUG = 3
S4_PROF = 0

# Specify custom compilers if needed
#CXX = g++
#CC  = gcc

#CFLAGS += -O3 -fPIC
#CFLAGS = -Wall -O3 -msse3 -msse2 -msse -fPIC

# options for Sampler module
OPTFLAGS = -O3

OBJDIR = ./build
S4_BINNAME = $(OBJDIR)/S4
S4_LIBNAME = $(OBJDIR)/libS4.a
S4r_LIBNAME = $(OBJDIR)/libS4r.a

#### Download, compile, and install boost serialization lib. 
#### This should all work fine, you must modify BOOST_INC, BOOST_LIBS,
#### and PREFIX if you want to install boost to a different location 

# Specify the paths to the boost include and lib directories
#BOOST_PREFIX=${CURDIR}/S4
#BOOST_INC = -I$(BOOST_PREFIX)/include
#BOOST_LIBS = -L$(BOOST_PREFIX)/lib/ -lboost_serialization
#BOOST_URL=https://sourceforge.net/projects/boost/files/boost/1.61.0/boost_1_61_0.tar.gz
#BOOST_FILE=boost.tar.gz
# Target for downloading boost from above URL
#$(BOOST_FILE):
#	wget $(BOOST_URL) -O $(BOOST_FILE)

# Target for extracting boost from archive and compiling. Depends on download target above
${CURDIR}/S4/lib: $(BOOST_FILE)  
#	$(eval BOOST_DIR := $(shell tar tzf $(BOOST_FILE) | sed -e 's@/.*@@' | uniq))
#	@echo Boost dir is $(BOOST_DIR)
#	tar -xzvf $(BOOST_FILE)
#	mv $(BOOST_DIR) boost_src
#	cd boost_src && ./bootstrap.sh --with-libraries=serialization --prefix=$(BOOST_PREFIX) && ./b2 install
# Final target which pulls everything together
#boost: $(BOOST_PREFIX)/lib

##################### DO NOT EDIT BELOW THIS LINE #####################


#### Set the compilation flags

CPPFLAGS = -Wall -I. -IS4 -IS4/RNP -IS4/kiss_fft 
 
ifeq ($(S4_PROF), 1)
CPPFLAGS += -g -pg
endif

ifeq ($(S4_DEBUG), 1)
CPPFLAGS += -ggdb 
endif

ifeq ($(S4_DEBUG), 2)
CPPFLAGS += -DENABLE_S4_TRACE
CPPFLAGS += -ggdb 
endif

ifeq ($(S4_DEBUG), 3)
CPPFLAGS += -DENABLE_S4_TRACE
CPPFLAGS += -DDUMP_MATRICES
CPPFLAGS += -ggdb 
endif

ifeq ($(S4_DEBUG), 4)
CPPFLAGS += -DENABLE_S4_TRACE
CPPFLAGS += -DDUMP_MATRICES
CPPFLAGS += -DDUMP_MATRICES_LARGE
CPPFLAGS += -ggdb 
endif

ifdef BOOST_INC
	CPPFLAGS += $(BOOST_INC) $(BOOST_LIBS)
endif

ifdef BLAS_LIB
CPPFLAGS += -DHAVE_BLAS
endif


ifdef LAPACK_LIB
CPPFLAGS += -DHAVE_LAPACK
endif

ifdef FFTW3_LIB
CPPFLAGS += -DHAVE_FFTW3 $(FFTW3_INC)
endif

ifdef PTHREAD_LIB
CPPFLAGS += -DHAVE_LIBPTHREAD $(PTHREAD_INC)
endif

ifdef CHOLMOD_LIB
CPPFLAGS += -DHAVE_LIBCHOLMOD $(CHOLMOD_INC)
endif

ifdef MPI_LIB
CPPFLAGS += -DHAVE_MPI $(MPI_INC)
endif
CPPFLAGS += -IS4 -IS4/RNP -IS4/kiss_fft
LIBS = $(BLAS_LIB) $(LAPACK_LIB) $(FFTW3_LIB) $(PTHREAD_LIB) $(CHOLMOD_LIB) $(MPI_LIB) $(BOOST_LIBS)

#### Compilation targets

S4_LIBNAME = libS4.$(ALIB_EXT)
S4_LUA_LIBNAME = libS4_lua.$(ALIB_EXT)
S4_LUA_MODNAME = S4v2.$(SHLIB_EXT)

all: $(OBJDIR)/$(S4_LIBNAME)

objdir:
	mkdir -p $(OBJDIR)
	mkdir -p $(OBJDIR)/S4k
	
S4_LIBOBJS = \
	$(OBJDIR)/S4k/S4.o \
	$(OBJDIR)/S4k/rcwa.o \
	$(OBJDIR)/S4k/fmm_common.o \
	$(OBJDIR)/S4k/GenEpsilon.o \
	$(OBJDIR)/S4k/Patterning.o \
	$(OBJDIR)/S4k/Shape.o \
	$(OBJDIR)/S4k/fft_iface.o \
	$(OBJDIR)/S4k/numalloc.o \
	$(OBJDIR)/S4k/gsel.o \
	$(OBJDIR)/S4k/sort.o \
	$(OBJDIR)/S4k/kiss_fft.o \
	$(OBJDIR)/S4k/kiss_fftnd.o

ifndef LAPACK_LIB
  S4_LIBOBJS += $(OBJDIR)/S4k/Eigensystems.o
endif

$(OBJDIR)/$(S4_LIBNAME): objdir $(S4_LIBOBJS)
	$(AR) crvs $@ $(S4_LIBOBJS)

$(OBJDIR)/S4k/S4.o: S4/S4.cpp
	$(CXX) -c $(CXXFLAGS) $(CPPFLAGS) $< -o $@
$(OBJDIR)/S4k/rcwa.o: S4/rcwa.cpp
	$(CXX) -c $(CXXFLAGS) $(CPPFLAGS) $< -o $@
$(OBJDIR)/S4k/fmm_common.o: S4/fmm/fmm_common.cpp
	$(CXX) -c $(CXXFLAGS) $(CPPFLAGS) $< -o $@
$(OBJDIR)/S4k/GenEpsilon.o: S4/GenEpsilon.cpp
	$(CXX) -c $(CXXFLAGS) $(CPPFLAGS) $< -o $@
$(OBJDIR)/S4k/Patterning.o: S4/Patterning.cpp
	$(CXX) -c $(CXXFLAGS) $(CPPFLAGS) $< -o $@
$(OBJDIR)/S4k/Shape.o: S4/Shape.cpp
	$(CXX) -c $(CXXFLAGS) $(CPPFLAGS) $< -o $@
$(OBJDIR)/S4k/fft_iface.o: S4/fmm/fft_iface.cpp
	$(CXX) -c $(CXXFLAGS) $(CPPFLAGS) $< -o $@
$(OBJDIR)/S4k/numalloc.o: S4/numalloc.c
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@
$(OBJDIR)/S4k/gsel.o: S4/gsel.c
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@
$(OBJDIR)/S4k/sort.o: S4/sort.c
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@
$(OBJDIR)/S4k/kiss_fft.o: S4/kiss_fft/kiss_fft.c
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@
$(OBJDIR)/S4k/kiss_fftnd.o: S4/kiss_fft/tools/kiss_fftnd.c
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@
$(OBJDIR)/S4k/Eigensystems.o: S4/RNP/Eigensystems.cpp
	$(CXX) -c $(CXXFLAGS) $(CPPFLAGS) $< -o $@

#### Python extension

S4_pyext: objdir $(OBJDIR)/libS4.a
# sh gensetup.py.sh $(OBJDIR) $(S4_LIBNAME) $(LIBS)
# sh gensetup.py.sh $(OBJDIR) $(OBJDIR)/$(S4_LIBNAME) $(LIBS) $(BOOST_PREFIX)
	echo "$(LIBS)" > $(OBJDIR)/tmp.txt
	sh gensetup.py.sh $(OBJDIR) $(OBJDIR)/$(S4_LIBNAME)
	pip install --upgrade ./

clean:
	rm -rf $(OBJDIR)

#### Lua extension
$(OBJDIR)/$(S4_LUA_LIBNAME): $(OBJDIR)/$(S4_LIBNAME) S4/ext_lua.c
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $(LUA_INC) S4/ext_lua.c -o $(OBJDIR)/ext_lua.o
	$(AR) crvs $@ $(OBJDIR)/ext_lua.o
$(OBJDIR)/$(S4_LUA_MODNAME): $(OBJDIR)/$(S4_LIBNAME) $(OBJDIR)/$(S4_LUA_LIBNAME) S4/ext_lua.c
	$(CC) $(CFLAGS) $(CPPFLAGS) $(SHLIB_FLAGS) $(LUA_INC) S4/ext_lua.c -o $@ $(LUA_MODULE_LIB) -L$(OBJDIR) -lS4 $(LA_LIBS) -lstdc++
