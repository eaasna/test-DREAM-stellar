#!/usr/bin/env bash

size=${1}
er=${2}

#( /usr/bin/time -a -o $size/$er\_stellar.time -f "%e\t%M\t%x\t%C" snakemake --cores 16 --snakefile Snakefile_stellar --configfile $size/config.yaml --config error_rate=$er) 2> $size/$er\_stellar.err
( /usr/bin/time -a -o $size/$er\_dream.time -f "%e\t%M\t%x\t%C" snakemake --cores 16 --snakefile Snakefile_dream --configfile $size/config.yaml --config error_rate=$er) 2> $size/$er\_dream.err
