Test searching a split reference sequence
1. Simulate reference sequence
2. Sample local matches with 0-10% error rate
5. Split reference over IBF bins
6. Search queries in the bins with minLen=50bp and the corresponding number of errors

Run the workflow with: 
`snakemake --cores 8 --forceall --configfile 100kb/config.yaml`
