#!/bin/bash

set -e

# go to https://developer.nvidia.com/cudnn and follow instructions to download
# (the link should be something like below, but you cannot access this without logging in)
# https://developer.nvidia.com/downloads/compute/cudnn/secure/8.9.7/local_installers/12.x/cudnn-linux-x86_64-8.9.7.29_cuda12-archive.tar.xz

if [[ ! -f cudnn-linux-x86_64-8.9.7.29_cuda12-archive.tar.xz ]]; then
    echo "Cannot locate cuDNN installer, did you download it?"
    exit 1
fi

if [[ ! -d cudnn-linux-x86_64-8.9.7.29_cuda12-archive ]]; then
    echo "475333625c7e42a7af3ca0b2f7506a106e30c93b1aa0081cd9c13efb6e21e3bb  cudnn-linux-x86_64-8.9.7.29_cuda12-archive.tar.xz" | shasum -c
    tar xf cudnn-linux-x86_64-8.9.7.29_cuda12-archive.tar.xz
fi

# https://docs.nvidia.com/deeplearning/cudnn/install-guide/index.html#installlinux-tar
sudo cp cudnn-linux-x86_64-8.9.7.29_cuda12-archive/include/cudnn*.h /usr/local/cuda-12.9/include
sudo cp -P cudnn-linux-x86_64-8.9.7.29_cuda12-archive/lib/libcudnn* /usr/local/cuda-12.9/lib64
sudo chmod a+r /usr/local/cuda-12.9/include/cudnn*.h /usr/local/cuda-12.9/lib64/libcudnn*
