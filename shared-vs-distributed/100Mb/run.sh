#!/bin/bash

set -e

VALIK=/group/ag_abi/eaasna/valik/build/bin/valik
export VALIK_STELLAR=/group/ag_abi/eaasna/stellar3/build/bin/stellar
export VALIK_TMP=/dev/shm/valik
mkdir -p $VALIK_TMP
rm -rf $VALIK_TMP/*

b=64
$VALIK split ref.fasta --ref-meta split/ref.txt --seg-meta split/seg.txt --overlap 100 --bins $b

$VALIK build ref.fasta --seg-meta split/seg.txt --ref-meta split/ref.txt --from-segments --window 15 --kmer 13 --output /dev/shm/valik.index --size 50M --threads 8

t=8
max_carts=64
for max_cap in 2000
do
	/usr/bin/time -f "%e\t%x\t$max_cap\tlocal" $VALIK search  --time --shared-memory --cart_max_capacity $max_cap --max_queued_carts $max_carts --index /dev/shm/valik.index --ref-meta split/ref.txt --seg-meta split/seg.txt --query queries/e0.05.fastq --error 1 --pattern 100 --overlap 98 --threads $t --output ${max_cap}_shared_memory.gff

	/usr/bin/time -f "%e\t%x\t$max_cap\tdist" $VALIK search --time --cart_max_capacity $max_cap --max_queued_carts $max_carts --index /dev/shm/valik.index --ref-meta split/ref.txt --seg-meta split/seg.txt --query queries/e0.05.fastq --error 1 --pattern 100 --overlap 98 --threads $t --output ${max_cap}_distributed.gff
done

