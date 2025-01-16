#!/bin/bash

set -e

# conda activate python27

ref="/srv/data/evelina/human/ref_concat.fa"
index="/srv/data/evelina/human/ref.mmi"

#echo "index $ref"
#pbmm2 index $ref $index --preset HIFI

work_dir="/buffer/ag_abi/evelina/1000genomes/hifi/ftp.sra.ebi.ac.uk/vol1/run"

for sample in $work_dir/*/*/*1.bam;do
	sample_dir="$(dirname "$sample")"
	
	reads="$sample"
	mapped="$sample_dir/pbmm2.bam"	
	unmapped="$sample_dir/unmapped.bam"	
	fasta="$sample_dir/unmapped.fa"
	if [ ! -f $mapped ]; then
		# alignments are discarded if they do not have at least 70% gap-compressed identity
		# https://github.com/PacificBiosciences/pbmm2/blob/develop/README.md#how-do-you-define-gap-compressed-identity
		echo "align $reads"
		pbmm2 align $index $reads $mapped --preset HIFI --unmapped

		echo "filter out unmapped"
		samtools view --bam -f 4 $mapped > $unmapped
	fi
	
	echo "make fasta"
	samtools view $unmapped | awk '{print ">"$1 "\t" $10 }' | sed 's/[ \t]\{1,\}/\n/' > $fasta
done

