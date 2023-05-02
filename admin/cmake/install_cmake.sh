#!/bin/bash

set -e

root_dir=$(readlink -f $(dirname "${BASH_SOURCE[0]}"))

if [[ ! -f cmake-3.26.3-linux-x86_64.tar.gz ]]; then
    wget -nv https://github.com/Kitware/CMake/releases/download/v3.26.3/cmake-3.26.3-linux-x86_64.tar.gz
    echo "28d4d1d0db94b47d8dfd4f7dec969a3c747304f4a28ddd6fd340f553f2384dc2  cmake-3.26.3-linux-x86_64.tar.gz" | shasum -c
fi

if [[ ! -d /usr/local/cmake-3.26.3 ]]; then
    sudo tar xfv cmake-3.26.3-linux-x86_64.tar.gz -C /usr/local/cmake-3.26.3 --strip-components 1
fi
