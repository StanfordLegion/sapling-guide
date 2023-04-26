#!/bin/bash

set -e

if [[ ! -d /usr/local/slurm-23.02.1 ]]; then
    echo "Install SLURM first!"
    exit 1
fi

if [[ ! -d openmpi-4.1.5 ]]; then
    wget -nv https://download.open-mpi.org/release/open-mpi/v4.1/openmpi-4.1.5.tar.bz2
    echo "a640986bc257389dd379886fdae6264c8cfa56bc98b71ce3ae3dfbd8ce61dbe3  openmpi-4.1.5.tar.bz2" | shasum -c
    tar xf openmpi-4.1.5.tar.bz2
fi

if [[ ! -d /usr/local/openmpi-4.1.5 ]]; then
    mpi_config_flags=(
	--prefix=/usr/local/openmpi-4.1.5
	--with-hwloc=/usr/local/hwloc-2.9.1
	--with-pmix=/usr/local/pmix-4.1.1
        --enable-orterun-prefix-by-default
        --with-verbs
    )

    pushd openmpi-4.1.5
    ./configure "${mpi_config_flags[@]}"
    make -j20
    sudo make install
    popd
fi
