#!/bin/bash

set -e

root_dir=$(readlink -f $(dirname "${BASH_SOURCE[0]}"))

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

# unpack SLURM installation
pushd /
if [[ ! -d /usr/local/hwloc-2.9.1 ]]; then
    sudo tar xfv $root_dir/install-hwloc-2.9.1.tar.gz
fi

if [[ ! -d /usr/local/pmix-4.1.1 ]]; then
    sudo tar xfv $root_dir/install-pmix-4.1.1.tar.gz
fi

if [[ ! -d /usr/local/slurm-23.02.1 ]]; then
    sudo tar xfv $root_dir/install-slurm-23.02.1.tar.gz
fi
popd

sudo cp slurm.conf /etc/slurm.conf

sudo mkdir -p /var/spool/slurmd
sudo chown slurm:slurm /var/spool/slurmd

sudo touch /var/run/slurmd.pid
sudo chown slurm:slurm /var/run/slurmd.pid

sudo cp slurm-23.02.1/etc/slurmd.service /etc/systemd/system/slurmd.service
sudo systemctl enable slurmd
sudo systemctl start slurmd
