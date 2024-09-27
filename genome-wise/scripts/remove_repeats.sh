#!/bin/bash

set -x

DIR=${1}
INPUT=${2}
OUTPUT=${3}

cd $DIR

export PATH="/group/ag_abi/evelina/seqan3_tools/build/bin:$PATH"

st_dna5todna4 ${INPUT} > tmp.dna4.fa
awk '/^>/ {printf("\n%s\n",$0);next; } { printf("%s",$0);}  END {printf("\n");}' < tmp.dna4.fa > tmp.fa
rm tmp.dna4.fa

tail -n +2 tmp.fa > $OUTPUT
rm tmp.fa

sed -i 's/TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT/TTTTTTTTTTTTTTTGTTTTTTTTTTTTTTT/g' $OUTPUT
