#!/bin/bash

set -ex

log="log.txt"
./mask_repeats.sh >> $log 2>&1

./map_reads.sh >> $log 2>&1

./find_local_matches.sh >> $log 2>&1

./find_inversions.sh >> $log 2>&1
