#!/bin/bash

# local matches with one error rate
sed -n '2~4p' local_matches.fastq >> matches.txt

# convert multi line fasta to one line fasta
awk '/^>/ {printf("\n%s\n",$0);next; } { printf("%s",$0);}  END {printf("\n");}' < query.fasta > one_line.fasta 

sequence=$(<one_line.fasta)

MAX=1048576 # length of query sequence
bias=0
while IFS= read -r line;
do
    rand=$(perl -e 'print int(rand(1048576))');
    pos=$((rand+bias))
    echo -e "$line\t$pos" >> ground_truth.txt
    sequence="${sequence:0:pos}${line}${sequence:pos}"
    size=${#line} 
    bias=$((bias+size))
done < matches.txt

echo $sequence > insertions_0e.fasta

rm one_line.fasta
rm matches.txt
