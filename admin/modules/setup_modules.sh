#!/bin/bash

set -e

sudo apt update -qq
sudo apt install -y environment-modules

sudo mkdir -p /usr/local/modules
sudo cp modulespath /usr/share/modules/init/.modulespath
