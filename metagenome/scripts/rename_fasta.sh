#!/bin/bash

p="data/${1}/bins"
echo "${p}"
cd $p

FILE="bin_${2}.fasta"

if [ -f "$FILE" ]; then
    echo "renaming bin files"
    for file in bin_*.fasta; do 
	    mv "$file" "${file#bin_}";
    done;

    for file in 0000[0-9]*.fasta; do
        mv "$file" "${file#0}";
    done;
    for file in 000[0-9]*.fasta; do
        mv "$file" "${file#0}";
    done;
    for file in 00[0-9]*.fasta; do
        mv "$file" "${file#0}";
    done;
    for file in 0[0-9]*.fasta; do
        mv "$file" "${file#0}";
    done;
fi


