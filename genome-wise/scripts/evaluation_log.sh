#!/usr/bin/env bash

set -x 

ER=$1
INFILE=$2
OUTFILE=$3

echo "er\ttotal_match_count" > $OUTFILE
echo -n "$1\t" >> $OUTFILE
echo "$(wc -l $INFILE | awk '{print $1}')" >> $OUTFILE
