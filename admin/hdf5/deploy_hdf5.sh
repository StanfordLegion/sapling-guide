#!/bin/bash

set -e

root_dir=$(readlink -f $(dirname "${BASH_SOURCE[0]}"))

# unpack HDF5 installation
pushd /
if [[ ! -d /usr/local/hdf5-1.14.1-2 ]]; then
    sudo tar xfv $root_dir/install-hdf5-1.14.1-2.tar.gz
fi
popd
