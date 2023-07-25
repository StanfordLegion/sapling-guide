#!/bin/bash

# Convenience script to deploy all compute node software at once.

set -e

# TODO: MPI, CUDA, ...
# Note: need to check that each script is idempotent before adding

pushd llvm
./deploy_llvm.sh
popd

pushd hdf5
./deploy_hdf5.sh
popd

pushd modules
./setup_modules.sh
popd
