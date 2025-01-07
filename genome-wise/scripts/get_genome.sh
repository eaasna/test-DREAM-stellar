#!/bin/bash

set -ex 

if [[ "$#" -ne 3 ]]; then
	echo "Usage: bash get_genome.sh <data_dir> <short_ids> <species:{human, mouse, fly}>"
	exit
fi	

data_dir=$1
short_ids=$2
species=$3

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
else
	echo "species must be one of {human, mouse, fly}"
	exit 1
fi

wget $ftp_dir/$ftp_filename.fna.gz -P $data_dir

gzip -d $data_dir/$ftp_filename.fna.gz

#convert to single line fasta
awk '{if(NR==1) {print $0} else {if($0 ~ /^>/) {print "\n"$0} else {printf $0}}}' $data_dir/$ftp_filename.fna > $data_dir/$release.fa
rm $data_dir/$ftp_filename.fna

./concat_scaffolds.sh $data_dir $short_ids "$release.fa" "$outfile"
rm $data_dir/$release.fa

