# Sapling User Guide

## First Time Setup

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

### 2. Launching Interactive Jobs with SLURM

Because the hardware and software is different on different nodes, it is
important to build and run all software on the compute nodes. On
Sapling, we do this through the SLURM job scheduler.

To launch an interactive, single-node job (e.g., for building software):

```bash
srun -N 1 -n 1 -c 40 --pty bash
```

Here's a break-down of the parts in this command:

  * `srun`: we're going to launch the job immediately (as opposed to, say,
    via a batch script).
  * `-N 1` (a.k.a., `--nodes 1`): request one node.
  * `-n 1` (a.k.a., `--ntasks 1`): we're going to run one "task". This
    is the number of processes to launch. In this case because we only
    want one copy of bash to be running.
  * `-c 40` (a.k.a., `--cpus-per-task 40`): the number of CPUs per task.
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

srun hostname
```

Note that, because the flags (`-N 2 -n 2 -c 40`) were provided on the
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

### 4. Spack

Reminder: all software should be installed and built on the compute
nodes themselves. Please run the following in an interactive SLURM job
(see Section 2 above).

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

### 5. Coordinating with Other Users

Sapling is a mixed-mode machine. While SLURM is the default job
scheduler, users can still use SSH to directly access nodes (and for
some purposes, may need to do so). Therefore, when you are doing
something performance-sensitive, please let us know on the #sapling
channel that you intend to do so. Similarly, please watch the #sapling
channel to make sure you're not stepping on what other users are doing.
