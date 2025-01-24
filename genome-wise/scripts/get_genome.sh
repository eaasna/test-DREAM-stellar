#!/bin/bash

set -e 

if [[ "$#" -ne 2 ]]; then
	echo "Usage: bash get_genome.sh <data_dir> <species:{human, mouse, fly}>"
	exit
fi	

data_dir=$1
species=$2

ref_len_cutoff=10000
outfile="ref_concat.fa"
if [[ "$species" == "human" ]] then
	ftp_dir="https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/001/405/GCF_000001405.26_GRCh38/GRCh38_major_release_seqs_for_alignment_pipelines"
	release="GRCh38"
	ftp_filename="GCA_000001405.15_GRCh38_full_analysis_set"
elif [[ "$species" == "mouse" ]] then
	ftp_dir="https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/001/635/GCF_000001635.27_GRCm39"
	release="GRCm39"
	ftp_filename="GCF_000001635.27_GRCm39_genomic"
elif [[ "$species" == "fly" ]] then
	ftp_dir="https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/001/215/GCF_000001215.4_Release_6_plus_ISO1_MT"
	release="6_plus_ISO1_MT"
	ftp_filename="GCF_000001215.4_Release_6_plus_ISO1_MT_genomic"
	outfile="query_concat.fa"
	ref_len_cutoff=500
else
	echo "species must be one of {human, mouse, fly}"
	exit 1
fi

# download ref
wget $ftp_dir/$ftp_filename.fna.gz -P $data_dir

gzip -d $data_dir/$ftp_filename.fna.gz

#short_ids="short_ids.txt"
#echo "Find short ids"
#./find_short_ids.sh $data_dir $ftp_filename.fna $ref_len_cutoff $short_ids
#cat $data_dir/$short_ids

#./concat_scaffolds.sh $data_dir $short_ids $ftp_filename.fna $outfile
