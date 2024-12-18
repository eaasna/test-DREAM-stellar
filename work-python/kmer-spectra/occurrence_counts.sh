#!/bin/bash

set -x

if [[ "$#" -ne 3 ]]; then
	echo "Usage: bash occurrence_counts.sh <data_dir> <in.kmer.dump> <out.tsv>"
	exit
fi	

DIR=$1
INPUT=$2 # kmer.dump
OUTPUT=$3 # kmer.tsv

cd $DIR

awk '{print $2}' $INPUT | sort -n | uniq -c > tmp
awk '{print $1 "\t" $2}' tmp > $OUTPUT
rm tmp
