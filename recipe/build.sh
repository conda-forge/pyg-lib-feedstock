#!/bin/bash
set -ex

if [[ ${cuda_compiler_version} != "None" ]]; then
  export FORCE_CUDA=1

  # Set the CUDA arch list from
  # https://github.com/conda-forge/pytorch-cpu-feedstock/blob/main/recipe/build_pytorch.sh

  if [[ ${cuda_compiler_version} == 9.0* ]]; then
    export TORCH_CUDA_ARCH_LIST="3.5;5.0;6.0;7.0+PTX"
    export CUDA_TOOLKIT_ROOT_DIR=$CUDA_HOME
  elif [[ ${cuda_compiler_version} == 9.2* ]]; then
    export TORCH_CUDA_ARCH_LIST="3.5;5.0;6.0;6.1;7.0+PTX"
    export CUDA_TOOLKIT_ROOT_DIR=$CUDA_HOME
  elif [[ ${cuda_compiler_version} == 10.* ]]; then
    export TORCH_CUDA_ARCH_LIST="3.5;5.0;6.0;6.1;7.0;7.5+PTX"
    export CUDA_TOOLKIT_ROOT_DIR=$CUDA_HOME
  elif [[ ${cuda_compiler_version} == 11.0* ]]; then
    export TORCH_CUDA_ARCH_LIST="3.5;5.0;6.0;6.1;7.0;7.5;8.0+PTX"
    export CUDA_TOOLKIT_ROOT_DIR=$CUDA_HOME
  elif [[ ${cuda_compiler_version} == 11.1 ]]; then
    export TORCH_CUDA_ARCH_LIST="3.5;5.0;6.0;6.1;7.0;7.5;8.0;8.6+PTX"
    export CUDA_TOOLKIT_ROOT_DIR=$CUDA_HOME
  elif [[ ${cuda_compiler_version} == 11.2 ]]; then
    export TORCH_CUDA_ARCH_LIST="3.5;5.0;6.0;6.1;7.0;7.5;8.0;8.6+PTX"
    export CUDA_TOOLKIT_ROOT_DIR=$CUDA_HOME
  elif [[ ${cuda_compiler_version} == 11.8 ]]; then
    export TORCH_CUDA_ARCH_LIST="3.5;5.0;6.0;6.1;7.0;7.5;8.0;8.6;8.9+PTX"
    export CUDA_TOOLKIT_ROOT_DIR=$CUDA_HOME
  elif [[ ${cuda_compiler_version} == 12.0 ]]; then
    export TORCH_CUDA_ARCH_LIST="5.0;6.0;6.1;7.0;7.5;8.0;8.6;8.9;9.0+PTX"
    # $CUDA_HOME not set in CUDA 12.0. Using $PREFIX
    export CUDA_TOOLKIT_ROOT_DIR="${PREFIX}"
  else
    echo "unsupported cuda version. edit build.sh"
    exit 1
  fi

  CMAKE_ARGS+=" -DCAFFE2_USE_CUDNN=1"
else
  export FORCE_CUDA=0
fi

# Dynamic libraries need to be lazily loaded so that torch
# can be imported on system without a GPU
export LDFLAGS="${LDFLAGS//-Wl,-z,now/-Wl,-z,lazy}"

# export USE_MKL_BLAS=1  # only used for >0.1.0
export FORCE_NINJA=1
export EXTERNAL_PHMAP_INCLUDE_DIR="${BUILD_PREFIX}/include/"
export EXTERNAL_CUTLASS_INCLUDE_DIR="${BUILD_PREFIX}/include/"

# note that we patch PYG_CMAKE_ARGS into setup.py, in order to set Torch_DIR correctly also for cross-compilation
export PYG_CMAKE_ARGS="${CMAKE_ARGS} -DCMAKE_INSTALL_PREFIX=${PREFIX} -DTorch_DIR=${PREFIX}/lib/python${PY_VER}/site-packages/torch/share/cmake/Torch"

${PYTHON} -m pip install . -vvv
