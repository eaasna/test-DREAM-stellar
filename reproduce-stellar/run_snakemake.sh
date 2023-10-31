#!/usr/bin/env bash
set -x

#snakemake --use-conda --cores 8 --configfile 1kb/config.yaml
#snakemake --use-conda --cores 8 --configfile 10kb/config.yaml
#snakemake --use-conda --cores 8 --configfile 100kb/config.yaml
#snakemake --use-conda --cores 8 --configfile 1Mb/config.yaml
snakemake --use-conda --forceall --cores 8 --configfile 10Mb/config.yaml

python scripts/make_stellar_table2.py
