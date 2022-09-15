#!/bin/bash

# https://docs.docker.com/engine/install/ubuntu/

sudo apt-get remove docker docker-engine docker.io containerd runc
sudo apt-get update
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

echo "Elliott: skipping relocation of /var/lib/docker on n* nodes because they do not have SSDs (or at least, they don't all have them)"
exit 0

# now need to move the storage directory out of /var/lib/docker
# $ ls -ld /var/lib/docker
# drwx--x--- 13 root root 4096 Mar 10 15:55 /var/lib/docker

# https://evodify.com/change-docker-storage-location/
mkdir -p /scr-ssd/docker
sudo chown root:root /scr-ssd/docker
sudo cp /etc/docker/daemon.json /etc/docker/daemon.json.backup || true
echo '{"data-root": "/scr-ssd/docker"}' > daemon.json
sudo mv daemon.json /etc/docker/daemon.json
sudo systemctl stop docker
sudo systemctl start docker
