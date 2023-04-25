#!/bin/bash

set -e

if [[ ! -f cuda_11.7.1_515.65.01_linux.run ]]; then
    wget -nv https://developer.download.nvidia.com/compute/cuda/11.7.1/local_installers/cuda_11.7.1_515.65.01_linux.run
    echo "52286a29706549b7d0feeb0e7e3eca1b15287c436a69fa880ad385b1be3e04db  cuda_11.7.1_515.65.01_linux.run" | shasum -c
fi
sudo sh cuda_11.7.1_515.65.01_linux.run --silent --toolkit
