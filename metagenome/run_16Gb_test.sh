#!/usr/bin/env bash

size="16Gb"
er=0.05
bins=1024

snakemake --cores 1 --snakefile Snakefile_simulate --configfile $size/config.yaml --config error_rate=$er ibf_bins=$bins --
( /usr/bin/time -a -o $size/stellar.time -f "%e\t%M\t%x\t%C" snakemake --cores 16 --snakefile Snakefile_stellar --configfile $size/config.yaml --config error_rate=$er ibf_bins=$bins -- ) 2> $size/stellar.err
( /usr/bin/time -a -o $size/dream.time -f "%e\t%M\t%x\t%C" snakemake --cores 16 --snakefile Snakefile_dream --configfile $size/config.yaml --config error_rate=$er ibf_bins=$bins -- ) 2> $size/dream.err

# snakemake --cores 1 --snakefile Snakefile_evaluate --configfile $size/config.yaml --config error_rate=$er ibf_bins=$bins --

