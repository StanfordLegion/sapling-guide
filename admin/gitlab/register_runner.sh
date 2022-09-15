#!/bin/bash

set -e

# This isn't a very sophisticated script; after running this, you'll
# still need to edit the CPU pinning by hand.

name="$1"
token="$2"

for i in 0 1 2 3 4 5 6; do
    sudo gitlab-runner register --url https://gitlab.com/ --registration-token "$token" --name "$name"-$i --executor docker --docker-image ubuntu:22.04 --tag-list compute,linux
done
