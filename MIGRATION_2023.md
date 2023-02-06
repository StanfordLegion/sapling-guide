# Sapling Head Node Migration Plan

Elliott Slaughter

February 2023

## Division of Responsibities

I'd like propose the following division of responsibilities. The three
main groups are:

 1. Stanford CS staff (Andrej, Brian, Jimmy)
 2. Legion project members responsible for administering the machine (Elliott, etc.)
 3. Sapling users

### Responsbilities of Stanford CS Staff

  * Hardware installation and maintenance
  * Base OS installation
  * DNS
  * Filesystems (including NFS)
  * CUDA drivers (if applicable), but **NOT** CUDA toolkit/software
  * Infiniband: OFED, nvidia-fm, p2p rdma, etc.

### Responsibilities of Legion Project Members

  * CUDA toolkit/software
  * SLURM
  * MPI
  * Docker
  * HTTP server
  * A very small number of additional packages (e.g., CMake, compilers)

### Responsibilities of Sapling Users

  * All other software packages (installed on a per-user basis)

## Migration Plan

Here are the steps I envision taking. I use some abbreviations to
simplify the instructions.

Roles:

  * `CS`: Stanford CS staff
  * `LP`: Legion project members
  * `UR`: Users

Machines:

  * `H1`: old head node
  * `H2`: new head node
  * `GN`: one GPU compute node, for initial testing
  * `RN`: all remaining compute nodes

### Part 1. Spin Up New Head Node

 1. `CS`: Install Ubuntu 20.04 base OS on `H2`
 2. `CS`: Make `H2` available via private IPMI as head2-ipmi
 3. `CS`: Make `H2` available via public DNS as sapling2.stanford.edu
 4. `CS`: Make `H2` available via public SSH
 5. `CS`: Set up DNS on `H2` such that it can access `H1` and compute nodes
 6. `CS`: Configure disks on `H2`:
      * One 8 TB SSD as `/home`
      * Other SSDs/HDDs should be set up as `/scratchN` where `N` starts at 1
 7. `LP`: Verify and confirm
 7. `LP`: Copy `/etc/passwd`, `/etc/shadow`, `/etc/group`, `/etc/gshadow`, `/etc/subuid`, `/etc/subgid` from `H1` to `H2`
 8. `LP`: Verify that `H2` can be rebooted through `sudo reboot` or similar without losing access or any critical services

### Part 2. Install Basic Services

 8. `LP`: Install SLURM
 9. `LP`: Install MPI
10. `LP`: Install CUDA toolkit
11. `LP`: Install Docker
12. `LP`: Install HTTP server
13. `LP`: Install module system

### Part 3. Initial Migration Testing

Choose one compute node (probably a GPU node) to move over to the new
`H2` configurations. Call this machine `GN`. We will test everything with
this node before performing the rest of the migration.

14. `CS`: Do **NOT** install a new base OS; we'll keep Ubuntu 20.04 on these nodes
15. `CS`: Configure network (IPMI, DHCP, DNS) on `GN`
16. `CS`: Configure NFS on `GN` to access `H2`'s drives (and remove access to `H1`'s drives)
17. `LP`: Configure SLURM/MPI/CUDA/Docker/CMake/modules on `GN`
18. `LP`: Verify that jobs are able to be launched on `GN`
19. `UR`: Verify `H2` and `GN` access and software

### Part 4. Flag Day: Critical Migration Steps

20. `UR`: **STOP USING `H1` FOR ALL JOBS**
21. `CS`: Make a final copy of `H1`'s `/home` into `H2` `/scratch1/oldhome`
22. `CS`: Make a final copy of `H1`'2 `/scratch` into `H2` `/scratch1/oldscratch`
23. `CS`: Make a final copy of `H1`'2 `/scratch2` into `H2` `/scratch1/oldscratch2`
24. `LP`: Verify and confirm
25. `UR`: **CAN BEGIN USE OF `H2`**

### Part 5. Final Migration Steps

26. For each remaining compute node `RN`:
     1. `CS`: Do **NOT** install a new base OS; we'll keep Ubuntu 20.04 on these nodes
     2. `CS`: Configure network (IPMI, DHCP, DNS) on `RN`
     3. `CS`: Configure NFS on `RN` to access `H2`'s drives (and remove access to `H1`'s drives)
     4. `LP`: Configure SLURM/MPI/CUDA/Docker/CMake/modules on `RN`
     5. `LP`: Verify that jobs are able to be launched on `RN`
27. `LP`: Re-enable CI jobs on `RN`
28. `LP`: Re-enable GitHub mirror script
29. `UR`: Verify and confirm final configuration
30. `CS`: Make `H2` available under sapling.stanford.edu
31. `LP`/`UR`: Verify and confirm
32. `CS`: `H1` can be decomissioned
