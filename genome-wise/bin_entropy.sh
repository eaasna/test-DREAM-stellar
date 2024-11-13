#!/usr/bin/env bash

set -e

valik=/group/ag_abi/evelina/valik2/build/bin/valik
stellar=/group/ag_abi/evelina/stellar3/build/bin/stellar

prefix="human_bin_entropy"
mkdir -p work/$prefix
cd work/$prefix 

#ref="/buffer/ag_abi/evelina/mouse/chr1.fa"
#query="/buffer/ag_abi/evelina/fly/dna4.fa"
ref="/buffer/ag_abi/evelina/human/ref_concat.fa"
query="/buffer/ag_abi/evelina/mouse/dna4.random.fa"
#query="/buffer/ag_abi/evelina/fly/rDNA.fa"

min_len=150
timeout="24h"
max_er=0.0267
threads=16
numMatches=20000
sortThresh=$(($numMatches + 1))

kmer_cmin=0 # min k-mer count
kmer_cmax=254

tau=0.9999
p_max=0.15
threads=16
cart_max_cap=15000

repeat_mask="--keep-best-repeats"
ibf_fpr=0.005

min_overlap=100
threads=32
er=0.0267

mkdir -p meta
ref_meta="meta/human_ref_b${ibf_bins}.bin"
mkdir -p /dev/shm/$prefix
index="/dev/shm/$prefix/human_b${ibf_bins}_l${min_len}.index"

split_log="split_valik.time"
build_log="build_valik.time"
search_log="search_valik.time"
stellar_log="stellar.time"


for log_file in $split_log $build_log $search_log
do
	echo "#human vs mouse" >> $log_file
done

echo -e "time\tmem\terror-code\tcommand\tmax-er\tmin-len\tbins\tibf-fpr" >> $split_log
echo -e "time\tmem\terror-code\tcommand\tbins\tcmin\tcmax\tthreads\tibf-size\tibf-fpr" >> $build_log
echo -e "time\tmem\terror-code\tcommand\tbins\tthreads\tcart-max-cap\tmax-queued\tmin-len\ter\tcmin\tcmax\trepeat-mask\tbin-entropy\tibf-fpr\tibf-size\trepeats\tmatches\ttruth-set-matches\ttrue-matches\tmissed\tmin_overlap" >> $search_log

for ibf_bins in 8192 4096 2048 1024
do
max_queued_carts=$ibf_bins

#################### SPLIT ####################
echo "Splitting reference database"
/usr/bin/time -a -o $split_log -f "%e\t%M\t%x\tvalik-split\t${max_er}\t${min_len}\t${ibf_bins}\t$ibf_fpr" $valik split $ref --verbose --fpr $ibf_fpr --out $ref_meta --error-rate $max_er --pattern $min_len -n $ibf_bins &> "b${ibf_bins}_fpr${ibf_fpr}_split.err"

#################### BUILD ####################
echo "Building IBF"
/usr/bin/time -a -o $build_log -f "%e\t%M\t%x\tvalik-build\t${bins}\t${kmer_cmin}\t${kmer_cmax}\t${threads}\t$ibf_fpr" $valik build --verbose --fast --threads $threads --output $index --ref-meta $ref_meta --kmer-count-min $kmer_cmin --kmer-count-max $kmer_cmax
truncate -s -1 $build_log
ls -lh $index | awk '{ print "\t" $5}' >> $build_log

#################### SEARCH ####################
for bin_entropy in "0.1" "0.01"
do
	#truth_file="human_vs_mouse_stellar_l${min_len}_e${er}.gff" 
	truth_file="../blast/human_vs_mouse_blast_e1_k28.txt"
	
	#(timeout $timeout /usr/bin/time -a -o $stellar_log -f "%e\t%M\t%x\tstellar\t${min_len}\t${er}" $stellar -a dna --numMatches $numMatches --sortThresh $sortThresh $ref $query -e $er -l $min_len -o $truth_file)

	echo "Search for local matches and $repeat_mask" 
	run_id="b${ibf_bins}_l${min_len}"
	out="${run_id}.gff"

	/usr/bin/time -a -o $search_log -f "%e\t%M\t%x\tvalik-search\t${ibf_bins}\t$threads\t${cart_max_cap}\t${max_queued_carts}\t${min_len}\t${er}\t$kmer_cmin\t${kmer_cmax}\t$repeat_mask\t$bin_entropy\t$ibf_fpr" $valik search $repeat_mask --bin-entropy-cutoff $bin_entropy --time --verbose --split-query --cache-thresholds --numMatches $numMatches --sortThresh $sortThresh --index $index --ref-meta $ref_meta --query $query --error-rate $er --threads $threads --output $out --cart-max-capacity $cart_max_cap --max-queued-carts $max_queued_carts > ${timeout}_${run_id}.log 2> ${run_id}.err

	truncate -s -1 $search_log
	ls -lh $index | awk '{ print "\t" $5}' >> $search_log

	truncate -s -1 $search_log
	grep "Insufficient" ${run_id}.err | wc -l | awk '{ print "\t" $1}' >> $search_log
	
	truncate -s -1 $search_log
	wc -l $out | awk '{ print "\t" $1 "\t"}' >> $search_log

	truncate -s -1 $search_log
#if [ -s $truth_file ];  && [ -s $out ]; then
#	../../scripts/search_accuracy.sh $truth_file $out $min_len $min_overlap $ref_meta tmp.log
#	tail -n 1 tmp.log >> $search_log
#	rm tmp.log
	#rm $out 
#else
	echo -e "N/A\tN/A\tN/A" >> $search_log
#fi

	truncate -s -1 $search_log
	echo -e "\t$min_overlap" >> $search_log

done
done

#rm $ref_meta	
rm $index
rm /dev/shm/$prefix/*.minimiser
rm /dev/shm/$prefix/*.header

