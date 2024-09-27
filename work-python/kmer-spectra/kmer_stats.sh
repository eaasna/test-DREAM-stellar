#!/bin/bash

set -x

DIR=$1
INPUT=$2

cd $DIR
mkdir -p data

export PATH="/group/ag_abi/evelina/decode/bin:$PATH"

echo -e "kmer-size\tdistinct-kmer-count" >> kmer.stats
for k in 11 13 15 17 19 21 23
do
	kmc_file=$k.res
	echo -n "$k" >> kmer.stats 
	kmc -k$k -fm -ci1 -cs64000 -t8 $INPUT $kmc_file data/ | grep "unique k-mers" | awk -F':' '{print $2}' | cat >> kmer.stats
done
