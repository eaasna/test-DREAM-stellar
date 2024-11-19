#!/bin/bash

set -x

DIR=$1
INPUT=$2 # kmer.dump
OUTPUT=$3 # kmer.tsv

cd $DIR

awk '{print $2}' $INPUT | sort -n | uniq -c > tmp
awk '{print $1 "\t" $2}' tmp > $OUTPUT
rm tmp
