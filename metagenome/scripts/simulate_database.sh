#!/usr/bin/env bash
set -e

BINARY_DIR="./../../../lib/raptor_data_simulation/build/bin"

REP=$1

# reference parameters
LENGTH=$2
SEED=$3
BIN_NUMBER=$4
HAPLOTYPE_COUNT=$5

rep_dir="rep${REP}"
mkdir -p $rep_dir
cd $rep_dir

bin_dir=bins
info_dir=info

mkdir -p $bin_dir
mkdir -p $info_dir

bin_length=$((LENGTH / BIN_NUMBER))
echo "Simulating $BIN_NUMBER bins with reference length of $LENGTH and bin_length of $bin_length"
# Simulate reference
echo "Simulating genome"
$BINARY_DIR/mason_genome -l $LENGTH -o $bin_dir/ref.fasta -s $SEED

# Evenly distribute it over bins
echo "Splitting genome into bins"
$BINARY_DIR/split_sequence --input $bin_dir/ref.fasta --length $bin_length --parts $BIN_NUMBER
# We do not need the reference anymore
rm $bin_dir/ref.fasta
# Rename the bins to .fa
for i in $bin_dir/*.fasta; do mv $i $bin_dir/$(basename $i .fasta).fa; done
# Simulate haplotypes for each bin
echo "Generating haplotypes"
for i in $bin_dir/*.fa
do
   $BINARY_DIR/mason_variator \
       -ir $i \
       -n $HAPLOTYPE_COUNT \
       -of $bin_dir/$(basename $i .fa).fasta \
       -ov $info_dir/$(basename $i .fa).vcf	
   rm $i
   rm $i.fai
done

seq -f "$rep_dir/bins/bin_%0${#BIN_NUMBER}g.fasta" 0 1 $((BIN_NUMBER-1)) > bin_paths.txt
