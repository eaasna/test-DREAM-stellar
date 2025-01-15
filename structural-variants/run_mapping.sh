#!/bin/bash

set -ex

# conda activate python27

work_dir="/buffer/ag_abi/evelina/1000genomes/hifi/ftp.sra.ebi.ac.uk/vol1/run/ERR386/ERR3861390/"
reads="$work_dir/HG00732-hifi-r54329U_20190607_183639-D01.bam"
ref="/srv/data/evelina/human/ref_concat.fa"
index="/srv/data/evelina/human/ref.mmi"

echo "index $ref"
pbmm2 index $ref $index --preset HIFI

mapped="$work_dir/pbmm2.bam"	
unmapped="$work_dir/unmapped.bam"	

# alignments are discarded if they do not have at least 70% gap-compressed identity
# https://github.com/PacificBiosciences/pbmm2/blob/develop/README.md#how-do-you-define-gap-compressed-identity 

echo "align $reads"
pbmm2 align $index $reads $mapped --preset HIFI --unmapped

echo "filter out unmapped"
samtools view --bam -f 4 $mapped > $unmapped

echo "get fasta"

