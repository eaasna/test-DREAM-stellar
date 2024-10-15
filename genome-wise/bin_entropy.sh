#!/usr/bin/env bash

set -e

valik=/group/ag_abi/evelina/valik/build/bin/valik

cd work 
mkdir -p /dev/shm/test-genome-wise

#ref="/buffer/ag_abi/evelina/mouse/chr1.fa"
#query="/buffer/ag_abi/evelina/fly/dna4.fa"
ref="/buffer/ag_abi/evelina/mouse/ref_concat.fa"
query="/buffer/ag_abi/evelina/fly/query_concat.fa"
#query="/buffer/ag_abi/evelina/fly/rDNA.fa"

ibf_bins=1024
min_len=150
timeout="180m"
query_seg_count=20000
cart_max_cap=$query_seg_count
er=0.025
threads=16
numMatches=20000
sortThresh=$(($numMatches + 1))
kmer_size=19
threshold=50

kmer_cmin=0 # min k-mer count
kmer_cmax=254

ref_meta="meta/test_mouse_ref_b${ibf_bins}.bin"
index="/dev/shm/test-genome-wise/mouse_b${ibf_bins}_k${kmer_size}_l${min_len}.index"

split_log="split_valik_manual.time"
build_log="build_valik_manual.time"
search_log="search_valik_manual.time"

#echo -e "time\tmem\terror-code\tcommand\tk\tmax-er\tmin-len\tbins" >> $split_log
#echo "Splitting reference database"
#/usr/bin/time -a -o $split_log -f "%e\t%M\t%x\tvalik-split\t${kmer_size}\t${er}\t${min_len}\t${ibf_bins}" $valik split $ref --without-parameter-tuning -k $kmer_size --verbose --fpr 0.01 --out $ref_meta --error-rate $er --pattern $min_len -n $ibf_bins
	
#echo -e "time\tmem\terror-code\tcommand\tbins\tk\tcmin\tcmax\tthreads\tibf-size" >> $search_log
#echo "Building IBF"
#/usr/bin/time -a -o $build_log -f "%e\t%M\t%x\tvalik-build\t${bins}\t${kmer_size}\t${kmer_cmin}\t${kmer_cmax}\t${threads}" $valik build --fast --without-parameter-tuning --verbose --kmer $kmer_size --threads $threads --output $index --ref-meta $ref_meta --kmer-count-min $kmer_cmin --kmer-count-max $kmer_cmax
#truncate -s -1 $build_log
#ls -lh $index | awk '{ print "\t" $5}' >> $build_log

echo -e "time\tmem\terror-code\tcommand\tbins\tk\tquery-seg\tcart-max-cap\tmin-len\ter\tthresh\tcmin\tcmax\tbin-entropy-cutoff\tibf-size\tmatches\trepeats\ttruth-set-matches\ttrue-matches\tmissed" >> $search_log

threads=16
repeat_mask="--keep-best-repeats" 
bin_entropy_cutoff="N/A"
#--bin-entropy-cutoff $bin_entropy_cutoff 
#for bin_entropy_cutoff in 0.1 0.2 0.3 0.4
#do
	echo "Search for local matches and $repeat_mask" 
	prefix="test_b${ibf_bins}_k${kmer_size}_q${query_seg_count}_l${min_len}_t${threshold}_cmax${kmer_cmax}"
	out="valik_${prefix}.gff"
	rm $out
	
	(timeout $timeout /usr/bin/time -a -o $search_log -f "%e\t%M\t%x\tvalik-search\t${ibf_bins}\t${kmer_size}\t${query_seg_count}\t${cart_max_cap}\t${min_len}\t${er}\t${threshold}\t${kmer_cmax}\t${bin_entropy_cutoff}" $valik search $repeat_mask --without-parameter-tuning --verbose --seg-count $query_seg_count --threshold $threshold --pattern $min_len --split-query --cache-thresholds --numMatches $numMatches --sortThresh $sortThresh --index $index --ref-meta $ref_meta --query $query --error-rate $er --threads $threads --output $out --cart-max-capacity $cart_max_cap --max-queued-carts $ibf_bins || touch $out ) > ${timeout}_${prefix}.log 2> ${prefix}.err

	truncate -s -1 $search_log
	ls -lh $index | awk '{ print "\t" $5}' >> $search_log

	truncate -s -1 $search_log
	wc -l $out | awk '{ print "\t" $1}' >> $search_log

	truncate -s -1 $search_log
	grep "Insufficient" ${prefix}.err | wc -l | awk '{ print "\t" $1 "\t"}' >> $search_log

	truncate -s -1 $search_log
	truth_file="stellar_l150.gff" 
	../scripts/search_accuracy.sh $truth_file $out $min_len 10 tmp.log
	tail -n 1 tmp.log >> $search_log
	rm tmp.log
#done

#rm $index
#rm /dev/shm/test-genome-wise/*.minimiser
#rm /dev/shm/test-genome-wise/*.header

