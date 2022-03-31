# Reproducing STELLAR benchmarks

Prerequisites:
- active conda environment with snakemake installation
- built raptor_data_simulation binaries in lib directory

The data simulation, stellar search and search evaluation are run in a snakemake workflow with:

`snakemake --use-conda --cores {nr e.g 8}`

Reproducing Table 1
1. Simulate `ref.fastq`
2. Sample 500 local matches of length 50, 100, 150, 200bp with error rates 0%, 2.5%, 5%, 7.5% or 10%. There are read_length * error_rate many edit operations done to each read. There is a low likelihood that the same nucleotide is edited multiple times which will result in an edit distance that is less than the error rate.
3. Simulate 1MB of query sequence (`query/query.fastq`)
4. Insert the local matches (of a certain error rate) into `query.fastq` at random positions and create ground truth files.
5. Search the `ref.fastq` for local matches for the query with a minimum length of 50bp and the corresponding error rate.
6. Evaluate stellar output against ground truth. 

Repeat this process 5 times and take the average run-time.
