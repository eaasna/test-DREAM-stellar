#!/usr/bin/env bash

set -x

cd work 
er=0.025
min_len=150
timeout="180m"
threads=16
kmer_size=19
kmer_cmin=1 # min k-mer count
kmer_cmax=254
log="build_valik_manual.time"
ibf_fpr=0.01

function run_build () {
	prefix=$1
	ibf_bins=$2
	echo "$prefix ref index"
	exec_mode=$3
	
	ref="/buffer/ag_abi/evelina/$prefix/ref_concat.fa"

	mkdir -p /dev/shm/$prefix
	ref_meta="meta/${prefix}_ref_b${ibf_bins}.bin"
	index="/dev/shm/$prefix/b${ibf_bins}_k${kmer_size}_l${min_len}.index"

	# Cleanup existing
	rm $index
	rm /dev/shm/$prefix/*.minimiser
	rm /dev/shm/$prefix/*.header
	
	echo "Splitting reference database"
	$valik split $ref --without-parameter-tuning -k $kmer_size --verbose --fpr $ibf_fpr --out $ref_meta --error-rate $er --pattern $min_len -n $ibf_bins
	
	echo "Building IBF"
	/usr/bin/time -a -o $log -f "%e\t%M\t%x\t$exec_mode-build\t$prefix\t$ibf_bins\t$ibf_fpr\t$kmer_size\t$kmer_cmin\t$kmer_cmax\t$threads" $valik build --fast --without-parameter-tuning --verbose --kmer $kmer_size --threads $threads --output $index --ref-meta $ref_meta --kmer-count-min $kmer_cmin --kmer-count-max $kmer_cmax

	truncate -s -1 $log
	ls -lh $index | awk '{print "\t" $5}' >> $log
}	

echo -e "time\tmem\terror-code\tcommand\tref\tbins\tk\tcmin\tcmax\tthreads\tibf-size" >> $log

valik=/group/ag_abi/evelina/valik/build/bin/valik
run_build "human" 1024 "linear"

valik=/group/ag_abi/evelina/valik2/build/bin/valik
run_build "human" 1024 "parallel"

