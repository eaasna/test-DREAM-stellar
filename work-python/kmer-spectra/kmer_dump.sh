#!/bin/bash

set -x

if [[ "$#" -ne 4 ]]; then
	echo "Usage: bash kmer_dump.sh <data_dir> <in.fasta> <out.kmer.dump> <k>"
	exit
fi	

DIR=$1
INPUT=$2 # .fasta
OUTPUT=$3 # kmer.dump
k=$4

cd $DIR
mkdir -p data

export PATH="/group/ag_abi/evelina/decode/bin:$PATH"

kmc_file=$INPUT.res
kmc -k$k -fm -ci1 -cs64000 -t8 $INPUT $kmc_file data/
kmc_dump -ci1 $kmc_file $OUTPUT

