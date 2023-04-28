#!/bin/bash

set -e

uid="$1"

if [[ -z $uid ]]; then
    echo "Need to specify user"
    exit 1
fi

sudo zfs create home/$uid
sudo zfs set quota=500G home/$uid
sudo chown $uid:$uid /home/$uid
sudo chmod 750 /home/$uid
sudo chmod g+s /home/$uid
