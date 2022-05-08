#!/usr/bin/env bash

snakemake --cores 8 --use-conda --configfile size_1_haplotype/config.yaml
snakemake --cores 8 --use-conda --configfile size_8_haplotypes/config.yaml
snakemake --cores 8 --use-conda --configfile overlap/config.yaml

