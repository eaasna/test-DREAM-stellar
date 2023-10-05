#!/usr/bin/env bash
set -e

OUT_PATH=$1
ERROR_RATE=$2
MATCH_COUNT=$3
MIN_LEN=$4
MAX_LEN=$4
REF_LEN=$5

echo "Sampling $MATCH_COUNT local matches between $MIN_LEN and $MAX_LEN bp with an error rate of $ERROR_RATE for each sequence in the reference file"

generate_local_matches \
	--matches-out $OUT_PATH \
	--max-error-rate $ERROR_RATE \
	--num-matches $MATCH_COUNT \
	--min-match-length $MIN_LEN \
	--max-match-length $MAX_LEN \
	--ref-len $REF_LEN \
	ref.fasta

