#!/bin/bash

set -ex 

if [[ "$#" -ne 2 ]]; then
	echo "Usage: bash significant_bed.sh <bed_in> <min_len>"
	exit
fi	

in=$1
min_len=$2
out="${in%.bed}_sorted_l$min_len.bed"

# does this work with minus strand
awk -v 'l="$min_len"' '($3 - $2 >= l) || ($3 - $2 <= -l)' | LC_ALL=C sort -gk 6 $in > $out

for n in 100 500 1000 1500
do
	head -n $n $out > "${out%.bed}_top$n.bed"
done
