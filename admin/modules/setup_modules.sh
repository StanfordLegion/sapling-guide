#!/bin/bash

set -e

sudo apt update -qq
sudo apt install -y environment-modules

sudo mkdir -p /usr/local/modules
sudo cp modulerc /usr/share/modules/init/modulerc
