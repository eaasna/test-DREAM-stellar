#!/usr/bin/env bash
set -e

BINARY_DIR="../lib/raptor_data_simulation/build/bin"
REF_FILE="dmel.fasta"
SEED=42 # was 20181406 before, but was hardcoded to 42 in seqan
ERRORS=2
READ_LENGTHS="150"
READ_COUNT=16384

for read_length in $READ_LENGTHS
do
    echo "Generating $READ_COUNT reads of length $read_length with $ERRORS errors"
    read_dir=reads_e$ERRORS\_$read_length
    mkdir -p $read_dir
    $BINARY_DIR/generate_reads_refseq \
        --output $read_dir \
        --errors $ERRORS \
        --number_of_reads $READ_COUNT \
        --read_length $read_length \
        $REF_FILE > /dev/null
done
