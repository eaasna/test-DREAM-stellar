#!/usr/bin/env bash

set -e

valik=/group/ag_abi/evelina/valik/build/bin/valik
stellar=/group/ag_abi/evelina/stellar3/build/bin/stellar

cd work 

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

prefix="index_param"
mkdir -p /dev/shm/$prefix
ref_meta="meta/${prefix}_mouse_ref_b${ibf_bins}.bin"
index="/dev/shm/${prefix}/mouse_b${ibf_bins}_l${min_len}.index"

split_log="${prefix}_split_valik.time"
build_log="${prefix}_build_valik.time"
search_log="${prefix}_search_valik.time"
stellar_log="${prefix}_stellar.time"

min_overlap=100

for log_file in $split_log $build_log $search_log $stellar_log
do
	echo "#log split out" >> $log_file
done

truth_file="mouse_vs_fly_stellar_l${min_len}_e${er}.gff" 
#(timeout $timeout /usr/bin/time -a -o $stellar_log -f "%e\t%M\t%x\tstellar\t${min_len}\t${er}" $stellar -a dna --numMatches $numMatches --sortThresh $sortThresh $ref $query -e $er -l $min_len -o $truth_file)

echo -e "time\tmem\terror-code\tcommand\tmax-er\tmin-len\tbins\tibf-fpr" >> $split_log
echo -e "time\tmem\terror-code\tcommand\tbins\tcmin\tcmax\tthreads\tibf-size\tibf-fpr" >> $build_log
echo -e "time\tmem\terror-code\tcommand\tbins\tthreads\tcart-max-cap\tmax-queued\tmin-len\ter\tcmin\tcmax\trepeat-mask\trepeats\tibf-fpr\tibf-size\tmatches\ttruth-set-matches\ttrue-matches\tmissed\tmin_overlap" >> $search_log

repeat_mask="--keep-all-repeats"
for ibf_bins in 1024
	#64 512 1024 2048
do
	for ibf_fpr in 0.005
		#0.001 0.005 0.01 0.05
	do
	
	#################### SPLIT ####################
	echo "Splitting reference database"
	/usr/bin/time -a -o $split_log -f "%e\t%M\t%x\tvalik-split\t${max_er}\t${min_len}\t${ibf_bins}\t$ibf_fpr" $valik split $ref --verbose --fpr $ibf_fpr --out $ref_meta --error-rate $max_er --pattern $min_len -n $ibf_bins &> "b${ibf_bins}_fpr${ibf_fpr}_split.err"
	
	#################### BUILD ####################
	echo "Building IBF"
	/usr/bin/time -a -o $build_log -f "%e\t%M\t%x\tvalik-build\t${bins}\t${kmer_cmin}\t${kmer_cmax}\t${threads}\t$ibf_fpr" $valik build --verbose --fast --threads $threads --output $index --ref-meta $ref_meta --kmer-count-min $kmer_cmin --kmer-count-max $kmer_cmax
	truncate -s -1 $build_log
	ls -lh $index | awk '{ print "\t" $5}' >> $build_log

	#################### SEARCH ####################
	for threads in 16
	do
	echo "Search for local matches and $repeat_mask" 
	run_id="${prefix}_b${ibf_bins}_fpr${ibf_fpr}_l${min_len}_cmax${kmer_cmax}"
	out="${run_id}.gff"

	valik=/group/ag_abi/evelina/valik/debug/bin/valik
	#(timeout $timeout /usr/bin/time -a -o $search_log -f "%e\t%M\t%x\tvalik-search\t${ibf_bins}\t$threads\t${cart_max_cap}\t${max_queued_carts}\t${min_len}\t${er}\t$kmer_cmin\t${kmer_cmax}\t$repeat_mask\t$ibf_fpr" 
	valgrind --tool=massif $valik search $repeat_mask --time --verbose --split-query --cache-thresholds --numMatches $numMatches --sortThresh $sortThresh --index $index --ref-meta $ref_meta --query $query --error-rate $er --threads $threads --output $out --cart-max-capacity $cart_max_cap --max-queued-carts $max_queued_carts > valgrind.out 2>&1 
	#|| touch $out ) > ${timeout}_${run_id}.log 2> ${run_id}.err

	truncate -s -1 $search_log
	grep "Insufficient" ${run_id}.err | wc -l | awk '{ print "\t" $1}' >> $search_log
	truncate -s -1 $search_log
	ls -lh $index | awk '{ print "\t" $5}' >> $search_log

	truncate -s -1 $search_log
	wc -l $out | awk '{ print "\t" $1 "\t"}' >> $search_log

	truncate -s -1 $search_log
	../scripts/search_accuracy.sh $truth_file $out $min_len $min_overlap tmp.log
	tail -n 1 tmp.log >> $search_log
	rm tmp.log
	#rm $out 

	truncate -s -1 $search_log
	echo -e "\t$min_overlap" >> $search_log

	done

	rm $ref_meta	
	rm $index
	rm /dev/shm/$prefix/*.minimiser
	rm /dev/shm/$prefix/*.header

	done
done


