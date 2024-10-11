#!/usr/bin/env bash

set -x

valik=/group/ag_abi/evelina/valik/build/bin/valik

cd work 
mkdir -p /dev/shm/genome-wise

#ref="/buffer/ag_abi/evelina/mouse/chr1.fa"
#query="/buffer/ag_abi/evelina/fly/dna4.fa"
ref="/buffer/ag_abi/evelina/mouse/ref_concat.fa"
query="/buffer/ag_abi/evelina/fly/query_concat.fa"

ibf_bins=1024
query_seg_count=30000
min_len=150
timeout="60m"
er=0.025
threads=16
numMatches=10000
sortThresh=$(($numMatches + 1))
kmer_cmin=0 # min k-mer count
log="valik_manual.time"

ref_meta="meta/mouse_ref_b${ibf_bins}.bin"
index="/dev/shm/genome-wise/mouse_b${ibf_bins}_k${kmer_size}_l${min_len}.index"

echo -e "time\tmem\terror-code\tcommand\tbins\tk\tquery-seg\tmin-len\ter\tthresh\tcmin\tcmax\tibf-size\tmatches\trepeats" >> valik_manual.time

#for kmer_size in 19
for kmer_size in 19 21
do	
	echo "Splitting reference database"
	$valik split $ref --without-parameter-tuning -k $kmer_size --verbose --fpr 0.0005 --out $ref_meta --error-rate $er --pattern $min_len -n $ibf_bins 2> split.err
	
for kmer_cmin in 0 
do
	for kmer_cmax in 250
	do
		echo "Building IBF"
		$valik build --without-parameter-tuning --verbose --kmer $kmer_size --fast --threads $threads --output $index --ref-meta $ref_meta --kmer-count-min $kmer_cmin --kmer-count-max $kmer_cmax 2> build.err

		for query_seg_count in 20000
		do
		for threshold in 20 30 40 50 60
		do
			prefix="b${ibf_bins}_k${kmer_size}_q${query_seg_count}_l${min_len}_t${threshold}_cmax${kmer_cmax}"
			out="valik_${prefix}.gff"
			rm $out
		
			echo "Search for local matches"
			(timeout $timeout /usr/bin/time -a -o $log -f "%e\t%M\t%x\tvalik-search\t${ibf_bins}\t${kmer_size}\t${query_seg_count}\t${min_len}\t${er}\t${threshold}\t${kmer_cmin}\t${kmer_cmax}" $valik search --without-parameter-tuning --keep-best-repeats --verbose --seg-count $query_seg_count --threshold $threshold --pattern $min_len --split-query --cache-thresholds --numMatches $numMatches --sortThresh $sortThresh --index $index --ref-meta $ref_meta --query $query --error-rate $er --threads $threads --output $out --cart-max-capacity $query_seg_count --max-queued-carts $ibf_bins || touch $out ) > ${timeout}_${prefix}.log 2> ${prefix}.err

			truncate -s -1 $log
			ls -lh $index | awk '{ print "\t" $5}' >> $log

			truncate -s -1 $log
			wc -l $out | awk '{ print "\t" $1}' >> $log

			truncate -s -1 $log
			grep "Insufficient" ${prefix}.err | wc -l | awk '{ print "\t" $1}' >> $log
		done
		done
		rm $index
		rm /dev/shm/genome-wise/*.minimiser
		rm /dev/shm/genome-wise/*.header		
	done
done
done
