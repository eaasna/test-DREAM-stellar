#!/bin/bash

set -x

if [[ "$#" -ne 2 ]]; then
	echo "Usage: bash find_all_genome_counts.sh <data_dir> <in.fasta>"
	exit
fi	

dir=$1
fin=$2
fout=$3

for k in 11 13 15 17 19
do
	./kmer_dump.sh $dir $fin ${fin}.${k}mer.dump $k
	./occurrence_counts.sh $dir ${fin}.${k}mer.dump ${fin}.${k}mer.tsv
done

