#!/usr/bin/env bash
set -e

# TODO: this script is part of Enrico's raptor data simulation
# the raptor data simulation should be a supproject of this repo?
BINARY_DIR="/home/evelin/metagenomics/raptor_data_simulation/build/bin"
OUT_DIR="simulated_data"
LENGTH=102400 	# 4*2^20 =  64MiB
SEED=42 # was 20181406 before, but was hardcoded to 42 in seqan
BIN_NUMBER=8
ERRORS=5
READ_LENGTHS=150
READ_COUNT=1024
HAPLOTYPE_COUNT=4
SNP_RATE=0.01
INDEL_RATE=0.001

output_dir=$OUT_DIR/$BIN_NUMBER
bin_dir=$output_dir/bins
info_dir=$output_dir/info

mkdir -p $output_dir
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
       --snp-rate $SNP_RATE \
       --small-indel-rate $INDEL_RATE \
       -ov $info_dir/$(basename $i .fa).vcf &> /dev/null
   	
   rm $i
   rm $i.fai
done

for read_length in $READ_LENGTHS
do
    echo "Generating $READ_COUNT reads of length $read_length with $ERRORS errors"
    read_dir=$output_dir/reads_e$ERRORS\_$read_length
    mkdir -p $read_dir
    $BINARY_DIR/generate_reads \
        --output $read_dir \
        --max_errors $ERRORS \
        --number_of_reads $READ_COUNT \
        --read_length $read_length \
        --number_of_haplotypes $HAPLOTYPE_COUNT \
        $(seq -f "$output_dir/bins/bin_%0${#BIN_NUMBER}g.fasta" 0 1 $((BIN_NUMBER-1))) &> /dev/null
    cat $read_dir/*.fastq > $read_dir/all
    mv $read_dir/all $read_dir/all.fastq
    # for i in $(seq 0 9); do cat $read_dir/all.fastq >> $read_dir/all_10.fastq; done
done
