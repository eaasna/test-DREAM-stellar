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

mkdir -p local_matches
mkdir -p query
generate_local_matches \
	--matches-out local_matches/rep${REP}_e${ERROR_RATE}.fasta \
	--genome-out query/rep${REP}_e${ERROR_RATE}.fasta \
	--max-error-rate $ERROR_RATE \
	--num-matches $MATCH_COUNT \
	--min-match-length $MIN_LEN \
	--max-match-length $MAX_LEN \
	--ref-len $REF_LEN \
	--verbose-ids \
	--query random_rep${REP}.fasta \
	ref_rep${REP}.fasta 1> match_positions.txt 2> /dev/null

grep ">" local_matches/rep${REP}_e${ERROR_RATE}.fasta | cut -c 2- | awk -F, '{ print $1 " " $2 }' | sed 's/start_position=//g' | sed 's/length=//g' | awk '{print $2 "\t" $2+$3 }' > ground_truth/rep${REP}_e${ERROR_RATE}.tsv
sort -g -k2 ground_truth/rep${REP}_e${ERROR_RATE}.tsv -o ground_truth/rep${REP}_e${ERROR_RATE}.tsv

