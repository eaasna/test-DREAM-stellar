#!/bin/bash

set -ex

if [[ "$#" -ne 4 ]]; then
	echo "Usage: bash concat_scaffolds.sh <work_dir> <short_ids> <fasta_in> <fasta_out>"
	exit 1
fi

work_dir=${1}

cd $work_dir

short_ids=${2}
ref_in=${3}
out=${4}

while read id; do
  grep -A 1 $id $ref_in >> short_sequences.fa
done < $short_ids

grep -v ">" short_sequences.fa > tmp.fa
sed -i "s/-//g" tmp.fa
tr -d '\n' < tmp.fa > short_sequences.fa
rm tmp.fa

grep ">" $ref_in | grep -v -f short_ids.txt > long_ids.txt

grep -A 1 -f long_ids.txt $ref_in > $out
sed -i "s/-//g" $out

echo ">Concatenated" >> $out
cat short_sequences.fa >> $out

