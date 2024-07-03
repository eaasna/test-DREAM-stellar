#!/usr/bin/env bash
set -x

ibf_bins=64
kmer_size=11
query_seg_count=10000
min_len=100
timeout="60m"


mkdir -p /dev/shm/genome-wise

#for threshold in 21 23 25
for threshold in 20
do
	./search.sh $ibf_bins $kmer_size $query_seg_count $min_len $threshold $timeout 2> ${ibf_bins}_${kmer_size}_${query_seg_count}_${min_len}_${threshold}.err 
done

