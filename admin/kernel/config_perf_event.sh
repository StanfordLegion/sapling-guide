#!/bin/bash

set -e

# https://github.com/rr-debugger/rr/wiki/Building-And-Installing#os-configuration

# see also: https://www.kernel.org/doc/Documentation/sysctl/kernel.txt

sudo sysctl kernel.perf_event_paranoid=1

echo 'kernel.perf_event_paranoid=1' | sudo tee '/etc/sysctl.d/51-enable-perf-events.conf'
