#!/usr/bin/env bash

set -x

stellar=/group/ag_abi/evelina/stellar3/build/bin/stellar

prefix="stellar"
mkdir -p work/$prefix
cd work/$prefix

#ref="/buffer/ag_abi/evelina/mouse/chr1.fa"
#query="/buffer/ag_abi/evelina/fly/dna4.fa"
ref="/buffer/ag_abi/evelina/mouse/ref_concat.fa"
query="/buffer/ag_abi/evelina/fly/query_concat.fa"

min_len=1000
numMatches=20000
sortThresh=$(($numMatches + 1))

log="stellar_manual.time"
echo "#increase match length" >> $log
echo -e "time\tmem\terror-code\tcommand\tmin-len\ter\tmatches\trepeats" >> $log

for er in 0.053
#for er in 0.0067 0.013 0.02 0.0267 0.033 0.04 0.0467 0.053
do
	run_id="l${min_len}_e${er}"
	out="mouse_vs_fly_${run_id}.gff"

	echo "Search for local matches with er=$er"
	/usr/bin/time -a -o $log -f "%e\t%M\t%x\tstellar\t${min_len}\t${er}" $stellar $ref $query --verbose -l $min_len --numMatches $numMatches --alphabet dna --sortThresh $sortThresh -e $er --out $out > ${run_id}.log 2> ${run_id}.err

	truncate -s -1 $log
	wc -l $out | awk '{ print "\t" $1}' >> $log

	repeat_file="stellar.disabled.fasta"
	if [ -s $repeat_file ]; then
		truncate -s -1 $log
		grep  wc -l stellar.disabled.fasta | awk '{ print "\t" $1 "\n"}' >> $log
	else
		echo -e "0\n" >> $log
	fi
done

