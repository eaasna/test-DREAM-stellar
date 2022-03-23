#!/bin/bash

# LOCAL MATCH FILES WITH ONE ERROR RATE
sed -n '2~4p' reads_e0_50/ref.fastq > matches.txt
sed -n '2~4p' reads_e0_100/ref.fastq >> matches.txt
sed -n '2~4p' reads_e0_150/ref.fastq >> matches.txt
sed -n '2~4p' reads_e0_200/ref.fastq >> matches.txt

awk '/^>/ {printf("\n%s\n",$0);next; } { printf("%s",$0);}  END {printf("\n");}' < query.fasta > one_line.fasta 

sequence=$(<one_line.fasta)

MAX=1048576 # length of query sequence
bias=0
while IFS= read -r line;
do
    rand=$(perl -e 'print int(rand(1048576))');
    pos=$((rand+bias))
    echo -e "$line\t$pos" >> ground_truth_0e.txt
    sequence="${sequence:0:pos}${line}${sequence:pos}"
    size=${#line} 
    bias=$((bias+size))
done < matches.txt

echo $sequence > insertions_0e.fasta

rm one_line.fasta
rm matches.txt
