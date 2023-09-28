#!/usr/bin/env bash
set -e

REP=$1
REF_LENGTH=$2 	# 2^20 = 1Mb
REF_SEED=$3
QUERY_SEED=$4
CHR_SIZE_BOUND=300000000 
	
if [ $REF_LENGTH -gt $CHR_SIZE_BOUND ]
then
	echo "Simulating random genome with chromosomes equal to "
	mason_genome -l 248956422 -l 242193529 -l 198295559 -l 190214555 -l 181538259 -l 170805979 -l 159345973 -l 145138636 -l 138394717 -l 133797422 -l 135086622 -l 133275309 -l 114364328 -l 107043718 -l 101991189 -l 90338345 -l 83257441 -l 80373285 -l 58617616 -l 64444167 -l 46709983 -l 50818468 -l 156040895 -l 57227415 -o genomeA_rep${REP}.fasta -s $REF_SEED
fi

if [ $REF_LENGTH -le $CHR_SIZE_BOUND ]
then
	nr_chrs=10
	chr_len=`bc <<< "scale=0; $REF_LENGTH / $nr_chrs"`
	echo "Simulating random genome with $nr_chrs of length $chr_len "
	mason_genome -o genomeA_rep${REP}.fasta -s $REF_SEED \
		-l $chr_len \
		-l $chr_len \
		-l $chr_len \
		-l $chr_len \
		-l $chr_len \
		-l $chr_len \
		-l $chr_len \
		-l $chr_len \
		-l $chr_len \
		-l $chr_len
fi

echo "Simulating related genome of same length "
mason_variator \
	-ir genomeA_rep${REP}.fasta \
	-n 1 \
	-of genomeB_rep${REP}.fasta \
	-ov variants.vcf \
	--snp-rate 0.1	
#\
#	--small-indel-rate 0.01 \
#	--sv-indel-rate 0.0001 \
#	--sv-inversion-rate 0.0001 \
#	--sv-duplication-rate 0.0001 \
#	--sv-translocation-rate 0.0001 \
#	--s $QUERY_SEED


