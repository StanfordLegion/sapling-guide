#!/bin/bash

set -e

uid="$1"

if [[ -z $uid ]]; then
    echo "Need to specify user"
    exit 1
fi

root_dir=$(readlink -f $(dirname "${BASH_SOURCE[0]}"))

sudo adduser --no-create-home $uid

"$root_dir"/create_home.sh $uid

# mkhomedir_helper refuses to do anything on an existing directory, so
# we've got to do this ourselves
sudo cp -r /etc/skel/. /home/$uid
