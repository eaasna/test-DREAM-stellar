#!/usr/bin/env bash
set -e

BINARY_DIR="./../../../lib/raptor_data_simulation/build/bin"
REP=$1 # gives a unique name to each output file
REF_LENGTH=$2 	# 2^20 = 1Mb
REF_SEED=$3

rep_dir="rep${REP}"
mkdir -p $rep_dir
cd $rep_dir
echo "Simulating reference of length $REF_LENGTH with seed $REF_SEED"
$BINARY_DIR/mason_genome -l $REF_LENGTH -o ref.fasta -s $REF_SEED
