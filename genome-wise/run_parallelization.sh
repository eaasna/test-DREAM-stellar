#!/usr/bin/env bash
set -ex


snakef="Snakefile_dream_entropy_blast"

for t in 96 64 32 16 8 2 1
do
	snakemake --snakefile $snakef --configfile parallelization_config.yaml --keep-going --cores $t 1>> parallelization.out 2>> parallelization.err
done
