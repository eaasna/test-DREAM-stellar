#!/usr/bin/env bash

# (w, k)-minimisers
snakemake --cores 8 --use-conda --configfile size_1_haplotype/config.yaml
snakemake --cores 8 --use-conda --configfile size_8_haplotypes/config.yaml
snakemake --cores 8 --use-conda --configfile overlap/config.yaml

# (k, k)-minimisers
snakemake --cores 8 --use-conda --configfile size_1_haplotype_kmers/config.yaml
snakemake --cores 8 --use-conda --configfile size_8_haplotypes_kmers/config.yaml
snakemake --cores 8 --use-conda --configfile overlap_kmers/config.yaml
