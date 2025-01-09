#!/bin/bash

set -ex 

if [[ "$#" -ne 2 ]]; then
	echo "Usage: bash significant_lastz.sh <gff_in> <min_len>"
	exit
fi	

in=$1
min_len=$2
out="${in%.gff}_sorted_l$min_len.gff"

awk -F';' '{print $0 "\t" $3}' $in | sed 's/eValue=//g' | LC_ALL=C sort -grk 10 | awk -v 'l="$min_len"' '$5 - $4 > l' | awk -F';' '{print $1 ";" $2 ";score=" $3 ";cigar=;mutations="}' > $out

for n in 100 500 1000 1500
do
	head -n $n $out > "${out%.gff}_top$n.gff"
done
