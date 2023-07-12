#!/bin/bash

set -x

VALIK_DEBUG=/home/evelin/DREAM-Stellar/valik/debug/bin/valik
VALIK_DNA_DEBUG=/home/evelin/DREAM-Stellar/valik/debug_dna/bin/valik
export VALIK_STELLAR=/home/evelin/DREAM-Stellar/stellar3/debug/bin/stellar

b=8
#$VALIK_DEBUG split ref.fasta --ref-meta split/ref.txt --seg-meta split/seg.txt --overlap 100 --bins $b

#$VALIK_DEBUG build ref.fasta --seg-meta split/seg.txt --ref-meta split/ref.txt --from-segments --window 15 --kmer 13 --output /dev/shm/valik.index --size 50K --threads 8

max_cap=50
t=4
#LOCAL
/usr/bin/time -f "%e\t%M\t%x\tDNA" $VALIK_DNA_DEBUG search  --time --shared-memory --cart_max_capacity $max_cap --max_queued_carts 1024 --index /dev/shm/valik.index --ref-meta split/ref.txt --seg-meta split/seg.txt --query queries/e0.05.fastq --error 1 --pattern 100 --overlap 98 --threads $t --output shared_memory.gff > shared_memory.gff.debug

#LOCAL
/usr/bin/time -f "%e\t%M\t%x\tDNA5" $VALIK_DEBUG search  --time --shared-memory --cart_max_capacity $max_cap --max_queued_carts 1024 --index /dev/shm/valik.index --ref-meta split/ref.txt --seg-meta split/seg.txt --query queries/e0.05.fastq --error 1 --pattern 100 --overlap 98 --threads $t --output shared_memory.gff > shared_memory.gff.debug

# distributed
/usr/bin/time -f "%e\t%M\t%x\tdistributed" $VALIK_DEBUG search --time --cart_max_capacity $max_cap --max_queued_carts 1024 --index /dev/shm/valik.index --ref-meta split/ref.txt --seg-meta split/seg.txt --query queries/e0.05.fastq --error 1 --pattern 100 --overlap 98 --threads $t --output distributed.gff

#$VALIK_STELLAR --time --version-check 0 ref.fasta queries/e0.05.fasta --referenceLength 102400 --sequenceOfInterest 0 --segmentBegin 0 --segmentEnd 102400 -e 0.01 -l 100 -o stellar.gff > stellar.debug
