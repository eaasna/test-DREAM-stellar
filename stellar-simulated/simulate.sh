#!/usr/bin/env bash
set -e

BINARY_DIR="../lib/raptor_data_simulation/build/bin"
LENGTH=1048576 	# 2^20 = 1Mb
SEED=42 # was 20181406 before, but was hardcoded to 42 in seqan
ERROR_RATES="0 0.025 0.05 0.075 0.10"
MATCH_LENGTHS="50 100 150 200"
MATCH_COUNT=125

# Simulate reference
echo "Simulating genome of length $LENGTH"
$BINARY_DIR/mason_genome -l $LENGTH -o ref.fasta -s $SEED &> /dev/null

# Simulating local matches
for match_length in $MATCH_LENGTHS
do
    for error_rate in $ERROR_RATES
    do
	float_errors=$(echo $match_length*$error_rate | bc)
        errors=$(echo "($float_errors+0.5)/1" | bc)
        echo "Sampling $MATCH_COUNT local matches of length $match_length with $errors errors"
        match_dir=matches_e$errors\_$match_length
        mkdir -p $match_dir
        $BINARY_DIR/generate_reads \
            --output $match_dir \
            --max_errors $errors \
            --number_of_reads $MATCH_COUNT \
            --read_length $match_length \
            --number_of_haplotypes 1 \
            ref.fasta &> /dev/null

	# Create unique IDs
	awk '{if( (NR-1)%4 ) print; else printf("@e%s_%s_%d\n",$e,$l,cnt++)}' l=$match_length e=$errors $match_dir/ref.fastq >> local_matches.fastq
    done
done

rm -r matches_e*

# Simulating 1Mb of query sequence
$BINARY_DIR/mason_genome -l 1048576 -o query.fasta -s $SEED &> /dev/null

