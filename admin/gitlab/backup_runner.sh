#!/bin/bash

set -e

backup_dir="$1"

backup_file="$backup_dir"/backup-"$(hostname)".tar.gz

sudo tar cfzv "$backup_file" /etc/gitlab-runner /etc/init/gitlab-runner.conf /usr/lib/gitlab-runner /usr/bin/gitlab-*runner /usr/bin/gitlab-runner.* /usr/share/gitlab-runner /usr/share/doc/gitlab-runner /etc/apt/sources.list.d/*gitlab-runner*

sudo chown $USER:$USER "$backup_file"
