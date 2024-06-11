#!/usr/bin/env bash

set -x 

INFILE=$1
OUTFILE=$2

echo "total_match_count" > $OUTFILE
echo "$(wc -l $INFILE | awk '{print $1}')" >> $OUTFILE
