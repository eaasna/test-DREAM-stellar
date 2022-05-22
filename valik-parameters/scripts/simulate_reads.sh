#!/usr/bin/env bash
set -e

BINARY_DIR="./../../lib/raptor_data_simulation/build/bin"

# reference parameters
BIN_NUMBER=$1
HAPLOTYPE_COUNT=$2

# local match parameters
ERRORS=$3
READ_LENGTH=$4
READ_COUNT=$5

bin_dir=bins
info_dir=info

echo "Generating $READ_COUNT reads of length $READ_LENGTH with $ERRORS errors"
read_dir=queries
mkdir -p $read_dir
$BINARY_DIR/generate_reads \
    --output $read_dir \
    --max_errors $ERRORS \
    --number_of_reads $READ_COUNT \
    --read_length $READ_LENGTH \
    --number_of_haplotypes $HAPLOTYPE_COUNT \
    $(seq -f "bins/bin_%0${#BIN_NUMBER}g.fasta" 0 1 $((BIN_NUMBER-1))) 

cat $read_dir/*.fastq > $read_dir/all
mv $read_dir/all $read_dir/e$ERRORS.fastq
rm $read_dir/bin_*

# seq -f "queries/bin_%0${#BIN_NUMBER}g_e${ERROR_RATE}.fasta" 0 1 $((BIN_NUMBER-1)) > e$ERROR_RATE\_bin_query_paths.txt

