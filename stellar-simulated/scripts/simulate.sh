#!/usr/bin/env bash
set -e

BINARY_DIR="../lib/raptor_data_simulation/build/bin"
REP=$1 # gives a unique name to each output file
REF_LENGTH=1048576 	# 2^20 = 1Mb
QUERY_LENGTH=1048576 	# 2^20 = 1Mb
REF_SEED=$2
QUERY_SEED=$3
ERROR_RATES="0 0.025 0.05 0.075 0.1"
MATCH_LENGTHS="50 100 150 200"
MATCH_COUNT=125

echo "Simulating reference of length $REF_LENGTH with seed $REF_SEED"
$BINARY_DIR/mason_genome -l $REF_LENGTH -o ref_rep$REP.fasta -s $REF_SEED &> /dev/null

# Simulating local matches
for match_length in $MATCH_LENGTHS
do
    for error_rate in $ERROR_RATES
    do
	float_errors=$(echo $match_length*$error_rate | bc)
        errors=$(echo "($float_errors)/1" | bc)
        echo "Sampling $MATCH_COUNT local matches of length $match_length with $errors errors and an error rate of $error_rate"
        match_dir=matches_rep$REP\_e$errors\_$match_length
        mkdir -p $match_dir
        $BINARY_DIR/generate_reads \
            --output $match_dir \
            --max_errors $errors \
            --number_of_reads $MATCH_COUNT \
            --read_length $match_length \
            --number_of_haplotypes 1 \
            ref_rep$REP.fasta &> /dev/null

	# Create unique IDs
	awk -v l=$match_length '{if( (NR-1)%4 ) print; else printf("@l" l "-" "%d\n",cnt++)}' $match_dir/ref_rep$REP.fastq >> local_matches/rep${REP}\_e"${error_rate//.}".fastq
	done
done

rm -r matches_rep$REP\_e*

echo "Simulating query of length $QUERY_LENGTH with seed $QUERY_SEED"
$BINARY_DIR/mason_genome -l $QUERY_LENGTH -o query/query_rep$REP.fasta -s $QUERY_SEED &> /dev/null

# convert multi line fasta to one line fasta
awk '/^>/ {printf("\n%s\n",$0);next; } { printf("%s",$0);}  END {printf("\n");}' < query/query_rep$REP.fasta > query/one_line_rep$REP.fasta
sed -i '1d' query/one_line_rep$REP.fasta

