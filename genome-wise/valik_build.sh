#!/usr/bin/env bash

set -x

valik=/group/ag_abi/evelina/valik/build/bin/valik

cd work 
mkdir -p /dev/shm/debug-genome-wise

#ref="/buffer/ag_abi/evelina/mouse/chr1.fa"
#query="/buffer/ag_abi/evelina/fly/dna4.fa"
ref="/buffer/ag_abi/evelina/mouse/ref_concat.fa"
query="/buffer/ag_abi/evelina/fly/query_concat.fa"
#query="/buffer/ag_abi/evelina/fly/rDNA.fa"

ibf_bins=1024
min_len=150
timeout="180m"
query_seg_count=20000
er=0.025
threads=16
numMatches=20000
sortThresh=$(($numMatches + 1))
kmer_cmin=1 # min k-mer count
log="test_valik_manual.time"

ref_meta="meta/test_mouse_ref_b${ibf_bins}.bin"
index="/dev/shm/debug-genome-wise/mouse_b${ibf_bins}_k${kmer_size}_l${min_len}.index"

echo -e "time\tmem\terror-code\tcommand\tbins\tk\tquery-seg\tcart-max-cap\tmin-len\ter\tthresh\tcmax\tibf-size\tmatches\trepeats" >> test_valik_manual.time

kmer_size=19
threshold=75
kmer_cmax=50

echo "Splitting reference database"
$valik split $ref --without-parameter-tuning -k $kmer_size --verbose --fpr 0.01 --out $ref_meta --error-rate $er --pattern $min_len -n $ibf_bins
	
echo "Building IBF"
#/usr/bin/time -a -o $log -f "%e\t%M\t%x\tvalik-build\tthreads=${threads}" $valik build --fast --without-parameter-tuning --verbose --kmer $kmer_size --threads $threads --output $index --ref-meta $ref_meta --kmer-count-min $kmer_cmin --kmer-count-max $kmer_cmax

#rm $index
#rm /dev/shm/test-genome-wise/*.minimiser
#rm /dev/shm/test-genome-wise/*.header

echo "Building IBF in parallel"
kmer_cmin=2
kmer_cmax=49
valik=/group/ag_abi/evelina/valik_debug/build/bin/valik
/usr/bin/time -a -o $log -f "%e\t%M\t%x\tvalik-build\tthreads=${threads}" $valik build --fast --without-parameter-tuning --verbose --kmer $kmer_size --threads $threads --output $index --ref-meta $ref_meta --kmer-count-min $kmer_cmin --kmer-count-max $kmer_cmax

#prefix="test_b${ibf_bins}_k${kmer_size}_q${query_seg_count}_l${min_len}_t${threshold}_cmax${kmer_cmax}"
#out="valik_${prefix}.gff"
#rm $out

#threads=16
#for cart_max_cap in 20900
#do
#	echo "Search for local matches"
#	(timeout $timeout /usr/bin/time -a -o $log -f "%e\t%M\t%x\tvalik-search\t${ibf_bins}\t${kmer_size}\t${query_seg_count}\t${cart_max_cap}\t${min_len}\t${er}\t${threshold}\t${kmer_cmax}" $valik search --keep-all-repeats --without-parameter-tuning --verbose --seg-count $query_seg_count --threshold $threshold --pattern $min_len --split-query --cache-thresholds --numMatches $numMatches --sortThresh $sortThresh --index $index --ref-meta $ref_meta --query $query --error-rate $er --threads $threads --output $out --cart-max-capacity $cart_max_cap --max-queued-carts $ibf_bins || touch $out ) > ${timeout}_${prefix}.log 2> ${prefix}.err

#	truncate -s -1 $log
#	ls -lh $index | awk '{ print "\t" $5}' >> $log

#	truncate -s -1 $log
#	wc -l $out | awk '{ print "\t" $1}' >> $log
#
#	truncate -s -1 $log
#	grep "Insufficient" ${prefix}.err | wc -l | awk '{ print "\t" $1}' >> $log
#done

rm $index
rm /dev/shm/test-genome-wise/*.minimiser
rm /dev/shm/test-genome-wise/*.header

