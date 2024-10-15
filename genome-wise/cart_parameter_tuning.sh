#!/usr/bin/env bash

set -e

valik=/group/ag_abi/evelina/valik/build/bin/valik

cd work 

#ref="/buffer/ag_abi/evelina/mouse/chr1.fa"
#query="/buffer/ag_abi/evelina/fly/dna4.fa"
ref="/buffer/ag_abi/evelina/mouse/ref_concat.fa"
query="/buffer/ag_abi/evelina/fly/query_concat.fa"
#query="/buffer/ag_abi/evelina/fly/rDNA.fa"

ibf_bins=1024
ibf_fpr=0.005
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
outdir="cart-param-tuning" 
prefix="cart_param"

truth_file="stellar_l150.gff" 
min_overlap=10

mkdir -p /dev/shm/$outdir
ref_meta="meta/${prefix}_mouse_ref_b${ibf_bins}.bin"
index="/dev/shm/$outdir/mouse_b${ibf_bins}_l${min_len}.index"

split_log="split_$prefix.time"
build_log="build_$prefix.time"
search_log="search_$prefix.time"

for log_file in $split_log $build_log $search_log
do
	echo "#reduce cart capacity = multiple stellar instances for a single bin" >> $log_file
done

echo -e "time\tmem\terror-code\tcommand\tmax-er\tmin-len\tbins\tibf-fpr" >> $split_log
echo "Splitting reference database"
/usr/bin/time -a -o $split_log -f "%e\t%M\t%x\tvalik-split\t${max_er}\t${min_len}\t${ibf_bins}\tibf_fpr" $valik split $ref --verbose --fpr $ibf_fpr --out $ref_meta --error-rate $max_er --pattern $min_len -n $ibf_bins
	
echo -e "time\tmem\terror-code\tcommand\tbins\tibf-fpr\tcmin\tcmax\tthreads\tibf-size" >> $build_log
echo "Building IBF"
/usr/bin/time -a -o $build_log -f "%e\t%M\t%x\tvalik-build\t$bins\t$ibf_fpr\t$kmer_cmin\t$kmer_cmax\t$threads" $valik build --verbose --fast --threads $threads --output $index --ref-meta $ref_meta --kmer-count-min $kmer_cmin --kmer-count-max $kmer_cmax
truncate -s -1 $build_log
ls -lh $index | awk '{ print "\t" $5}' >> $build_log

echo -e "time\tmem\terror-code\tcommand\tbins\tibf-fpr\tcart-max-cap\tmax-queued-carts\tmin-len\ter\tcmin\tcmax\trepeat-mask\trepeats\tibf-size\tmatches\ttruth-set-matches\ttrue-matches\tmissed\tmin_overlap" >> $search_log


for cart_max_cap in 10 1000 5000 10000 20000
do
	for max_queued_carts in 10 64 512 1024
	do
		echo "Search for local matches and $repeat_mask" 
		run_id="${prefix}_cap${cart_max_cap}_queued${max_queued_carts}"
		out="valik_${run_id}.gff"
		#rm $out
	
		(timeout $timeout /usr/bin/time -a -o $search_log -f "%e\t%M\t%x\tvalik-search\t$ibf_bins\t$ibf_fpr\t$cart_max_cap\t$max_queued_carts\t$min_len\t$er\t$kmer_cmin\t$kmer_cmax" $valik search --time --keep-all-repeats --verbose --split-query --cache-thresholds --numMatches $numMatches --sortThresh $sortThresh --index $index --ref-meta $ref_meta --query $query --error-rate $er --threads $threads --output $out --cart-max-capacity $cart_max_cap --max-queued-carts $max_queued_carts || touch $out ) > ${run_id}.log 2> ${run_id}.err

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

		truncate -s -1 $search_log
		echo -e "\t$min_overlap" >> $search_log
	done
done

rm $index
rm /dev/shm/$outdir/*.minimiser
rm /dev/shm/$outdir/*.header

