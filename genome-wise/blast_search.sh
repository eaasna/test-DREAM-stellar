#!/usr/bin/env bash

set -x

cd work 

#ref="/buffer/ag_abi/evelina/mouse/chr1.fa"
#query="/buffer/ag_abi/evelina/fly/dna4.fa"
ref="/buffer/ag_abi/evelina/mouse/ref.fa"
query="/buffer/ag_abi/evelina/fly/query.fa"
ref_meta="meta/mouse_ref_b${ibf_bins}.bin"
index="/dev/shm/genome-wise/mouse_b${ibf_bins}_k${kmer_size}_l${min_len}.index"

#printf -v evalue %.f 1e-65
timeout="180m"
numMatches=10000
sortThresh=$(($numMatches + 1))
log="blast_manual.time"

#echo -e "time\tmem\terror-code\tcommand\te-value\tmatches" >> $log
echo "Build index"
#(/usr/bin/time -a -o $log -f "%e\t%M\t%x\tblast-index\t${evalue}" makeblastdb -dbtype nucl -in $ref)

for evalue in 0.01
do
	prefix="e${evalue}"
	out="blast_${prefix}.txt"
	rm $out
		
	echo "Search for local matches"
	(/usr/bin/time -a -o $log -f "%e\t%M\t%x\tblast-search\t${evalue}" blastn -min_raw_gapped_score 138 -evalue $evalue -db $ref -query $query -outfmt "6 sseqid sstart send pident sstrand evalue qseqid qstart qend" -out $out)

	truncate -s -1 $log
	wc -l $out | awk '{ print "\t" $1}' >> $log
done
