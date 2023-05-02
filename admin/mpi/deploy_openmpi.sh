#!/bin/bash

set -e

root_dir=$(readlink -f $(dirname "${BASH_SOURCE[0]}"))

# unpack MPI installation
pushd /
if [[ ! -d /usr/local/openmpi-4.1.5 ]]; then
    sudo tar xfv $root_dir/install-openmpi-4.1.5.tar.gz
fi
popd
