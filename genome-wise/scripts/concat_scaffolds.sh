#!/bin/bash

set -e

if [[ "$#" -ne 4 ]]; then
	echo "Usage: bash concat_scaffolds.sh <work_dir> <short_ids> <multi line fasta in> <single line fasta out>"
	exit 1
fi

work_dir=${1}

cd $work_dir

short_ids=${2}
ref_in=${3}
out=${4}

#convert to single line fasta
awk '{if(NR==1) {print $0} else {if($0 ~ /^>/) {print "\n"$0} else {printf $0}}}' $ref_in > single_line.fa

touch short_sequences.fa
rm short_sequences.fa
while read id; do
  grep -A 1 $id single_line.fa >> short_sequences.fa
done < $short_ids

grep -v ">" short_sequences.fa > tmp.fa
sed -i "s/-//g" tmp.fa
tr -d '\n' < tmp.fa > short_sequences.fa
rm tmp.fa

grep ">" $ref_in | grep -v -f short_ids.txt > long_ids.txt

grep -A 1 -f long_ids.txt single_line.fa > $out
sed -i "s/-//g" $out

echo ">Concatenated" >> $out
cat short_sequences.fa >> $out

rm long_ids.txt
rm short_sequences.fa
rm single_line.fa
