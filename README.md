# Sapling User Guide

This guide is intended for users of Sapling (sapling.stanford.edu). If
you're a new user, please follow the steps below for first-time
setup. The rest of the guide describes how to use the machine.

## First-Time Setup

Please follow these steps when you first set up your Sapling account.

### 1. How to SSH

```bash
ssh username@sapling.stanford.edu
```

### 2. Change your Password

```bash
passwd
```

### 3. Create a Passwordless SSH Key

This will help make access to the machine nodes easier, so that when you
run jobs you don't need to enter your password.

```bash
ssh-keygen # just enter an empty password
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
```

### 4. Questions? Ask on Slack

We have a `#sapling` channel on Slack. If you have any questions, that's
the best place to ask. Also, that is where we will provide announcements
when there are changes, maintenance, etc. for the machine. (Please ask
to be added if you are not already on our Slack instance.)

## Quickstart

These instructions are the fastest way to get started with Legion or
Regent on Sapling.

### 1. Legion Quickstart

```bash
git clone -b master https://github.com/StanfordLegion/legion.git
srun -N 1 -p gpu --exclusive --pty bash --login
module load cuda
cd legion/examples/circuit
LG_RT_DIR=$PWD/../../runtime USE_CUDA=1 make -j20
./circuit -ll:gpu 1
```

### 2. Regent Quickstart

```bash
git clone -b master https://github.com/StanfordLegion/legion.git
srun -N 1 -p gpu --exclusive --pty bash --login
module load cuda
cd legion/language
CMAKE_PREFIX_PATH=/scratch2/eslaught/sw/llvm/llvm-11/install_g_nodes ./install.py --debug --cuda
./regent.py examples/circuit_sparse.rg -fcuda 1 -ll:gpu 1
```

## Machine Layout

Sapling consists of four sets of nodes:

<table>
<thead>
<tr class="header">
<th>Type</th>
<th>Name</th>
<th>Memory</th>
<th>CPU (Cores)</th>
<th>GPU</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>Head</td>
<td>sapling</td>
<td>96 GB</td>
<td>Intel Xeon E5606<br />
(4 cores)</td>
<td></td>
</tr>
<tr class="even">
<td>CPU</td>
<td>c0001 to c0004</td>
<td>256 GB</td>
<td>2x Intel Xeon CPU E5-2640 v4<br />
(2x20 cores)</td>
<td></td>
</tr>
<tr class="odd">
<td>GPU</td>
<td>g0001 to g0004</td>
<td>256 GB</td>
<td>2x Intel Xeon CPU E5-2640 v4<br />
(2x20 cores)</td>
<td>4x Tesla P100 (Pascal)</td>
</tr>
<tr class="even">
<td>CI</td>
<td>n0000 to n0004</td>
<td>48 GB</td>
<td>2x Intel Xeon X5680<br />
(2x6 cores)</td>
<td>2x Tesla C2070 (Fermi)</td>
</tr>
</tbody>
</table>

When you log in, you'll get to the head node. Note that, because it uses
a different architecture from the CPU/GPU nodes, it is probably best to
use one of those nodes to build and run your software. (See below for
machine access instructions.)

## Using the Machine

Some things to keep in mind while using the machine:

### 1. Module System

Sapling has a very *minimal* module system. The intention is to provide
compilers, MPI, and SLURM. All other packages should be installed on a
per-user basis with Spack (see below).

To get started with the module system, we recommend adding the following
to your `~/.bashrc`:

```bash
module load mpi
module load slurm
```

Some additional modules are only available on the compute nodes. E.g.,
on the GPU nodes, CUDA is available via:

```bash
module load cuda
```

### 2. Launching Interactive Jobs with SLURM

Because the hardware and software is different on different nodes, it is
important to build and run all software on the compute nodes. On
Sapling, we do this through the SLURM job scheduler.

To launch an interactive, single-node job (e.g., for building software):

```bash
srun -N 1 -n 1 -c 40 -p cpu --pty bash --login
```

Here's a break-down of the parts in this command:

  * `srun`: we're going to launch the job immediately (as opposed to, say,
    via a batch script).
  * `-N 1` (a.k.a., `--nodes 1`): request one node.
  * `-n 1` (a.k.a., `--ntasks 1`): we're going to run one "task". This
    is the number of processes to launch. In this case because we only
    want one copy of bash to be running.
  * `-c 40` (a.k.a., `--cpus-per-task 40`): the number of CPUs per task.
  * `-p cpu` (a.k.a., `--partition cpu`): select the CPU
    partition. (Change to `gpu` if you want to use GPU nodes, or skip
    if you don't care.)
  * `--pty`: because it's an interactive job, we want the terminal to be
    set up like an interactive shell. You'd skip this on a batch job.
  * `bash`: the command to run. (Replace this with your shell of choice.)

### 3. Launching Batch Jobs with SLURM

To launch a batch job, you might do something like the following:

```bash
sbatch my_batch_script.sh
```

Where `my_batch_script.sh` contains:

```bash
#!/bin/bash
#SBATCH -N 2
#SBATCH -n 2
#SBATCH -c 40
#SBATCH -p cpu

srun hostname
```

Note that, because the flags (`-N 2 -n 2 -c 40 -p cpu`) were provided on the
`SBATCH` lines in the script, it is *not* necessary to provide them
when calling `srun`. SLURM will automatically pick them up and use
them for any `srun` commands contained in the script.

After the job runs, you will get a file like `slurm-12.out` that
contains the job output. In this case, that output would look
something like:

```
c0001.stanford.edu
c0002.stanford.edu
```

### 4. Workaround for MPI-SLURM incompatibility

As of this current writing, MPI has not been built with SLURM
compatibility enabled. That means that Legion, Regent and MPI jobs
*cannot* be launched with `srun`. A workaround for this is to use
`mpirun` instead. For example, in a 2 node job, you might do:

```bash
mpirun -n 2 -npernode 1 -bind-to none ...
```

Note: Continue to follow the same instructions above for either using
`salloc` or `sbatch`. The difference is to use `mpirun` instead of
`srun` to launch the job.

### 5. Spack

Reminder: all software should be installed and built on the compute
nodes themselves. Please run the following in an interactive SLURM job
(see [Launching Interactive
Jobs](#2-launching-interactive-jobs-with-slurm) above).

Note: these instructions are condensed from the Spack documentation at
https://spack.readthedocs.io/en/latest/. However for more advanced
topics please see the original documentation.

```bash
git clone https://github.com/spack/spack.git
echo "if [[ \$(hostname) = c0* || \$(hostname) = g0* ]]; then source \$HOME/spack/share/spack/setup-env.sh; fi" >> ~/.bashrc
source $HOME/spack/share/spack/setup-env.sh
spack compiler find
spack external find openmpi
```

At that point, you should be able to install Spack packages. E.g.:

```bash
spack install legion
```

(Note: you probably *don't* want to do this, because most Legion users
prefer to be on `master` or `control_replication`, but anyway, it
should work.)

### 6. Coordinating with Other Users

Sapling is a mixed-mode machine. While SLURM is the default job
scheduler, users can still use SSH to directly access nodes (and for
some purposes, may need to do so). Therefore, when you are doing
something performance-sensitive, please let us know on the `#sapling`
channel that you intend to do so. Similarly, please watch the `#sapling`
channel to make sure you're not stepping on what other users are doing.

## Administration

How to...

### 1. Upgrade CUDA Driver

Contact `action@cs`. They installed the CUDA driver originally on the
`g000*` nodes, and know how to upgrade it.

For posterity, here is the upgrade procedure used (as of
2022-09-15)&mdash;but you can let the admins do this:

```
wget https://us.download.nvidia.com/XFree86/Linux-x86_64/515.65.01/NVIDIA-Linux-x86_64-515.65.01.run
systemctl stop nvidia-persistenced.service
chmod +x NVIDIA-Linux-x86_64-515.65.01.run
./NVIDIA-Linux-x86_64-515.65.01.run --uninstall
./NVIDIA-Linux-x86_64-515.65.01.run -q -a -n -X -s
systemctl start nvidia-persistenced.service
```

### 2. Install CUDA Toolkit

We can do this ourselves. Note: for the driver, see above.

```bash
admin/install_cuda_toolkit.sh
admin/install_cudnn.sh # note: requires download (see script)
sudo cp admin/cuda/modules/11.7 /usr/local/modules/cuda/
```

### 3. Upgrade Linux Kernel (or System Software)

We can do this ourselves, but watch out for potential upgrade hazards
(e.g., GCC minor version updates, Linux kernel upgrades).

```bash
sudo apt update
sudo apt upgrade
sudo reboot
```

**Important:** check the status of the NVIDIA driver after this. If
`nvidia-smi` breaks, see above.

### 4. Install Docker

We are responsible for maintaining Docker on the compute nodes.

```bash
admin/install_docker.sh
```

### 5. Install GitLab Runner

We are responsible for maintaining GitLab Runner on the compute nodes.

See `admin/gitlab` for some sample scripts.

### 6. Troubleshoot SLURM Jobs

 1. Jobs do not complete, but remain in the `CG` (completing) state.

    There seem to be two possible causes for this:

      * Either there is something wrong with the compute node itself
        (e.g., out of memory) that is preventing it from killing the
        job, or

      * There is some sort of a network issue. For example, we have
        seen DNS issues that created these symptoms. If `ping sapling`
        fails or connects to `127.0.1.1` instead of the head node,
        this is the likely culprit.

    Remember that SLURM itself will keep retrying to clear the
    completing job, so if it stays in the queue, it's because of an
    ongoing (not just one-time) issue.

    Steps to diagnose:

      * SSH to the failing node and see if it looks healthy (`htop`).

      * Try `ping sapling` from the compute node and see if it works.

    `/var/log/syslog` is unlikely to be helpful at default SLURM
    logging levels. You can `/etc/slurm.conf` to define log files and
    levels to allow you to get more information if you need to.
