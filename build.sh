#!/bin/bash

set -euo pipefail

KLEE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KLEE_ULIBC="$KLEE_DIR/../klee-uclibc"
LLVM_DIR="$KLEE_DIR/../llvm"
Z3_DIR="$KLEE_DIR/../z3"

BUILD_DIR="$KLEE_DIR/build"

CMAKE_OPTIONS=(
  "${COMMON_CMAKE_OPTIONS[@]}"
  -DCMAKE_CXX_FLAGS="-D_GLIBCXX_USE_CXX11_ABI=0"
)

build() {
  [ -d "$BUILD_DIR" ] || mkdir -p "$BUILD_DIR"
  cd "$BUILD_DIR"

  [ -f "Makefile" ] || \
    CMAKE_PREFIX_PATH="$Z3_DIR/build" \
    CMAKE_INCLUDE_PATH="$Z3_DIR/build/include/" \
    cmake \
      -DENABLE_UNIT_TESTS=OFF \
      -DBUILD_SHARED_LIBS=OFF \
      -DLLVM_CONFIG_BINARY="$LLVM_DIR/Release/bin/llvm-config" \
      -DLLVMCC="$LLVM_DIR/Release/bin/clang" \
      -DLLVMCXX="$LLVM_DIR/Release/bin/clang++" \
      -DENABLE_SOLVER_Z3=ON \
      -DENABLE_KLEE_UCLIBC=ON \
      -DKLEE_UCLIBC_PATH="$KLEE_ULIBC" \
      -DENABLE_POSIX_RUNTIME=ON \
      -DENABLE_KLEE_ASSERTS=ON \
      -DENABLE_DOXYGEN=OFF \
      -DCMAKE_BUILD_TYPE=RelWithDebInfo \
      $KLEE_DIR

  make -kj $(nproc) || exit 1
}

build
