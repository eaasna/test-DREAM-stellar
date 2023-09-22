#!/bin/bash

REF_IN="dmel-all-chromosome-r6.46.fasta"
REF_OUT="dmel.fasta"
wget http://ftp.flybase.net/genomes/Drosophila_melanogaster/dmel_REFSEQ/fasta/$REF_IN.gz
gunzip $REF_IN.gz

# remove scaffolds
sed -i -e '/Scaffold/{N;d;}' $REF_IN
# remove contigs
sed -i -e '/>211/{N;d;}' $REF_IN
# remove mitochondrial DNA
sed -i -e '/mitochondrion/{N;d;}' $REF_IN
# remove ribosomal DNA
sed -i -e '/rDNA/{N;d;}' $REF_IN

# short and simple chromosome IDs
cat $REF_IN | awk -F 'type=' '{print $1}' > $REF_OUT
rm $REF_IN
