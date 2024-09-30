#!/usr/bin/env bash
set -x

cd work

ibf_bins=1024
query_seg_count=20000
min_len=150
timeout="60m"

mkdir -p /dev/shm/genome-wise

./search.sh $ibf_bins $query_seg_count $min_len $timeout

