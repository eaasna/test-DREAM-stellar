#!/usr/bin/env bash

BINS=${1}

seq -f "stellar --verbose $BINS/bins/bin_%0${#BINS}g.fasta /dev/shm/$BINS/queries/" 0 1 $((BINS-1)) > col1
seq -f "bin_%0${#BINS}g_e0.05.fasta -e 0.05 -l 100 -a dna -o $BINS/dream_stellar/" 0 1 $((BINS-1))   > col2  
seq -f "bin_%0${#BINS}g_e0.05.gff" 0 1 $((BINS-1))  > col3

paste col1 col2 col3 -d ""
rm col1 col2 col3

