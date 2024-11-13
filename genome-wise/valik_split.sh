#!/usr/bin/env bash

set -x

cd work 
er=0.025
min_len=150
kmer_size=19
log="build_valik_manual.time"
ibf_fpr=0.01

function run_split () {
	prefix=$1
	ibf_bins=$2
	echo "$prefix ref split"
	exec_mode=$3
	
	ref="/buffer/ag_abi/evelina/$prefix/ref_concat.fa"

	mkdir -p /dev/shm/$prefix
	ref_meta="meta/${prefix}_ref_b${ibf_bins}.bin"

	# Cleanup existing
	rm $ref_meta

	echo "Splitting reference database"
	$valik split $ref --without-parameter-tuning -k $kmer_size --verbose --fpr $ibf_fpr --out $ref_meta --error-rate $er --pattern $min_len -n $ibf_bins 2> seg_lens
	
}	

#echo -e "time\tmem\terror-code\tcommand\tref\tbins\tk\tmin-len\tmax-er" >> $log

valik=/group/ag_abi/evelina/valik/build/bin/valik
run_split "mouse" 1024 "print-seg-lens"

#valik=/group/ag_abi/evelina/valik2/build2/bin/valik
#run_build "mouse" 1024 "linear-kmer"

