#!/usr/bin/env bash

set -x 

valik=/group/ag_abi/evelina/valik_debug/debug/bin/valik

er=${1}
k=${2}
t=${3}
timeout=${4}

cd work/100kb
mkdir -p /dev/shm/reproduce-stellar
ref="ref_rep0.fasta"

query="query/rep0_e${er}.fasta"
ref_meta="meta/ref_rep0_e${er}.bin"
index="/dev/shm/reproduce-stellar/rep0_e${er}.index"

out="query/rep0_e${er}_k${k}_t${t}.gff"

min_len=50
bins=64
threads=16
$valik split $ref --without-parameter-tuning -k $k --verbose --fpr 0.0005 --out $ref_meta --error-rate $er --pattern $min_len -n $bins

#threads=1
valgrind $valik build --without-parameter-tuning --verbose --kmer $k --fast --threads $threads --output $index --ref-meta $ref_meta 

log="valik_manual.time"
rm $out
#(/usr/bin/time -a -o $log -f "%e\t%M\t%x\tvalik-search\ter=${er}\tk=${k}\tt=${t}" timeout $timeout $valik search --without-parameter-tuning --seg-count 10537 --threshold $t --pattern $min_len --split-query --verbose --cache-thresholds --numMatches 53000 --sortThresh 53001 --time --index $index --ref-meta $ref_meta --query $query --error-rate $er --threads $threads --output $out --cart-max-capacity 5000 --max-queued-carts 4096 || touch $out ) > ${timeout}_${er}_${k}_${t}.log

truncate -s -1 $log
echo -ne "\tibf_size=" >> $log
ls -lh $index | awk '{print $5}' >> $log

truncate -s -1 $log
echo -ne "\tmatches=" >> $log
wc -l $out | awk '{print $1}' >> $log

