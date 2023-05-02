#!/bin/bash

set -e

# if [[ ! -d /usr/local/cuda-11.7 ]]; then
#     echo "Install CUDA toolkit first!"
#     exit 1
# fi

# install SLURM dependencies
package_list=(
    # hwloc
    libxml2-dev libcairo2-dev libpciaccess-dev libudev-dev libltdl-dev

    # pmix
    libevent-dev

    # SLURM
    munge libmunge-dev # authentication
)
sudo apt update -qq
sudo apt install -y "${package_list[@]}"

if [[ ! -d hwloc-2.9.1 ]]; then
    wget -nv https://download.open-mpi.org/release/hwloc/v2.9/hwloc-2.9.1.tar.bz2
    echo "7cc4931a20fef457e0933af3f375be6eafa7703fde21e137bfb9685b1409599e  hwloc-2.9.1.tar.bz2" | shasum -c
    tar xf hwloc-2.9.1.tar.bz2
fi

if [[ ! -d /usr/local/hwloc-2.9.1 ]]; then
    hwloc_config_flags=(
	--prefix=/usr/local/hwloc-2.9.1
	# I'm concerned about compatibility against future CUDA updates, so shut this off
	# --with-cuda=/usr/local/cuda-11.7
	--with-cuda=/disabled
    )
    pushd hwloc-2.9.1
    ./configure "${hwloc_config_flags[@]}"
    make -j20
    sudo make install
    popd
fi
# pack for deployment
rm install-hwloc-2.9.1.tar.gz
tar cfz install-hwloc-2.9.1.tar.gz /usr/local/hwloc-2.9.1

if [[ ! -d pmix-4.1.1 ]]; then
    wget -nv https://github.com/openpmix/openpmix/releases/download/v4.1.1/pmix-4.1.1.tar.bz2
    echo "0527a15d616637b95975d238bbc100b244894518fbba822cd8f46589ca61ccec  pmix-4.1.1.tar.bz2" | shasum -c
    tar xf pmix-4.1.1.tar.bz2
fi

if [[ ! -d /usr/local/pmix-4.1.1 ]]; then
    pmix_config_flags=(
	--prefix=/usr/local/pmix-4.1.1
	--with-hwloc=/usr/local/hwloc-2.9.1
    )
    pushd pmix-4.1.1
    ./configure "${pmix_config_flags[@]}"
    make -j20
    sudo make install
    popd
fi
# pack for deployment
rm install-pmix-4.1.1.tar.gz
tar cfz install-pmix-4.1.1.tar.gz /usr/local/pmix-4.1.1

if [[ ! -f slurm-23.02.1.tar.bz2 ]]; then
    wget -nv https://download.schedmd.com/slurm/slurm-23.02.1.tar.bz2
    echo "868a83cdeaec98bc34e558b06e5df05ca52aadda0a6f1129cc02c81b13cbb022  slurm-23.02.1.tar.bz2" | shasum -c
    tar xf slurm-23.02.1.tar.bz2
fi

if [[ ! -d /usr/local/slurm-23.02.1 ]]; then
    slurm_config_flags=(
	--prefix=/usr/local/slurm-23.02.1
	--with-hwloc=/usr/local/hwloc-2.9.1
	--with-pmix=/usr/local/pmix-4.1.1
	# I'm concerned about compatibility against future CUDA updates, so shut this off
	# --with-nvml=/usr/local/cuda-11.7
	--sysconfdir=/etc
	--localstatedir=/var
	--runstatedir=/run
    )

    pushd slurm-23.02.1
    ./configure "${slurm_config_flags[@]}"
    make -j20
    sudo make install
    popd
fi
# pack for deployment
rm install-slurm-23.02.1.tar.gz
tar cfz install-slurm-23.02.1.tar.gz /usr/local/slurm-23.02.1
