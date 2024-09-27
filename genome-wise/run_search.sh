#!/usr/bin/env bash
set -x

cd work

ibf_bins=1024
kmer_size=21
query_seg_count=20000
min_len=150
timeout="60m"

mkdir -p /dev/shm/genome-wise

for threshold in 50 56 60 80
do
	./search.sh $ibf_bins $kmer_size $query_seg_count $min_len $threshold $timeout 2> ${ibf_bins}_${kmer_size}_${query_seg_count}_${min_len}_${threshold}.err 
	#count_cutoff_${ibf_bins}_${kmer_size}_${query_seg_count}_${min_len}_${threshold}.err 
done

