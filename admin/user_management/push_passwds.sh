#!/bin/bash

root_dir=$(readlink -f $(dirname "${BASH_SOURCE[0]}"))

#set -e
#set -x

NODES="n0000 n0001"
NODES+=" c0001 c0002 c0003 c0004"
NODES+=" g0001 g0002 g0003 g0004"

unset SSH_AUTH_SOCK

#sudo -v

for n in $NODES
do
  echo $n
  # order of files matters here
  cat /etc/passwd | ssh -x root@$n "$root_dir"/update_passwds.py /etc/passwd $*
  cat /etc/shadow | ssh -x root@$n "$root_dir"/update_passwds.py /etc/shadow -i /etc/passwd $*
  cat /etc/group | ssh -x root@$n "$root_dir"/update_passwds.py /etc/group $*
  cat /etc/gshadow | ssh -x root@$n "$root_dir"/update_passwds.py /etc/gshadow -i /etc/group $*
  cat /etc/subuid | ssh -x root@$n "$root_dir"/update_passwds.py /etc/subuid -i /etc/passwd $*
  cat /etc/subgid | ssh -x root@$n "$root_dir"/update_passwds.py /etc/subgid -i /etc/group $*
done
