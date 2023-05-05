#!/bin/bash

set -e

root_dir=$(readlink -f $(dirname "${BASH_SOURCE[0]}"))

# unpack LLVM installation
pushd /
if [[ ! -d /usr/local/llvm-16.0.3 ]]; then
    sudo tar xfv $root_dir/install-llvm-16.0.3.tar.gz
fi
popd
