#!/usr/bin/env bash
set -e

BINARY_DIR="./../../lib/raptor_data_simulation/build/bin"
REF_LENGTH=$1 	# 2^20 = 1Mb
REF_SEED=$2

echo "Simulating reference of length $REF_LENGTH with seed $REF_SEED"
$BINARY_DIR/mason_genome -l $REF_LENGTH -o ref.fasta -s $REF_SEED
