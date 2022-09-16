#!/bin/bash

set -e

# go to https://developer.nvidia.com/cudnn and follow instructions to download
# (the link should be something like below, but you cannot access this without logging in)
# https://developer.nvidia.com/compute/cudnn/secure/8.5.0/local_installers/11.7/cudnn-linux-x86_64-8.5.0.96_cuda11-archive.tar.xz

if [[ ! -f cudnn-linux-x86_64-8.5.0.96_cuda11-archive.tar.xz ]]; then
    echo "Cannot locate cuDNN installer, did you download it?"
    exit 1
fi

if [[ ! -d cudnn-linux-x86_64-8.5.0.96_cuda11-archive ]]; then
    tar xf cudnn-linux-x86_64-8.5.0.96_cuda11-archive.tar.xz
fi

# https://docs.nvidia.com/deeplearning/cudnn/install-guide/index.html#installlinux-tar
sudo cp cudnn-linux-x86_64-8.5.0.96_cuda11-archive/include/cudnn*.h /usr/local/cuda-11.7/include
sudo cp -P cudnn-linux-x86_64-8.5.0.96_cuda11-archive/lib/libcudnn* /usr/local/cuda-11.7/lib64
sudo chmod a+r /usr/local/cuda-11.7/include/cudnn*.h /usr/local/cuda-11.7/lib64/libcudnn*
