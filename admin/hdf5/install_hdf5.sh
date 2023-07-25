#!/bin/bash

set -e

module load cmake # depends on CMake >= 3.18
module unload mpi # make sure we DON'T build against MPI

if [[ ! -f hdf5-1_14_1-2.tar.gz ]]; then
    wget https://github.com/HDFGroup/hdf5/releases/download/hdf5-1_14_1-2/hdf5-1_14_1-2.tar.gz
    echo "06950ec33f5ac2d86aa6eb680c735dc304665911e0d10e54cf68719d76acdd67  hdf5-1_14_1-2.tar.gz" | shasum -c
    tar xf hdf5-1_14_1-2.tar.gz
fi

if [[ ! -d /usr/local/hdf5-1.14.1-2 ]]; then
    llvm_config_flags=(
        -DCMAKE_INSTALL_PREFIX=/usr/local/hdf5-1.14.1-2
        -DCMAKE_BUILD_TYPE=Release
        -DHDF5_ENABLE_THREADSAFE=ON
        -DHDF5_BUILD_HL_LIB=OFF
    )

    mkdir build
    pushd build
    cmake ../hdfsrc "${llvm_config_flags[@]}"
    make -j20
    sudo make install
    popd
fi
# pack for deployment
rm -f install-hdf5-1.14.1-2.tar.gz
tar cfz install-hdf5-1.14.1-2.tar.gz /usr/local/hdf5-1.14.1-2
