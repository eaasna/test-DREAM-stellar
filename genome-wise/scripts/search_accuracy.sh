#!/bin/bash

#set -ex

if [[ "$#" -ne 5 ]]; then
	echo "Usage: bash search_accuracy.sh <truth_file> <match_file> <min_len> <min_overlap> <out>"
	exit 1
fi

TRUTH=${1}
filename=$(basename -- "$TRUTH")
TRUTHFILE_TYPE="${filename##*.}"
#echo $TRUTHFILE_TYPE

MATCHES=${2}
filename=$(basename -- "$MATCHES")
MATCHFILE_TYPE="${filename##*.}"
#echo $MATCHFILE_TYPE

MIN_LENGTH=${3}
MIN_OVERLAP=${4}
OUT=${5}

max_adjust=$(bc <<< "$MIN_LENGTH - $MIN_OVERLAP")

if [[ "$TRUTHFILE_TYPE" == "gff" ]]; then
	#awk '{ print $1 "\t" $4 "\t" $5 "\t" $9}' $TRUTH | awk -F";" '{ print $1 "\t" $2}' | awk -F"seq2Range=" '{ print $1 "\t" $2}' | awk -F"," '{ print $1 "\t" $2}' > $TRUTH.tmp
	awk '{ print $1 "\t" $4 "\t" $5 "\t" $1}' $TRUTH > $TRUTH.tmp
else
	#awk '{print $1 "\t" $2 "\t" $3 "\t" $7 "\t" $8 "\t" $9}' $TRUTH > $TRUTH.tmp
	awk '{ print $1 "\t" $2 "\t" $3 "\t" $1}' $TRUTH > $TRUTH.tmp
fi

if [[ "$MATCHFILE_TYPE" == "gff" ]]; then

	awk '{print $1 "\t" $4 }' $MATCHES | sort -g -k2 > $MATCHES.begin.tsv
	awk '{print $5 "\t" $1 }' $MATCHES | sort -g -k1 > $MATCHES.end.tsv
else
	awk '{print $1 "\t" $2 }' $MATCHES | sort -g -k2 > $MATCHES.begin.tsv
	awk '{print $3 "\t" $1 }' $MATCHES | sort -g -k1 > $MATCHES.end.tsv
fi

total_match_count=$(wc -l "$TRUTH.tmp" | awk '{ print $1 }')
grep -v -f $MATCHES.begin.tsv $TRUTH.tmp | grep -v -f $MATCHES.end.tsv > $MATCHES.still.searching
rm $TRUTH.tmp

# Check if search output is shifted slightly to the left
for i in $(seq 1 $max_adjust); 
do
	search_space=$(wc -l $MATCHES.still.searching | awk '{print $1}')
	if [[ $search_space -eq 0 ]]; then
		break
	fi

	cat $MATCHES.still.searching > $MATCHES.not.found
	gawk -i inplace -v s=1 '{print $1 "\t" $2-s}' $MATCHES.begin.tsv
	
	#debug
	#echo "printing begins after subtraction"
	#cat $MATCHES.begin.tsv
	gawk -i inplace -v s=1 '{print $1-s "\t" $2}' $MATCHES.end.tsv

	grep -v -f $MATCHES.begin.tsv $MATCHES.not.found > $MATCHES.tmp 
	search_space=$(wc -l $MATCHES.tmp | awk '{print $1}')
	if [[ $search_space -eq 0 ]]; then
		break
	fi
	grep -v -f $MATCHES.end.tsv $MATCHES.tmp > $MATCHES.still.searching
	rm $MATCHES.tmp
done

# Back to baseline
gawk -i inplace -v s=$max_adjust '{print $1 "\t" $2+s}' $MATCHES.begin.tsv
gawk -i inplace -v s=$max_adjust '{print $1+s "\t" $2}' $MATCHES.end.tsv

# Check if search output is shifted slightly to the right
for i in $(seq 1 $max_adjust); 
do
	search_space=$(wc -l $MATCHES.still.searching | awk '{print $1}')
	if [[ $search_space -eq 0 ]]; then
		break
	fi
	cat $MATCHES.still.searching > $MATCHES.not.found
	gawk -i inplace -v s=1 '{print $1 "\t" $2+s}' $MATCHES.begin.tsv
	#debug
	#echo "printing ends after addition"
	#cat $MATCHES.begin.tsv
	gawk -i inplace -v s=1 '{print $1+s "\t" $2}' $MATCHES.end.tsv

	grep -v -f $MATCHES.begin.tsv $MATCHES.not.found > $MATCHES.tmp
	search_space=$(wc -l $MATCHES.tmp | awk '{print $1}')
	if [[ $search_space -eq 0 ]]; then
		break
	fi
	grep -v -f $MATCHES.end.tsv $MATCHES.tmp > $MATCHES.still.searching
	rm $MATCHES.tmp
done

missed_match_count=$(wc -l "$MATCHES.still.searching" | awk '{ print $1 }')
true_match_count=$(bc <<< "$total_match_count - $missed_match_count")
missed=$(bc <<< "scale=2; 1.0 - $true_match_count/$total_match_count")
echo -e 'total_match_count\ttrue_match_count\tmissed' >> $OUT
echo -e "$total_match_count\t$true_match_count\t$missed" >> $OUT

rm $MATCHES.begin.tsv $MATCHES.end.tsv $MATCHES.not.found 
#$MATCHES.still.searching
