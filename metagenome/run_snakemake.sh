#!/usr/bin/env bash

size=${1}

snakemake --cores 1 --snakefile Snakefile_simulate --configfile $size/config.yaml
( /usr/bin/time -a -o $size/stellar.time -f "%e\t%M\t%x\t%C" snakemake --cores 16 --snakefile Snakefile_stellar --configfile $size/config.yaml ) 2> $size/stellar.err
( /usr/bin/time -a -o $size/dream.time -f "%e\t%M\t%x\t%C" snakemake --cores 16 --snakefile Snakefile_dream --configfile $size/config.yaml ) 2> $size/dream.err
#snakemake --cores 16 --snakefile Snakefile_evaluate --configfile $size/config.yaml

