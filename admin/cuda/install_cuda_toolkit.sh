#!/bin/bash

set -e

if [[ ! -f cuda_11.7.1_515.65.01_linux.run ]]; then
    wget -nv https://developer.download.nvidia.com/compute/cuda/11.7.1/local_installers/cuda_11.7.1_515.65.01_linux.run
fi
sudo sh cuda_11.7.1_515.65.01_linux.run --silent --toolkit
