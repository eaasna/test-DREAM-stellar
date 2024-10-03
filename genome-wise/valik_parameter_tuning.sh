#!/usr/bin/env bash

set -x

valik=/group/ag_abi/evelina/valik/build/bin/valik

cd work 
mkdir -p /dev/shm/genome-wise

#ref="/buffer/ag_abi/evelina/mouse/chr1.fa"
#query="/buffer/ag_abi/evelina/fly/dna4.fa"
ref="/buffer/ag_abi/evelina/mouse/ref.fa"
query="/buffer/ag_abi/evelina/fly/query.fa"
ref_meta="meta/mouse_ref_b${ibf_bins}.bin"
index="/dev/shm/genome-wise/mouse_b${ibf_bins}_k${kmer_size}_l${min_len}.index"

ibf_bins=1024
query_seg_count=20000
min_len=150
timeout="60m"
er=0.025
threads=16
numMatches=20000
sortThresh=$(($numMatches + 1))
kmer_cmin=1 # min k-mer count
log="valik_manual.time"

echo -e "time\tmem\terror-code\tcommand\tbins\tk\tquery-seg\tmin-len\ter\tthresh\tcmax\tibf-size\tmatches\trepeats" >> valik_manual.time

#for kmer_size in 19
for kmer_size in 19 21
do	
	echo "Splitting reference database"
	$valik split $ref --without-parameter-tuning -k $kmer_size --verbose --fpr 0.0005 --out $ref_meta --error-rate $er --pattern $min_len -n $ibf_bins
	
	#for kmer_cmax in 50
	for kmer_cmax in 40 50 60 70
	do
		echo "Building IBF"
		$valik build --without-parameter-tuning --verbose --kmer $kmer_size --fast --threads $threads --output $index --ref-meta $ref_meta --kmer-count-min $kmer_cmin --kmer-count-max $kmer_cmax

		#for threshold in 50
		for threshold in 50 60 70 80
		do
			prefix="b${ibf_bins}_k${kmer_size}_q${query_seg_count}_l${min_len}_t${threshold}_cmax${kmer_cmax}"
			out="valik_${prefix}.gff"
			rm $out
		
			echo "Search for local matches"
			(timeout $timeout /usr/bin/time -a -o $log -f "%e\t%M\t%x\tvalik-search\t${ibf_bins}\t${kmer_size}\t${query_seg_count}\t${min_len}\t${er}\t${threshold}\t${kmer_cmax}" $valik search --without-parameter-tuning --keep-repeats --verbose --seg-count $query_seg_count --threshold $threshold --pattern $min_len --split-query --cache-thresholds --numMatches $numMatches --sortThresh $sortThresh --index $index --ref-meta $ref_meta --query $query --error-rate $er --threads $threads --output $out --cart-max-capacity $query_seg_count --max-queued-carts $ibf_bins || touch $out ) > ${timeout}_${prefix}.log 2> ${prefix}.err

			truncate -s -1 $log
			ls -lh $index | awk '{ print "\t" $5}' >> $log

			truncate -s -1 $log
			wc -l $out | awk '{ print "\t" $1}' >> $log

			truncate -s -1 $log
			grep "Insufficient" ${prefix}.err | wc -l | awk '{ print "\t" $1}' >> $log
		done

		rm $index
		rm /dev/shm/genome-wise/*.minimiser
		rm /dev/shm/genome-wise/*.header
	done
done

