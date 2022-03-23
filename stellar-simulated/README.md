# Reproducing STELLAR benchmarks

Table 1
1. Simulate ref.fastq
2. Sample 500 local matches of length 50, 100, 150, 200bp with error rates 0%, 2.5%, 5%, 7.5% or 10%. There are read_length * error_rate many edit operations done to each read. There is a low likelihood that the same nucleotide is edited multiple times which will result in an edit distance that is less than the error rate.
3. Simulate query.fastq (first three steps with `simulate.sh`)
4. Insert the local matches (of a certain error rate) into query.fastq at random positions with `random.sh`
5. Search the ref.fastq for local matches for the query with a minimum length of 50bp and the corresponding error rate.

Repeat this process 5 times and take the average run-time.
