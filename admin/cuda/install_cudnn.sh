#!/bin/bash

set -e

# go to https://developer.nvidia.com/cudnn and follow instructions to download
# (the link should be something like below, but you cannot access this without logging in)
# https://developer.nvidia.com/downloads/compute/cudnn/secure/8.9.1/local_installers/12.x/cudnn-linux-x86_64-8.9.1.23_cuda12-archive.tar.xz

if [[ ! -f cudnn-linux-x86_64-8.9.1.23_cuda12-archive.tar.xz ]]; then
    echo "Cannot locate cuDNN installer, did you download it?"
    exit 1
fi

if [[ ! -d cudnn-linux-x86_64-8.9.1.23_cuda12-archive ]]; then
    echo "35163c5c542be0c511738b27e25235193cbeedc5e0e006e44b1cdeaf1922e83e  cudnn-linux-x86_64-8.9.1.23_cuda12-archive.tar.xz" | shasum -c
    tar xf cudnn-linux-x86_64-8.9.1.23_cuda12-archive.tar.xz
fi

# https://docs.nvidia.com/deeplearning/cudnn/install-guide/index.html#installlinux-tar
sudo cp cudnn-linux-x86_64-8.9.1.23_cuda12-archive/include/cudnn*.h /usr/local/cuda-12.1/include
sudo cp -P cudnn-linux-x86_64-8.9.1.23_cuda12-archive/lib/libcudnn* /usr/local/cuda-12.1/lib64
sudo chmod a+r /usr/local/cuda-12.1/include/cudnn*.h /usr/local/cuda-12.1/lib64/libcudnn*
