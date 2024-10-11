#!/usr/bin/env bash

set -x

stellar=/group/ag_abi/evelina/stellar3/build/bin/stellar

cd work 

#ref="/buffer/ag_abi/evelina/mouse/chr1.fa"
#query="/buffer/ag_abi/evelina/fly/dna4.fa"
ref="/buffer/ag_abi/evelina/mouse/ref_concat.fa"
query="/buffer/ag_abi/evelina/fly/query_concat.fa"

min_len=150
timeout="180m"
er=0.025
numMatches=10000
sortThresh=$(($numMatches + 1))
log="stellar_manual.time"

echo -e "time\tmem\terror-code\tcommand\tmin-len\ter\tmatches\trepeats" >> $log
prefix="l${min_len}"
out="stellar_${prefix}.gff"
rm $out
		
echo "Search for local matches"
(timeout $timeout /usr/bin/time -a -o $log -f "%e\t%M\t%x\tstellar\t${min_len}\t${er}" $stellar $ref $query --verbose -l $min_len --numMatches $numMatches --alphabet dna --sortThresh $sortThresh -e $er --out $out || touch $out ) > ${timeout}_${prefix}.log 2> ${prefix}.err

truncate -s -1 $log
wc -l $out | awk '{ print "\t" $1}' >> $log

truncate -s -1 $log
grep  wc -l stellar.disabled.fasta | awk '{ print "\t" $1 "\n"}' >> $log

