#!/bin/bash

set -e

execs=(dust st_dna5todna4 pbmm2 valik)
for exec in "${execs[@]}"; do
    if ! which ${exec} &>/dev/null; then
        echo "${exec} is not available"
        echo ""
        echo "make sure \"${execs[@]}\" are reachable via the \${PATH} variable"
        echo ""

        echo "try "
	echo 'export PATH="/group/ag_abi/evelina/seqan3_tools/build/bin:/group/ag_abi/evelina/meme/bin:/group/ag_abi/evelina/meme/libexec/meme-5.5.6:/group/ag_abi/evelina/valik/build/bin:$PATH"'
	echo 'conda activate python27'
        exit 127
    fi
done

log="log.txt"
data_dir="/buffer/ag_abi/evelina/1000genomes/phase2/ftp.sra.ebi.ac.uk/vol1/run"
work_dir="/group/ag_abi/evelina/DREAM-stellar-benchmark/structural-variants"
min_len=50
er=0.02

ref="/srv/data/evelina/human/GCA_000001405.15_GRCh38_full_analysis_set.fna"
ref_dna4="/srv/data/evelina/human/unmasked_dna4.fa"
index="/srv/data/evelina/human/unmasked.mmi"
if [ ! -f $ref_dna4 ]; then
	echo "Conver ref to dna4"
	st_dna5todna4 $ref > $ref_dna4	
fi	

if [ ! -f $index ]; then
	echo "index $ref"
	pbmm2 index $ref_dna4 $index --preset HIFI
fi

# get sample data
while read ftp_path; do
	bam_filename="$(basename "$ftp_path")"
	run_id=$(basename $(dirname $ftp_path))
	sample_id=$(basename $(dirname $(dirname $ftp_path)))
	sample_dir="$data_dir/$sample_id/$run_id"	

	reads="$sample_dir/$bam_filename"
	mapped="$sample_dir/pbmm2.bam"
	unmapped="$sample_dir/unmapped.bam"
	fasta="$sample_dir/unmapped.fa"
	if [ ! -f $fasta ]; then
		echo "Can not find $fasta"
		if [ ! -f "$sample_dir/$bam_filename" ]; then
			cd $data_dir
			echo "Downloading $bam_filename"
			wget -x $ftp_filename >> $log 2>&1
			cd $work_dir
		fi

		if [ ! -f "$unmapped" ]; then
			echo "Map reads for $sample_id/$run_id"
			./map_reads.sh $index $reads $mapped $unmapped $fasta >> $log 2>&1
			rm $reads
			rm $mapped
		fi
	fi

	local_matches="$sample_dir/l${min_len}_e${er}.gff"
	if [ ! -f $local_matches ]; then
		echo "Finding local alignments for $sample_id/$run_id"
		./find_local_matches.sh $ref_dna4 $min_len $er $fasta $local_matches >> $log 2>&1
	fi
	
	echo "Finding inversions in $sample_dir"
	./find_inversions.sh $local_matches >> $log 2>&1

done < file_paths.txt
