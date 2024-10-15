#!/usr/bin/env bash

set -x

valik=/group/ag_abi/evelina/valik2/build/bin/valik

cd work 

prefix="runtime"
mkdir -p /dev/shm/$prefix

log="search_manual_param.time"
echo -e "time\tmem\terror-code\tcommand\tbins\tibf-fpr\tk\tmin-len\ter\tcmin\tcmax\tquery-seg\tthresh\tibf-size\trepeats\tmatches\ttruth-set-matches\ttrue-matches\tmissed\tmin-overlap" >> $log

ref="/buffer/ag_abi/evelina/mouse/ref_concat.fa"
query="/buffer/ag_abi/evelina/fly/query_concat.fa"
ibf_bins=1024
query_seg_count=20000
min_len=150
min_overlap=10

timeout="60m"
er=0.025
threads=16
numMatches=20000
sortThresh=$(($numMatches + 1))
kmer_cmin=0 # min k-mer count
ibf_fpr=0.005

truth_file="stellar_l${min_len}.gff"

function run_manual_split() {
	kmer_size=$1
	run_id="${prefix}_k${kmer_size}"

	ref_meta="meta/${run_id}.bin"
	$valik split $ref --without-parameter-tuning --kmer $kmer_size \
		--verbose --fpr $ibf_fpr --out $ref_meta \
		--error-rate $er --pattern $min_len -n $ibf_bins 1> /dev/null 2> split_${run_id}.err

	echo $ref_meta
}

function run_manual_build() {
	ref_meta=$1
	kmer_size=$2
	kmer_cmin=$3
	kmer_cmax=$4
	
	run_id="k${kmer_size}_cmin${kmer_cmin}_cmax${kmer_cmax}"

	index="/dev/shm/$prefix/$run_id.index"
	$valik build --without-parameter-tuning --verbose \
		--kmer $kmer_size --fast --threads $threads \
		--output $index --ref-meta $ref_meta \
		--kmer-count-min $kmer_cmin --kmer-count-max $kmer_cmax 1> /dev/null 2> build_${prefix}_${run_id}.err
	echo $index
}

function run_manual_search() {
	index=$1
	ref_meta=$2
	set_params=$3

	seg_count=$4
	threshold=$5

	run_id="seg${seg_count}_t${threshold}"

	out="${prefix}_${run_id}.gff"
	rm $out
		
	echo "Search for local matches"
	(timeout $timeout /usr/bin/time -a -o $log -f \
		"%e\t%M\t%x\tvalik-search\t${set_params}\t${seg_count}\t${threshold}" \
		$valik search --without-parameter-tuning --keep-best-repeats \
			--verbose --seg-count $seg_count \
			--threshold $threshold \
			--pattern $min_len \
			--split-query --cache-thresholds \
			--numMatches $numMatches --sortThresh $sortThresh \
			--index $index --ref-meta $ref_meta \
			--query $query --error-rate $er \
			--threads $threads --output $out \
			--cart-max-capacity $seg_count \
			--max-queued-carts $ibf_bins || touch $out ) > ${timeout}_${run_id}.log 2> search_${prefix}_${run_id}.err

	truncate -s -1 $log
	ls -lh $index | awk '{ print "\t" $5}' >> $log

	truncate -s -1 $log
	wc -l $out | awk '{ print "\t" $1}' >> $log

	truncate -s -1 $log
	grep "Insufficient" search_${prefix}_${run_id}.err | wc -l | awk '{ print "\t" $1 "\t"}' >> $log
	
	truncate -s -1 $log
	../scripts/search_accuracy.sh $truth_file $out $min_len $min_overlap tmp.log
	tail -n 1 tmp.log >> $log
	rm tmp.log

	truncate -s -1 $log
	echo -e "\t$min_overlap" >> $log
}


for k in 19 
	#21
do	
	ref_meta=$(run_manual_split $k)
	for cmin in 0 
		#1
	do
		for cmax in 50 
			#150 250
		do
			index=$(run_manual_build $ref_meta $k $cmin $cmax)
			for seg_count in 10000 
				#20000 30000
			do
				for t in 20 
					#25 30
				do
					set_params="$ibf_bins\t$ibf_fpr\t$k\t$min_len\t$er\t$cmin\t$cmax"
					run_manual_search $index $ref_meta $set_params $seg_count $t
				done
			done
			rm /dev/shm/$prefix/*.index
			rm /dev/shm/$prefix/*.minimiser
			rm /dev/shm/$prefix/*.header	
		done
	done
done
