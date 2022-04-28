#!/usr/bin/env bash
set -e

BINARY_DIR="./../../lib/raptor_data_simulation/build/bin"

REP=$1

# reference parameters
BIN_NUMBER=$2
HAPLOTYPE_COUNT=$3

# local match parameters
ERRORS=$4
ERROR_RATE=$5
READ_LENGTH=$6
READ_COUNT=$7

output_dir=rep$REP
bin_dir=$output_dir/bins
info_dir=$output_dir/info

echo "Generating $READ_COUNT reads of length $READ_LENGTH with $ERRORS errors"
read_dir=$output_dir/queries
mkdir -p $read_dir
$BINARY_DIR/generate_reads \
    --output $read_dir \
    --max_errors $ERRORS \
    --number_of_reads $READ_COUNT \
    --read_length $READ_LENGTH \
    --number_of_haplotypes $HAPLOTYPE_COUNT \
    $(seq -f "$output_dir/bins/bin_%0${#BIN_NUMBER}g.fasta" 0 1 $((BIN_NUMBER-1))) 

cat $read_dir/*.fastq > $read_dir/all
mv $read_dir/all $read_dir/e$ERROR_RATE.fastq
# for i in $(seq 0 9); do cat $read_dir/all.fastq >> $read_dir/all_10.fastq; done
rm $read_dir/bin_*
