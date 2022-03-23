#!/usr/bin/env bash
set -e

BINARY_DIR="../lib/raptor_data_simulation/build/bin"
LENGTH=1048576 	# 2^20 = 1Mb
SEED=42 # was 20181406 before, but was hardcoded to 42 in seqan
ERROR_RATES="0 0.025 0.05 0.075 0.10"
READ_LENGTHS="50 100 150 200"
READ_COUNT=125

# Simulate reference
echo "Simulating genome of length $LENGTH"
$BINARY_DIR/mason_genome -l $LENGTH -o ref.fasta -s $SEED &> /dev/null

# Simulating local matches
for read_length in $READ_LENGTHS
do
    for error_rate in $ERROR_RATES
    do
	float_errors=$(echo $read_length*$error_rate | bc)
        errors=$(echo "($float_errors+0.5)/1" | bc)
        echo "Sampling $READ_COUNT reads of length $read_length with $errors errors"
        read_dir=reads_e$errors\_$read_length
        mkdir -p $read_dir
        $BINARY_DIR/generate_reads \
            --output $read_dir \
            --max_errors $errors \
            --number_of_reads $READ_COUNT \
            --read_length $read_length \
            --number_of_haplotypes 1 \
            ref.fasta &> /dev/null
    done
done

# Simulating 1Mb of query sequence
$BINARY_DIR/mason_genome -l 1048576 -o query.fasta -s $SEED &> /dev/null

# TODO: insert 500 local matches of the same error rate into query.fasta at random positions
