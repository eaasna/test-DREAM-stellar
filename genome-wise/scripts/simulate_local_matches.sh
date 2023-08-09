#!/usr/bin/env bash
set -e

BINARY_DIR="../../lib/raptor_data_simulation/build/bin"
ERROR_RATE=$1
MATCH_COUNT=$2
MIN_LEN=$3
MAX_LEN=$3

echo "Sampling $MATCH_COUNT local matches between $MIN_LEN and $MAX_LEN bp with an error rate of $ERROR_RATE"

match_dir=queries_e$ERROR_RATE
mkdir -p $match_dir
$BINARY_DIR/generate_local_matches \
	--output $match_dir \
	--max-error-rate $ERROR_RATE \
	--num-matches $MATCH_COUNT \
	--min-match-length $MIN_LEN \
	--max-match-length $MAX_LEN \
	ref.fasta

mv $match_dir/ref.fastq queries/e$ERROR_RATE.fastq
rm -r $match_dir
