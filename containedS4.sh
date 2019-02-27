#!/bin/bash

# conda install -c defaults -c conda-forge numpy openblas suitesparse libgcc pip gcc lapack fftw boost

set -e # set the script to fail completely if a command has an error

# Hard coding the number of cpus to use; this might be different if you don't have more than 4 cores or would like to use more.
export NPROCS=1

# Pass the environment name as the only argument to the script
# For a fresh installation, you'll want to run
# user@local $~ gnucompile_MEEP.sh mycompiledMEEPenv -rcenv
# If you only want to compile (or re-compile after updates, hence '-rcXXX' prefix) portions of the suite into an existing conda environment
# you can pass the options below, e.g. to only compile h5py and meep from source:
# `gnucompile_MEEP.sh -n mycompiledMEEPenv -rch5py -rcmeep`

RCTBB=false
RCS4=false
INSTALLMEEP=false
RUNFINALTESTS=true
export SRCBUILDDIR="${HOME}/gnu_src_build"
COMPILERS="gnu"
export CONDATRGTENV="compiledMEEP"

while [ -n "$1" ];
do
  case "$1" in
    -rctbb) RCTBB=true;;
    -rcs4) RCS4=true;;
    -source-dir) export SRCBUILDDIR=$2;
      shift;;
    -comiplers) export COMPILERS=$2;
      shift;;
    -n) export CONDATRGTENV=$2;
      shift;;
    -j) export NPROCS=$2;
      shift;;
esac
shift
done
# source $HOME/anaconda3/bin/activate base

source $HOME/anaconda3/bin/activate $CONDATRGTENV


cd $HOME

mkdir -p $SRCBUILDDIR
cd $SRCBUILDDIR


# Notes: Install SuiteSparse to both the S4 director and the conda env:
# Also don't forget to set the TBB var to wherever Intel libtbb.so is
# from SuiteSparse build folder
# INSTALL=$SRCBUILDDIR/S4/S4 make library INSTALL=$SRCBUILDDIR/S4/S4 TBB=/path/to/libtbb.so

# source ~/bin/intelvars.sh

#export MKLROOT="$HOME/intel/compilers_and_libraries_2018.3.222/linux/mkl"
export PATH="$CONDA_PREFIX/bin:$CONDA_PREFIX/x86_64-conda_cos6-linux-gnu/sysroot/usr:$HOME/bin:/bin:/usr/bin"
# RPATH_FLAGS="-Wl,--no-as-needed,-rpath,$SRCBUILDDIR/S4/S4/lib/:${MKLROOT}:$SRCBUILDDIR/SuiteSparse/lib/:${CONDA_PREFIX}/lib/:${CONDA_PREFIX}/lib/openmpi/"
export LIBRARY_PATH="$SRCBUILDDIR/S4/S4/lib/:$CONDA_PREFIX/lib/:$CONDA_PREFIX/x86_64-conda_cos6-linux-gnu/sysroot/usr/lib/:$CONDA_PREFIX/lib/openmpi/:$SRCBUILDDIR/S4/boost_src/"
export CPPFLAGS="-I$CONDA_PREFIX/include/ -I$SRCBUILDDIR/S4/S4/include/ -I$CONDA_PREFIX/x86_64-conda_cos6-linux-gnu/sysroot/usr/include/"
# export CPPFLAGS="$CPPFLAGS -I$SRCBUILDDIR/S4/boost_src/boost/"
export CPATH="$CPATH:${CONDA_PREFIX}/include:${CONDA_PREFIX}/lib/python3.6/site-packages/mpi4py/include:${CONDA_PREFIX}/lib/python3.6/site-packages/numpy/core/include/numpy/:${SRCBUILDDIR}/S4/S4/include/:$CONDA_PREFIX/x86_64-conda_cos6-linux-gnu/sysroot/usr/include/:"
# export CPATH="$CPATH:$SRCBUILDDIR/S4/boost_src/boost/"
export LD_RUN_PATH=$LIBRARY_PATH
export LD_LIBRARY_PATH=$LIBRARY_PATH
# Uncomment exports below to use gcc version X if you have it installed, give the path to it, or just gcc-X if it is installed system wide
# On Ubuntu 16.04, if you have sudo access, it is as easy as:
# sudo apt install --install-recommends --install-suggests gfortran-7 gcc-7 g++-7 -y
# sudo apt install --install-recommends --install-suggests gcc-7
export CC=gcc-7
export CXX=g++-7
# export F77=/usr/bin/gfortran-7
# export MPICC=${CONDA_PREFIX}/bin/mpicc
# export MPICXX=${CONDA_PREFIX}/bin/mpic++
# export CC=$MPICC
# export CXX=$MPICXX
# if [$COMPILERS == "intel"]  # TODO
# export CFLAGS="-O3 -m64 -march=native -mtune=native -pipe $CFLAGS"
# export FFLAGS="-O3 -fPIC -m64 -march=native -mtune=native -pipe"

# Flags
export CFLAGS="-O3 -m64 -march=native -mtune=native -pipe"
# export FFLAGS="-O3 -fPIC -m64 -march=native -mtune=native -pipe"

# export BLAS_LIB="-L$CONDA_PREFIX/lib/ -lmkl_rt -lpthread -ldl"
# export LAPACK_LIB="-L$CONDA_PREFIX/lib/ -lmkl_rt -lpthread -ldl"
export BLAS_LIB="-lblas"
export LAPACK_LIB="-llapack"
# export BLAS_LIB="-L$CONDA_PREFIX/lib/ -lmkl_core -lmkl_rt -lstdc++ -lpthread -lm -ldl"
# export BLAS_LIB="-L$CONDA_PREFIX/lib/ -lpord -lmkl_scalapack_lp64 -lmkl_gf_ilp64 -lmkl_blacs_intelmpi_lp64 -lmkl_intel_lp64 -lmkl_intel_thread -lmkl_core -liomp5 -lpthread -lm -lmpi -lblas -lpthread"
# export BLAS_LIB="-L/usr/lib/x86_64-linux-gnu/ -lcublas -L$CONDA_PREFIX/lib/ -lmkl_core -lmkl_rt -lstdc++ -lpthread -lm -ldl"
# export BLAS_LIB="-L$CONDA_PREFIX/lib/ -lmkl_rt -lpthread -ldl"
# export LAPACK_LIB=$BLAS_LIB
# export LA_LIBS=$BLAS_LIB

# export FFTW3_INC="-I$HOME/intel/compilers_and_libraries_2018.3.222/linux/mkl/include/fftw/"
# export FFTW3_LIB="-L$CONDA_PREFIX/lib/ -lfftw3_mpi"
# export FFTW3_INC="-I$HOME/intel/compilers_and_libraries_2018.3.222/linux/mkl/include/fftw/"
export FFTW3_LIB="-lfftw3"

export PTHREAD_INC="-DHAVE_UNISTD_H"
export PTHREAD_LIB="-L$CONDA_PREFIX/lib/ -lpthread"

export CHOLMOD_INC="-I$SRCBUILDDIR/SuiteSparse/include/"
export CHOLMOD_LIB="-L$SRCBUILDDIR/SuiteSparse/lib/ -lcholmod -lamd -lcolamd -lcamd -lccolamd"


# export BOOST_INC="-I$CONDA_PREFIX/include"
# export BOOST_LIBS="-L$CONDA_PREFIX/lib/ -lboost_serialization -lboost_wserialization"

# export LAPACK_LIB="$BLAS_LIB $CHOLMOD_LIB $FFTW3_LIB"
# export LA_LIBS="$BLAS_LIB $CHOLMOD_LIB $FFTW3_LIB"
# export MPI_INC="-I${CONDA_PREFIX}/include/"
# export MPI_LIB="-L${CONDA_PREFIX}/lib/ -lmpi"

# export OBJDIR="$SRCBUILDDIR/S4/build"
# export S4_LIBNAME="${OBJDIR}/libS4.so"
# export S4r_LIBNAME="${OBJDIR}/libS4r.so"

if $RCTBB;
then
  printf "\n\n=========================INSTALLING TBB============================\n"
  conda install --override-channels -c conda-forge -c intel tbb -y;
  printf "\n\n=========================TBB INSTALL DONE==========================\n";
fi


if $RCS4;
then
  printf "\n\n=========================COMPILE_S4================================\n"
  # cd $SRCBUILDDIR/S4/ || cd $SRCBUILDDIR
  # git pull https://github.com/soamaven/S4.git || git clone https://github.com/soamaven/S4.git
  # git checkout working_mkl_with_conda
  cd $SRCBUILDDIR/S4/
  make clean

  # make boost
  # NEED TO RUN THIS LINE inside Boost.Build source folder to make the INTEL serialization libs
  # ./b2 install --prefix=../S4 --with-serialization toolset=intel variant=release link=static threading=single runtime-link=shared

  make all
  # pwd
  # echo $PATH
  make S4_pyext
  printf "\n\n===========================DONE====================================\n";
  # cd $CONDA_PREFIX
  # mkdir -p ./etc/conda/activate.d
  # mkdir -p ./etc/conda/deactivate.d
  # echo "#!/bin/bash; export CHOLMOD_USE_GPU=1;" > ./etc/conda/activate.d/env_vars.sh
  # echo "#!/bin/bash; uset CHOLMOD_USE_GPU;" > ./etc/conda/deactivate.d/env_vars.sh

fi
