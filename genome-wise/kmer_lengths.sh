#!/usr/bin/env bash

set -e

valik=/group/ag_abi/evelina/valik_long/build/bin/valik
stellar=/group/ag_abi/evelina/stellar3/build/bin/stellar

prefix="long_matches"
mkdir -p work/$prefix
cd work/$prefix

#ref="/buffer/ag_abi/evelina/mouse/chr1.fa"
#query="/buffer/ag_abi/evelina/fly/dna4.fa"
ref="/buffer/ag_abi/evelina/mouse/ref_concat.fa"
query="/buffer/ag_abi/evelina/fly/query_concat.fa"
#query="/buffer/ag_abi/evelina/fly/rDNA.fa"

ibf_bins=1024
min_len=500
max_er=0.053
threads=16
numMatches=20000
sortThresh=$(($numMatches + 1))

kmer_cmin=0 # min k-mer count
kmer_cmax=254

cart_max_cap=15000
max_queued_carts=1024

tau=0.999
p_max=0.15

mkdir -p meta
ref_meta="meta/mouse_ref_b${ibf_bins}.bin"
mkdir -p /dev/shm/$prefix
index="/dev/shm/${prefix}/mouse_b${ibf_bins}_l${min_len}.index"

split_log="split_valik.time"
build_log="build_valik.time"
search_log="search_valik.time"

min_overlap=100

#for log_file in $split_log $build_log $search_log $stellar_log
for log_file in $stellar_log
do
	echo "#randomize DNA5 to DNA4 conversion" >> $log_file
done

#echo -e "time\tmem\terror-code\tcommand\tmax-er\tmin-len\tbins\tibf-fpr" >> $split_log
#echo -e "time\tmem\terror-code\tcommand\tbins\tcmin\tcmax\tthreads\tibf-size\tibf-fpr" >> $build_log
#echo -e "time\tmem\terror-code\tcommand\tbins\tthreads\ttau\tp_max\tcart-max-cap\tmax-queued\tmin-len\ter\tcmin\tcmax\trepeat-mask\tibf-fpr\tibf-size\trepeats\tmatches\ttruth-set-matches\ttrue-matches\tmissed\tmin_overlap" >> $search_log

ibf_fpr=0.005
	
#################### SPLIT ####################
echo "Splitting reference database"
/usr/bin/time -a -o $split_log -f "%e\t%M\t%x\tvalik-split\t${max_er}\t${min_len}\t${ibf_bins}\t$ibf_fpr" $valik split $ref --verbose --fpr $ibf_fpr --out $ref_meta --error-rate $max_er --pattern $min_len -n $ibf_bins 
#&> "b${ibf_bins}_fpr${ibf_fpr}_split.err"

#################### BUILD ####################
echo "Building IBF"
/usr/bin/time -a -o $build_log -f "%e\t%M\t%x\tvalik-build\t${bins}\t${kmer_cmin}\t${kmer_cmax}\t${threads}\t$ibf_fpr" $valik build --verbose --fast --threads $threads --output $index --ref-meta $ref_meta --kmer-count-min $kmer_cmin --kmer-count-max $kmer_cmax
truncate -s -1 $build_log
ls -lh $index | awk '{ print "\t" $5}' >> $build_log

#################### SEARCH ####################

#for er in 0.0067 0.013 0.02 0.0267 0.033 0.04 0.0467 0.053

for er in 0.053
do
	mkdir -p ../stellar
	truth_file="../stellar/mouse_vs_fly_l${min_len}_e${er}.gff" 
	#truth_file="../blast/blast_e1_k16.txt"

if [ -f $truth_file ]; then
for repeat_mask in "--keep-best-repeats"
do
	#/usr/bin/time -a -o $stellar_log -f "%e\t%M\t%x\tstellar\t${min_len}\t${er}" $stellar -a dna --numMatches $numMatches --sortThresh $sortThresh $ref $query -e $er -l $min_len -o $truth_file

	echo "Search for local matches and $repeat_mask" 
	run_id="b${ibf_bins}_e${er}_l${min_len}_tau${tau}_pmax${p_max}"
	out="${run_id}.gff"

	/usr/bin/time -a -o $search_log -f "%e\t%M\t%x\tvalik-search\t${ibf_bins}\t$threads\t$tau\t$p_max\t${cart_max_cap}\t${max_queued_carts}\t${min_len}\t${er}\t$kmer_cmin\t${kmer_cmax}\t$repeat_mask\t$ibf_fpr" $valik search $repeat_mask --time --verbose --split-query --cache-thresholds --numMatches $numMatches --sortThresh $sortThresh --index $index --ref-meta $ref_meta --query $query --error-rate $er --threads $threads --output $out --cart-max-capacity $cart_max_cap --max-queued-carts $max_queued_carts > ${run_id}.log 2> ${run_id}.err

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
done
fi
done

#rm $ref_meta	
rm $index
rm /dev/shm/$prefix/*.minimiser
rm /dev/shm/$prefix/*.header
