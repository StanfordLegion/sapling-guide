#!/usr/bin/env python3

import argparse, os, sys
from collections import OrderedDict

parser = argparse.ArgumentParser()
parser.add_argument('-v', '--verbose', action='store_true',
                    help='print verbose output')
parser.add_argument('-q', '--quiet', action='store_true',
                    help='suppress all non-error output')
parser.add_argument('-b', '--backup', action='store_true',
                    help='leave .old file as backup')
parser.add_argument('-y', '--yes', action='store_true',
                    help='set this to actually update files')
parser.add_argument('tgtfile',
                    help='target file to update')
parser.add_argument('-m', '--min-id', type=int, default=1000,
                    help='minimum user/group id to propagate')
parser.add_argument('-i', '--id-file',
                    help='passwd/group-style file to get ids from')
parser.add_argument('-f', '--force', type=str, action='append', default=[],
                    help='names of users/groups to force update for')
args = parser.parse_args()

if args.id_file:
    ids = {}
    with open(args.id_file, 'r') as f:
        for line in f:
            user, _, idfield, _ = line.split(':', 3)
            ids[user] = int(idfield)

# parse input, splitting on first ':'
updates = OrderedDict()
for line in sys.stdin:
    if args.min_id:
        if args.id_file:
            user, _ = line.split(':', 1)
            if (user not in args.force) and (ids.get(user, 0) < args.min_id):
                continue
        else:
            user, _, idfield, _ = line.split(':', 3)
            if (user not in args.force) and (int(idfield) < args.min_id):
                continue
    else:
        user, _ = line.split(':', 1)
    assert user not in updates
    updates[user] = line

# now open the target file and see what's changed
outdata = ''
updated = []
with open(args.tgtfile, 'r') as f:
    for line in f:
        user, _ = line.split(':', 1)
        if user in updates:
            if line != updates[user]:
                updated.append(user)
            outdata += updates.pop(user)
        else:
            outdata += line

extra = list(updates)
outdata += ''.join(updates.values())

if updated or extra:
    if args.verbose:
        print('{}: {} updates ({}), {} additions ({})'.format(args.tgtfile,
                                                              len(updated),
                                                              ','.join(updated),
                                                              len(extra),
                                                              ','.join(extra)))
    elif not args.quiet:
        print('{}: {} updates, {} additions'.format(args.tgtfile,
                                                    len(updated),
                                                    len(extra)))
    if args.yes:
        newfile = args.tgtfile + '.new'
        with open(newfile, 'w') as f:
            f.write(outdata)
            os.chmod(newfile, os.stat(args.tgtfile).st_mode)
        if args.backup:
            oldfile = args.tgtfile + '.old'
            os.rename(args.tgtfile, oldfile)
        os.rename(newfile, args.tgtfile)
else:
    if args.verbose:
        print('{}: no changes'.format(args.tgtfile))

