#!/bin/bash

set -e

home_dir=/group/ag_abi/eaasna
VALIK_DNA4=$home_dir/valik/build_DNA4/bin/valik
VALIK_DNA5=$home_dir/valik/build_DNA5/bin/valik
export VALIK_TMP=/dev/shm/valik
mkdir -p $VALIK_TMP
rm -rf $VALIK_TMP/*

b=64
$VALIK_DNA5 split ref.fasta --ref-meta split/ref.txt --seg-meta split/seg.txt --overlap 100 --bins $b

$VALIK_DNA5 build ref.fasta --seg-meta split/seg.txt --ref-meta split/ref.txt --from-segments --window 15 --kmer 13 --output /dev/shm/valik.index --size 50M --threads 8

t=8
max_carts=64
max_cap=2000


for i in 0 1 2
do
	/usr/bin/time -f "%e\t%x\tDNA4\tlocal" $VALIK_DNA4 search  --time --shared-memory --cart_max_capacity $max_cap --max_queued_carts $max_carts --index /dev/shm/valik.index --ref-meta split/ref.txt --seg-meta split/seg.txt --query queries/e0.05.fastq --error 1 --pattern 100 --overlap 98 --threads $t --output dna4_shared_memory.gff > /dev/null

	/usr/bin/time -f "%e\t%x\tDNA5\tlocal" $VALIK_DNA5 search  --time --shared-memory --cart_max_capacity $max_cap --max_queued_carts $max_carts --index /dev/shm/valik.index --ref-meta split/ref.txt --seg-meta split/seg.txt --query queries/e0.05.fastq --error 1 --pattern 100 --overlap 98 --threads $t --output dna5_shared_memory.gff > /dev/null

	export VALIK_STELLAR=$home_dir/stellar3/build_DNA4/bin/stellar
	/usr/bin/time -f "%e\t%x\tDNA4\tdist" $VALIK_DNA4 search --time --cart_max_capacity $max_cap --max_queued_carts $max_carts --index /dev/shm/valik.index --ref-meta split/ref.txt --seg-meta split/seg.txt --query queries/e0.05.fastq --error 1 --pattern 100 --overlap 98 --threads $t --output dna4_distributed.gff

	export VALIK_STELLAR=$home_dir/stellar3/build_DNA5/bin/stellar
	/usr/bin/time -f "%e\t%x\tDNA5\tdist" $VALIK_DNA5 search --time --cart_max_capacity $max_cap --max_queued_carts $max_carts --index /dev/shm/valik.index --ref-meta split/ref.txt --seg-meta split/seg.txt --query queries/e0.05.fastq --error 1 --pattern 100 --overlap 98 --threads $t --output dna5_distributed.gff
done
