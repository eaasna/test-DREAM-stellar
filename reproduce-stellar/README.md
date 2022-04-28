# Reproducing STELLAR benchmarks

## Prerequisites:
- active conda environment with snakemake installation
- built raptor_data_simulation binaries in lib directory

The data simulation, stellar search and search evaluation are run in a snakemake workflow with:

`snakemake --use-conda --cores {nr e.g 8}`

add `--forceall` to rerun all workflow steps even if intermediate results exist. 

## Table 1 input data
1. Simulate 1MB of reference and query sequences
2. From the reference sample local matches
  * 125 local matches for each error rate 0%, 2.5%, 5%, 7.5% or 10%
  * Match lengths are drawn randomly from 50-200bp

Repeat this process 5 times and gather the average run-time and accuracy in `table1.tsv`. There are length * error_rate many edit operations done to each read. There is a low likelihood that the same nucleotide is edited multiple times which will result in an edit distance that is less than the error rate.

## Table 2 input data
1. Simulate reference and query sequences of equal lengths where length={1kb, 10kb, 100kb, 1Mb, 10Mb}
2. From each reference sample local matches
  * Number of alignments per reference and error rate is max(length/2000, 1). E.g for 1kb of reference sample max(1024/2000, 1) = 1 match for each error rate
  * Match lengths are drawn randomly from 50-200bp

Repeat the simulation 50 times for 1kb of sequence and 10 times for 10kb and 100kb sequences. 

## Recreating Tables 1 and 2
1. Insert the local matches (of a certain error rate) into `query.fastq` at random positions and create ground truth files.
2. Search the `ref.fastq` for local matches for the query with a minimum length of 50bp and the corresponding error rate.
3. Compare Stellar output against the ground truth: if stellar match overlaps the ground truth by 40bp then it is considered correct.
4. Gather run-time for Stellar mapping. 
