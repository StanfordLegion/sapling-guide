#!/bin/bash

set -e

sudo mkdir -p /usr/local/modules
sudo cp modulespath /usr/share/modules/init/.modulespath
sudo rsync -rv --delete modules/ /usr/local/modules/
