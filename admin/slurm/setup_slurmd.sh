#!/bin/bash

root_dir=$(readlink -f $(dirname "${BASH_SOURCE[0]}"))

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
