#!/bin/bash

set -e

execs=(valik)
for exec in "${execs[@]}"; do
    if ! which ${exec} &>/dev/null; then
        echo "${exec} is not available"
        echo ""
        echo "make sure \"${execs[@]}\" are reachable via the \${PATH} variable"
        echo ""

        echo "try "
	echo 'export PATH="/group/ag_abi/evelina/valik/build/bin:$PATH"'

        exit 127
    fi
done

work_dir="/buffer/ag_abi/evelina/1000genomes/hifi/ftp.sra.ebi.ac.uk/vol1/run"
ref_dir="/srv/data/evelina/human"
ref="$ref_dir/unmasked_dna4.fa"

minlen=100
er=0.033
s="1111110110110111111"
numMatches=200
sortThresh=$((numMatches+1))
	
meta="$ref_dir/human_l${minlen}_e${er}_s${s}.bin"
index="$ref_dir/human_l${minlen}_s${s}.index"

if [ ! -f $meta ]; then
	valik split $ref --fpr 0.005 --out $meta --error-rate $er --pattern $minlen -n 4096 --shape $s
fi

if [ ! -f $index ]; then
	valik build --fast --threads 8 --output $index --ref-meta $meta
fi

for sample in $work_dir/*/*/unmapped.fa; do
	read_count=$(grep ">" $sample | wc -l | awk '{ print $1 }')
	seg_count=$((read_count*5))
	echo "$read_count"
	sample_dir="$(dirname "$sample")"
	
	matches="$sample_dir/l${minlen}_e${er}.gff"
	log="$sample_dir/search_valik.time"
	echo "Processing $sample"
	if [ ! -f $matches ]; then
		( /usr/bin/time -a -o $log -f "%e\t%M\t%x\t%C" \
			valik search --keep-best-repeats --bin-entropy-cutoff 0.25 \
				--split-query --index $index --ref-meta $meta \
				--query $sample --error-rate $er --threads 16 \
				--output $matches --cart-max-capacity 100 \
				--numMatches $numMatches --sortThresh $sortThresh \
				--without-parameter-tuning --threshold 31 \
				--seg-count $seg_count --max-queued-carts 1024 \
				--pattern $minlen \
				--verbose &> $matches.search.err )
	fi
done

