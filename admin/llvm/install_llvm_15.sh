#!/bin/bash

set -e

if [[ ! -f llvm-project-15.0.7.src.tar.xz ]]; then
    wget https://github.com/llvm/llvm-project/releases/download/llvmorg-15.0.7/llvm-project-15.0.7.src.tar.xz
    echo "8b5fcb24b4128cf04df1b0b9410ce8b1a729cb3c544e6da885d234280dedeac6  llvm-project-15.0.7.src.tar.xz" | shasum -c
    tar xf llvm-project-15.0.7.src.tar.xz
fi

if [[ ! -d /usr/local/llvm-15.0.7 ]]; then
    llvm_config_flags=(
        -DCMAKE_INSTALL_PREFIX=/usr/local/llvm-15.0.7
        -DCMAKE_BUILD_TYPE=Release
        -DLLVM_ENABLE_PROJECTS="clang;lld"
        -DLLVM_ENABLE_RUNTIMES=libunwind
        -DLLVM_ENABLE_TERMINFO=OFF
        -DLLVM_ENABLE_LIBEDIT=OFF
        -DLLVM_ENABLE_ZLIB=OFF
        -DLLVM_ENABLE_ZSTD=OFF
        -DLLVM_ENABLE_LIBXML2=OFF
        -DLLVM_ENABLE_ASSERTIONS=OFF
        # experimental SPIRV target
        -DLLVM_EXPERIMENTAL_TARGETS_TO_BUILD=SPIRV
        -DLLVM_ENABLE_DUMP=ON
    )

    mkdir build
    pushd build
    cmake ../llvm-project-15.0.7.src/llvm "${llvm_config_flags[@]}"
    make -j20
    sudo make install
    popd
fi
# pack for deployment
rm -f install-llvm-15.0.7.tar.gz
tar cfz install-llvm-15.0.7.tar.gz /usr/local/llvm-15.0.7
