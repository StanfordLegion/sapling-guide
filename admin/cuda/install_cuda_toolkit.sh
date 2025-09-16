#!/bin/bash

set -e

if [[ ! -f cuda_12.9.1_575.57.08_linux.run ]]; then
    wget -nv https://developer.download.nvidia.com/compute/cuda/12.9.1/local_installers/cuda_12.9.1_575.57.08_linux.run
    echo "0f6d806ddd87230d2adbe8a6006a9d20144fdbda9de2d6acc677daa5d036417a  cuda_12.9.1_575.57.08_linux.run" | shasum -c
fi
sudo sh cuda_12.9.1_575.57.08_linux.run --silent --toolkit
