#!/usr/bin/env bash

set -e

valik=/group/ag_abi/evelina/valik/build_short/bin/valik
stellar=/group/ag_abi/evelina/stellar3/build/bin/stellar

prefix="queue_param"
mkdir -p work/$prefix
cd work/$prefix 

#ref="/buffer/ag_abi/evelina/mouse/chr1.fa"
#query="/buffer/ag_abi/evelina/fly/dna4.fa"
ref="/buffer/ag_abi/evelina/mouse/ref_concat.fa"
query="/buffer/ag_abi/evelina/fly/query_concat.fa"
#query="/buffer/ag_abi/evelina/fly/rDNA.fa"

max_er=0.0267
min_len=150
er=0.0267

numMatches=20000
sortThresh=$(($numMatches + 1))

kmer_cmin=0 # min k-mer count
kmer_cmax=254

repeat_mask="--keep-all-repeats"
ibf_fpr=0.005
ibf_bins=1024
threads=16

tau=0.9999
p_max=0.15

min_overlap=100

split_log="split_valik.time"
build_log="build_valik.time"
search_log="search_valik.time"
#stellar_log="stellar.time"

for log_file in $split_log $build_log $search_log
do
	echo "#" >> $log_file
done

echo -e "time\tmem\terror-code\tcommand\tmax-er\tmin-len\tbins\tibf-fpr" >> $split_log
echo -e "time\tmem\terror-code\tcommand\tbins\tcmin\tcmax\tthreads\tibf-size\tibf-fpr" >> $build_log
echo -e "time\tmem\terror-code\tcommand\tbins\tthreads\tcart-max-cap\tmax-queued\tmin-len\ter\tcmin\tcmax\trepeat-mask\tibf-fpr\tibf-size\trepeats\tmatches\ttruth-set-matches\ttrue-matches\tmissed\tmin_overlap" >> $search_log


mkdir -p meta
ref_meta="meta/mouse_ref_b${ibf_bins}.bin"
mkdir -p /dev/shm/$prefix
index="/dev/shm/$prefix/mouse_b${ibf_bins}_l${min_len}.index"

#################### SPLIT ####################
echo "Splitting reference database"
/usr/bin/time -a -o $split_log -f "%e\t%M\t%x\tvalik-split\t${max_er}\t${min_len}\t${ibf_bins}\t$ibf_fpr" $valik split $ref --verbose --fpr $ibf_fpr --out $ref_meta --error-rate $max_er --pattern $min_len -n $ibf_bins &> "b${ibf_bins}_fpr${ibf_fpr}_split.err"

################### BUILD ####################
echo "Building IBF"
/usr/bin/time -a -o $build_log -f "%e\t%M\t%x\tvalik-build\t${bins}\t${kmer_cmin}\t${kmer_cmax}\t${threads}\t$ibf_fpr" $valik build --verbose --fast --threads $threads --output $index --ref-meta $ref_meta --kmer-count-min $kmer_cmin --kmer-count-max $kmer_cmax
truncate -s -1 $build_log
ls -lh $index | awk '{ print "\t" $5}' >> $build_log

truth_file="../stellar/mouse_vs_fly_stellar_l${min_len}_e${er}.gff"
#/usr/bin/time -a -o $stellar_log -f "%e\t%M\t%x\tstellar\t${min_len}\t${er}" $stellar -a dna --numMatches $numMatches --sortThresh $sortThresh $ref $query -e $er -l $min_len -o $truth_file

#################### SEARCH ####################
for max_queued_carts in 1024 
	#512 256 128 64
do

for cart_max_cap in 10000 
	#1000 100 10
do

if [ -f $truth_file ]; then

	echo "Search for local matches and $repeat_mask" 
	run_id="carts${max_queued_carts}_cap${cart_max_cap}"
	out="${run_id}.gff"

	/usr/bin/time -a -o $search_log -f "%e\t%M\t%x\tvalik-search\t${ibf_bins}\t$threads\t${cart_max_cap}\t${max_queued_carts}\t${min_len}\t${er}\t$kmer_cmin\t${kmer_cmax}\t$repeat_mask\t$ibf_fpr" $valik search $repeat_mask --time --verbose --split-query --cache-thresholds --numMatches $numMatches --sortThresh $sortThresh --index $index --ref-meta $ref_meta --query $query --error-rate $er --threads $threads --output $out --cart-max-capacity $cart_max_cap --max-queued-carts $max_queued_carts > ${run_id}.log 2> ${run_id}.err

	truncate -s -1 $search_log
	ls -lh $index | awk '{ print "\t" $5}' >> $search_log

	truncate -s -1 $search_log
	grep "Insufficient" ${run_id}.err | wc -l | awk '{ print "\t" $1}' >> $search_log
	
	truncate -s -1 $search_log
	wc -l $out | awk '{ print "\t" $1 "\t"}' >> $search_log

	truncate -s -1 $search_log
	../../scripts/search_accuracy.sh $truth_file $out $min_len $min_overlap $ref_meta tmp.log
	tail -n 1 tmp.log >> $search_log
	rm tmp.log
	#rm $out 

	truncate -s -1 $search_log
	echo -e "\t$min_overlap" >> $search_log
fi

done
done

#rm $ref_meta	
rm $index
rm /dev/shm/$prefix/*.minimiser
rm /dev/shm/$prefix/*.header

