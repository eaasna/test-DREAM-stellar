#!/usr/bin/env bash
set -x

#snakemake --forceall --use-conda --cores 8 --configfile 1Mb/config.yaml
#snakemake --forceall --use-conda --cores 16 --configfile 10Mb/config.yaml
snakemake --forceall --use-conda --cores 16 --configfile 100Mb/config.yaml
#snakemake --forceall --use-conda --cores 16 --configfile human/config.yaml
