#!/bin/bash

set -ex

work_dir=${1}

cd $work_dir

warning_in=${2}
ref_in=${3}
awk '{print $2}' $warning_in > short_ids.txt

while read id; do
  grep -A 1 $id $ref_in >> short_sequences.fa
done < short_ids.txt

grep -v ">" short_sequences.fa > tmp.fa
sed -i "s/-//g" tmp.fa
tr -d '\n' < tmp.fa > short_sequences.fa
rm tmp.fa

grep ">" $ref_in | grep -v -f short_ids.txt > long_ids.txt

grep -A 1 -f long_ids.txt $ref_in > ref_concat.fa
sed -i "s/-//g" ref_concat.fa

echo ">Concatenated" >> ref_concat.fa
cat short_sequences.fa >> ref_concat.fa

