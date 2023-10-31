#!/bin/bash

MATCHES=${1}
TRUTH=${2}
MIN_OVERLAP=${3}
MIN_LENGTH=${4}
OUT=${5}
OUTPUT_TYPE=${6}

max_adjust=$(bc <<< "$MIN_LENGTH - $MIN_OVERLAP")

if [[ "$OUTPUT_TYPE" == "gff" ]]; then

	awk '{print $4 }' $MATCHES | sort -g -k1 > $MATCHES.begin.tsv
	awk '{print $5 }' $MATCHES | sort -g -k1 > $MATCHES.end.tsv
else
	awk '{print $2 }' $MATCHES | sort -g -k1 > $MATCHES.begin.tsv
	awk '{print $3 }' $MATCHES | sort -g -k1 > $MATCHES.end.tsv
fi

#TODO: remove begins and ends that already matched
total_match_count=$(wc -l "$TRUTH" | awk '{ print $1 }')
grep -v -f $MATCHES.begin.tsv $TRUTH | grep -v -f $MATCHES.end.tsv > $MATCHES.still.searching

# Check if search output is shifted slightly to the left
for i in $(seq 1 $max_adjust); 
do
	search_space=$(wc -l $MATCHES.still.searching | awk '{print $1}')
	if [[ $search_space -eq 0 ]]; then
		break
	fi

	cat $MATCHES.still.searching > $MATCHES.not.found
	gawk -i inplace -v s=1 '{print $1-s}' $MATCHES.begin.tsv
	
	#debug
	#echo "printing begins after subtraction"
	#cat $MATCHES.begin.tsv
	gawk -i inplace -v s=1 '{print $1-s}' $MATCHES.end.tsv

	grep -v -f $MATCHES.begin.tsv $MATCHES.not.found > $MATCHES.tmp 
	search_space=$(wc -l $MATCHES.tmp | awk '{print $1}')
	if [[ $search_space -eq 0 ]]; then
		break
	fi
	grep -v -f $MATCHES.end.tsv $MATCHES.tmp > $MATCHES.still.searching
	rm $MATCHES.tmp
done

# Back to baseline
gawk -i inplace -v s=$max_adjust '{print $1+s}' $MATCHES.begin.tsv
gawk -i inplace -v s=$max_adjust '{print $1+s}' $MATCHES.end.tsv

# Check if search output is shifted slightly to the right
for i in $(seq 1 $max_adjust); 
do
	search_space=$(wc -l $MATCHES.still.searching | awk '{print $1}')
	if [[ $search_space -eq 0 ]]; then
		break
	fi
	cat $MATCHES.still.searching > $MATCHES.not.found
	gawk -i inplace -v s=1 '{print $1+s}' $MATCHES.begin.tsv
	#debug
	#echo "printing ends after addition"
	#cat $MATCHES.begin.tsv
	gawk -i inplace -v s=1 '{print $1+s}' $MATCHES.end.tsv

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
echo -e 'total_match_count\ttrue_match_count\tmissed' > $OUT
echo -e "$total_match_count\t$true_match_count\t$missed" >> $OUT

rm $MATCHES.begin.tsv $MATCHES.end.tsv $MATCHES.not.found $MATCHES.still.searching
