# metagenome-read-mapping

This repo is a work in progress. The goal is to compare different methods of mapping metagenomics reads to a reference database.

Data has been simulated using this tool https://github.com/eseiler/raptor_data_simulation

To run the snakemake workflow and automatically create the conda environments:
`snakemake --use-conda`

But the `lambda` aligner isn't available through conda! 
https://github.com/seqan/lambda/wiki/Packages
