TODO:
1. Simulate data for metagenomics, regular read mapping and pairwise genome matching
2. Search with DREAM-Stellar and also Stellar
3. Gather precision, accuracy, time and memory

# Testing sliding window

Test runs for the sliding window filter: https://github.com/eaasna/sliding-window

Data has been simulated using this tool https://github.com/eseiler/raptor_data_simulation

The bovine gut metagenomic database can be downloaded from https://omics.informatics.indiana.edu/mg/RAPSearch2/

To run the snakemake workflow:
`snakemake --use-conda --cores {e.g 8}`
