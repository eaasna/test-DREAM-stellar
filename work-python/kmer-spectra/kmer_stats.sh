#!/bin/bash

set -x

if [[ "$#" -ne 3 ]]; then
	echo "Usage: bash kmer_stats.sh <data_dir> <fasta_in> <tsv_out>"
	exit
fi	

DIR=$1
INPUT=$2
OUTPUT=$3

cd $DIR
mkdir -p data

export PATH="/group/ag_abi/evelina/decode/bin:$PATH"

echo -e "kmer-size\tdistinct-kmer-count" >> $OUTPUT
for k in 11 13 15 17 19 21 23
do
	kmc_file=$k.res
	echo -n "$k" >> $OUTPUT 
	kmc -k$k -fm -ci1 -cs64000 -t8 $INPUT $kmc_file data/ | grep "unique k-mers" | awk -F':' '{print $2}' | cat >> $OUTPUT
done

