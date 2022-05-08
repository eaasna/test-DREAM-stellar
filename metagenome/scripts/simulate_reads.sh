#!/usr/bin/env bash
set -e

BINARY_DIR="./../../lib/raptor_data_simulation/build/bin"

# reference parameters
BIN_NUMBER=$1
HAPLOTYPE_COUNT=$2

# local match parameters
ERRORS=$3
ERROR_RATE=$4
READ_LENGTH=$5
READ_COUNT=$6

output_dir=$BIN_NUMBER
bin_dir=$output_dir/bins
info_dir=$output_dir/info

echo "Generating $READ_COUNT reads of length $READ_LENGTH with $ERRORS errors"
read_dir=$output_dir/queries
mkdir -p $read_dir
mkdir -p $read_dir\_$ERRORS
$BINARY_DIR/generate_reads \
    --output $read_dir\_$ERRORS \
    --max_errors $ERRORS \
    --number_of_reads $READ_COUNT \
    --read_length $READ_LENGTH \
    --number_of_haplotypes $HAPLOTYPE_COUNT \
    $(seq -f "$output_dir/bins/bin_%0${#BIN_NUMBER}g.fasta" 0 1 $((BIN_NUMBER-1))) 

cat $read_dir\_$ERRORS/*.fastq > $read_dir\_$ERRORS/all
mv $read_dir\_$ERRORS/all $read_dir/e$ERROR_RATE.fastq
# for i in $(seq 0 9); do cat $read_dir/all.fastq >> $read_dir/all_10.fastq; done
rm -r $read_dir\_$ERRORS

seq -f "/dev/shm/$output_dir/queries/bin_%0${#BIN_NUMBER}g_e${ERROR_RATE}.fasta" 0 1 $((BIN_NUMBER-1)) > $output_dir/e$ERROR_RATE\_bin_query_paths.txt
