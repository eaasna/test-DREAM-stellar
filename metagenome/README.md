Test searching a metagenome reference database
1. Simulate reference sequences
2. Sample local matches with 0-10% error rate
3. Build an IBF where each reference file corresponds to a IBF bin
4. Search queries in the bins with minLen=50bp and the corresponding number of errors
5. Compare Stellar and DREAM-Stellar run-time

Run the workflow with: 
`snakemake --cores 8 --forceall --configfile 100kb/config.yaml`
