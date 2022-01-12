#!/bin/bash

p="data/${1}/bins"
echo "${p}"
cd $p

echo "mixing reads..."

awk '{f=NR ".0"; print ">" $0 > f}' RS='>' 0.fasta
awk '{f=NR ".1"; print ">" $0 > f}' RS='>' 1.fasta
rm 0.fasta 1.fasta 1.0 1.1 
cat 2.0 3.0 2.1 3.1 > 0.fasta
cat 4.0 5.0 4.1 5.1 > 1.fasta
rm *.0 *.1 

