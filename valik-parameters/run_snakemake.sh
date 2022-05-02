#!/usr/bin/env bash

snakemake --cores 8 --use-conda --configfile size_config.yaml
snakemake --cores 8 --use-conda --configfile overlap_config.yaml --dryrun

