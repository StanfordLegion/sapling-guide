#!/bin/bash

# to be run on a compute node after extracting etc/gitlab-runner in the backup tarballs

# i.e.:
# $ sudo tar xfv $backup_dir/backup-$node.tar.gz etc/gitlab-runner

set -e

curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | sudo bash

sudo apt-get install gitlab-runner
