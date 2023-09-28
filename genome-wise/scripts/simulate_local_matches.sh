#!/usr/bin/env bash
set -e

REP=$1 # gives a unique name to each output file
MIN_LEN=$2
MAX_LEN=$3
REF_LEN=$4
ERROR_RATE=$5
MATCH_COUNT=$6
SEED=$7

echo "Sampling $MATCH_COUNT local matches between $MIN_LEN and $MAX_LEN bp with an error rate of $ERROR_RATE"

generate_local_matches \
	--matches-out local_matches_rep${REP}.fasta \
	--genome-out genomeB_rep${REP}.fasta \
	--max-error-rate $ERROR_RATE \
	--num-matches $MATCH_COUNT \
	--min-match-length $MIN_LEN \
	--max-match-length $MAX_LEN \
	--ref-len $REF_LEN \
	--verbose-ids \
	--query random_rep${REP}.fasta \
	--seed $SEED \
	genomeA_rep${REP}.fasta 
	#&> /dev/null

