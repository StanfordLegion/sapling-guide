#!/bin/bash

set -e

if [[ ! -f llvm-project-16.0.3.src.tar.xz ]]; then
    wget https://github.com/llvm/llvm-project/releases/download/llvmorg-16.0.3/llvm-project-16.0.3.src.tar.xz
    echo "3b12e35332e10cf650578ae18247b91b04926d5427e1a6ae9a51d170a47cfbb2  llvm-project-16.0.3.src.tar.xz" | shasum -c
    tar xf llvm-project-16.0.3.src.tar.xz
fi

if [[ ! -d /usr/local/llvm-16.0.3 ]]; then
    llvm_config_flags=(
        -DCMAKE_INSTALL_PREFIX=/usr/local/llvm-16.0.3
        -DCMAKE_BUILD_TYPE=Release
        -DLLVM_ENABLE_PROJECTS=clang;lld
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
    cmake ../llvm-project-16.0.3.src/llvm "${llvm_config_flags[@]}"
    make -j20
    sudo make install
    popd
fi
# pack for deployment
rm -f install-llvm-16.0.3.tar.gz
tar cfz install-llvm-16.0.3.tar.gz /usr/local/llvm-16.0.3
