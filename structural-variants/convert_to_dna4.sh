#!/bin/bash

set -ex

execs=(st_dna5todna4)
for exec in "${execs[@]}"; do
    if ! which ${exec} &>/dev/null; then
        echo "${exec} is not available"
        echo ""
        echo "make sure \"${execs[@]}\" are reachable via the \${PATH} variable"
        echo ""

        echo "try "
	echo 'export PATH="/group/ag_abi/evelina/seqan3_tools/build/bin:/group/ag_abi/evelina/meme/bin:/group/ag_abi/evelina/meme/libexec/meme-5.5.6:$PATH"'

        exit 127
    fi
done

ref="/srv/data/evelina/human/GCA_000001405.15_GRCh38_full_analysis_set.fna"
ref_dna4="/srv/data/evelina/human/unmasked_dna4.fa"
if [ ! -f $ref_dna4 ]; then
	st_dna5todna4 $ref > $ref_dna4 
fi

#work_dir="/buffer/ag_abi/evelina/1000genomes/hifi/ftp.sra.ebi.ac.uk/vol1/run"
#for sample in $work_dir/*/*/unmapped.fa;do
#	sample_dir="$(dirname "$sample")"
#	
#	dna4="$sample_dir/unmasked_dna4.fa"
#	if [ ! -f $dna4 ]; then
#		st_dna5todna4 $sample > $dna4	
#	fi
#done

