#!/bin/bash

set -ex

work_dir=${1}

cd $work_dir

warning_in=${2}
ref_in=${3}
out=${4}

awk '{print $2}' $warning_in > short_ids.txt

while read id; do
  grep -A 1 $id $ref_in >> short_sequences.fa
done < short_ids.txt

grep -v ">" short_sequences.fa > tmp.fa
sed -i "s/-//g" tmp.fa
tr -d '\n' < tmp.fa > short_sequences.fa
rm tmp.fa

grep ">" $ref_in | grep -v -f short_ids.txt > long_ids.txt

grep -A 1 -f long_ids.txt $ref_in > $out
sed -i "s/-//g" $out

echo ">Concatenated" >> $out
cat short_sequences.fa >> $out

