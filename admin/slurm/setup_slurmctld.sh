#!/bin/bash

set -e

sudo cp slurm.conf /etc/slurm.conf

sudo mkdir -p /var/spool/slurmctld
sudo chown slurm:slurm /var/spool/slurmctld

sudo touch /var/run/slurmctld.pid
sudo chown slurm:slurm /var/run/slurmctld.pid

sudo cp slurm-23.02.1/etc/slurmctld.service /etc/systemd/system/slurmctld.service
sudo systemctl enable slurmctld
sudo systemctl start slurmctld
