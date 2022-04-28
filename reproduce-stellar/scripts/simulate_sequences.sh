#!/usr/bin/env bash
set -e

BINARY_DIR="../../lib/raptor_data_simulation/build/bin"
REP=$1 # gives a unique name to each output file
REF_LENGTH=$2 	# 2^20 = 1Mb
QUERY_LENGTH=$3 	# 2^20 = 1Mb
REF_SEED=$4
QUERY_SEED=$5

echo "Simulating reference of length $REF_LENGTH with seed $REF_SEED"
$BINARY_DIR/mason_genome -l $REF_LENGTH -o ref_rep$REP.fasta -s $REF_SEED &> /dev/null

echo "Simulating query of length $QUERY_LENGTH with seed $QUERY_SEED"
$BINARY_DIR/mason_genome -l $QUERY_LENGTH -o query/query_rep$REP.fasta -s $QUERY_SEED &> /dev/null

# convert multi line fasta to one line fasta
awk '/^>/ {printf("\n%s\n",$0);next; } { printf("%s",$0);}  END {printf("\n");}' < query/query_rep$REP.fasta > query/one_line_rep$REP.fasta
sed -i '1d' query/one_line_rep$REP.fasta
