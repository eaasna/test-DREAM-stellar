#!/bin/bash

set -x

VALIK=/group/ag_abi/eaasna/valik/debug/bin/valik
export VALIK_STELLAR=/group/ag_abi/eaasna/stellar3/debug/bin/stellar
export VALIK_TMP=tmp
mkdir -p $VALIK_TMP
rm tmp/*

minLen=100
b=2
$VALIK split ref.fasta --ref-meta split/ref.txt --seg-meta split/seg.txt --overlap $minLen --bins $b

$VALIK build ref.fasta --seg-meta split/seg.txt --ref-meta split/ref.txt --from-segments --window 15 --kmer 13 --output /dev/shm/valik.index --size 50K --threads 8

max_cap=6000
max_carts=64
t=4
#LOCAL
/usr/bin/time -f "%e\t%M\t%x\tshared" $VALIK search  --time --shared-memory --cart_max_capacity $max_cap --max_queued_carts $max_carts --index /dev/shm/valik.index --ref-meta split/ref.txt --seg-meta split/seg.txt --query queries/e0.05.fasta --error 1 --pattern 100 --overlap 98 --threads $t --output shared_memory.gff > shared_memory.gff.debug
#valgrind --tool=callgrind $VALIK search  --time --shared-memory --cart_max_capacity $max_cap --max_queued_carts $max_carts --index /dev/shm/valik.index --ref-meta split/ref.txt --seg-meta split/seg.txt --query queries/e0.05.fastq --error 1 --pattern 100 --overlap 98 --threads $t --output shared_memory.gff > shared_memory.gff.debug

# distributed
#/usr/bin/time -f "%e\t%M\t%x\tdistributed" $VALIK search --time --cart_max_capacity $max_cap --max_queued_carts $max_carts --index /dev/shm/valik.index --ref-meta split/ref.txt --seg-meta split/seg.txt --query queries/e0.05.fastq --error 1 --pattern $minLen --overlap 98 --threads $t --output distributed.gff

#valgrind --tool=callgrind $VALIK search --time --cart_max_capacity $max_cap --max_queued_carts $max_carts --index /dev/shm/valik.index --ref-meta split/ref.txt --seg-meta split/seg.txt --query queries/e0.05.fastq --error 1 --pattern $minLen --overlap 98 --threads $t --output distributed.gff

#valgrind --tool=callgrind $VALIK_STELLAR --time --version-check 0 ref.fasta queries/e0.05.fasta --referenceLength 102400 --sequenceOfInterest 0 --segmentBegin 0 --segmentEnd 5242881 -e 0.01 -l 100 -o stellar.gff > stellar.debug
