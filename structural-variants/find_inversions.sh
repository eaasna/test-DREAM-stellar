#!/bin/bash

set -e

work_dir="/buffer/ag_abi/evelina/1000genomes/hifi/ftp.sra.ebi.ac.uk/vol1/run"

for sample in $work_dir/*/*/l*e*.gff; do
	sample_dir="$(dirname "$sample")"
	seq_file="$(basename "$sample")"
	echo "$sample_dir"
	echo "$seq_file"
	./scripts/find_inversion.sh $sample_dir $seq_file
done

