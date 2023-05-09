#!/bin/bash

set -e

if [[ ! -f cuda_12.1.1_530.30.02_linux.run ]]; then
    wget -nv https://developer.download.nvidia.com/compute/cuda/12.1.1/local_installers/cuda_12.1.1_530.30.02_linux.run
    echo "d74022d41d80105319dfa21beea39b77a5b9919539c0487a05caaf2446d6a70e  cuda_12.1.1_530.30.02_linux.run" | shasum -c
fi
sudo sh cuda_12.1.1_530.30.02_linux.run --silent --toolkit
