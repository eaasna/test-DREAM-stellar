#!/usr/bin/env bash

set -ex

prefix=blast
mkdir -p work/$prefix
cd work/$prefix

#ref="/buffer/ag_abi/evelina/mouse/chr1.fa"
#query="/buffer/ag_abi/evelina/fly/dna4.fa"
ref="/buffer/ag_abi/evelina/human/ref_concat.fa"
query="/buffer/ag_abi/evelina/mouse/dna4.random.fa"

log="blast_manual.time"

echo -e "time\tmem\terror-code\tcommand\te-value\tmatches" >> $log
echo "Build index"
(/usr/bin/time -a -o $log -f "%e\t%M\t%x\tblast-index\t${evalue}" makeblastdb -dbtype nucl -in $ref)


echo -e "#human vs mouse" >> $log
echo -e "time\tmem\terror-code\tcommand\te-value\tk\tmatches" >> $log

for k in 16 18
do
for evalue in 0.1 0.01 0.001 
do
	run_id="e${evalue}_k${k}"
	out="human_vs_mouse_${run_id}.txt"
	#rm $out
		
	echo "Search for local matches"
	(/usr/bin/time -a -o $log -f "%e\t%M\t%x\tblast-search\t${evalue}\t${k}" blastn -evalue $evalue -word_size $k -db $ref -query $query -outfmt "6 sseqid sstart send pident sstrand evalue qseqid qstart qend" -out $out)

	truncate -s -1 $log
	wc -l $out | awk '{ print "\t" $1}' >> $log
done
done
