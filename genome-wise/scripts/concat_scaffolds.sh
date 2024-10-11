#!/bin/bash

set -e

work_dir=${1}

cd $work_dir

warning_in=${2}
ref_in=${3}
awk '{print $2}' $warning_in > short_ids.txt

while read id; do
  grep -A 1 $id $ref_in >> tmp.fa
done < short_ids.txt

grep -v ">" tmp.fa > short_sequences.fa
rm tmp.fa

# manually make single line fasta

#grep ">" $ref_in | grep -v -f short_ids.txt > long_ids.txt

#grep -A 1 -f long_ids.txt $ref_in > ref_concat.fa

#cat short_sequences.fa >> ref_concat.fa

#sed -i "s/-//g" ref_concat.fa
