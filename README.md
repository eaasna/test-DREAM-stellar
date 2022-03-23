# Getting started
```
git clone --recurse-submodules https://github.com/eaasna/DREAM-stellar-benchmark.git
cd DREAM-stellar-benchmark
mkdir build
cd build
cmake ..
make -j2 install
```
# Local prefilter example
Create partially overlapping segments from the reference sequence.
```
valik split dmel.fasta --reference-output reference-metadata.txt --segment-output reference-segments.txt --overlap 151 --bins 1024
```
Build an IBF so that each segment corresponds to a bin.
```
valik build dmel.fasta --output index.ibf --size 8m --from-segments --seg-path reference-segments.txt --ref-meta reference-metadata.txt
```
Search the simulated reads in the IBF.
```
valik search --threads 8 --index index.ibf --query reads_e2_150/dmel.fastq --output search.out --error 1 --pattern 50 --overlap 5
```

# Data sources
1. Simulated metagenomic data and a dataset from the bovine gut (https://omics.informatics.indiana.edu/mg/RAPSearch2/)
2. D. melanogaster reference genome and simulated reads

# Testing DREAM-Stellar

Test runs for the sliding window filter: https://github.com/eaasna/valik
