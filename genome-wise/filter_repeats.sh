#!/usr/bin/env bash

set -e

valik=/group/ag_abi/evelina/valik2/build/bin/valik

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
max_er=0.05
er=0.025
threads=16
numMatches=20000
sortThresh=$(($numMatches + 1))

kmer_cmin=0 # min k-mer count
kmer_cmax=254

threads=16

cart_max_cap=15000
max_queued_carts=1024

mkdir -p /dev/shm/parameter-tuning
ref_meta="meta/param_tuning_mouse_ref_b${ibf_bins}.bin"
index="/dev/shm/parameter-tuning/mouse_b${ibf_bins}_l${min_len}.index"

split_log="split_valik.time"
build_log="build_valik.time"
search_log="search_valik.time"

truth_file="stellar_l${min_len}.gff" 
min_overlap=10

for log_file in $split_log $build_log $search_log
do
	echo "#reduce cart capacity = multiple stellar instances for a single bin" >> $log_file
done

echo -e "time\tmem\terror-code\tcommand\tmax-er\tmin-len\tbins" >> $split_log
echo "Splitting reference database"
/usr/bin/time -a -o $split_log -f "%e\t%M\t%x\tvalik-split\t${max_er}\t${min_len}\t${ibf_bins}" $valik split $ref --verbose --fpr 0.005 --out $ref_meta --error-rate $max_er --pattern $min_len -n $ibf_bins
	
echo -e "time\tmem\terror-code\tcommand\tbins\tcmin\tcmax\tthreads\tibf-size" >> $build_log
echo "Building IBF"
/usr/bin/time -a -o $build_log -f "%e\t%M\t%x\tvalik-build\t${bins}\t${kmer_cmin}\t${kmer_cmax}\t${threads}" $valik build --verbose --fast --threads $threads --output $index --ref-meta $ref_meta --kmer-count-min $kmer_cmin --kmer-count-max $kmer_cmax
truncate -s -1 $build_log
ls -lh $index | awk '{ print "\t" $5}' >> $build_log

echo -e "time\tmem\terror-code\tcommand\tbins\tcart-max-cap\tmax-queued\tmin-len\ter\tcmin\tcmax\trepeat-mask\trepeats\tibf-size\tmatches\ttruth-set-matches\ttrue-matches\tmissed\tmin_overlap" >> $search_log

for repeat_mask in "--keep-all-repeats" "--keep-all-repeats" "--keep-best-repeats" "\t"
do
	
	echo "Search for local matches and $repeat_mask" 
	prefix="test_b${ibf_bins}_l${min_len}_cmax${kmer_cmax}"
	out="valik_${prefix}.gff"
	#rm $out
	
	(timeout $timeout /usr/bin/time -a -o $search_log -f "%e\t%M\t%x\tvalik-search\t${ibf_bins}\t${cart_max_cap}\t${max_queued_carts}\t${min_len}\t${er}\t$kmer_cmin\t${kmer_cmax}\t$repeat_mask" $valik search --time $repeat_mask --verbose --split-query --cache-thresholds --numMatches $numMatches --sortThresh $sortThresh --index $index --ref-meta $ref_meta --query $query --error-rate $er --threads $threads --output $out --cart-max-capacity $cart_max_cap --max-queued-carts $max_queued_carts || touch $out ) > ${timeout}_${prefix}.log 2> ${prefix}.err

	truncate -s -1 $search_log
	grep "Insufficient" ${prefix}.err | wc -l | awk '{ print "\t" $1 "\t"}' >> $search_log
	truncate -s -1 $search_log
	ls -lh $index | awk '{ print "\t" $5}' >> $search_log

	truncate -s -1 $search_log
	wc -l $out | awk '{ print "\t" $1 "\t"}' >> $search_log

	truncate -s -1 $search_log
	../scripts/search_accuracy.sh $truth_file $out $min_len $min_overlap tmp.log
	tail -n 1 tmp.log >> $search_log
	rm tmp.log

	truncate -s -1 $search_log
	echo -e "\t$min_overlap" >> $search_log
done

#rm $index
#rm /dev/shm/test-genome-wise/*.minimiser
#rm /dev/shm/test-genome-wise/*.header

