#!/usr/bin/env bash
set -ex

# Search mouse vs fly

#snakemake --snakefile Snakefile_blast_only --configfile blast_mouse_config.yaml --keep-going --cores 8 1> blast_mouse.out 2> blast_mouse.err

#snakemake --rerun-incomplete --snakefile Snakefile_stellar_only --configfile stellar_mouse_config.yaml --keep-going --cores 2 1> stellar_mouse.out 2> stellar_mouse.err

#snakef="Snakefile_dream_long"
snakemake --snakefile $snakef --configfile queue_param_config.yaml --keep-going --cores 32 1> queue_param.out 2> queue_param.err

#snakef="Snakefile_dream_entropy"
#snakemake --snakefile $snakef --configfile parallelization_config.yaml --keep-going --cores 96 1> parallelization.out 2> parallelization.err

#snakef="Snakefile_dream_entropy_blast"
#snakemake --snakefile $snakef --configfile error_rates_config.yaml --keep-going --cores 32 1> error_rates.out 2> error_rates.err
#snakemake --snakefile $snakef --configfile bin_entropy_config.yaml --keep-going --cores 32 1> bin_entropy.out 2> bin_entropy.err

# Search human vs mouse
#snakemake --snakefile Snakefile_blast_only --configfile blast_human_config.yaml --keep-going --cores 8 1> blast_human.out 2> blast_human.err

#snakef="Snakefile_dream_vs_blast"
snakemake --snakefile $snakef --configfile human_config.yaml --keep-going --cores 32 1> human.out 2> human.err
