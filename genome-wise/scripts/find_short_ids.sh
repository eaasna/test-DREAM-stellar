#!/bin/bash

set -e 

if [[ "$#" -ne 4 ]]; then
	echo "Usage: bash find_short_ids.sh <work_dir> <multi line fasta in> <ref len cutoff> <short ids out>"
	exit 1
fi

work_dir=${1}
cd $work_dir

ref_in=${2}
len_cutoff=${3}
out=${4}

grep -n ">" $ref_in | awk '{print $1}' | awk -F':>' '{print $1 "\t" $2}' > $ref_in.ids

touch $out
rm $out
prev_id=""
prev_start=0
while read start id; do
	record_len=$((start - prev_start))
	if [ $prev_start -ne 0 ]; then
		echo -e "$prev_id\t$record_len" >> record_lengths.txt
		if [ $record_len -le $len_cutoff ]; then
			echo -e "$prev_id\t$record_len" 
			echo $prev_id | awk -v rec_len="$record_len" '{print $1}' >> $out
		fi
	fi
	prev_id=$id
	prev_start=$start
done < $ref_in.ids

short_count=$(wc -l $out | awk '{print $1}')
echo "Found $short_count sequences shorter than $len_cutoff"

