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
ssh-keygen -t ed25519 # just enter an empty password
cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys
```

### 4. Questions? Ask on Zulip

We have a `#sapling` stream on Zulip. If you have any questions, that's
the best place to ask. Also, that is where we will provide announcements
when there are changes, maintenance, etc. for the machine. (Please ask
for the signup link if you are not already on our Zulip instance.)

## Quickstart

These instructions are the fastest way to get started with Legion or
Regent on Sapling.

### 1. Legion Quickstart

```bash
git clone -b master https://github.com/StanfordLegion/legion.git
srun -n 1 -N 1 -c 40 -p gpu --exclusive --pty bash --login
module load cuda
cd legion/examples/circuit
LG_RT_DIR=$PWD/../../runtime USE_CUDA=1 make -j20
./circuit -ll:gpu 1
```

### 2. Regent Quickstart

```bash
git clone -b master https://github.com/StanfordLegion/legion.git
srun -n 1 -N 1 -c 40 -p gpu --exclusive --pty bash --login
module load cmake cuda llvm
cd legion/language
./install.py --debug --cuda
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
      <td>256 GB</td>
      <td>Intel Xeon Silver 4316<br />
        (20 cores)</td>
      <td></td>
    </tr>
    <tr class="even">
      <td>CPU</td>
      <td>c0001 to c0004</td>
      <td>256 GB</td>
      <td>2x Intel Xeon CPU E5-2640 v4<br />
        (2x10 cores)</td>
      <td></td>
    </tr>
    <tr class="odd">
      <td>GPU</td>
      <td>g0001 to g0004</td>
      <td>256 GB</td>
      <td>2x Intel Xeon CPU E5-2640 v4<br />
        (2x10 cores)</td>
      <td>4x Tesla P100 (Pascal)</td>
    </tr>
    <tr class="even">
      <td>CI</td>
      <td>n0000 to n0002</td>
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

## Filesystems

The following filesystems are mounted on NFS and are available on all
nodes in the cluster.

<table>
  <thead>
    <tr class="header">
      <th>Path</th>
      <th>Filesystem</th>
      <th>Total Capacity</th>
      <th>Quota</th>
      <th>Replication Factor</th>
    </tr>
  </thead>
  <tbody>
    <tr class="odd">
      <td><code>/home</code></td>
      <td>ZFS</td>
      <td>7 TiB</td>
      <td>100 GiB</td>
      <td>2x</td>
    </tr>
    <tr class="even">
      <td><code>/scratch</code></td>
      <td>ZFS</td>
      <td>7 TiB</td>
      <td>None</td>
      <td>None</td>
    </tr>
    <tr class="odd">
      <td><code>/scratch2</code></td>
      <td>ZFS</td>
      <td>7 TiB</td>
      <td>None</td>
      <td>None</td>
    </tr>
  </tbody>
</table>

Please note that `/home` has a quota. Larger files may be placed on
`/scratch` or `/scratch2`, but please be careful about disk usage. If
your usage is excessive, you may be contacted to reduce it.

You may check your `/home` quota usage with:

```bash
df -h $HOME
```

## Using the Machine

Some things to keep in mind while using the machine:

### 0. Hardware Differences

As of the May 2023 upgrade, we now maintain uniform software across
the machine (e.g., the module system below, and the base OS). However,
the head node and compute nodes still use different generations of
Intel CPUs. It is usually possible to build compatible software, as
long as you do not specify an `-march=native` flag (or similar) while
building. **However, note that Legion and Regent set `-march=native`
by default and should not be expected to work.** There are two
possible solutions to this:

 1. Build on a compute node. (See below for how to launch an
    interactive job.)

 2. Disable `-march=native`.

    * For Legion, with Make build system: set `MARCH=broadwell`
    * For Legion, with CMake build system: set `-DBUILD_MARCH=broadwell`
    * For Regent: requires modifications to Terra, so it is easiest to
      follow (1) above.

### 1. Module System

Sapling has a very *minimal* module system. The intention is to provide
compilers, MPI, and SLURM. All other packages should be installed on a
per-user basis with Spack (see below).

To get started with the module system, we recommend adding the following
to your `~/.bashrc`:

```bash
module load slurm mpi cmake
```

If you wish to use CUDA, you may also add:

```bash
module load cuda
```

Note: as of the May 2023 upgrade, we now maintain a uniform module
system across the machine. All modules should be available on all
nodes. For example, CUDA is available even on nodes without a GPU,
including the head node. This should make it easier to build software
that runs across the entire cluster.

### 2. Launching Interactive Jobs with SLURM

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
  * `-c 40` (a.k.a., `--cpus-per-task 40`): the number of CPUs per
    task. This is important, or else your job will be bound to a
    single core.
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

**Note: this workaround is no longer required. MPI should now detect
the SLURM job properly.**

Previously, MPI had not been built with SLURM
compatibility enabled. That meant that Legion, Regent and MPI jobs
could not be launched with `srun`. A workaround for this was to use
`mpirun` instead. For example, in a 2 node job, you might do:

```bash
mpirun -n 2 -npernode 1 -bind-to none ...
```

Now, instead of doing this, you can simply do:

```bash
srun -n 2 -N 2 -c 40 ...
```

(Note: the `-c 40` is required to make sure your job is given access
to all the cores on the node.)

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
cd admin/cuda
./install_cuda_toolkit.sh
./install_cudnn.sh # note: requires download (see script)
cd ../modules
./setup_modules.sh
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
cd admin
./install_docker.sh
```

Do **NOT** add users to to the `docker` group. This is equivalent to
adding them to `sudo`. Instead see rootless setup below.

#### 4.1 Rootless Docker

From: https://docs.docker.com/engine/security/rootless/

Install `uidmap` utility:

```bash
sudo apt update
sudo apt install uidmap
```

Create a range of at least 65536 UIDs/GIDs for the user in
`/etc/subuid` and `/etc/subgid`:

```
$ cat /etc/subuid
test_docker:655360:65536
$ cat /etc/subgid
test_docker:655360:65536
```

**Within the user account,** run:

```bash
salloc -n 1 -N 1 -c 40 -p gpu --exclusive
ssh $SLURM_NODELIST
dockerd-rootless-setuptool.sh install
```

(The SSH is required because user-level systemctl seems to be highly
sensitive to how you log into the node. Otherwise you'll get an error
saying "systemd not detected".)

Make sure to export the variables printed by the command above. E.g.:

```bash
export PATH=/usr/bin:$PATH
export DOCKER_HOST=unix:///run/user/$(id -u)/docker.sock
```

Relocate Docker's internal storage into `/tmp/$USER` to avoid issues
with NFS:

```bash
mkdir -p /tmp/$USER
mkdir -p ~/.config/docker
echo '{"data-root":"/tmp/'$USER'"}' > ~/.config/docker/daemon.json
systemctl --user stop docker
systemctl --user start docker
```

Try running a container:

```bash
docker run -ti ubuntu:22.04
```

Clean up old containers (WARNING: may delete data):

```bash
docker container prune
```

### 5. Install GitLab Runner

We are responsible for maintaining GitLab Runner on the compute nodes.

See `admin/gitlab` for some sample scripts.

### 6. Reboot Nodes

There are three ways to reboot nodes, with progressively more
aggressive settings:

  * **Soft reboot.** SSH to the node and run:

    ```bash
    sudo reboot
    ```

    IMPORTANT: be sure you are on the compute node and **not the head
    node** when you do this. Otherwise you will kill the machine for
    everyone.

    In some cases, I've seen nodes not come back after a soft reboot,
    so a hard reboot may be required. Or if the node is out of memory,
    it may not be possible to get a shell on the node to run `sudo
    reboot` from.

  * **Hard reboot.** Run:

    ```
    ipmitool -U IPMI_USER -H c0001-ipmi -I lanplus chassis power cycle
    ```

    Be sure to change `IPMI_USER` to your IPMI username (different
    from your regular username!) and `c0001` to the node you want to
    reboot.

    This cuts power to the node and restarts it. There is also a soft
    reboot setting with `soft`, but I do not think it is particularly
    useful compared to `sudo reboot` (though it does not require SSH).

  * Otherwise, contact `action@cs`. It may be that there is a hardware
    issue preventing the node from coming back up.

### 7. Manage SLURM Node State

Check the state of SLURM nodes with:

```bash
sinfo
```

To set the SLURM state of a node to `S`:

```bash
sudo /usr/local/slurm-23.02.1/bin/scontrol update NodeName=c0001 State=S
```

Here are some states you might find useful:

  * `DRAIN`: This prevents any further jobs from being scheduled on
    the node, but allows current jobs to complete. Recommended when
    you want to do maintenance but don't want to disrupt jobs on the
    system.

  * `DOWN`: This kills any jobs currently running on the node and
    prevents further jobs from running. This is usually not required,
    but may be useful if something gets really messed up and the job
    cannot be killed by the system.

  * `RESUME`: Makes the node available to schedule jobs. Note that any
    issues have to be resolved *before* doing this, or else the node
    will just go back into the `DOWN` state again.

For `DRAIN` and `DOWN` states, a `Reason` argument is also
required. Please use this to indicate why the node is down (e.g.,
maintenance).

### 8. Troubleshoot SLURM Jobs

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

    Once the issue is resolved, the node state will usually fix
    itself, but if that doesn't happen, you can force it to reset by
    setting the node to `DOWN` and then `RESUME` again (see above).
