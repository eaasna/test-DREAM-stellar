#!/bin/bash

set -ex

# WRK IN PROGRESS

cd /buffer/ag_abi/evelina/human
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/001/405/GCF_000001405.26_GRCh38/GRCh38_major_release_seqs_for_alignment_pipelines/GCA_000001405.15_GRCh38_full_analysis_set.fna.gz 

gunzip -d GCA

cd /group/ag_abi/evelina/DREAM-Stellar-benchmark/genome-wise/scripts

./remove_repeats.sh /buffer/ag_abi/evelina/fly dmel-all-chromosome-r6-59.fasta dna4.random.fa

./concat_scaffolds.sh /buffer/ag_abi/evelina/human split.out dna4.random.fa
